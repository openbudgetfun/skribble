//! Hand-drawn leptoskit components from the skribble design system.
//!
//! Rough borders, sketched fills, pen marks, and doodles for apps written
//! once with leptoskit. The ink comes from [`skribble_rough`], the Rust port
//! of the engine skribble's Flutter widgets paint with, so the same seed
//! draws the same wobble everywhere.
//!
//! ```
//! use leptoskit::prelude::*;
//! use skribble_leptoskit::*;
//!
//! pub fn welcome(on_start: impl Fn() + Send + Sync + 'static) -> Element {
//! 	view! {
//! 		<SkribblePage class="items-center gap-6 p-6">
//! 			<WiredCard seed=3 class="gap-4">
//! 				<View class="flex-row items-center gap-1">
//! 					<Text class="text-2xl font-bold">"Draw it"</Text>
//! 					<WiredHighlight kind=HighlightKind::Circle seed=5>
//! 						<Text class="text-2xl font-bold">"differently"</Text>
//! 					</WiredHighlight>
//! 				</View>
//! 				<WiredButton label="Start sketching" on_press=on_start />
//! 			</WiredCard>
//! 		</SkribblePage>
//! 	}
//! }
//! # let _ = welcome(|| {});
//! ```
//!
//! # Components
//!
//! | Component                             | Draws                                                             |
//! | ------------------------------------- | ----------------------------------------------------------------- |
//! | [`SkribblePage`](fn@SkribblePage)     | The theme's paper and ink behind a screen                         |
//! | [`WiredBox`](fn@WiredBox)             | A rough rectangle around content, optionally filled               |
//! | [`WiredCard`](fn@WiredCard)           | A roomy box for grouped content                                   |
//! | [`WiredCircle`](fn@WiredCircle)       | A rough ellipse around content, for stickers and step numbers     |
//! | [`WiredBadge`](fn@WiredBadge)         | A small filled capsule for a status or count                      |
//! | [`WiredButton`](fn@WiredButton)       | A button with a rough border, filled when it is the primary one   |
//! | [`WiredInput`](fn@WiredInput)         | A platform text field inside a rough frame                        |
//! | [`WiredCheckbox`](fn@WiredCheckbox)   | A rough square that gets a tick                                   |
//! | [`WiredRadio`](fn@WiredRadio)         | A rough circle that gets a dot                                    |
//! | [`WiredSwitch`](fn@WiredSwitch)       | A rough capsule with a sliding knob                               |
//! | [`WiredProgress`](fn@WiredProgress)   | A rough track that fills with hachure                             |
//! | [`WiredHighlight`](fn@WiredHighlight) | An underline, circle, box, strike, or marker around text          |
//! | [`WiredDivider`](fn@WiredDivider)     | A rough horizontal rule                                           |
//! | [`Sketch`](fn@Sketch)                 | Any [`Shape`] at an explicit size: arrows, scribbles, annotations |
//!
//! Every component takes a `seed` (give neighbours different ones so their
//! wobbles differ), an optional [`Theme`], and extra Tailwind `class`es.
//! Controls follow leptoskit's controlled pattern: they show a value and
//! propose changes through a callback, and you rebuild with the accepted
//! value.
//!
//! # Platforms
//!
//! The ink is drawn as leptoskit `Vector` elements, which the web renderer
//! shows as inline SVG and every native backend (macOS, iOS, Android,
//! Windows, Linux) draws through its own path API. Every platform gets the
//! same rough strokes and sketched fills. Ink paints with the element's text
//! colour, so dark mode follows leptoskit's `dark:` classes everywhere, and
//! no feature needs turning on.

mod button;
mod container;
mod divider;
mod highlight;
mod ink;
mod input;
mod progress;
mod sketch;
mod theme;
mod toggle;

pub use button::ButtonVariant;
pub use button::WiredButton;
pub use container::SkribblePage;
pub use container::WiredBadge;
pub use container::WiredBox;
pub use container::WiredCard;
pub use container::WiredCircle;
pub use divider::WiredDivider;
pub use highlight::HighlightKind;
pub use highlight::WiredHighlight;
pub use input::WiredInput;
pub use progress::WiredProgress;
pub use sketch::Sketch;
pub use skribble_rough as rough;
pub use skribble_rough::FillStyle;
pub use skribble_rough::Point;
pub use skribble_rough::RoughPen;
pub use skribble_rough::Shape;
pub use theme::Palette;
pub use theme::Theme;
pub use theme::Tone;
pub use toggle::WiredCheckbox;
pub use toggle::WiredRadio;
pub use toggle::WiredSwitch;
