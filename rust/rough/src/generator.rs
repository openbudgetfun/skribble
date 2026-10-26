//! The low-level entry point for rough shapes.

use std::f64::consts::PI;

use crate::DrawConfig;
use crate::Drawable;
use crate::Filler;
use crate::Op;
use crate::OpSet;
use crate::Point;
use crate::math::clamp;
use crate::renderer;

/// The cubic Bézier handle length that approximates a quarter circle.
const KAPPA: f64 = 0.552_284_749_830_793_6;

/// Draws rough rectangles, ellipses, arcs, lines, polygons, and curves.
///
/// The outline draws from [`Generator::draw`] and the fill from the
/// [`Filler`]'s own stream. Every method mirrors `Generator` in the Dart
/// package `skribble_rough`, and the same seed draws the same shape in both.
///
/// Coordinates and sizes must be finite. [`crate::sketch`] checks them with
/// [`crate::Shape::validate`]; call it yourself when you draw untrusted shapes
/// with a generator directly.
///
/// ```
/// use skribble_rough::DrawConfig;
/// use skribble_rough::DrawOptions;
/// use skribble_rough::FillOptions;
/// use skribble_rough::FillStyle;
/// use skribble_rough::Filler;
/// use skribble_rough::Generator;
///
/// let options = DrawOptions {
/// 	seed: 7,
/// 	..DrawOptions::default()
/// };
/// let filler = Filler::new(
/// 	FillStyle::Hachure,
/// 	FillOptions::default(),
/// 	DrawConfig::new(options),
/// );
/// let mut generator = Generator::new(DrawConfig::new(options), filler);
/// let card = generator.rectangle(4.0, 4.0, 192.0, 92.0);
/// assert_eq!(card.sets.len(), 2);
/// ```
#[derive(Debug, Clone, PartialEq)]
pub struct Generator {
	/// How outlines wander, and the stream they draw from.
	pub draw: DrawConfig,
	/// How closed shapes are filled.
	pub filler: Filler,
}

impl Generator {
	/// Creates a generator.
	pub fn new(draw: DrawConfig, filler: Filler) -> Self {
		Self { draw, filler }
	}

	fn build(&mut self, outline: OpSet, fill_points: Option<&[Point]>) -> Drawable {
		let mut sets = Vec::with_capacity(2);
		if let Some(points) = fill_points {
			sets.push(self.filler.fill(points));
		}
		sets.push(outline);
		Drawable {
			sets,
			pen: self.draw.options.pen,
			seed: self.draw.options.seed,
		}
	}

	/// A straight line.
	pub fn line(&mut self, x1: f64, y1: f64, x2: f64, y2: f64) -> Drawable {
		let outline = renderer::line_set(x1, y1, x2, y2, &mut self.draw);
		self.build(outline, None)
	}

	/// A rectangle whose top-left corner is (`x`, `y`).
	pub fn rectangle(&mut self, x: f64, y: f64, width: f64, height: f64) -> Drawable {
		let corners = [
			Point::new(x, y),
			Point::new(x + width, y),
			Point::new(x + width, y + height),
			Point::new(x, y + height),
		];
		let outline = renderer::linear_path(&corners, true, &mut self.draw);
		self.build(outline, Some(&corners))
	}

	/// An ellipse centred on (`x`, `y`).
	pub fn ellipse(&mut self, x: f64, y: f64, width: f64, height: f64) -> Drawable {
		let center = Point::new(x, y);
		let params = renderer::ellipse_params(width, height, &mut self.draw);
		let outline = renderer::ellipse_set(center, params, &mut self.draw);
		let estimate = renderer::ellipse_points(params, center, 0.0, 0.0, &mut self.draw);
		self.build(outline, Some(&estimate))
	}

	/// A circle centred on (`x`, `y`).
	pub fn circle(&mut self, x: f64, y: f64, diameter: f64) -> Drawable {
		self.ellipse(x, y, diameter, diameter)
	}

	/// An unfilled path through `points`, back to the first point when
	/// `closed`.
	pub fn linear_path(&mut self, points: &[Point], closed: bool) -> Drawable {
		let outline = renderer::linear_path(points, closed, &mut self.draw);
		self.build(outline, None)
	}

	/// A closed, fillable polygon through `points`.
	pub fn polygon(&mut self, points: &[Point]) -> Drawable {
		let outline = renderer::linear_path(points, true, &mut self.draw);
		self.build(outline, Some(points))
	}

