//! Ink as a decorative SVG image of rough strokes.

use std::collections::BTreeMap;
use std::fmt::Write as _;

use leptoskit::native::Element;
use leptoskit::prelude::Image;
use skribble_rough::DrawConfig;
use skribble_rough::DrawOptions;
use skribble_rough::Drawable;
use skribble_rough::FillOptions;
use skribble_rough::FillStyle;
use skribble_rough::Filler;
use skribble_rough::Generator;
use skribble_rough::Point;
use skribble_rough::RoughPen;
use skribble_rough::RoughSvgPaths;
use skribble_rough::format_number;

use super::Ink;
use super::InkShape;
use crate::Tone;
use crate::theme::css_hex;

/// Sketched fill lines are a little lighter than outlines.
const SKETCH_WEIGHT: f32 = 0.75;

/// How one SVG path is painted.
#[derive(Debug, Clone, Copy, PartialEq)]
pub(crate) enum SvgPaint {
	/// Filled with a tone.
	Fill(Tone),
	/// Stroked with a tone, `width` logical pixels wide.
	Stroke { tone: Tone, width: f32 },
}

/// One SVG path and its paint.
#[derive(Debug, Clone, PartialEq)]
pub(crate) struct SvgPath {
	pub(crate) data: String,
	pub(crate) paint: SvgPaint,
}

/// A standalone SVG drawing, ready to become an image source.
#[derive(Debug, Clone, PartialEq)]
pub(crate) struct SvgImage {
	/// The coordinate space the paths are drawn in.
	pub(crate) width: f64,
	pub(crate) height: f64,
	/// Stretch to whatever box shows the image, keeping strokes at their
	/// width. Otherwise the image keeps `width` by `height` as its size.
	pub(crate) stretch: bool,
	pub(crate) paths: Vec<SvgPath>,
}

impl SvgImage {
	/// The SVG document.
	///
	/// Dark colours come from a `prefers-color-scheme` rule inside the image,
	/// the same query leptoskit's web renderer uses for `dark:` classes.
	pub(crate) fn markup(&self) -> String {
		let width = format_number(self.width, 2);
		let height = format_number(self.height, 2);
		let mut dark_rules = BTreeMap::new();
		let mut paths = String::new();
		for path in &self.paths {
			write_path(&mut paths, path, self.stretch, &mut dark_rules);
		}

		let mut style = String::new();
		if !dark_rules.is_empty() {
			style.push_str("<style>@media (prefers-color-scheme:dark){");
			for (rule, class) in dark_rules {
				let _ = write!(style, ".{class}{{{rule}}}");
			}
			style.push_str("}</style>");
		}

		if self.stretch {
			// The outer SVG has no viewBox, so it has no intrinsic aspect ratio
			// and fills the image box even under `object-fit: contain`. The
			// inner one stretches the drawing to it.
			format!(
				"<svg xmlns='http://www.w3.org/2000/svg' width='100%' height='100%'>{style}<svg \
				 width='100%' height='100%' viewBox='0 0 {width} {height}' \
				 preserveAspectRatio='none' overflow='visible'>{paths}</svg></svg>"
			)
		} else {
			format!(
				"<svg xmlns='http://www.w3.org/2000/svg' width='{width}' height='{height}' \
				 viewBox='0 0 {width} {height}'>{style}{paths}</svg>"
			)
		}
	}

	/// The drawing as a `data:` URL for an image source.
	pub(crate) fn data_uri(&self) -> String {
		format!("data:image/svg+xml,{}", percent_encode(&self.markup()))
	}
}

