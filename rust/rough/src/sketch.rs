//! Shapes described as data, drawn into paths any renderer can paint.

use std::f64::consts::PI;
use std::fmt;

use crate::DrawConfig;
use crate::DrawOptions;
use crate::Drawable;
use crate::DrawableInk;
use crate::DrawableInkOptions;
use crate::FillOptions;
use crate::FillStyle;
use crate::Filler;
use crate::Generator;
use crate::OpSetKind;
use crate::Point;
use crate::RoughSvgPaths;
use crate::math::format_number;
use crate::svg::escape_attribute;
use crate::svg::op_set_to_svg_path;

/// A shape to sketch, in the sketch's own coordinates.
#[derive(Debug, Clone, PartialEq)]
pub enum Shape {
	/// A rectangle whose top-left corner is (`x`, `y`).
	Rectangle {
		/// Left edge.
		x: f64,
		/// Top edge.
		y: f64,
		/// Width.
		width: f64,
		/// Height.
		height: f64,
	},
	/// A rectangle with rounded corners.
	RoundedRectangle {
		/// Left edge.
		x: f64,
		/// Top edge.
		y: f64,
		/// Width.
		width: f64,
		/// Height.
		height: f64,
		/// Corner radii, clockwise from the top left.
		radii: [f64; 4],
	},
	/// An ellipse centred on (`x`, `y`).
	Ellipse {
		/// Centre, from the left edge.
		x: f64,
		/// Centre, from the top edge.
		y: f64,
		/// Width.
		width: f64,
		/// Height.
		height: f64,
	},
	/// A circle centred on (`x`, `y`).
	Circle {
		/// Centre, from the left edge.
		x: f64,
		/// Centre, from the top edge.
		y: f64,
		/// Diameter.
		diameter: f64,
	},
	/// A straight line.
	Line {
		/// Where the line starts.
		from: Point,
		/// Where the line ends.
		to: Point,
		/// Ends the line in two short barbs.
		arrowhead: bool,
	},
	/// Straight segments through `points`, open unless `closed`.
	LinearPath {
		/// The points, in order.
		points: Vec<Point>,
		/// Joins the last point back to the first.
		closed: bool,
	},
	/// A closed, fillable polygon.
	Polygon {
		/// The corners, in order.
		points: Vec<Point>,
	},
	/// An elliptical arc centred on (`x`, `y`).
	Arc {
		/// Centre, from the left edge.
		x: f64,
		/// Centre, from the top edge.
		y: f64,
		/// Width of the full ellipse.
		width: f64,
		/// Height of the full ellipse.
		height: f64,
		/// Start angle, in radians.
		start: f64,
		/// Stop angle, in radians.
		stop: f64,
		/// Draws a pie slice back to the centre.
		closed: bool,
	},
	/// A smooth curve through at least two points.
	Curve {
		/// The points the curve passes through.
		points: Vec<Point>,
		/// Ends the curve in two short barbs that follow its last segment.
		arrowhead: bool,
	},
}

impl Shape {
	/// A rectangle whose top-left corner is (`x`, `y`).
	pub const fn rectangle(x: f64, y: f64, width: f64, height: f64) -> Self {
		Self::Rectangle {
			x,
			y,
			width,
			height,
		}
	}

	/// An ellipse centred on (`x`, `y`).
	pub const fn ellipse(x: f64, y: f64, width: f64, height: f64) -> Self {
		Self::Ellipse {
			x,
			y,
			width,
			height,
		}
	}

	/// A rectangle with the same `radius` at every corner.
	pub const fn rounded_rectangle(x: f64, y: f64, width: f64, height: f64, radius: f64) -> Self {
		Self::RoundedRectangle {
			x,
			y,
			width,
			height,
			radii: [radius; 4],
		}
	}

	/// A circle centred on (`x`, `y`).
	pub const fn circle(x: f64, y: f64, diameter: f64) -> Self {
		Self::Circle { x, y, diameter }
	}

