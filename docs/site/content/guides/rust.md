---
title: skribble for Rust
description: skribble's colourways, component ink, scribbles, charts, and maps as framework-free Rust, ready for any renderer.
---

# skribble for Rust

[`skribble_core`](https://github.com/openbudgetfun/skribble/tree/main/rust/core) is skribble's design system for Rust. It holds the primitives every Rust renderer of skribble shares, with no UI framework: the colourways and theme, the ink behind each component, freehand scribbles, financial charts, and vector maps. Everything it draws is plain data, SVG path data with a light and a dark colour for each path, so any framework can paint it and a server can write it straight to SVG.

The ink comes from [`skribble_rough`](https://github.com/openbudgetfun/skribble/tree/main/rust/rough), a Rust port of the pure-Dart [rough engine](../core/rough-engine). It draws byte-identical SVG to the Dart engine, so a seed wobbles the same in a Rust app as in a Flutter app, a [Jaspr site](jaspr), or a [JavaScript project](javascript).

## Using it in a leptoskit app

[leptoskit](https://github.com/leptoskit/leptoskit) apps get skribble's components, charts, and maps from leptoskit's own [`leptoskit_skribble`](https://github.com/leptoskit/leptoskit/tree/main/crates/leptoskit_skribble) crate. It is built on `skribble_core` and draws its ink with leptoskit's `Vector` element, so it looks the same on the web, macOS, iOS, Android, Windows, and Linux. leptoskit moves quickly, so the integration lives in leptoskit and follows its releases; skribble only supplies the primitives. See that crate's documentation for the components.

## 1. Install

```toml
[dependencies]
skribble_core = "0.1"
```

The crate depends on nothing but `skribble_rough` and builds for every target, including `wasm32-unknown-unknown`.

## 2. Draw a component's ink

Each skribble component has a recipe in `skribble_core::components` that says what it draws. A recipe returns an `Ink`: a shape, the nominal canvas it is drawn on, its outline, and its fill. Its drawing stretches to the component it sits behind, with strokes kept at their width.

```rust
use skribble_core::Theme;
use skribble_core::colorway::Appearance;
use skribble_core::components::{self, ButtonVariant};

let theme = Theme::SKRIBBLE;
let save = components::button(ButtonVariant::Primary, 3, theme);

// The label colour that reads on the button's fill.
let label = save.content_tone();

// The rough border and fill.
let drawing = save.drawing();
let svg = drawing.to_svg(Appearance::Light);
```

| Recipe      | Draws                                                                   |
| ----------- | ----------------------------------------------------------------------- |
| `button`    | A rough rectangle, filled with the accent for the primary action        |
| `boxed`     | A rough rectangle, optionally filled; the fill defaults to the marker   |
| `card`      | A roomier rectangle for grouped content                                 |
| `circle`    | A rough ellipse, for stickers and step numbers                          |
| `badge`     | A small capsule filled with the accent                                  |
| `input`     | The frame around a text field                                           |
| `divider`   | A rough horizontal rule                                                 |
| `checkbox`  | A rough square, and a tick when checked                                 |
| `radio`     | A rough circle, and a dot when selected                                 |
| `switch`    | A capsule that fills with the marker, and a knob that slides to the end |
| `progress`  | A rough track and a hachure filling as wide as the share done           |
| `highlight` | An underline, circle, box, strike, or marker around text                |

Give neighbouring components different seeds so their wobbles differ; the same seed always draws the same ink, so server-rendered pages are identical on every build.

<!-- {=rustInkRoom} -->

Buttons and controls are at least 44 pixels tall and grow with their text. Content keeps at least 12 pixels from the ink at the sides and 8 above and below. The padding also covers the few pixels the outline sits inside its component, which grow as the ink stretches, so a box pads 20 at the sides and 12 above and below, and buttons and fields pad 12 above and below.

<!-- {/rustInkRoom} -->

## 3. Colour it

skribble is a sticker book, not a pencil sketch on grey paper (see [Vivid and alive](vivid-design)). The default `Theme` is the sunny colourway, the same one the Flutter widgets and `skribble_jaspr` use: plum ink on warm paper, paper ink on a plum night in dark mode, a sunshine marker, a tomato accent, and six washes for colour-coding content. Outlines are 1.6 pixels wide with playful roughness.

| Role        | Used by                                                                                       |
| ----------- | --------------------------------------------------------------------------------------------- |
| `ink`       | Outlines, running text, pen marks                                                             |
| `paper`     | The page behind everything                                                                    |
| `marker`    | Marker highlights, switch tracks, progress, and the default fill of boxes, cards, and circles |
| `accent`    | The primary button and badges: the one loud action on a screen                                |
| `washes`    | Colour-coding, read with `theme.accent_at(index)`                                             |
| `muted_ink` | Disabled labels                                                                               |

Pick another colourway with `Theme::colorway`: `Sunny` (the default), `Berry`, `Ocean`, `Citrus`, or `Quiet` for briefs that ask for calm. A `Theme` is a light and a dark `Palette`, a `stroke_width`, and a `roughness`, so you can also start from one and change what you need:

```rust
use skribble_core::colorway::{Colorway, swatch};
use skribble_core::{Palette, Theme};

pub const BERRY: Theme = Theme::colorway(Colorway::Berry);

pub const MINT_ACTIONS: Theme = Theme {
	light: Palette { accent: swatch::MINT, ..Palette::LIGHT },
	dark: Palette { accent: swatch::MINT, ..Palette::DARK },
	..Theme::SKRIBBLE
};
```

Every colour is a `Tone`: one `Rgba` for the light appearance and one for the dark. Labels on a wash use `theme.on(wash)`, which picks the ink or paper with the better contrast in each appearance, and `Ink::content_tone` does this for solid fills. The `colorway` module holds the named `swatch`es (the same values as Flutter's `WiredPalette`), the `Colorway`s, and WCAG contrast helpers.

## 4. Scribble

`Scribble` draws arrows, curves, and annotations from `skribble_rough` with the pen's tapered ink, at an explicit size:

```rust
use skribble_core::{Scribble, Shape};

let arrow = Scribble::new(
	120.0,
	60.0,
	vec![Shape::curve([(4.0, 50.0), (40.0, 10.0), (80.0, 40.0), (116.0, 12.0)]).with_arrowhead()],
);
let drawing = arrow.drawing()?;
```

It returns an error for a size that is not positive and finite, or a shape the engine cannot draw.

## 5. Charts

The `charts` module draws candlesticks, OHLC bars, lines, areas, bars, volume, and SMA, EMA, and Bollinger overlays. Charts draw at an explicit size, so price geometry stays exact: candle bodies and wicks keep the open, high, low, and close positions the data gives them, and only the texture wobbles.

```rust
use skribble_core::charts::{Candle, CandlestickChart, Overlay, SeriesKind};

let chart = CandlestickChart {
	kind: SeriesKind::Candles,
	overlays: vec![Overlay::Sma(20), Overlay::Bollinger { period: 20, deviations: 2.0 }],
	show_volume: true,
	..CandlestickChart::new(candles)
};
let drawing = chart.drawing(360.0, 220.0)?;
```

`LineChart` draws a line through values or points, and `BarChart` draws bars growing from zero (lay its `labels()` out under the plot yourself). `ChartTheme` holds the paper, grid, rise, fall, and indicator tones. The `indicators` module computes `sma`, `ema`, `bollinger`, `rsi`, and `macd` with the same numbers as the Flutter [`skribble_charts`](charts) package.

## 6. Maps

The `maps` module draws its own vector maps: there are no tiles and no network. A `Camera` projects geographic coordinates into a flat Web Mercator viewport, north up, and the rough engine inks areas, routes, and dots on paper.

```rust
use skribble_core::Theme;
use skribble_core::maps::{Camera, LatLng, MapFeature, MapStyle, features_drawing, graticule};

let start = LatLng::new(51.5074, -0.1278);
let camera = Camera::new(start, 14.0);
let style = MapStyle::PAPER;
let theme = style.inked(Theme::SKRIBBLE);

let grid = graticule(camera, 360.0, 240.0, style.graticule.expect("paper has a grid"), 1);
let ink = features_drawing(
	camera,
	360.0,
	240.0,
	&[MapFeature::route(vec![start, LatLng::new(51.516, -0.11)])],
	theme,
	1,
);
```

`pin_drawing` draws a pastel `PinCategory` pin with a cream sticker edge, and `pin_origin` places it with its tip on the point, or returns `None` when it is off screen. `zoom_button_drawing` and `zoom_steps` draw and step a pair of zoom buttons. `Camera::fit` frames a `LatLngBounds` with padding; latitudes clamp to `MAX_LATITUDE` and longitudes wrap across the antimeridian.

## Painting an `InkDrawing`

Everything above ends in an `InkDrawing`: a `width` by `height` coordinate space, a scaling, and paths in paint order, each filled or stroked with a `Tone`.

- `to_svg(appearance)` writes a standalone SVG document. Use it on a server, in an email, or to check a drawing by eye.
- `runs()` groups neighbouring paths that share a tone. A UI framework draws each run as one vector element in that tone. Painting a run with the element's text colour, and switching that colour with the appearance, recolours the ink for dark mode without redrawing it.
- `InkScaling::Stretch` drawings (component ink) stretch to their parent on both axes with strokes at their width. `InkScaling::Fit` drawings (scribbles, charts, maps, pins) keep their proportions.

Components cannot always measure themselves, so each recipe draws into a box near its usual proportions; very wide or tall components stretch the wobble with them. The ink is decorative: names, roles, and states come from the controls an integration draws it behind.

## Drawing with the engine directly

`skribble_rough` works anywhere Rust does. `sketch` returns SVG paths with their colours and widths, or an error for a shape it cannot draw; the lower-level `Generator`, `Filler`, `RoughPen`, and `DrawableInk` mirror the Dart engine. See its [README](https://github.com/openbudgetfun/skribble/tree/main/rust/rough).

```rust
use skribble_rough::{sketch, Shape, SketchOptions};

let options = SketchOptions { fill: Some("#ffd43b".to_owned()), ..SketchOptions::default() };
let badge = sketch(&[Shape::ellipse(50.0, 50.0, 90.0, 90.0)], &options)?;
let svg = badge.to_svg_string(100.0, 100.0, Some("A sketched badge"));
```
