---
title: Using skribble with leptoskit (Rust)
description: Hand-drawn components for leptoskit apps written once in Rust, with rough ink on the web and the same components on macOS, iOS, Android, Windows, and Linux.
---

# Using skribble with leptoskit (Rust)

[leptoskit](https://github.com/ifiokjr/leptoskit) lets you write an app's interface once in Rust and render it on the web and as native widgets on macOS, iOS, Android, Windows, and Linux. [`skribble_leptoskit`](https://github.com/openbudgetfun/skribble/tree/main/rust/leptoskit) gives that interface skribble's hand-drawn look: rough borders, sketched fills, pen marks around text, and doodles.

The ink comes from [`skribble_rough`](https://github.com/openbudgetfun/skribble/tree/main/rust/rough), a Rust port of the pure-Dart [rough engine](../core/rough-engine). It draws byte-identical SVG to the Dart engine, so a seed wobbles the same in a leptoskit app as in a Flutter app, a [Jaspr site](jaspr), or a [JavaScript project](javascript).

## What you get on each platform

| Platform                            | What the components draw                                                                                                |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| Web                                 | Rough ink, drawn as SVG images. Dark mode follows the browser, as leptoskit's `dark:` classes do.                       |
| macOS, iOS, Android, Windows, Linux | The same components with the same layout, colours, and line weight, but straight borders and flat fills instead of ink. |

leptoskit's native renderers can show images only from files and cannot draw paths yet, so native apps get the plain version for now. Your code is the same on every platform: a screen built from these components works everywhere, and gets the rough ink natively as soon as leptoskit can draw it.

## 1. Install

leptoskit is not on crates.io yet, so neither is `skribble_leptoskit`. Depend on both from Git. Each skribble commit pins one leptoskit commit in its root `Cargo.toml`; use that commit for `leptoskit` so your app and the components build against the same version:

```toml
[dependencies]
leptoskit = { git = "https://github.com/ifiokjr/leptoskit", rev = "ad19e75ab44b4d93807c5be1e565c769269d87d8" }
skribble_leptoskit = { git = "https://github.com/openbudgetfun/skribble", rev = "<skribble commit>" }
```

Then turn on the crate's `web` feature in your app's web build. If your app has a `web` feature, add it there:

```toml
[features]
web = ["leptoskit/web", "skribble_leptoskit/web"]
```

Without the feature, the components draw their native version, which is what you want in native builds.

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

The label is visible and names the control for screen readers, and the whole row responds to a press. Put the radios of one choice in a `View` with `role=Role::RadioGroup` and an `aria_label`, so screen readers announce them as a set. Buttons and controls are at least 44 pixels tall and grow with their text.

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

Components cannot measure themselves, so each draws its ink into a box near its usual proportions and stretches it to fit, with strokes kept at their width. Very wide or tall components stretch the wobble with them. The ink is a decorative image (`aria-hidden`, empty `alt`); names and states come from the components themselves.

Each image carries its dark colours in a `prefers-color-scheme` rule, so the ink switches with the page and needs no JavaScript.

## See every component

The crate's `notebook` example server-renders every component to a static page:

```bash
cargo run -p skribble_leptoskit --example notebook --features web -- notebook.html
```

Leave out `--features web` to see what native builds draw, through the same renderer.

## Drawing with the engine directly

`skribble_rough` works anywhere Rust does, including servers and `wasm32`. `sketch` returns SVG paths with their colours and widths; the lower-level `Generator`, `Filler`, `RoughPen`, and `DrawableInk` mirror the Dart engine. See its [README](https://github.com/openbudgetfun/skribble/tree/main/rust/rough).

```rust
use skribble_rough::{sketch, Shape, SketchOptions};

let options = SketchOptions { fill: Some("#ffd43b".to_owned()), ..SketchOptions::default() };
let badge = sketch(&[Shape::ellipse(50.0, 50.0, 90.0, 90.0)], &options)?;
let svg = badge.to_svg_string(100.0, 100.0, Some("A sketched badge"));
```