	/// An open elliptical arc centred on (`x`, `y`) from `start` to `stop`
	/// radians.
	pub const fn arc(x: f64, y: f64, width: f64, height: f64, start: f64, stop: f64) -> Self {
		Self::Arc {
			x,
			y,
			width,
			height,
			start,
			stop,
			closed: false,
		}
	}

	/// A straight line from `from` to `to`.
	pub fn line(from: impl Into<Point>, to: impl Into<Point>) -> Self {
		Self::Line {
			from: from.into(),
			to: to.into(),
			arrowhead: false,
		}
	}

	/// Open straight segments through `points`.
	pub fn linear_path<P: Into<Point>>(points: impl IntoIterator<Item = P>) -> Self {
		Self::LinearPath {
			points: points.into_iter().map(Into::into).collect(),
			closed: false,
		}
	}

	/// A closed, fillable polygon through `points`.
	pub fn polygon<P: Into<Point>>(points: impl IntoIterator<Item = P>) -> Self {
		Self::Polygon {
			points: points.into_iter().map(Into::into).collect(),
		}
	}

	/// A smooth curve through `points`.
	pub fn curve<P: Into<Point>>(points: impl IntoIterator<Item = P>) -> Self {
		Self::Curve {
			points: points.into_iter().map(Into::into).collect(),
			arrowhead: false,
		}
	}

	/// This shape ending in an arrowhead, when it is a line or a curve.
	#[must_use]
	pub fn with_arrowhead(mut self) -> Self {
		if let Self::Line { arrowhead, .. } | Self::Curve { arrowhead, .. } = &mut self {
			*arrowhead = true;
		}
		self
	}

	/// Checks that the shape can be drawn, without drawing it.
	///
	/// # Errors
	///
	/// - [`SketchError::NonFinite`] when a coordinate, size, radius, or angle is
	///   NaN or infinite.
	/// - [`SketchError::EmptyArc`] for an arc whose stop angle is not after its
	///   start.
	/// - [`SketchError::TooFewCurvePoints`] for a curve through fewer than two
	///   points.
	pub fn validate(&self) -> Result<(), SketchError> {
		let finite = |values: &[f64]| values.iter().all(|value| value.is_finite());
		let finite_points = |points: &[Point]| points.iter().all(|p| finite(&[p.x, p.y]));

		let is_finite = match self {
			&Self::Rectangle {
				x,
				y,
				width,
				height,
			}
			| &Self::Ellipse {
				x,
				y,
				width,
				height,
			} => finite(&[x, y, width, height]),
			&Self::RoundedRectangle {
				x,
				y,
				width,
				height,
				radii,
			} => finite(&[x, y, width, height]) && finite(&radii),
			&Self::Circle { x, y, diameter } => finite(&[x, y, diameter]),
			&Self::Line { from, to, .. } => finite_points(&[from, to]),
			Self::LinearPath { points, .. } | Self::Polygon { points } => finite_points(points),
			&Self::Arc {
				x,
				y,
				width,
				height,
				start,
				stop,
				..
			} => {
				if !finite(&[x, y, width, height, start, stop]) {
					return Err(SketchError::NonFinite);
				}
				// Both angles are finite here, so this is a plain comparison.
				if stop <= start {
					return Err(SketchError::EmptyArc);
				}
				true
			}
			Self::Curve { points, .. } => {
				if points.len() < 2 {
					return Err(SketchError::TooFewCurvePoints {
						found: points.len(),
					});
				}
				finite_points(points)
			}
		};

		if is_finite {
			Ok(())
		} else {
			Err(SketchError::NonFinite)
		}
	}
}

/// A shape that cannot be drawn.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum SketchError {
	/// A coordinate, size, radius, or angle is NaN or infinite.
	NonFinite,
	/// An arc's stop angle is not after its start, so it sweeps nothing.
	EmptyArc,
	/// A curve needs at least two points.
	TooFewCurvePoints {
		/// How many points the curve had.
		found: usize,
	},
}

impl fmt::Display for SketchError {
	fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
		match self {
			Self::NonFinite => formatter.write_str("a shape's numbers must all be finite"),
			Self::EmptyArc => formatter.write_str("an arc's stop angle must come after its start"),
			Self::TooFewCurvePoints { found } => {
				write!(
					formatter,
					"a curve needs at least two points, found {found}"
				)
			}
		}
	}
}

