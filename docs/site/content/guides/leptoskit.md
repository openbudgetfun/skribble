---
title: Using skribble with leptoskit (Rust)
description: Hand-drawn components for leptoskit apps written once in Rust, with the same rough ink on the web, macOS, iOS, Android, Windows, and Linux.
---

# Using skribble with leptoskit (Rust)

[leptoskit](https://github.com/leptoskit/leptoskit) lets you write an app's interface once in Rust and render it on the web and as native widgets on macOS, iOS, Android, Windows, and Linux. [`skribble_leptoskit`](https://github.com/openbudgetfun/skribble/tree/main/rust/leptoskit) gives that interface skribble's hand-drawn look: rough borders, sketched fills, pen marks around text, and doodles.

The ink comes from [`skribble_rough`](https://github.com/openbudgetfun/skribble/tree/main/rust/rough), a Rust port of the pure-Dart [rough engine](../core/rough-engine). It draws byte-identical SVG to the Dart engine, so a seed wobbles the same in a leptoskit app as in a Flutter app, a [Jaspr site](jaspr), or a [JavaScript project](javascript).

## What you get on each platform

| Platform                            | What the components draw                                                                          |
| ----------------------------------- | ------------------------------------------------------------------------------------------------- |
| Web                                 | Rough ink, drawn as inline SVG. Dark mode follows the browser, as leptoskit's `dark:` classes do. |
| macOS, iOS, Android, Windows, Linux | The same rough ink, drawn with the platform's own path API.                                       |

The components draw their ink with leptoskit's `Vector` element, which every backend draws natively, so your code and its drawing are the same on every platform.

## 1. Install

`skribble_leptoskit` builds on leptoskit 0.3:

```toml
[dependencies]
leptoskit = "0.3"
skribble_leptoskit = "0.1"
```

<!-- {=leptoskitPatch} -->

The leptoskit requirements above stay crates.io ranges so you stay free to choose your own leptoskit commit, but the skribble Rust crates build and test against leptoskit's `main`, which runs ahead of the 0.3 releases on crates.io. Bring the same commit into your build with a `[patch.crates-io]` section in your root `Cargo.toml`: cargo applies `[patch]` sections only from the workspace root, so a patch inside a dependency never reaches you. Keep every entry at the same rev, in step with the rev pinned in [`Cargo.toml`](https://github.com/openbudgetfun/skribble/blob/main/Cargo.toml) at the root of the skribble repository at the commit you depend on, and give any leptoskit crate you depend on directly that same rev, so the graph holds one leptoskit checkout. The rev below needs Rust 1.95 or later.

```toml
[patch.crates-io]
leptoskit = { git = "https://github.com/leptoskit/leptoskit", rev = "a93214edc8e5f6c7999c628285093f15cf188639" }
leptoskit_native = { git = "https://github.com/leptoskit/leptoskit", rev = "a93214edc8e5f6c7999c628285093f15cf188639" }
leptoskit_testing = { git = "https://github.com/leptoskit/leptoskit", rev = "a93214edc8e5f6c7999c628285093f15cf188639" }
```

<!-- {/leptoskitPatch} -->

There is no feature to turn on: web and native builds draw the same ink.

## 2. Build a screen

The components work with leptoskit's `view!` markup and with its builder functions, alongside `View`, `Text`, and the other built-in components.

```rust
use leptoskit::prelude::*;
use skribble_leptoskit::*;

pub fn welcome(name: &str, on_start: impl Fn() + Send + Sync + 'static) -> Element {
	view! {
		<SkribblePage class="items-center gap-6 p-6">
			<WiredCard seed=3 class="w-full max-w-[420px]">
				<View class="flex-row items-center gap-1">
					<Text class="text-2xl font-bold">"Draw it"</Text>
					<WiredHighlight kind=HighlightKind::Circle seed=5>
						<Text class="text-2xl font-bold">"differently"</Text>
					</WiredHighlight>
				</View>
				<Text>"Welcome back, " {name.to_owned()}</Text>
				<WiredButton label="Start sketching" on_press=on_start />
			</WiredCard>
		</SkribblePage>
	}
}
```

`SkribblePage` paints the theme's paper behind the screen and sets the ink as the text colour. Give neighbouring components different `seed`s so their wobbles differ; the same seed always draws the same shape, so server-rendered pages are identical on every build.

## 3. The components

| Component        | Use it for                                                                              |
| ---------------- | --------------------------------------------------------------------------------------- |
| `WiredBox`       | Any content inside a rough rectangle, optionally filled with a sketched pattern         |
| `WiredCard`      | Grouped content with more room around it                                                |
| `WiredCircle`    | Stickers and step numbers inside a rough ellipse                                        |
| `WiredBadge`     | A short status or count in a filled capsule                                             |
| `WiredButton`    | Actions. `ButtonVariant::Primary` is filled with the accent; `Secondary` is an outline  |
| `WiredInput`     | Text entry in the platform's own field, inside a rough frame. `secret` masks passwords  |
| `WiredCheckbox`  | A yes-or-no choice: a rough square that gets a tick                                     |
| `WiredRadio`     | One choice from a few: a rough circle that gets a dot                                   |
| `WiredSwitch`    | A setting that takes effect at once: a capsule with a sliding knob                      |
| `WiredProgress`  | How much of a task is done, as a track filling with hachure                             |
| `WiredHighlight` | Marking text with an underline, circle, box, strike, or highlighter                     |
| `WiredDivider`   | Separating sections with a rough rule                                                   |
| `Sketch`         | Arrows, scribbles, and annotations: any shape from the rough engine at an explicit size |

Closed shapes take a `fill_style`: `Hachure`, `CrossHatch`, `ZigZag`, `Dashed`, `Dots`, or `Solid`, drawn the same on the web and on native. Boxes, cards, and circles fill with the theme's marker unless you pass a `fill`; badges fill with the accent. A solid fill picks whichever of the ink and paper reads on it for the text inside, so labels stay at 4.5:1 or better in both appearances.

### Controls hold no state

Checkboxes, radios, switches, and inputs follow leptoskit's controlled pattern. They show the value you pass and propose a change through a callback; you store the value and rebuild:

```rust
use std::sync::Arc;
use std::sync::atomic::{AtomicBool, Ordering};

use leptoskit::prelude::*;
use skribble_leptoskit::WiredSwitch;

pub fn settings(dark: &Arc<AtomicBool>, rebuild: impl Fn() + Send + Sync + 'static) -> Element {
	let state = Arc::clone(dark);
	view! {
		<WiredSwitch
			label="Dark paper"
			on=dark.load(Ordering::SeqCst)
			on_toggle=move |on: bool| {
				state.store(on, Ordering::SeqCst);
				rebuild();
			}
		/>
	}
}
```

The label is visible and names the control for screen readers, and the whole row responds to a press. Put the radios of one choice in a `View` with `role=Role::RadioGroup` and an `aria_label`, so screen readers announce them as a set.

<!-- {=leptoskitInkRoom} -->

Buttons and controls are at least 44 pixels tall and grow with their text. Content keeps at least 12 pixels from the ink at the sides and 8 above and below. The padding also covers the few pixels the outline sits inside its component, which grow as the ink stretches, so `WiredBox` pads 20 at the sides and 12 above and below, and buttons and fields pad 12 above and below.

<!-- {/leptoskitInkRoom} -->

### Doodles

`Sketch` draws shapes from `skribble_rough` with the pen's tapered ink, in its own coordinates:

```rust
use leptoskit::prelude::*;
use skribble_leptoskit::{Shape, Sketch};

pub fn arrow() -> Element {
	view! {
		<Sketch
			width=120.0
			height=60.0
			shapes=vec![Shape::curve([(4.0, 50.0), (40.0, 10.0), (80.0, 40.0), (116.0, 12.0)]).with_arrowhead()]
			label="Points to the sign-up form"
		/>
	}
}
```

Without a `label`, a sketch is decorative and hidden from screen readers. It draws the same doodle on the web and on every native platform.

## 4. Colour it

skribble is a sticker book, not a pencil sketch on grey paper (see [Vivid and alive](vivid-design)). The default `Theme` is the sunny colourway, the same one the Flutter widgets and `skribble_jaspr` use: plum ink on warm paper, paper ink on a plum night in dark mode, a sunshine marker, a tomato accent, and six washes for colour-coding content. Outlines are 1.6 pixels wide with playful roughness.

| Role        | Used by                                                                                       |
| ----------- | --------------------------------------------------------------------------------------------- |
| `ink`       | Outlines, running text, pen marks                                                             |
| `paper`     | `SkribblePage`'s background                                                                   |
| `marker`    | Marker highlights, switch tracks, progress, and the default fill of boxes, cards, and circles |
| `accent`    | The primary `WiredButton` and `WiredBadge`: the one loud action on a screen                   |
| `washes`    | Colour-coding, read with `theme.accent_at(index)`                                             |
| `muted_ink` | Disabled labels                                                                               |

Give each screen one primary button, and colour-code runs of content with `accent_at`, so five cards are five colours:

```rust
use leptoskit::prelude::*;
use skribble_leptoskit::{FillStyle, Theme, WiredCard};

fn cards(titles: &[&'static str]) -> Fragment {
	let theme = Theme::SKRIBBLE;
	titles
		.iter()
		.enumerate()
		.map(|(index, title)| view! {
			<WiredCard seed=index as i64 fill_style=FillStyle::Solid fill=theme.accent_at(index)>
				<Text class="text-lg font-bold">{*title}</Text>
			</WiredCard>
		})
		.collect()
}
```

Labels on a wash use `theme.on(wash)`, which picks the ink or paper with the better contrast in each appearance. Components do this for you on solid fills.

Pick another colourway with `Theme::colorway`: `Sunny` (the default), `Berry`, `Ocean`, `Citrus`, or `Quiet` for briefs that ask for calm. Every component takes a `theme`, and a `Theme` is a light and a dark `Palette`, a `stroke_width`, and a `roughness`, so you can also start from one and change what you need:

```rust
use skribble_leptoskit::colorway::{Colorway, swatch};
use skribble_leptoskit::{Palette, Theme, color};

pub const BERRY: Theme = Theme::colorway(Colorway::Berry);

pub const MINT_ACTIONS: Theme = Theme {
	light: Palette { accent: color(swatch::MINT), ..Palette::LIGHT },
	dark: Palette { accent: color(swatch::MINT), ..Palette::DARK },
	..Theme::SKRIBBLE
};
```

Pass it as `theme=BERRY`. Fill colours (`fill=`) and highlight colours (`color=`) take a `Color` for both appearances or a `Tone` with one colour for each.

The colours themselves live in `skribble_leptoskit::colorway`, which has no leptoskit types: an `Rgba` colour, the named `swatch`es (the same values as Flutter's `WiredPalette`), the `Colorway`s, and WCAG contrast helpers. `color(rgba)` turns one into a leptoskit `Color`.

## 5. Letter it in Noto Sketch (web)

leptoskit has no font-family utility yet, so the components use the platform's system font. On the web you can letter the page in Skribble Noto Sketch, skribble's default typeface, with your own CSS. Self-host [`SkribbleNotoSketch-Regular.ttf`](https://github.com/openbudgetfun/skribble/tree/main/packages/skribble_font_noto_sketch/assets/fonts) and add:

```css
@font-face {
  font-family: "SkribbleNotoSketch";
  src: url("/fonts/SkribbleNotoSketch-Regular.ttf") format("truetype");
}
body * {
  font-family: "SkribbleNotoSketch", "Segoe Print", "Bradley Hand", cursive;
}
```

The rule targets every element because leptoskit sets the system font on its root view.

## How the web ink works

Components cannot measure themselves, so each draws its ink into a box near its usual proportions and stretches it to fit, with strokes kept at their width. Very wide or tall components stretch the wobble with them. The ink is decorative (`aria-hidden`); names and states come from the components themselves.

The ink paints with its element's text colour, set by a `text-[…] dark:text-[…]` class, so it switches with the theme on every platform and needs no JavaScript on the web.

## See every component

The crate's `notebook` example server-renders every component to a static page:

```bash
cargo run -p skribble_leptoskit --example notebook -- notebook.html
```

## Drawing with the engine directly

`skribble_rough` works anywhere Rust does, including servers and `wasm32`. `sketch` returns SVG paths with their colours and widths, or an error for a shape it cannot draw; the lower-level `Generator`, `Filler`, `RoughPen`, and `DrawableInk` mirror the Dart engine and finish on degenerate input, drawing nothing for an empty or reversed arc. See its [README](https://github.com/openbudgetfun/skribble/tree/main/rust/rough).

```rust
use skribble_rough::{sketch, Shape, SketchOptions};

let options = SketchOptions { fill: Some("#ffd43b".to_owned()), ..SketchOptions::default() };
let badge = sketch(&[Shape::ellipse(50.0, 50.0, 90.0, 90.0)], &options)?;
let svg = badge.to_svg_string(100.0, 100.0, Some("A sketched badge"));
```

## Charts

[`skribble_leptoskit_charts`](https://github.com/openbudgetfun/skribble/tree/main/rust/leptoskit_charts) adds hand-drawn financial charts to leptoskit: candlesticks, OHLC bars, lines, areas, volume bars, SMA, EMA, Bollinger Bands, RSI, and MACD. Price geometry stays exact, and the chart ink follows the same light and dark theme as the components. See [skribble charts for leptoskit](/guides/leptoskit-charts).
