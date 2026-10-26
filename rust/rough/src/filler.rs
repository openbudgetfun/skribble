//! Sketched fills: hachure, cross-hatching, zig-zags, dashes, dots, and
//! solid ink.

use std::cmp::Ordering;
use std::fmt;
use std::str::FromStr;

use crate::DrawConfig;
use crate::Line;
use crate::Op;
use crate::OpSet;
use crate::OpSetKind;
use crate::Point;
use crate::geometry::is_in_polygon;
use crate::math::compare_doubles;
use crate::math::dart_sort;
use crate::renderer;

/// How a closed rough shape is filled. The names match rough.js, so designs
/// and docs written for either read the same.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Default)]
pub enum FillStyle {
	/// No fill.
	#[default]
	None,
	/// Parallel lines at [`FillOptions::hachure_angle`].
	Hachure,
	/// Two hachure passes at right angles.
	CrossHatch,
	/// Hachure lines joined end to end.
	ZigZag,
	/// Dashed hachure lines.
	Dashed,
	/// Scattered rough dots.
	Dots,
	/// A solid polygon whose corners wander slightly.
	Solid,
}

impl FillStyle {
	/// Every fill style, in declaration order.
	pub const ALL: [Self; 7] = [
		Self::None,
		Self::Hachure,
		Self::CrossHatch,
		Self::ZigZag,
		Self::Dashed,
		Self::Dots,
		Self::Solid,
	];

	/// The rough.js name of the style, such as `"cross-hatch"`.
	pub const fn name(self) -> &'static str {
		match self {
			Self::None => "none",
			Self::Hachure => "hachure",
			Self::CrossHatch => "cross-hatch",
			Self::ZigZag => "zigzag",
			Self::Dashed => "dashed",
			Self::Dots => "dots",
			Self::Solid => "solid",
		}
	}
}

impl fmt::Display for FillStyle {
	fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
		formatter.write_str(self.name())
	}
}

/// The error for a fill style name that does not exist.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct UnknownFillStyle(pub String);

impl fmt::Display for UnknownFillStyle {
	fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
		write!(formatter, "unknown fill style `{}`", self.0)
	}
}

impl std::error::Error for UnknownFillStyle {}

impl FromStr for FillStyle {
	type Err = UnknownFillStyle;

	fn from_str(name: &str) -> Result<Self, Self::Err> {
		Self::ALL
			.into_iter()
			.find(|style| style.name() == name)
			.ok_or_else(|| UnknownFillStyle(name.to_owned()))
	}
}

/// The values that shape a fill pattern.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct FillOptions {
	/// Diameter of dots and displacement of solid fill corners.
	pub fill_weight: f64,
	/// Angle of hachure lines, in degrees.
	pub hachure_angle: f64,
	/// Distance between neighbouring hachure lines.
	pub hachure_gap: f64,
	/// Length of each dash in a dashed fill.
	pub dash_offset: f64,
	/// Gap between dashes in a dashed fill.
	pub dash_gap: f64,
	/// Offset of zig-zag turns from the hachure line.
	pub zigzag_offset: f64,
}

impl Default for FillOptions {
	/// The engine's defaults. [`crate::sketch`] narrows the hachure gap to 8.
	fn default() -> Self {
		Self {
			fill_weight: 1.0,
			hachure_angle: 320.0,
			hachure_gap: 15.0,
			dash_offset: 15.0,
			dash_gap: 2.0,
			zigzag_offset: 5.0,
		}
	}
}

/// A fill pattern and the random stream it draws with.
///
/// Give every filler a [`DrawConfig`] of its own, built from the shape's seed,
/// so the fill and the outline replay independently.
#[derive(Debug, Clone, PartialEq)]
pub struct Filler {
	/// The pattern.
	pub style: FillStyle,
	/// The pattern's measurements.
	pub options: FillOptions,
	/// How fill strokes wander and how their ink is laid down.
	pub draw: DrawConfig,
}

#[derive(Debug, Clone, Copy)]
struct Edge {
	y_min: f64,
	y_max: f64,
	x: f64,
	slope: f64,
}