impl std::error::Error for SketchError {}

/// How a sketch is drawn and painted.
#[derive(Debug, Clone, PartialEq)]
pub struct SketchOptions {
	/// How far the hand wanders, the seed, and the pen.
	pub draw: DrawOptions,
	/// The fill pattern's measurements. The hachure gap defaults to 8.
	pub pattern: FillOptions,
	/// The fill pattern for closed shapes. When `None`, shapes with a
	/// [`SketchOptions::fill`] colour get [`FillStyle::Hachure`], like
	/// rough.js, and the rest are not filled.
	pub fill_style: Option<FillStyle>,
	/// Fill colour for closed shapes. `None` paints `currentColor`.
	pub fill: Option<String>,
	/// Ink colour, as any SVG paint.
	pub stroke: String,
	/// Outline width.
	pub stroke_width: f64,
	/// Width of sketched fill lines.
	pub sketch_width: f64,
	/// Paint outlines and sketched fills as pen-shaped ink (filled outlines
	/// with tapered ends) instead of constant-width strokes. Uniform pens
	/// always use plain strokes. Turn it off for drawings that stretch with
	/// their container.
	pub ink: bool,
}

impl Default for SketchOptions {
	fn default() -> Self {
		Self {
			draw: DrawOptions::default(),
			pattern: FillOptions {
				hachure_gap: 8.0,
				..FillOptions::default()
			},
			fill_style: None,
			fill: None,
			stroke: "currentColor".to_owned(),
			stroke_width: 1.5,
			sketch_width: 1.0,
			ink: true,
		}
	}
}

impl SketchOptions {
	/// The fill pattern these options draw.
	pub fn resolved_fill_style(&self) -> FillStyle {
		self.fill_style.unwrap_or(if self.fill.is_some() {
			FillStyle::Hachure
		} else {
			FillStyle::None
		})
	}

	/// The fill colour these options paint.
	pub fn fill_color(&self) -> &str {
		self.fill.as_deref().unwrap_or("currentColor")
	}

	/// A generator whose outline and fill both replay from the seed. The fill
	/// gets its own stream so the two never share one.
	pub fn generator(&self) -> Generator {
		Generator::new(
			DrawConfig::new(self.draw),
			Filler::new(
				self.resolved_fill_style(),
				self.pattern,
				DrawConfig::new(self.draw),
			),
		)
	}
}

/// Which part of a drawing a [`SketchPath`] paints.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum SketchPart {
	/// The outline, in the ink colour.
	Outline,
	/// A sketched fill, in the fill colour.
	Sketch,
	/// A solid fill, in the fill colour.
	Solid,
}

impl SketchPart {
	/// The part's name, as used in path keys.
	pub const fn name(self) -> &'static str {
		match self {
			Self::Outline => "outline",
			Self::Sketch => "sketch",
			Self::Solid => "solid",
		}
	}
}

/// The paint for one SVG `<path>` of a sketch.
#[derive(Debug, Clone, PartialEq)]
pub struct SketchPath {
	/// A key that is stable for the same drawing, for framework lists.
	pub key: String,
	/// Which part of the drawing this path belongs to.
	pub part: SketchPart,
	/// SVG path data.
	pub d: String,
	/// Fill paint, or `"none"`.
	pub fill: String,
	/// Stroke paint, or `"none"`.
	pub stroke: String,
	/// Stroke width; zero when the path is filled.
	pub stroke_width: f64,
}

