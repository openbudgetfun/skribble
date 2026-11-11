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

`skribble_leptoskit` builds on the pinned leptoskit commit:

```toml
[dependencies]
leptoskit = { git = "https://github.com/leptoskit/leptoskit", rev = "1f7f1462a17a9a33eccb933909f6cdae20d03052" }
skribble_leptoskit = "0.1"
```

<!-- {=leptoskitPatch} -->

These crates build and test against leptoskit `main` at `1f7f1462a17a9a33eccb933909f6cdae20d03052` (`feat: adopt Exact's performance budgets`). The pin is a git dependency on `leptoskit`, `leptoskit_native`, and `leptoskit_testing` in `[workspace.dependencies]` in the root [`Cargo.toml`](https://github.com/openbudgetfun/skribble/blob/main/Cargo.toml), not a `[patch]` override. Use that same rev for any of those crates you depend on directly so the graph stays on one checkout. It needs Rust 1.95 or later.

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

Closed shapes take a `fill_style`: `Hachure`, `CrossHatch`, `ZigZag`, `Dashed`, `Dots`, or `Solid`. On native, sketched patterns become a light tint of the fill colour and `Solid` stays solid.

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

Without a `label`, a sketch is decorative and hidden from screen readers. On native it keeps its size and label but draws nothing yet.

## 4. Theme it

Every component takes a `theme`. A `Theme` has a light and a dark `Palette` (`ink`, `paper`, `accent`, `on_accent`), a `stroke_width`, and a `roughness`. Start from skribble's and change what you need:

```rust
use leptoskit::native::Color;
use skribble_leptoskit::{Palette, Theme};

pub const MINT: Theme = Theme {
	light: Palette {
		accent: Color::rgba(0x8c, 0xe9, 0xc2, 0xff),
		..Palette::LIGHT
	},
	dark: Palette {
		accent: Color::rgba(0x4f, 0xb2, 0x8a, 0xff),
		..Palette::DARK
	},
	..Theme::SKRIBBLE
};
```

Pass it as `theme=MINT`. Fill colours (`fill=`) and highlight colours (`color=`) take a `Color` for both appearances or a `Tone` with one colour for each.

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
