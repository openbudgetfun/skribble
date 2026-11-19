---
title: Using skribble with leptoskit (Rust)
description: leptoskit apps get skribble's hand-drawn components, charts, and maps from leptoskit's own leptoskit_skribble crate, built on skribble_core.
---

# Using skribble with leptoskit (Rust)

[leptoskit](https://github.com/leptoskit/leptoskit) lets you write an app's interface once in Rust and render it on the web and as native widgets on macOS, iOS, Android, Windows, and Linux. Its [`leptoskit_skribble`](https://github.com/leptoskit/leptoskit/tree/main/crates/leptoskit_skribble) crate gives that interface skribble's hand-drawn look: rough borders, sketched fills, pen marks around text, scribbles, charts, and maps, drawn with leptoskit's `Vector` element on every platform.

The integration lives in the leptoskit repository so it can follow leptoskit's fast-moving API, and it builds on [`skribble_core`](rust), skribble's framework-free design system for Rust. skribble supplies the colours, the component ink, the charts, and the maps; leptoskit turns them into components.

## Install

Add `leptoskit_skribble` from the leptoskit repository. Once leptoskit publishes it to crates.io, depend on its version there instead.

```toml
[dependencies]
leptoskit_skribble = { git = "https://github.com/leptoskit/leptoskit" }
```

Its documentation lists every component, chart, and map, and its `ink` module renders any `skribble_core` drawing as leptoskit elements. Read it in the [crate's README](https://github.com/leptoskit/leptoskit/tree/main/crates/leptoskit_skribble).

```rust
use leptoskit::prelude::*;
// leptoskit's prelude has a `Theme` of its own, so name skribble's.
use leptoskit_skribble::Theme;
use leptoskit_skribble::*;

pub fn welcome(on_start: impl Fn() + Send + Sync + 'static) -> Element {
	let theme = Theme::SKRIBBLE;
	view! {
		<SkribblePage class="items-center gap-6 p-6">
			<WiredCard seed=3 fill_style=FillStyle::Solid fill=theme.accent_at(0) class="gap-4">
				<WiredHighlight kind=HighlightKind::Marker seed=5>
					<Text class="text-2xl font-bold">"Draw it differently"</Text>
				</WiredHighlight>
				<WiredButton label="Start sketching" on_press=on_start />
			</WiredCard>
		</SkribblePage>
	}
}
```

## Moving from `skribble_leptoskit`

The `skribble_leptoskit`, `skribble_leptoskit_charts`, and `skribble_leptoskit_maps` crates published from this repository are replaced by `leptoskit_skribble`. The components keep their names, so most apps only change their imports:

| Before                                | After                                  |
| ------------------------------------- | -------------------------------------- |
| `use skribble_leptoskit::*;`          | `use leptoskit_skribble::*;`           |
| `use skribble_leptoskit_charts::...;` | `use leptoskit_skribble::charts::...;` |
| `use skribble_leptoskit_maps::...;`   | `use leptoskit_skribble::maps::...;`   |
| `skribble_leptoskit::colorway`        | `skribble_core::colorway`              |

leptoskit's prelude has a `Theme` of its own, so a file that glob-imports both preludes names skribble's with `use leptoskit_skribble::Theme;`.

Colours are now `skribble_core::colorway::Rgba` values everywhere a `Tone` or `Palette` takes one, so there is no `color(rgba)` conversion to make.