impl SketchPath {
	/// This path as an SVG `<path>` element, with escaped paints.
	pub fn to_element(&self) -> String {
		let fill = escape_attribute(&self.fill);
		if self.stroke == "none" {
			return format!(r#"<path d="{}" fill="{fill}" stroke="none"/>"#, self.d);
		}
		format!(
			r#"<path d="{}" fill="{fill}" stroke="{}" stroke-width="{}" stroke-linecap="round" stroke-linejoin="round"/>"#,
			self.d,
			escape_attribute(&self.stroke),
			format_number(self.stroke_width, 2)
		)
	}
}

/// A drawn sketch: the rough geometry and the paths that paint it.
#[derive(Debug, Clone, PartialEq)]
pub struct Sketch {
	/// The rough geometry.
	pub drawable: Drawable,
	/// The paths that paint it, in paint order.
	pub paths: Vec<SketchPath>,
}

impl Sketch {
	/// The paths as SVG `<path>` elements.
	pub fn to_path_elements(&self) -> String {
		self.paths.iter().map(SketchPath::to_element).collect()
	}

	/// The sketch as a standalone `<svg>` `width` by `height` units across.
	///
	/// Without a `label` the SVG is decorative and hidden from assistive
	/// technology; with one it is an image with that name.
	pub fn to_svg_string(&self, width: f64, height: f64, label: Option<&str>) -> String {
		let width = format_number(width, 2);
		let height = format_number(height, 2);
		let accessibility = match label {
			None => r#" aria-hidden="true" focusable="false""#.to_owned(),
			Some(label) => format!(r#" role="img" aria-label="{}""#, escape_attribute(label)),
		};
		format!(
			r#"<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}"{accessibility}>{}</svg>"#,
			self.to_path_elements()
		)
	}
}

/// Draws `shape` with `generator`.
///
/// # Errors
///
/// Returns the [`SketchError`] from [`Shape::validate`] for a shape that cannot
/// be drawn.
pub fn draw_shape(generator: &mut Generator, shape: &Shape) -> Result<Drawable, SketchError> {
	shape.validate()?;
	let drawable = match shape {
		&Shape::Rectangle {
			x,
			y,
			width,
			height,
		} => generator.rectangle(x, y, width, height),
		&Shape::RoundedRectangle {
			x,
			y,
			width,
			height,
			radii,
		} => generator.rounded_rectangle(x, y, width, height, radii),
		&Shape::Ellipse {
			x,
			y,
			width,
			height,
		} => generator.ellipse(x, y, width, height),
		&Shape::Circle { x, y, diameter } => generator.circle(x, y, diameter),
		&Shape::Line {
			from,
			to,
			arrowhead,
		} => {
			let line = generator.line(from.x, from.y, to.x, to.y);
			if arrowhead {
				with_arrowhead(generator, line, from, to)
			} else {
				line
			}
		}
		Shape::LinearPath { points, closed } => generator.linear_path(points, *closed),
		Shape::Polygon { points } => generator.polygon(points),
		&Shape::Arc {
			x,
			y,
			width,
			height,
			start,
			stop,
			closed,
		} => generator.arc(x, y, width, height, start, stop, closed),
		Shape::Curve { points, arrowhead } => {
			let &[.., from, tip] = points.as_slice() else {
				unreachable!("validated curves have at least two points");
			};
			let curve = generator.curve(points);
			if *arrowhead {
				with_arrowhead(generator, curve, from, tip)
			} else {
				curve
			}
		}
	};
	Ok(drawable)
}

/// Adds two short barbs at `tip`, angled back along the `from` direction.
pub fn with_arrowhead(
	generator: &mut Generator,
	mut shaft: Drawable,
	from: Point,
	tip: Point,
) -> Drawable {
	let spread = PI / 7.0;
	let angle = (tip.y - from.y).atan2(tip.x - from.x);
	let length = 14f64.min(from.distance_to(tip) * 0.6);
	for side in [-spread, spread] {
		let barb = generator.line(
			tip.x,
			tip.y,
			tip.x - length * (angle + side).cos(),
			tip.y - length * (angle + side).sin(),
		);
		shaft.sets.extend(barb.sets);
	}
	shaft
}

/// Sketches `shapes`, drawn in order from one random stream.
///
/// # Errors
///
/// Returns the [`SketchError`] from [`Shape::validate`] for a shape that cannot
/// be drawn.
///
/// ```
/// use skribble_rough::Shape;
/// use skribble_rough::SketchOptions;
/// use skribble_rough::sketch;
///
/// let options = SketchOptions {
/// 	fill: Some("#ffd43b".to_owned()),
/// 	..SketchOptions::default()
/// };
/// let card = sketch(&[Shape::rectangle(4.0, 4.0, 192.0, 92.0)], &options)?;
/// let svg = card.to_svg_string(200.0, 100.0, Some("A sketched box"));
/// assert!(svg.starts_with("<svg"));
/// # Ok::<(), skribble_rough::SketchError>(())
/// ```
pub fn sketch(shapes: &[Shape], options: &SketchOptions) -> Result<Sketch, SketchError> {
	let mut generator = options.generator();
	let mut drawable = Drawable {
		sets: Vec::new(),
		pen: options.draw.pen,
		seed: options.draw.seed,
	};
	for shape in shapes {
		drawable
			.sets
			.extend(draw_shape(&mut generator, shape)?.sets);
	}
	let paths = drawable_paths(&drawable, options);
	Ok(Sketch { drawable, paths })
}

/// The paths that paint `drawable` with `options`' colours and widths, in
/// paint order: solid fill, sketched fill, then outline.
pub fn drawable_paths(drawable: &Drawable, options: &SketchOptions) -> Vec<SketchPath> {
	let fill = options.fill_color();
	let stroke = options.stroke.as_str();
	let filled = |part: SketchPart, key: String, d: String, color: &str| SketchPath {
		key,
		part,
		d,
		fill: color.to_owned(),
		stroke: "none".to_owned(),
		stroke_width: 0.0,
	};
	let stroked = |part: SketchPart, key: String, d: String, color: &str, width: f64| SketchPath {
		key,
		part,
		d,
		fill: "none".to_owned(),
		stroke: color.to_owned(),
		stroke_width: width,
	};

	let mut paths = Vec::new();
	if !options.ink || drawable.pen.is_uniform() {
		let groups = RoughSvgPaths::from_drawable(drawable);
		if !groups.solid.is_empty() {
			paths.push(filled(
				SketchPart::Solid,
				"solid".to_owned(),
				groups.solid,
				fill,
			));
		}
		if !groups.sketch.is_empty() {
			paths.push(stroked(
				SketchPart::Sketch,
				"sketch".to_owned(),
				groups.sketch,
				fill,
				options.sketch_width,
			));
		}
		if !groups.outline.is_empty() {
			paths.push(stroked(
				SketchPart::Outline,
				"outline".to_owned(),
				groups.outline,
				stroke,
				options.stroke_width,
			));
		}
		return paths;
	}

	let solid: String = drawable
		.sets
		.iter()
		.filter(|set| set.kind == OpSetKind::FillPath)
		.map(op_set_to_svg_path)
		.collect();
	if !solid.is_empty() {
		paths.push(filled(SketchPart::Solid, "solid".to_owned(), solid, fill));
	}

	let ink = DrawableInk::new(
		drawable,
		DrawableInkOptions::new(options.stroke_width, options.sketch_width),
	);
	let inked = ink
		.svg_paths()
		.into_iter()
		.filter(|path| path.kind != OpSetKind::FillPath && !path.data.is_empty());
	for (index, path) in inked.enumerate() {
		let (part, color) = if path.kind == OpSetKind::Path {
			(SketchPart::Outline, stroke)
		} else {
			(SketchPart::Sketch, fill)
		};
		let key = format!("{}-{index}", part.name());
		paths.push(if path.filled {
			filled(part, key, path.data, color)
		} else {
			stroked(part, key, path.data, color, path.stroke_width)
		});
	}
	paths
}

#[cfg(test)]
mod tests {
	use super::*;
	use crate::RoughPen;