impl Filler {
	/// Creates a filler.
	pub fn new(style: FillStyle, options: FillOptions, draw: DrawConfig) -> Self {
		Self {
			style,
			options,
			draw,
		}
	}

	/// The operations that fill the polygon through `points`.
	pub fn fill(&mut self, points: &[Point]) -> OpSet {
		let options = self.options;
		let sketch = |ops| OpSet {
			kind: OpSetKind::FillSketch,
			ops,
		};
		match self.style {
			FillStyle::None => sketch(Vec::new()),
			FillStyle::Hachure => sketch(self.hachure(points, options, false)),
			FillStyle::ZigZag => sketch(self.hachure(points, options, true)),
			FillStyle::CrossHatch => {
				let mut ops = self.hachure(points, options, false);
				let rotated = FillOptions {
					hachure_angle: options.hachure_angle + 90.0,
					..options
				};
				ops.extend(self.hachure(points, rotated, false));
				sketch(ops)
			}
			FillStyle::Dashed => {
				let lines = fill_lines(points, options);
				sketch(dashed_lines(&lines, options, &mut self.draw))
			}
			FillStyle::Dots => sketch(dots(points, options, &self.draw)),
			FillStyle::Solid => OpSet {
				kind: OpSetKind::FillPath,
				ops: solid(points, options, &mut self.draw),
			},
		}
	}

	/// Hachure lines across the polygon, joined end to end when `connect`.
	fn hachure(&mut self, points: &[Point], options: FillOptions, connect: bool) -> Vec<Op> {
		let mut lines = fill_lines(points, options);
		if connect {
			let connectors = connect_lines(points, &lines);
			lines.extend(connectors);
		}
		lines
			.iter()
			.flat_map(|line| {
				renderer::double_line(
					line.source.x,
					line.source.y,
					line.target.x,
					line.target.y,
					&mut self.draw,
				)
			})
			.collect()
	}
}

/// Parallel lines at the hachure angle, clipped to the polygon.
fn fill_lines(points: &[Point], options: FillOptions) -> Vec<Line> {
	let origin = Point::default();
	let angle = (options.hachure_angle + 90.0).round();
	if angle == 0.0 {
		return scan_lines(points.to_vec(), options.hachure_gap);
	}

	let rotated = points.iter().map(|p| p.rotated(origin, angle)).collect();
	scan_lines(rotated, options.hachure_gap)
		.iter()
		.map(|line| line.rotated(origin, -angle))
		.collect()
}

/// Horizontal scan lines `gap` apart across the polygon through `vertices`.
fn scan_lines(mut vertices: Vec<Point>, gap: f64) -> Vec<Line> {
	let mut lines = Vec::new();
	let (Some(&first), Some(&last)) = (vertices.first(), vertices.last()) else {
		return lines;
	};
	if first != last {
		vertices.push(first);
	}
	if vertices.len() <= 2 {
		return lines;
	}

	let gap = gap.max(0.1);
	let edges = sorted_edges(&vertices);
	let Some(first_edge) = edges.first() else {
		return lines;
	};
	let mut y = first_edge.y_min;
	let mut active: Vec<Edge> = Vec::new();
	let mut pending = 0;

	while !active.is_empty() || pending < edges.len() {
		// An edge that starts between scanlines joins at this one, so its
		// intercept moves along the edge to y. Starting it at y_min pushed lines
		// past short, shallow edges such as rounded corners.
		// "Not after y" rather than "at or before y", as the TypeScript port
		// compares: a NaN edge is taken and dropped instead of stalling the scan.
		while pending < edges.len()
			&& edges[pending].y_min.partial_cmp(&y) != Some(Ordering::Greater)
		{
			let edge = edges[pending];
			active.push(Edge {
				x: edge.x + (y - edge.y_min) * edge.slope,
				..edge
			});
			pending += 1;
		}
		active.retain(|edge| edge.y_max > y);
		dart_sort(&mut active, |a, b| compare_doubles(a.x, b.x));

		for pair in active.chunks_exact(2) {
			lines.push(Line::new(
				Point::new(pair[0].x.round(), y),
				Point::new(pair[1].x.round(), y),
			));
		}

		y += gap;
		for edge in &mut active {
			edge.x += gap * edge.slope;
		}
	}

	lines
}