/// Writes one `<path>`, registering a dark-mode rule when its tone changes.
fn write_path(
	out: &mut String,
	path: &SvgPath,
	stretch: bool,
	dark_rules: &mut BTreeMap<String, String>,
) {
	let (property, tone) = match path.paint {
		SvgPaint::Fill(tone) => ("fill", tone),
		SvgPaint::Stroke { tone, .. } => ("stroke", tone),
	};
	let class = (tone.light != tone.dark).then(|| {
		let rule = format!("{property}:{}", css_hex(tone.dark));
		let next = format!("d{}", dark_rules.len());
		format!(" class='{}'", dark_rules.entry(rule).or_insert(next))
	});

	let _ = write!(out, "<path{} d='{}'", class.unwrap_or_default(), path.data);
	match path.paint {
		SvgPaint::Fill(tone) => {
			let _ = write!(out, " fill='{}' stroke='none'", css_hex(tone.light));
		}
		SvgPaint::Stroke { tone, width } => {
			let _ = write!(
				out,
				" fill='none' stroke='{}' stroke-width='{}' stroke-linecap='round' \
				 stroke-linejoin='round'",
				css_hex(tone.light),
				format_number(f64::from(width), 2)
			);
			if stretch {
				out.push_str(" vector-effect='non-scaling-stroke'");
			}
		}
	}
	out.push_str("/>");
}

/// Percent-encodes `markup` for a `data:` URL, keeping the characters URLs
/// allow as they are so the source stays readable.
fn percent_encode(markup: &str) -> String {
	let mut encoded = String::with_capacity(markup.len() + markup.len() / 4);
	for byte in markup.bytes() {
		match byte {
			b'A'..=b'Z'
			| b'a'..=b'z'
			| b'0'..=b'9'
			| b'-'
			| b'_'
			| b'.'
			| b'~'
			| b'!'
			| b'$'
			| b'\''
			| b'('
			| b')'
			| b'*'
			| b','
			| b';'
			| b'='
			| b':'
			| b'@'
			| b'/' => encoded.push(char::from(byte)),
			other => {
				let _ = write!(encoded, "%{other:02X}");
			}
		}
	}
	encoded
}

/// Draws `ink` with the rough engine.
fn drawable(ink: &Ink) -> Drawable {
	let canvas = ink.canvas;
	let options = DrawOptions {
		seed: ink.seed,
		roughness: ink.theme.roughness,
		// The image stretches, so it keeps plain centrelines; the pen only
		// shapes ink drawn at its final size.
		pen: RoughPen::UNIFORM,
		..DrawOptions::default()
	};
	let pattern = FillOptions {
		hachure_gap: canvas.gap,
		..FillOptions::default()
	};
	let style = ink.fill.map_or(FillStyle::None, |fill| fill.style);
	let mut generator = Generator::new(
		DrawConfig::new(options),
		Filler::new(style, pattern, DrawConfig::new(options)),
	);

	let (width, height, inset) = (canvas.width, canvas.height, canvas.inset);
	let inner_width = width - inset * 2.0;
	let inner_height = height - inset * 2.0;
	match ink.shape {
		InkShape::Rectangle => generator.rectangle(inset, inset, inner_width, inner_height),
		InkShape::Capsule => {
			let radius = inner_width.min(inner_height) / 2.0;
			generator.rounded_rectangle(inset, inset, inner_width, inner_height, [radius; 4])
		}
		InkShape::Ellipse => {
			generator.ellipse(width / 2.0, height / 2.0, inner_width, inner_height)
		}
		InkShape::Rule => {
			let middle = height / 2.0;
			generator.line(inset, middle + 0.5, width - inset, middle - 0.5)
		}
		InkShape::Underline => {
			let bottom = height - inset;
			generator.line(inset, bottom, width - inset, bottom - 1.0)
		}
		InkShape::Check => generator.linear_path(
			&[
				Point::new(width * 0.2, height * 0.52),
				Point::new(width * 0.42, height * 0.76),
				Point::new(width * 0.8, height * 0.24),
			],
			false,
		),
	}
}