	#[test]
	fn a_fill_colour_picks_hachure() {
		let options = SketchOptions {
			fill: Some("gold".to_owned()),
			..SketchOptions::default()
		};
		assert_eq!(options.resolved_fill_style(), FillStyle::Hachure);
		assert_eq!(
			SketchOptions::default().resolved_fill_style(),
			FillStyle::None
		);
	}

	#[test]
	fn curves_need_two_points() {
		let error = sketch(&[Shape::curve([(1.0, 2.0)])], &SketchOptions::default())
			.expect_err("one point is not a curve");
		assert_eq!(error, SketchError::TooFewCurvePoints { found: 1 });
	}

	#[test]
	fn shapes_with_non_finite_numbers_are_rejected() {
		let filled = SketchOptions {
			fill: Some("red".to_owned()),
			..SketchOptions::default()
		};
		for shape in [
			Shape::rectangle(0.0, 0.0, 10.0, f64::NAN),
			Shape::line((0.0, 0.0), (f64::INFINITY, 5.0)),
			Shape::polygon([(0.0, 0.0), (f64::NAN, 1.0), (1.0, 1.0)]),
			Shape::circle(0.0, 0.0, f64::NEG_INFINITY),
			Shape::rounded_rectangle(0.0, 0.0, 10.0, 10.0, f64::NAN),
		] {
			assert_eq!(
				sketch(std::slice::from_ref(&shape), &filled),
				Err(SketchError::NonFinite),
				"{shape:?}"
			);
		}
	}