/// The polygon's non-horizontal edges, ordered for the scan-line fill.
fn sorted_edges(vertices: &[Point]) -> Vec<Edge> {
	let mut edges: Vec<Edge> = vertices
		.windows(2)
		.filter(|pair| pair[0].y != pair[1].y)
		.map(|pair| {
			let (p1, p2) = (pair[0], pair[1]);
			let y_min = p1.y.min(p2.y);
			Edge {
				y_min,
				y_max: p1.y.max(p2.y),
				x: if y_min == p1.y { p1.x } else { p2.x },
				slope: (p2.x - p1.x) / (p2.y - p1.y),
			}
		})
		.collect();

	dart_sort(&mut edges, |a, b| {
		if a.y_min < b.y_min {
			Ordering::Less
		} else if a.y_min > b.y_min {
			Ordering::Greater
		} else if a.x < b.x {
			Ordering::Less
		} else if a.x > b.x {
			Ordering::Greater
		} else {
			compare_doubles(a.y_max, b.y_max)
		}
	});
	edges
}

/// Segments that join each hachure line to the next inside the polygon.
fn connect_lines(polygon: &[Point], lines: &[Line]) -> Vec<Line> {
	let mut result = Vec::new();
	for pair in lines.windows(2) {
		let (previous, current) = (pair[0], pair[1]);
		if previous.length() < 3.0 {
			continue;
		}
		let segment = Line::new(current.source, previous.target);
		if segment.length() > 3.0 {
			result.extend(split_on_intersections(polygon, segment));
		}
	}
	result
}

/// The parts of `segment` that lie inside `polygon`.
fn split_on_intersections(polygon: &[Point], segment: Line) -> Vec<Line> {
	let inside_or_nothing = || {
		if segment.is_mid_point_in_polygon(polygon) {
			vec![segment]
		} else {
			Vec::new()
		}
	};

	let error = (segment.length() * 0.1).max(5.0);
	let mut intersections: Vec<(Point, f64)> = Vec::new();
	for (index, &start) in polygon.iter().enumerate() {
		let edge = Line::new(start, polygon[(index + 1) % polygon.len()]);
		if !segment.intersects(&edge) {
			continue;
		}
		if let Some(point) = segment.intersection_with(&edge) {
			let to_source = Line::new(point, segment.source).length();
			let to_target = Line::new(point, segment.target).length();
			if to_source > error && to_target > error {
				intersections.push((point, to_source));
			}
		}
	}
	if intersections.len() <= 1 {
		return inside_or_nothing();
	}

	// Dart compares the rounded-up difference, which is not a consistent
	// order; the insertion sort keeps its result anyway.
	dart_sort(&mut intersections, |a, b| {
		compare_doubles((a.1 - b.1).ceil(), 0.0)
	});
	let mut crossings: Vec<Point> = intersections.into_iter().map(|(point, _)| point).collect();
	if is_in_polygon(segment.source, polygon) {
		crossings.remove(0);
	}
	if is_in_polygon(segment.target, polygon) {
		crossings.pop();
	}
	if crossings.len() <= 1 {
		return inside_or_nothing();
	}

	let mut split_points = Vec::with_capacity(crossings.len() + 2);
	split_points.push(segment.source);
	split_points.extend(crossings);
	split_points.push(segment.target);
	split_points
		.chunks_exact(2)
		.map(|pair| Line::new(pair[0], pair[1]))
		.filter(|part| part.is_mid_point_in_polygon(polygon))
		.collect()
}

