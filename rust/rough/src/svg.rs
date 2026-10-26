//! SVG path data for rough drawings.

use std::fmt::Write as _;

use crate::Drawable;
use crate::OpSet;
use crate::OpSetKind;
use crate::math::format_number;

/// Converts the operations in `set` into SVG path data (the `d` attribute).
///
/// Moves become `M`, straight segments `L`, and cubic segments `C`. A solid
/// fill is closed with `Z`. Coordinates keep two decimals, so the same set
/// always produces the same string and server-rendered markup stays
/// byte-stable. Returns an empty string when `set` has no operations.
pub fn op_set_to_svg_path(set: &OpSet) -> String {
	if set.ops.is_empty() {
		return String::new();
	}

	let mut data = String::new();
	for op in &set.ops {
		data.push(op.command());
		for (index, point) in op.points().enumerate() {
			if index > 0 {
				data.push(' ');
			}
			data.push_str(&format_number(point.x, 2));
			data.push(' ');
			data.push_str(&format_number(point.y, 2));
		}
	}
	if set.kind == OpSetKind::FillPath {
		data.push('Z');
	}
	data
}

/// A drawable's path data, split the way skribble paints it.
///
/// Each group joins all of its op sets, so a shape costs at most three SVG
/// elements. These are plain centrelines, independent of the drawable's pen,
/// and suit scalable output that stretches with its element. Use
/// [`crate::DrawableInk`] when exported ink must keep the pen's tapered
/// widths.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct RoughSvgPaths {
	/// Outlines, stroked with the ink colour.
	pub outline: String,
	/// Sketched fills, stroked with the fill colour.
	pub sketch: String,
	/// Solid fills, filled with the fill colour.
	pub solid: String,
}

impl RoughSvgPaths {
	/// Splits `drawable`'s op sets into outline, sketch, and solid path data.
	pub fn from_drawable(drawable: &Drawable) -> Self {
		let mut paths = Self::default();
		for set in &drawable.sets {
			let data = op_set_to_svg_path(set);
			match set.kind {
				OpSetKind::Path => paths.outline.push_str(&data),
				OpSetKind::FillSketch => paths.sketch.push_str(&data),
				OpSetKind::FillPath => paths.solid.push_str(&data),
			}
		}
		paths
	}

	/// Renders the non-empty groups as SVG `<path>` elements in paint order:
	/// solid fill, sketched fill, then outline. Colours are attribute-escaped.
	/// Byte-identical to `RoughSvg.toPathElements` in Dart.
	pub fn to_path_elements(&self, options: &PathElementOptions<'_>) -> String {
		let effect = if options.non_scaling_stroke {
			r#" vector-effect="non-scaling-stroke""#
		} else {
			""
		};
		let ink = escape_attribute(options.stroke);
		let paint = escape_attribute(options.fill);
		let stroke = |data: &str, color: &str, width: f64| {
			format!(
				r#"<path d="{data}" fill="none" stroke="{color}" stroke-width="{}" stroke-linecap="round" stroke-linejoin="round"{effect}/>"#,
				format_number(width, 2)
			)
		};

		let mut elements = String::new();
		if !self.solid.is_empty() {
			let _ = write!(
				elements,
				r#"<path d="{}" fill="{paint}" stroke="none"/>"#,
				self.solid
			);
		}
		if !self.sketch.is_empty() {
			elements.push_str(&stroke(&self.sketch, &paint, options.sketch_width));
		}
		if !self.outline.is_empty() {
			elements.push_str(&stroke(&self.outline, &ink, options.stroke_width));
		}
		elements
	}
}

/// How [`RoughSvgPaths::to_path_elements`] paints each group.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct PathElementOptions<'a> {
	/// Outline colour, as any SVG paint.
	pub stroke: &'a str,
	/// Colour of both fill groups, as any SVG paint.
	pub fill: &'a str,
	/// Outline width.
	pub stroke_width: f64,
	/// Width of sketched fill lines.
	pub sketch_width: f64,
	/// Keep strokes at their width when the surrounding SVG stretches.
	pub non_scaling_stroke: bool,
}

impl Default for PathElementOptions<'_> {
	fn default() -> Self {
		Self {
			stroke: "currentColor",
			fill: "currentColor",
			stroke_width: 1.5,
			sketch_width: 1.0,
			non_scaling_stroke: false,
		}
	}
}

/// Escapes `value` for use inside a double-quoted XML attribute.
pub fn escape_attribute(value: &str) -> String {
	let mut escaped = String::with_capacity(value.len());
	for character in value.chars() {
		match character {
			'&' => escaped.push_str("&amp;"),
			'"' => escaped.push_str("&quot;"),
			'<' => escaped.push_str("&lt;"),
			'>' => escaped.push_str("&gt;"),
			other => escaped.push(other),
		}
	}
	escaped
}

#[cfg(test)]
mod tests {
	use super::*;
	use crate::Op;
	use crate::Point;

	#[test]
	fn solid_fills_close_their_path() {
		let set = OpSet {
			kind: OpSetKind::FillPath,
			ops: vec![
				Op::move_to(Point::new(0.0, 0.0)),
				Op::LineTo(Point::new(1.256, -0.001)),
			],
		};
		assert_eq!(op_set_to_svg_path(&set), "M0 0L1.26 0Z");
	}

	#[test]
	fn attributes_are_escaped() {
		assert_eq!(
			escape_attribute(r#"a "b" & <c>"#),
			"a &quot;b&quot; &amp; &lt;c&gt;"
		);
	}
}
