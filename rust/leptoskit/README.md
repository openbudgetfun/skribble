# skribble_leptoskit

Hand-drawn [leptoskit](https://github.com/leptoskit/leptoskit) components from the [skribble](https://openbudgetfun.github.io/skribble/) design system: rough borders, sketched fills, pen marks, and doodles for an interface you write once in Rust and ship to the web and to native platforms.

The ink comes from [`skribble_rough`](https://github.com/openbudgetfun/skribble/tree/main/rust/rough), the Rust port of the engine skribble's Flutter widgets paint with, so the same seed draws the same wobble everywhere.

## Install

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

There is no feature to turn on: the same build draws the ink on the web and on every native platform.

## Use the components

```rust
use leptoskit::prelude::*;
use skribble_leptoskit::*;

pub fn welcome(on_start: impl Fn() + Send + Sync + 'static) -> Element {
	view! {
		<SkribblePage class="items-center gap-6 p-6">
			<WiredCard seed=3 class="gap-4">
				<View class="flex-row items-center gap-1">
					<Text class="text-2xl font-bold">"Draw it"</Text>
					<WiredHighlight kind=HighlightKind::Circle seed=5>
						<Text class="text-2xl font-bold">"differently"</Text>
					</WiredHighlight>
				</View>
				<WiredButton label="Start sketching" on_press=on_start />
			</WiredCard>
		</SkribblePage>
	}
}
```

| Component        | Draws                                                                |
| ---------------- | -------------------------------------------------------------------- |
| `SkribblePage`   | The theme's paper and ink behind a screen                            |
| `WiredBox`       | A rough rectangle around content, optionally filled                  |
| `WiredCard`      | A roomy box for grouped content                                      |
| `WiredCircle`    | A rough ellipse around content, for stickers and step numbers        |
| `WiredBadge`     | A small filled capsule for a status or count                         |
| `WiredButton`    | A real button with a rough border, filled when it is the primary one |
| `WiredInput`     | A platform text field inside a rough frame, plain or `secret`        |
| `WiredCheckbox`  | A rough square that gets a tick                                      |
| `WiredRadio`     | A rough circle that gets a dot                                       |
| `WiredSwitch`    | A rough capsule with a sliding knob                                  |
| `WiredProgress`  | A rough track that fills with hachure                                |
| `WiredHighlight` | An underline, circle, box, strike, or marker around text             |
| `WiredDivider`   | A rough horizontal rule                                              |
| `Sketch`         | Any `Shape` at an explicit size: arrows, scribbles, annotations      |

- Every component takes a `seed`. Give neighbours different seeds so their wobbles differ.
- Every component takes an optional `theme` and extra Tailwind `class`es. `Theme::SKRIBBLE` is the default: dark ink on warm paper with a yellow accent, and chalk on charcoal in dark mode.
- Controls follow leptoskit's controlled pattern: they show a value and propose changes through `on_toggle`, `on_select`, or `on_change`, and you rebuild with the value you accept.
- Ink is decorative and hidden from assistive technology. Buttons are real buttons; checkboxes, radios, switches, progress bars, and dividers carry their ARIA roles and states.

<!-- {=leptoskitInkRoom} -->

Buttons and controls are at least 44 pixels tall and grow with their text. Content keeps at least 12 pixels from the ink at the sides and 8 above and below. The padding also covers the few pixels the outline sits inside its component, which grow as the ink stretches, so `WiredBox` pads 20 at the sides and 12 above and below, and buttons and fields pad 12 above and below.

<!-- {/leptoskitInkRoom} -->

## Platforms

| Where                               | What draws                                                                                                                                        |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| Web                                 | Rough ink as inline SVG. Dark mode follows `prefers-color-scheme`, as leptoskit's `dark:` classes do. Server rendering is byte-stable for a seed. |
| macOS, iOS, Android, Windows, Linux | The same rough ink, drawn with each platform's own path API through leptoskit's `Vector` element. `Sketch` draws its doodles natively too.        |

The ink is a set of leptoskit `Vector` elements painted with the element's text colour, so `dark:` classes recolour it on every platform.

leptoskit has no font-family utility yet either, so the components use the platform's system font. On the web you can letter a page in Skribble Noto Sketch with your own CSS; the [leptoskit guide](https://openbudgetfun.github.io/skribble/guides/leptoskit) shows how.

## See it

`examples/notebook.rs` server-renders every component to a static page:

```bash
cargo run -p skribble_leptoskit --example notebook -- notebook.html
```

## License

MIT