/// Dashes along every line.
fn dashed_lines(lines: &[Line], options: FillOptions, draw: &mut DrawConfig) -> Vec<Op> {
	let dash = options.dash_offset;
	let gap = options.dash_gap;
	let mut ops = Vec::new();
	for line in lines {
		let length = line.length();
		let count = (length / (dash + gap)).floor();
		let line_offset = (length + gap - count * (dash + gap)) / 2.0;
		let (start, end) = if line.source.x > line.target.x {
			(line.target, line.source)
		} else {
			(line.source, line.target)
		};
		let alpha = ((end.y - start.y) / (end.x - start.x)).atan();
		let (sin, cos) = (alpha.sin(), alpha.cos());

		let mut index = 0.0;
		while index < count {
			let start_offset = index * (dash + gap);
			let end_offset = start_offset + dash;
			ops.extend(renderer::double_line(
				start.x + start_offset * cos + line_offset * cos,
				start.y + start_offset * sin + line_offset * sin,
				start.x + end_offset * cos + line_offset * cos,
				start.y + end_offset * sin + line_offset * sin,
				draw,
			));
			index += 1.0;
		}
	}
	ops
}

/// Rough dots scattered along nearly horizontal lines through the polygon.
///
/// Dots draw with a stream of their own, reseeded from the fill's seed, and a
/// coarser, steadier pen.
fn dots(points: &[Point], options: FillOptions, draw: &DrawConfig) -> Vec<Op> {
	let mut draw = draw.fork(|dot| {
		dot.curve_step_count = 4.0;
		dot.roughness = 1.0;
	});
	let options = FillOptions {
		hachure_angle: 1.0,
		..options
	};
	let gap = options.hachure_gap.max(0.1);
	let weight = options.fill_weight.max(0.1);
	let jitter = gap / 4.0;

	let mut ops = Vec::new();
	for line in fill_lines(points, options) {
		let length = line.length();
		let count = (length / gap).ceil() - 1.0;
		let spare = length - count * gap;
		let x = (line.source.x + line.target.x) / 2.0 - gap / 4.0;
		let min_y = line.source.y.min(line.target.y);

		let mut index = 0.0;
		while index < count {
			let y = min_y + spare + index * gap;
			let cx = draw.offset(x - jitter, x + jitter, 1.0);
			let cy = draw.offset(y - jitter, y + jitter, 1.0);
			ops.extend(renderer::ellipse(Point::new(cx, cy), weight, weight, &mut draw).ops);
			index += 1.0;
		}
	}
	ops
}

/// The polygon with each corner nudged by up to the fill weight.
///
/// Smoothing a polygon as a spline rounds its corners and overshoots long
/// edges, so solid ink keeps the perturbed polygon and stays in its shape.
fn solid(points: &[Point], options: FillOptions, draw: &mut DrawConfig) -> Vec<Op> {
	if points.len() <= 2 {
		return Vec::new();
	}

	let weight = options.fill_weight;
	let corners: Vec<Point> = points
		.iter()
		.map(|p| {
			Point::new(
				p.x + draw.offset_symmetric(weight, 1.0),
				p.y + draw.offset_symmetric(weight, 1.0),
			)
		})
		.collect();

	let mut ops = Vec::with_capacity(corners.len() + 1);
	ops.push(Op::move_to(corners[0]));
	ops.extend(corners[1..].iter().map(|&corner| Op::LineTo(corner)));
	ops.push(Op::LineTo(corners[0]));
	ops
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn fill_styles_round_trip_through_their_names() {
		for style in FillStyle::ALL {
			assert_eq!(style.name().parse::<FillStyle>(), Ok(style));
		}
		assert!("crosshatch".parse::<FillStyle>().is_err());
	}

	#[test]
	fn hachure_lines_stay_inside_a_square() {
		let square = [
			Point::new(0.0, 0.0),
			Point::new(100.0, 0.0),
			Point::new(100.0, 100.0),
			Point::new(0.0, 100.0),
		];
		let lines = fill_lines(&square, FillOptions::default());
		assert!(!lines.is_empty());
		for line in lines {
			for end in [line.source, line.target] {
				assert!((-1.0..=101.0).contains(&end.x), "{end:?} leaves the square");
				assert!((-1.0..=101.0).contains(&end.y), "{end:?} leaves the square");
			}
		}
	}

	#[test]
	fn degenerate_polygons_have_no_fill() {
		let mut filler = Filler::new(
			FillStyle::Solid,
			FillOptions::default(),
			DrawConfig::default(),
		);
		assert!(
			filler
				.fill(&[Point::new(0.0, 0.0), Point::new(1.0, 1.0)])
				.ops
				.is_empty()
		);
	}
}
