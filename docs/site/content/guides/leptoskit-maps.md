---
title: Hand-drawn maps with skribble and leptoskit (Rust)
description: Vector maps with rough areas, routes, pins, and zoom controls for leptoskit apps, drawn by hand without tiles or network requests.
---

# Hand-drawn maps with skribble and leptoskit (Rust)

[`skribble_leptoskit_maps`](https://github.com/openbudgetfun/skribble/tree/main/rust/leptoskit_maps) adds maps to [leptoskit](https://github.com/ifiokjr/leptoskit) apps: rough areas with hachure fills, round-capped routes, pastel pins, and hand-drawn zoom controls.

leptoskit has no vector map engine, so this crate draws the map itself. There are no tiles, no network requests, and no map service to configure. A flat Web Mercator camera turns geographic coordinates into pixels, and [`skribble_rough`](https://github.com/openbudgetfun/skribble/tree/main/rust/rough) inks them as leptoskit `Vector` elements, so the same tree renders on the web and on every native platform.

## What you get

| Where                               | What the map draws                                                                         |
| ----------------------------------- | ------------------------------------------------------------------------------------------ |
| Web                                 | Rough ink as inline SVG. Dark mode follows the browser, as leptoskit's `dark:` classes do. |
| macOS, iOS, Android, Windows, Linux | The same rough ink, drawn with each platform's own path API.                               |

Everything the map draws is a coordinate you already have. The crate does not fetch tiles, geocode addresses, calculate directions, or host map data.

## 1. Install

The crate builds on leptoskit 0.3 and skribble_leptoskit 0.1:

```toml
[dependencies]
leptoskit = "0.3"
skribble_leptoskit = "0.1"
skribble_leptoskit_maps = "0.1"
```

## 2. Draw a map

A map takes its width and height in logical pixels and draws in that coordinate space, so features and pins never drift from one another.

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

| Component              | Use it for                                                     |
| ---------------------- | -------------------------------------------------------------- |
| `WiredMap`             | Paper, a faint graticule, rough features, and pins             |
| `WiredMapZoomControls` | Two hand-drawn buttons that propose a closer or further camera |

Areas get a rough outline and a light hachure fill. Routes are round-capped lines with a slight wobble. Points are small ink dots. Pins are cream sticker-edged markers with a pastel fill for their category and an optional short label under the tip.

Features and pins outside the viewport are culled before they are drawn, so a large data set stays cheap as long as its coordinates are spread out.

## 3. Camera and projection

`Camera` keeps north up, so one flat Web Mercator projection places everything. Project a coordinate to place your own content, or unproject a pointer position to learn where it landed.

```rust
use skribble_leptoskit_maps::{Camera, LatLng};

let camera = Camera::new(LatLng::new(51.5074, -0.1278), 12.0);
let (x, y) = camera.project(LatLng::new(51.5074, -0.1278), 320.0, 200.0);
assert!((x - 160.0).abs() < 0.01 && (y - 100.0).abs() < 0.01);

let back = camera.unproject(x, y, 320.0, 200.0);
assert!((back.lat - 51.5074).abs() < 0.001);
```

- Latitudes clamp to ±85.0511°, the projection's limit, so the poles land at the edge of the square world.
- Longitudes wrap into `-180..180`, so a feature across the antimeridian keeps its short shape.
- `Camera::fit(bounds, width, height, padding)` frames a `LatLngBounds` with breathing room around every corner and clamps the zoom to `MIN_ZOOM..=MAX_ZOOM`.

## 4. Pins

`MapPin` anchors its tip to the coordinate, so the head never covers the place it marks.

```rust
use skribble_leptoskit_maps::{LatLng, MapPin, PinCategory};

let gallery = MapPin::new(LatLng::new(51.5074, -0.1278), "Gallery")
	.with_category(PinCategory::Gallery)
	.with_on_press(|| println!("open the gallery"));
```

`PinCategory` covers `Place`, `CheckIn`, `Coffee`, `Market`, `Gallery`, `Favorite`, and `Person`, each with the pastel fill skribble's Flutter map pins use. With `on_press` a pin is a real button named by its label. Without one, a labelled pin is an image with that name, and an unlabelled pin is decorative.

## 5. Paper and zoom controls

`MapStyle` picks the background. `PAPER` is warm paper with a faint graticule, `DARK` is charcoal with chalk lines, and `PLAIN` has no grid. A map without a `background` uses `PAPER`, and every preset has a light and a dark appearance. A style can also carry its own `ink` for routes, outlines, and pin labels: `DARK` draws them in chalk so they read on charcoal, and the others use the theme's ink.

```rust
use leptoskit::prelude::*;
use skribble_leptoskit_maps::{Camera, LatLng, MapStyle, WiredMap};

let plain = view! {
	<WiredMap
		camera=Camera::new(LatLng::new(0.0, 0.0), 3.0)
		width=320.0
		height=200.0
		background=MapStyle::PLAIN
	/>
};
```

Zoom controls follow leptoskit's controlled pattern. They show the zoom you pass and propose a new one through `on_zoom`; keep the value in your state and rebuild:

```rust
use leptoskit::prelude::*;
use skribble_leptoskit_maps::WiredMapZoomControls;

let controls = view! {
	<WiredMapZoomControls zoom=12.0 on_zoom=|next: f64| println!("zoom to {next}") />
};
```

The controls clamp their proposal to the camera limits, `MIN_ZOOM` and `MAX_ZOOM`, and a press proposes `zoom + step` or `zoom - step`.

## Accessibility

- A map with a `label` is an image with that name. Without one the map itself is decorative, while pressable pins keep their own names.
- A pressable pin is a button, named by its label.
- A labelled pin without an action is an image with its label as its name.
- Ink is always hidden from assistive technology.

## How the ink works

Each tone in a drawing becomes one leptoskit `Vector` element painting with `currentColor`, and a `text-[…] dark:text-[…]` class sets that colour. The runs stack in order, so fills stay under outlines and dark mode recolours the whole map without JavaScript. Server rendering is byte-stable for a seed.

## See everything at once

The crate's `map` example server-renders an atlas page with every kind of feature, both paper styles, and the zoom controls:

```bash
cargo run -p skribble_leptoskit_maps --example map -- map.html
```
