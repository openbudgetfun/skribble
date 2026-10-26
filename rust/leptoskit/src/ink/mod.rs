//! The hand-drawn layer behind every component.
//!
//! A component describes its ink as an [`Ink`] and puts [`Ink::layer`] first
//! among its children, so its content paints on top. The layer fills its
//! parent and draws one of two ways:
//!
//! - With the `web` feature, as a decorative SVG image of rough strokes from
//!   [`skribble_rough`], which leptoskit's web renderer shows as an `<img>`.
//! - Without it, as plain views with borders and backgrounds in the same
//!   colours, because native leptoskit can show images only from files and
//!   has no way to draw paths yet.
//!
//! Only this module knows the difference, so a future leptoskit drawing
//! primitive can bring the rough strokes to native without touching any
//! component.

mod plain;
mod svg;

use leptoskit::native::Element;
use skribble_rough::FillStyle;

pub(crate) use self::svg::SvgImage;
pub(crate) use self::svg::SvgPaint;
pub(crate) use self::svg::SvgPath;
use crate::Theme;
use crate::Tone;

/// What an ink layer draws, in the space of its parent.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(crate) enum InkShape {
	/// A rough rectangle around the parent.
	Rectangle,
	/// A rough capsule: a rectangle whose short sides are half circles.
	Capsule,
	/// A rough ellipse touching the middle of each side.
	Ellipse,
	/// A rough horizontal line across the middle.
	Rule,
	/// A rough horizontal line along the bottom.
	Underline,
	/// A rough tick.
	Check,
}

/// The nominal space ink is drawn in before it stretches to its parent.
///
/// Components cannot measure themselves, so each draws into a box near its
/// usual proportions; the closer the box, the less the wobble stretches.
#[derive(Debug, Clone, Copy, PartialEq)]
pub(crate) struct Canvas {
	/// Nominal width.
	pub(crate) width: f64,
	/// Nominal height.
	pub(crate) height: f64,
	/// Distance from the edge to the ideal outline, which leaves room for the
	/// wobble.
	pub(crate) inset: f64,
	/// Distance between sketched fill lines.
	pub(crate) gap: f64,
}

impl Canvas {
	/// A canvas with skribble's default inset and hachure gap.
	pub(crate) const fn new(width: f64, height: f64) -> Self {
		Self {
			width,
			height,
			inset: 3.0,
			gap: 8.0,
		}
	}

	/// This canvas with the outline `inset` from its edges.
	pub(crate) const fn inset(self, inset: f64) -> Self {
		Self { inset, ..self }
	}

	/// This canvas with fill lines `gap` apart.
	pub(crate) const fn gap(self, gap: f64) -> Self {
		Self { gap, ..self }
	}
}

/// A fill pattern and the tone it is drawn in.
#[derive(Debug, Clone, Copy, PartialEq)]
pub(crate) struct InkFill {
	pub(crate) style: FillStyle,
	pub(crate) tone: Tone,
}

/// One hand-drawn layer: a shape, its outline, and its fill.
#[derive(Debug, Clone, Copy, PartialEq)]
pub(crate) struct Ink {
	pub(crate) shape: InkShape,
	pub(crate) canvas: Canvas,
	pub(crate) seed: i64,
	/// The outline tone, or `None` for a fill without an outline.
	pub(crate) outline: Option<Tone>,
	/// The fill, or `None` for an outline alone.
	pub(crate) fill: Option<InkFill>,
	pub(crate) theme: Theme,
}

/// How the current build draws ink.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(crate) enum InkTarget {
	/// Rough strokes in an SVG image, for leptoskit's web renderer.
	SvgImage,
	/// Borders and backgrounds on plain views, for native.
	PlainViews,
}

impl InkTarget {
	/// The target this build was compiled for.
	pub(crate) const ACTIVE: Self = if cfg!(feature = "web") {
		Self::SvgImage
	} else {
		Self::PlainViews
	};
}

impl Ink {
	/// An outline in the theme's ink, without a fill.
	pub(crate) fn outline(shape: InkShape, canvas: Canvas, seed: i64, theme: Theme) -> Self {
		Self {
			shape,
			canvas,
			seed,
			outline: Some(theme.ink()),
			fill: None,
			theme,
		}
	}

	/// This ink filled with `style` in `tone`; [`FillStyle::None`] removes the
	/// fill.
	pub(crate) fn filled(self, style: FillStyle, tone: Tone) -> Self {
		let fill = (style != FillStyle::None).then_some(InkFill { style, tone });
		Self { fill, ..self }
	}

	/// This ink without its outline.
	pub(crate) fn without_outline(self) -> Self {
		Self {
			outline: None,
			..self
		}
	}

	/// The decorative layer that draws this ink behind its parent's content.
	/// Put it first among the parent's children.
	pub(crate) fn layer(&self) -> Element {
		self.layer_for(InkTarget::ACTIVE)
	}

	/// The layer as `target` draws it.
	pub(crate) fn layer_for(&self, target: InkTarget) -> Element {
		match target {
			InkTarget::SvgImage => svg::layer(self),
			InkTarget::PlainViews => plain::layer(self),
		}
	}
}