/// The SVG image `ink` draws, stretched to its parent.
pub(crate) fn image(ink: &Ink) -> SvgImage {
	let paths = RoughSvgPaths::from_drawable(&drawable(ink));
	let stroke_width = ink.theme.stroke_width;
	let mut layers = Vec::new();
	if let Some(fill) = ink.fill {
		if !paths.solid.is_empty() {
			layers.push(SvgPath {
				data: paths.solid,
				paint: SvgPaint::Fill(fill.tone),
			});
		}
		if !paths.sketch.is_empty() {
			layers.push(SvgPath {
				data: paths.sketch,
				paint: SvgPaint::Stroke {
					tone: fill.tone,
					width: stroke_width * SKETCH_WEIGHT,
				},
			});
		}
	}
	if let Some(tone) = ink.outline {
		layers.push(SvgPath {
			data: paths.outline,
			paint: SvgPaint::Stroke {
				tone,
				width: stroke_width,
			},
		});
	}

	SvgImage {
		width: ink.canvas.width,
		height: ink.canvas.height,
		stretch: true,
		paths: layers,
	}
}

/// The decorative image that draws `ink` over its whole parent.
pub(super) fn layer(ink: &Ink) -> Element {
	Image(image(ink).data_uri())
		.class("absolute top-0 left-0 w-full h-full")
		.aria_hidden(true)
}

#[cfg(test)]
mod tests {
	use super::*;
	use crate::Palette;
	use crate::Theme;
	use crate::ink::Canvas;

	fn ink(shape: InkShape) -> Ink {
		Ink::outline(shape, Canvas::new(120.0, 40.0), 3, Theme::SKRIBBLE)
	}

	#[test]
	fn stretched_images_keep_strokes_at_their_width() {
		let markup = image(&ink(InkShape::Rectangle)).markup();
		assert!(markup.contains("preserveAspectRatio='none'"));
		assert!(markup.contains("vector-effect='non-scaling-stroke'"));
		assert!(markup.contains("stroke-width='2'"));
	}

	#[test]
	fn dark_mode_recolours_ink_inside_the_image() {
		let markup = image(&ink(InkShape::Ellipse)).markup();
		assert!(markup.contains(&format!("stroke='{}'", css_hex(Palette::LIGHT.ink))));
		assert!(markup.contains(&format!(
			"@media (prefers-color-scheme:dark){{.d0{{stroke:{}}}}}",
			css_hex(Palette::DARK.ink)
		)));
	}

	#[test]
	fn fixed_tones_need_no_dark_rule() {
		let fixed = Ink {
			outline: Some(Tone::fixed(Palette::LIGHT.ink)),
			..ink(InkShape::Rule)
		};
		assert!(!image(&fixed).markup().contains("<style>"));
	}

	#[test]
	fn fills_paint_under_the_outline() {
		let theme = Theme::SKRIBBLE;
		let filled = ink(InkShape::Rectangle).filled(FillStyle::Solid, theme.accent());
		let markup = image(&filled).markup();
		let fill = markup.find("fill='#ffd43b'").expect("a solid fill");
		let outline = markup.find("stroke='#1f1d1a'").expect("an outline");
		assert!(fill < outline);
	}

	#[test]
	fn the_same_seed_draws_the_same_image() {
		assert_eq!(
			image(&ink(InkShape::Capsule)),
			image(&ink(InkShape::Capsule))
		);
		let other = Ink {
			seed: 4,
			..ink(InkShape::Capsule)
		};
		assert_ne!(image(&ink(InkShape::Capsule)), image(&other));
	}

	#[test]
	fn data_uris_escape_markup() {
		let uri = image(&ink(InkShape::Check)).data_uri();
		let body = uri
			.strip_prefix("data:image/svg+xml,")
			.expect("an SVG data URL");
		assert!(body.starts_with("%3Csvg"));
		assert!(!body.contains(['<', '>', '#', '"', ' ', '{', '}']));
		for (index, _) in body.match_indices('%') {
			let escape = &body[index + 1..index + 3];
			assert!(
				escape.bytes().all(|byte| byte.is_ascii_hexdigit()),
				"bad escape %{escape}"
			);
		}
	}
}
