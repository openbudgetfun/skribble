//! skribble's hand-drawn design system for Rust, free of any UI framework.
//!
//! This crate holds the primitives every Rust renderer of skribble shares:
//! the [colourways](colorway) and [`Theme`], the ink behind each
//! [component](components), freehand [`Scribble`]s, [`charts`], and
//! [`maps`]. Everything ends in an [`InkDrawing`]: SVG path data plus a
//! light and dark [`Tone`] for each path. A framework adapter turns that into
//! its own vector elements, and anything else can call
//! [`InkDrawing::to_svg`].
//!
//! The ink comes from [`skribble_rough`] (re-exported as [`rough`]), the Rust
//! port of the engine skribble's Flutter widgets paint with, so the same seed
//! draws the same wobble everywhere.
//!
//! ```
//! use skribble_core::Theme;
//! use skribble_core::colorway::Appearance;
//! use skribble_core::colorway::Colorway;
//! use skribble_core::components;
//! use skribble_core::components::ButtonVariant;
//!
//! let theme = Theme::colorway(Colorway::Berry);
//! let save = components::button(ButtonVariant::Primary, 3, theme);
//! let svg = save.drawing().to_svg(Appearance::Light);
//! assert!(svg.contains("<path"));
//! ```
//!
//! # Adapters
//!
//! skribble does not ship UI components for a Rust framework itself; each
//! framework integrates these primitives on its own schedule. leptoskit's
//! integration lives in the leptoskit repository as `leptoskit_skribble`.
//! An adapter usually needs three things:
//!
//! - a way to paint an [`InkDrawing`]: one vector element per
//!   [`InkDrawing::runs`] entry, coloured with the run's [`Tone`];
//! - a way to switch a [`Tone`] with the host's light or dark appearance;
//! - layout, events, and accessibility for each component, drawing the
//!   [`components`] recipe behind its content.

pub mod charts;
pub mod colorway;
pub mod components;
mod drawing;
mod ink;
pub mod maps;
mod scribble;
mod theme;

pub use drawing::InkDrawing;
pub use drawing::InkPaint;
pub use drawing::InkPath;
pub use drawing::InkRun;
pub use drawing::InkScaling;
pub use ink::Canvas;
pub use ink::Ink;
pub use ink::InkFill;
pub use ink::InkShape;
pub use scribble::Scribble;
pub use scribble::ScribbleError;
pub use skribble_rough as rough;
pub use skribble_rough::FillStyle;
pub use skribble_rough::Point;
pub use skribble_rough::RoughPen;
pub use skribble_rough::Shape;
pub use theme::Palette;
pub use theme::Theme;
pub use theme::Tone;