	#[test]
	fn arcs_must_sweep_forward() {
		for (start, stop) in [(1.0, 1.0), (2.0, 1.0)] {
			let arc = Shape::arc(20.0, 20.0, 30.0, 30.0, start, stop);
			assert_eq!(arc.validate(), Err(SketchError::EmptyArc));
		}
		assert_eq!(
			Shape::arc(20.0, 20.0, 30.0, 30.0, 0.0, 1.0).validate(),
			Ok(())
		);
	}

	#[test]
	fn generators_finish_on_degenerate_input() {
		// Not reachable through `sketch`, which validates, but a generator used
		// directly must still finish rather than hang.
		let options = SketchOptions {
			fill: Some("red".to_owned()),
			..SketchOptions::default()
		};
		let mut generator = options.generator();
		let _ = generator.rectangle(0.0, 0.0, 10.0, f64::NAN);
		let _ = generator.arc(20.0, 20.0, 30.0, 30.0, 1.0, 1.0, true);
		let _ = generator.ellipse(0.0, 0.0, f64::INFINITY, 10.0);
	}

	#[test]
	fn ink_paths_are_filled_and_uniform_paths_are_stroked() {
		let shape = [Shape::rectangle(4.0, 4.0, 100.0, 50.0)];
		let inked = sketch(&shape, &SketchOptions::default()).expect("a rectangle draws");
		assert!(inked.paths.iter().all(|path| path.stroke == "none"));

		let uniform = SketchOptions {
			draw: DrawOptions {
				pen: RoughPen::UNIFORM,
				..DrawOptions::default()
			},
			..SketchOptions::default()
		};
		let plain = sketch(&shape, &uniform).expect("a rectangle draws");
		assert_eq!(plain.paths.len(), 1);
		assert_eq!(plain.paths[0].key, "outline");
		assert_eq!(plain.paths[0].stroke_width, 1.5);
	}

	#[test]
	fn arrowheads_add_two_barbs() {
		let options = SketchOptions {
			draw: DrawOptions {
				pen: RoughPen::UNIFORM,
				..DrawOptions::default()
			},
			..SketchOptions::default()
		};
		let plain = sketch(&[Shape::line((0.0, 0.0), (60.0, 0.0))], &options).expect("draws");
		let arrow = sketch(
			&[Shape::line((0.0, 0.0), (60.0, 0.0)).with_arrowhead()],
			&options,
		)
		.expect("draws");
		assert_eq!(arrow.drawable.sets.len(), plain.drawable.sets.len() + 2);
	}

	#[test]
	fn labels_make_the_svg_an_image() {
		let drawn = sketch(
			&[Shape::ellipse(20.0, 20.0, 30.0, 30.0)],
			&SketchOptions::default(),
		)
		.expect("draws");
		let decorative = drawn.to_svg_string(40.0, 40.0, None);
		assert!(decorative.contains(r#"aria-hidden="true""#));
		let labelled = drawn.to_svg_string(40.0, 40.0, Some(r#"A "loop""#));
		assert!(labelled.contains(r#"role="img" aria-label="A &quot;loop&quot;""#));
	}
}
