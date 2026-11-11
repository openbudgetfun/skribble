# skribble_leptoskit_maps

Hand-drawn maps for [leptoskit](https://github.com/leptoskit/leptoskit) apps, from the [skribble](https://openbudgetfun.github.io/skribble/) design system: rough areas with hachure fills, round-capped routes, pastel pins, and sketched zoom controls.

leptoskit has no vector map engine, so this crate draws the map itself. There are no tiles, no network requests, and no map service to configure: a flat Web Mercator camera projects geographic coordinates into pixels, and [`skribble_rough`](https://github.com/openbudgetfun/skribble/tree/main/rust/rough) inks them as leptoskit `Vector` elements. The same tree renders on the web as inline SVG and on every native platform through its own path API.

## Install

The crate builds on the pinned leptoskit commit and skribble_leptoskit 0.1:

```toml
[dependencies]
leptoskit = { git = "https://github.com/leptoskit/leptoskit", rev = "1f7f1462a17a9a33eccb933909f6cdae20d03052" }
skribble_leptoskit = "0.1"
skribble_leptoskit_maps = "0.1"
```

<!-- {=leptoskitPatch} -->

These crates build and test against leptoskit `main` at `1f7f1462a17a9a33eccb933909f6cdae20d03052` (`feat: adopt Exact's performance budgets`). The pin is a git dependency on `leptoskit`, `leptoskit_native`, and `leptoskit_testing` in `[workspace.dependencies]` in the root [`Cargo.toml`](https://github.com/openbudgetfun/skribble/blob/main/Cargo.toml), not a `[patch]` override. Use that same rev for any of those crates you depend on directly so the graph stays on one checkout. It needs Rust 1.95 or later.

<!-- {/leptoskitPatch} -->

## Use it

A map takes its size in logical pixels and draws in that coordinate space:

```rust
use leptoskit::prelude::*;
use skribble_leptoskit_maps::*;

pub fn city_walk() -> Element {
	let start = LatLng::new(51.5074, -0.1278);
	let end = LatLng::new(51.5160, -0.1100);

	view! {
		<WiredMap
			camera=Camera::new(start, 14.0)
			width=360.0
			height=240.0
			features=vec![
				MapFeature::area(vec![
					LatLng::new(51.505, -0.135),
					LatLng::new(51.505, -0.120),
					LatLng::new(51.515, -0.125),
				]),
				MapFeature::route(vec![start, end]),
				MapFeature::point(start),
			]
			pins=vec![
				MapPin::new(start, "Start").with_category(PinCategory::Coffee),
				MapPin::new(end, "Finish"),
			]
			label="A sketched walking route"
		/>
	}
}
```

| Component              | Draws                                                          |
| ---------------------- | -------------------------------------------------------------- |
| `WiredMap`             | Paper, a faint graticule, and rough features and pins          |
| `WiredMapZoomControls` | Two hand-drawn buttons that propose a closer or further camera |

Areas get a rough outline and a light hachure fill; routes are round-capped lines with a slight wobble; points are little ink dots. Pins are cream sticker-edged markers with a pastel fill per category and an optional short label.

## Camera and projection

`Camera` keeps north up, so one flat [Web Mercator](https://en.wikipedia.org/wiki/Web_Mercator_projection) projection places everything:

```rust
use skribble_leptoskit_maps::{Camera, LatLng, LatLngBounds};

let camera = Camera::new(LatLng::new(51.5074, -0.1278), 12.0);
let (x, y) = camera.project(LatLng::new(51.5074, -0.1278), 320.0, 200.0);
assert!((x - 160.0).abs() < 0.01 && (y - 100.0).abs() < 0.01);

let back = camera.unproject(x, y, 320.0, 200.0);
assert!((back.lat - 51.5074).abs() < 0.001);
```

- Latitudes clamp to ±85.0511°, the projection's limit.
- Longitudes wrap into `-180..180`, so a feature across the antimeridian keeps its short shape.
- `Camera::fit(bounds, width, height, padding)` frames a `LatLngBounds` with breathing room and clamps the zoom to `MIN_ZOOM..=MAX_ZOOM`.

Features and pins outside the viewport are culled before they are drawn.

## Pins

`MapPin` anchors its tip to a coordinate, so the head never covers the place it marks.

```rust
use skribble_leptoskit_maps::{LatLng, MapPin, PinCategory};

let cafe = MapPin::new(LatLng::new(51.5074, -0.1278), "Favourite cafe")
	.with_category(PinCategory::Coffee)
	.with_on_press(|| println!("open the cafe"));
```

`PinCategory` covers `Place`, `CheckIn`, `Coffee`, `Market`, `Gallery`, `Favorite`, and `Person`, each with the pastel fill skribble's Flutter map pins use. With `on_press` a pin is a real button named by its label; without it the pin is an image named by its label, or decorative when the label is empty.

## Paper and zoom

`MapStyle` picks the background: `PAPER` is warm paper with a faint graticule, `DARK` is charcoal with chalk lines, and `PLAIN` has no grid. A map without a `background` uses `PAPER`, and every preset has a light and a dark appearance. A style can also carry its own `ink` for routes, outlines, and pin labels: `DARK` draws them in chalk so they read on charcoal, and the others use the theme's ink.

Zoom controls follow leptoskit's controlled pattern: they show the zoom you pass and propose a new one.

```rust
use leptoskit::prelude::*;
use skribble_leptoskit_maps::WiredMapZoomControls;

let controls = view! {
	<WiredMapZoomControls zoom=12.0 on_zoom=|next: f64| println!("zoom to {next}") />
};
```

Keep the camera in your own state, build it from the accepted zoom, and rebuild.

## Accessibility

- A map with a `label` is an image with that name. Without one the map itself is decorative, while pressable pins keep their own names.
- A pressable pin is a button, named by its label.
- A pin with a label but no action is an image with that name.
- Ink is always hidden from assistive technology.

## Platforms

| Where                               | What draws                                                                                            |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------- |
| Web                                 | Rough ink as inline SVG. Dark mode follows `prefers-color-scheme`, as leptoskit's `dark:` classes do. |
| macOS, iOS, Android, Windows, Linux | The same rough ink through leptoskit's `Vector` element, with each platform's own path API.           |

Ink paints with the element's text colour, set by `text-[…] dark:text-[…]` classes, so it recolours with the theme everywhere.

## Scope

The crate draws coordinates you already have. It does not fetch tiles, geocode addresses, calculate directions, or host map data. The `map` example server-renders a page of everything it draws:

```bash
cargo run -p skribble_leptoskit_maps --example map -- map.html
```
