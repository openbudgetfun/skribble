# skribble_leptoskit

Hand-drawn [leptoskit](https://github.com/ifiokjr/leptoskit) components from the [skribble](https://openbudgetfun.github.io/skribble/) design system: rough borders, sketched fills, pen marks, and doodles for an interface you write once in Rust and ship to the web and to native platforms.

The ink comes from [`skribble_rough`](https://github.com/openbudgetfun/skribble/tree/main/rust/rough), the Rust port of the engine skribble's Flutter widgets paint with, so the same seed draws the same wobble everywhere.

## Install

Neither leptoskit nor this crate is on crates.io yet. Depend on both from Git, and pin this crate to a commit of skribble whose workspace pins the same leptoskit commit as your app (see `Cargo.toml` at the repository root):

```toml
[dependencies]
leptoskit = { git = "https://github.com/ifiokjr/leptoskit", rev = "ad19e75ab44b4d93807c5be1e565c769269d87d8" }
skribble_leptoskit = { git = "https://github.com/openbudgetfun/skribble", rev = "<commit>" }

[features]
web = ["leptoskit/web", "skribble_leptoskit/web"]
```

Turn on `skribble_leptoskit/web` in the feature your web build uses, as above. It draws the ink as SVG images, which leptoskit's web renderer shows. Native builds leave it off.

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
- Buttons and controls are at least 44 pixels tall and grow with their text. Content keeps 12 pixels from the ink at the sides and 8 above and below.
- Ink is decorative and hidden from assistive technology. Buttons are real buttons; checkboxes, radios, switches, progress bars, and dividers carry their ARIA roles and states.

## Platforms

| Where                               | What draws                                                                                                                                        |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| Web, with the `web` feature         | Rough ink as SVG images. Dark mode follows `prefers-color-scheme`, as leptoskit's `dark:` classes do. Server rendering is byte-stable for a seed. |
| macOS, iOS, Android, Windows, Linux | The same components, layout, colours, and line weight, with straight borders and flat fills. `Sketch` keeps its size and name but draws nothing.  |

Native leptoskit shows images only from files and has no way to draw paths yet. The difference lives in one internal module, so a future leptoskit drawing primitive brings the rough ink to native without changing any component.

leptoskit has no font-family utility yet either, so the components use the platform's system font. On the web you can letter a page in Skribble Noto Sketch with your own CSS; the [leptoskit guide](https://openbudgetfun.github.io/skribble/guides/leptoskit) shows how.

## See it

`examples/notebook.rs` server-renders every component to a static page:

```bash
cargo run -p skribble_leptoskit --example notebook --features web -- notebook.html
```

Leave out `--features web` to see the native drawing through the same renderer.

## License

MIT
