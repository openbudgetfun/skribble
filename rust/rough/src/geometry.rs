//! Points, segments, and the polygon tests the fill algorithms use.

/// A point in drawing coordinates.
#[derive(Debug, Clone, Copy, PartialEq, Default)]
pub struct Point {
	/// Distance from the left edge.
	pub x: f64,
	/// Distance from the top edge.
	pub y: f64,
}

impl Point {
	/// Creates a point.
	pub const fn new(x: f64, y: f64) -> Self {
		Self { x, y }
	}

	/// The distance from this point to `other`.
	pub fn distance_to(self, other: Self) -> f64 {
		let dx = self.x - other.x;
		let dy = self.y - other.y;
		(dx * dx + dy * dy).sqrt()
	}

	/// This point rotated around `center` by `degrees`.
	#[must_use]
	pub fn rotated(self, center: Self, degrees: f64) -> Self {
		let angle = std::f64::consts::PI / 180.0 * degrees;
		let (sin, cos) = (angle.sin(), angle.cos());
		Self {
			x: (self.x - center.x) * cos - (self.y - center.y) * sin + center.x,
			y: (self.x - center.x) * sin + (self.y - center.y) * cos + center.y,
		}
	}
}

impl From<(f64, f64)> for Point {
	fn from((x, y): (f64, f64)) -> Self {
		Self { x, y }
	}
}

impl From<[f64; 2]> for Point {
	fn from([x, y]: [f64; 2]) -> Self {
		Self { x, y }
	}
}

/// The orientation of three ordered points, used by intersection tests.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Orientation {
	/// The points lie on one line.
	Collinear,
	/// The points turn clockwise.
	Clockwise,
	/// The points turn counterclockwise.
	Counterclockwise,
}

impl Orientation {
	/// The orientation of the ordered triplet (`p`, `q`, `r`).
	pub fn of(p: Point, q: Point, r: Point) -> Self {
		let value = (q.x - p.x) * (r.y - q.y) - (q.y - p.y) * (r.x - q.x);
		if value == 0.0 {
			Self::Collinear
		} else if value > 0.0 {
			Self::Clockwise
		} else {
			Self::Counterclockwise
		}
	}
}

/// A segment from `source` to `target`.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Line {
	/// Where the segment starts.
	pub source: Point,
	/// Where the segment ends.
	pub target: Point,
}

impl Line {
	/// Creates a segment.
	pub const fn new(source: Point, target: Point) -> Self {
		Self { source, target }
	}

	/// The segment's length.
	pub fn length(&self) -> f64 {
		self.source.distance_to(self.target)
	}

	/// Whether `p`, known to be collinear with the segment, lies on it.
	pub fn on_segment(&self, p: Point) -> bool {
		let Self { source, target } = *self;
		p.x <= source.x.max(target.x)
			&& p.x >= source.x.min(target.x)
			&& p.y <= source.y.max(target.y)
			&& p.y >= source.y.min(target.y)
	}

	/// Whether this segment touches or crosses `line`.
	pub fn intersects(&self, line: &Self) -> bool {
		let Self { source, target } = *self;
		let o1 = Orientation::of(source, target, line.source);
		let o2 = Orientation::of(source, target, line.target);
		let o3 = Orientation::of(line.source, line.target, source);
		let o4 = Orientation::of(line.source, line.target, target);

		(o1 != o2 && o3 != o4)
			|| (o1 == Orientation::Collinear && self.on_segment(line.source))
			|| (o2 == Orientation::Collinear && self.on_segment(line.target))
			|| (o3 == Orientation::Collinear && line.on_segment(source))
			|| (o4 == Orientation::Collinear && line.on_segment(target))
	}

	/// Where the lines through this segment and `line` cross, if they are not
	/// parallel.
	pub fn intersection_with(&self, line: &Self) -> Option<Point> {
		let Self { source, target } = *self;
		let y_diff = target.y - source.y;
		let x_diff = source.x - target.x;
		let diff = y_diff * source.x + x_diff * source.y;
		let line_y_diff = line.target.y - line.source.y;
		let line_x_diff = line.source.x - line.target.x;
		let line_diff = line_y_diff * line.source.x + line_x_diff * line.source.y;
		let determinant = y_diff * line_x_diff - line_y_diff * x_diff;

		(determinant != 0.0).then(|| Point {
			x: (line_x_diff * diff - x_diff * line_diff) / determinant,
			y: (y_diff * line_diff - line_y_diff * diff) / determinant,
		})
	}

	/// Whether the segment's midpoint lies inside `polygon`.
	pub fn is_mid_point_in_polygon(&self, polygon: &[Point]) -> bool {
		let mid = Point {
			x: (self.source.x + self.target.x) / 2.0,
			y: (self.source.y + self.target.y) / 2.0,
		};
		is_in_polygon(mid, polygon)
	}

	/// This segment with both ends rotated around `center` by `degrees`.
	#[must_use]
	pub fn rotated(&self, center: Point, degrees: f64) -> Self {
		Self {
			source: self.source.rotated(center, degrees),
			target: self.target.rotated(center, degrees),
		}
	}
}

/// Whether `p` lies inside the polygon through `points`.
pub fn is_in_polygon(p: Point, points: &[Point]) -> bool {
	if points.len() < 3 {
		return false;
	}

	let ray = Line::new(p, Point::new(f64::MAX, p.y));
	let mut count = 0;
	for (index, &current) in points.iter().enumerate() {
		let next = points[(index + 1) % points.len()];
		let edge = Line::new(current, next);
		if edge.intersects(&ray) {
			if Orientation::of(current, p, next) == Orientation::Collinear {
				return edge.on_segment(p);
			}
			count += 1;
		}
	}
	count % 2 == 1
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn points_inside_and_outside_a_square() {
		let square = [
			Point::new(0.0, 0.0),
			Point::new(10.0, 0.0),
			Point::new(10.0, 10.0),
			Point::new(0.0, 10.0),
		];
		assert!(is_in_polygon(Point::new(5.0, 5.0), &square));
		assert!(!is_in_polygon(Point::new(15.0, 5.0), &square));
		assert!(!is_in_polygon(Point::new(5.0, 5.0), &square[..2]));
	}

	#[test]
	fn crossing_segments_intersect_where_expected() {
		let a = Line::new(Point::new(0.0, 0.0), Point::new(10.0, 10.0));
		let b = Line::new(Point::new(0.0, 10.0), Point::new(10.0, 0.0));
		assert!(a.intersects(&b));
		assert_eq!(a.intersection_with(&b), Some(Point::new(5.0, 5.0)));
	}

	#[test]
	fn parallel_lines_have_no_intersection() {
		let a = Line::new(Point::new(0.0, 0.0), Point::new(10.0, 0.0));
		let b = Line::new(Point::new(0.0, 5.0), Point::new(10.0, 5.0));
		assert!(!a.intersects(&b));
		assert_eq!(a.intersection_with(&b), None);
	}
}