	/// An elliptical arc centred on (`x`, `y`) from `start` to `stop`
	/// radians. A `closed` arc is drawn as a pie slice.
	pub fn arc(
		&mut self,
		x: f64,
		y: f64,
		width: f64,
		height: f64,
		start: f64,
		stop: f64,
		closed: bool,
	) -> Drawable {
		let center = Point::new(x, y);
		let outline = renderer::arc(
			center,
			width,
			height,
			start,
			stop,
			closed,
			true,
			&mut self.draw,
		);
		let fill = renderer::arc_polygon(center, width, height, start, stop, &mut self.draw);
		self.build(outline, Some(&fill))
	}

	/// A smooth curve through `points`.
	pub fn curve(&mut self, points: &[Point]) -> Drawable {
		let outline = renderer::curve_set(points, &mut self.draw);
		self.build(outline, None)
	}

	/// A rectangle with rounded corners, given clockwise from the top left.
	///
	/// Each pen pass follows one closed contour, so small radii do not leave
	/// knots where corners meet edges.
	pub fn rounded_rectangle(
		&mut self,
		x: f64,
		y: f64,
		width: f64,
		height: f64,
		radii: [f64; 4],
	) -> Drawable {
		let max_radius = (width / 2.0).min(height / 2.0);
		let [tl, tr, br, bl] = radii.map(|radius| clamp(radius, 0.0, max_radius));
		let offset = self
			.draw
			.options
			.max_randomness_offset
			.min(width.min(height) / 16.0);

		let mut contour = Contour {
			ops: Vec::new(),
			cursor: Point::default(),
		};
		for pass in 0..2 {
			let gain = if pass == 0 { 0.45 } else { 0.7 };
			let dx = self.draw.offset_symmetric(offset, gain);
			let dy = self.draw.offset_symmetric(offset, gain);
			let left = x + dx;
			let top = y + dy;
			let right = x + width + dx;
			let bottom = y + height + dy;
			let edge = EdgeStyle { offset, gain };

			contour.start(Point::new(left + tl, top), pass);
			contour.edge(Point::new(right - tr, top), edge, &mut self.draw);
			contour.curve(
				Point::new(right - tr + tr * KAPPA, top),
				Point::new(right, top + tr - tr * KAPPA),
				Point::new(right, top + tr),
			);
			contour.edge(Point::new(right, bottom - br), edge, &mut self.draw);
			contour.curve(
				Point::new(right, bottom - br + br * KAPPA),
				Point::new(right - br + br * KAPPA, bottom),
				Point::new(right - br, bottom),
			);
			contour.edge(Point::new(left + bl, bottom), edge, &mut self.draw);
			contour.curve(
				Point::new(left + bl - bl * KAPPA, bottom),
				Point::new(left, bottom - bl + bl * KAPPA),
				Point::new(left, bottom - bl),
			);
			contour.edge(Point::new(left, top + tl), edge, &mut self.draw);
			contour.curve(
				Point::new(left, top + tl - tl * KAPPA),
				Point::new(left + tl - tl * KAPPA, top),
				Point::new(left + tl, top),
			);
		}

		let fill = rounded_rectangle_fill(x, y, width, height, [tl, tr, br, bl]);
		self.build(OpSet::path(contour.ops), Some(&fill))
	}
}

/// How one pass of a rounded rectangle wanders along its straight edges.
#[derive(Debug, Clone, Copy)]
struct EdgeStyle {
	offset: f64,
	gain: f64,
}

/// A rounded rectangle's contour as it is drawn.
struct Contour {
	ops: Vec<Op>,
	cursor: Point,
}

impl Contour {
	fn start(&mut self, at: Point, pass: u32) {
		self.ops.push(Op::Move { to: at, pass });
		self.cursor = at;
	}

	fn curve(&mut self, control1: Point, control2: Point, end: Point) {
		self.ops.push(Op::CurveTo {
			control1,
			control2,
			end,
		});
		self.cursor = end;
	}

