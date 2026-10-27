//! The drawing operations a generator produces.

use crate::Point;
use crate::RoughPen;

/// A single drawing operation.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Op {
	/// Starts a new contour.
	Move {
		/// Where the contour starts.
		to: Point,
		/// Which pen pass the contour belongs to.
		///
		/// Zero is the first stroke. The generator draws most shapes twice and
		/// a [`RoughPen`] lays later passes down lighter.
		pass: u32,
	},
	/// A straight segment.
	LineTo(Point),
	/// A cubic Bézier segment.
	CurveTo {
		/// The first control point.
		control1: Point,
		/// The second control point.
		control2: Point,
		/// Where the segment ends.
		end: Point,
	},
}

impl Op {
	/// Starts a first-pass contour at `to`.
	pub const fn move_to(to: Point) -> Self {
		Self::Move { to, pass: 0 }
	}

	/// The points this operation carries, in SVG order.
	pub fn points(&self) -> impl Iterator<Item = Point> {
		let (points, count) = match *self {
			Self::Move { to, .. } | Self::LineTo(to) => ([to, to, to], 1),
			Self::CurveTo {
				control1,
				control2,
				end,
			} => ([control1, control2, end], 3),
		};
		points.into_iter().take(count)
	}

	/// The SVG path command for this operation.
	pub const fn command(&self) -> char {
		match self {
			Self::Move { .. } => 'M',
			Self::LineTo(_) => 'L',
			Self::CurveTo { .. } => 'C',
		}
	}
}

/// What an [`OpSet`] draws.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum OpSetKind {
	/// An outline, stroked with the ink colour.
	Path,
	/// A solid fill polygon, filled with the fill colour.
	FillPath,
	/// A sketched fill pattern, stroked with the fill colour.
	FillSketch,
}

/// Operations that are painted together.
#[derive(Debug, Clone, PartialEq)]
pub struct OpSet {
	/// What the operations draw.
	pub kind: OpSetKind,
	/// The operations, in drawing order.
	pub ops: Vec<Op>,
}

impl OpSet {
	/// Creates an outline from `ops`.
	pub const fn path(ops: Vec<Op>) -> Self {
		Self {
			kind: OpSetKind::Path,
			ops,
		}
	}
}

/// A generated rough shape: its op sets, and the pen and seed that drew it.
#[derive(Debug, Clone, PartialEq)]
pub struct Drawable {
	/// The op sets in paint order: the fill (if any), then the outline.
	pub sets: Vec<OpSet>,
	/// How ink leaves the pen along the outline.
	pub pen: RoughPen,
	/// The seed the shape was drawn with, which also seeds its ink.
	pub seed: i64,
}