	/// A straight edge from the cursor to `end` that bows gently, or wanders
	/// locally when it is long.
	fn edge(&mut self, end: Point, style: EdgeStyle, draw: &mut DrawConfig) {
		let options = draw.options;
		let start = self.cursor;
		let ex = end.x - start.x;
		let ey = end.y - start.y;
		let length = (ex * ex + ey * ey).sqrt();
		if length == 0.0 {
			return;
		}

		// The pass offset and local wobble share the reserved ink bleed.
		let limit = style.offset * options.roughness * (1.0 - style.gain);
		let at = |t: f64, across: f64| {
			let across = clamp(across, -limit, limit);
			Point::new(
				start.x + ex * t - (ey / length) * across,
				start.y + ey * t + (ex / length) * across,
			)
		};

		if length >= 48.0 && options.line_wobble > 0.0 {
			let segments = (length / 48.0).ceil().max(2.0) as usize;
			let count = segments as f64;
			let displacement: Vec<f64> = (0..=segments)
				.map(|i| {
					if i == 0 || i == segments {
						0.0
					} else {
						clamp(
							draw.offset_symmetric(style.offset, options.line_wobble * style.gain),
							-limit,
							limit,
						)
					}
				})
				.collect();
			for i in 0..segments {
				let before = displacement[i.saturating_sub(1)];
				let from = displacement[i];
				let to = displacement[i + 1];
				let after = displacement[(i + 2).min(segments)];
				// Zero endpoint tangents join the corner arcs without knots.
				let first = if i == 0 {
					0.0
				} else {
					from + (to - before) / 6.0
				};
				let second = if i == segments - 1 {
					0.0
				} else {
					to - (after - from) / 6.0
				};
				let step = i as f64;
				self.curve(
					at((step + 1.0 / 3.0) / count, first),
					at((step + 2.0 / 3.0) / count, second),
					at((step + 1.0) / count, to),
				);
			}
			return;
		}

		// Bow a continuous stroke gently; longer edges can wander locally.
		// Endpoint handles stay tangent to the rounded corners.
		let reach = style.offset.min(length / 12.0);
		let bow = draw.offset_symmetric(reach, options.bowing * style.gain);
		let drift = draw.offset_symmetric(reach, options.line_wobble * style.gain);
		self.curve(
			at(1.0 / 6.0, 0.0),
			at(1.0 / 3.0, bow + drift),
			at(1.0 / 2.0, bow),
		);
		self.curve(at(2.0 / 3.0, bow - drift), at(5.0 / 6.0, 0.0), end);
	}
}

/// The polygon a rounded rectangle's fill covers: eight steps per corner.
fn rounded_rectangle_fill(x: f64, y: f64, w: f64, h: f64, radii: [f64; 4]) -> Vec<Point> {
	let [tl, tr, br, bl] = radii;
	let corners = [
		(PI, x + tl, y + tl, tl),
		(-PI / 2.0, x + w - tr, y + tr, tr),
		(0.0, x + w - br, y + h - br, br),
		(PI / 2.0, x + bl, y + h - bl, bl),
	];

	let steps = 8;
	let mut points = Vec::with_capacity(corners.len() * (steps + 1));
	for (start, cx, cy, radius) in corners {
		for i in 0..=steps {
			let angle = start + PI / 2.0 * (i as f64 / steps as f64);
			points.push(Point::new(
				cx + radius * angle.cos(),
				cy + radius * angle.sin(),
			));
		}
	}
	points
}

#[cfg(test)]
mod tests {
	use super::*;
	use crate::DrawOptions;
	use crate::FillOptions;
	use crate::FillStyle;
	use crate::OpSetKind;

	fn generator(style: FillStyle, seed: i64) -> Generator {
		let options = DrawOptions {
			seed,
			..DrawOptions::default()
		};
		Generator::new(
			DrawConfig::new(options),
			Filler::new(style, FillOptions::default(), DrawConfig::new(options)),
		)
	}

	#[test]
	fn the_same_seed_draws_the_same_shape() {
		let first = generator(FillStyle::Hachure, 3).rectangle(0.0, 0.0, 80.0, 40.0);
		let second = generator(FillStyle::Hachure, 3).rectangle(0.0, 0.0, 80.0, 40.0);
		let other = generator(FillStyle::Hachure, 4).rectangle(0.0, 0.0, 80.0, 40.0);
		assert_eq!(first, second);
		assert_ne!(first, other);
	}

	#[test]
	fn closed_shapes_paint_their_fill_first() {
		let drawable = generator(FillStyle::Solid, 1).ellipse(40.0, 40.0, 60.0, 30.0);
		let kinds: Vec<_> = drawable.sets.iter().map(|set| set.kind).collect();
		assert_eq!(kinds, vec![OpSetKind::FillPath, OpSetKind::Path]);
	}

	#[test]
	fn lines_have_no_fill_and_two_passes() {
		let drawable = generator(FillStyle::Hachure, 1).line(0.0, 0.0, 30.0, 10.0);
		assert_eq!(drawable.sets.len(), 1);
		let passes: Vec<u32> = drawable.sets[0]
			.ops
			.iter()
			.filter_map(|op| match op {
				Op::Move { pass, .. } => Some(*pass),
				_ => None,
			})
			.collect();
		assert_eq!(passes, vec![0, 1]);
	}
}
