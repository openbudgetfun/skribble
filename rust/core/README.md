# skribble_core

skribble's hand-drawn design system for Rust, free of any UI framework. It holds the primitives every Rust renderer of [skribble](https://openbudgetfun.github.io/skribble/) shares:

- **Colours.** The `colorway` module has the sunny, berry, ocean, citrus, and quiet colourways, the named swatches (the same values as Flutter's `WiredPalette`), and WCAG contrast maths. `Theme` and `Palette` build on them: plum ink on warm paper, a marker, an accent for the one loud action, washes for colour-coding with `theme.accent_at(i)`, and `theme.on(wash)` for labels that stay readable on any fill.
- **Component ink.** The `components` module has the ink behind every skribble component: buttons, boxes, cards, circles, badges, text fields, dividers, checkboxes, radios, switches, progress bars, and highlights. An `Ink` is a shape, its outline, and its fill; its drawing stretches to the component it sits behind.
- **Scribbles.** `Scribble` draws arrows, curves, and annotations at an explicit size with the pen's tapered ink.
- **Charts.** The `charts` module draws candlesticks, OHLC bars, lines, areas, bars, volume, and SMA, EMA, and Bollinger overlays with exact price geometry, and computes SMA, EMA, Bollinger Bands, RSI, and MACD with the same numbers as the Flutter `skribble_charts` package.
- **Maps.** The `maps` module has a Web Mercator `Camera`, rough areas, routes, and dots, pastel pins, a paper background with a graticule, and zoom-button borders. There are no tiles and no network.

Everything ends in an `InkDrawing`: SVG path data in its own coordinate space, each path filled or stroked with a `Tone` that has a light and a dark colour. The ink comes from [`skribble_rough`](https://github.com/openbudgetfun/skribble/tree/main/rust/rough), so the same seed draws the same wobble as skribble's Flutter widgets, its Jaspr components, and the [`@skribble.dev/rough`](https://github.com/openbudgetfun/skribble/tree/main/js/rough) npm package. The crate has no other dependencies and builds for every target, including `wasm32-unknown-unknown`.

## Install

```toml
[dependencies]
skribble_core = "0.1"
```

## Draw a component

```rust
use skribble_core::Theme;
use skribble_core::colorway::{Appearance, Colorway};
use skribble_core::components::{self, ButtonVariant};

let theme = Theme::colorway(Colorway::Berry);
let save = components::button(ButtonVariant::Primary, 3, theme);

// The label colour that reads on the button's fill, in light and dark.
let label = save.content_tone();

// The border and fill, ready for any renderer, or as an SVG document.
let drawing = save.drawing();
let svg = drawing.to_svg(Appearance::Light);
```

Give neighbouring components different seeds so their wobbles differ. The same seed always draws the same ink.

## Draw a chart or a map

```rust
use skribble_core::Theme;
use skribble_core::charts::{Candle, CandlestickChart, Overlay};
use skribble_core::maps::{Camera, LatLng, MapFeature, features_drawing};

let chart = CandlestickChart {
	overlays: vec![Overlay::Sma(20)],
	show_volume: true,
	..CandlestickChart::new(vec![Candle::new(1, 10.0, 12.0, 9.0, 11.0, 100.0)])
};
let price = chart.drawing(320.0, 200.0)?;

let london = LatLng::new(51.5074, -0.1278);
let walk = features_drawing(
	Camera::new(london, 14.0),
	360.0,
	240.0,
	&[MapFeature::route(vec![london, LatLng::new(51.516, -0.11)])],
	Theme::SKRIBBLE,
	1,
);
```

## Use it from a UI framework

skribble does not ship components for a Rust UI framework. Each framework integrates these primitives on its own schedule, so a fast-moving framework never holds skribble back and skribble never pins a framework version. An integration needs three things:

1. **Paint an `InkDrawing`.** Draw each entry of `drawing.runs()` as one vector element in the run's tone. `InkScaling::Stretch` drawings stretch to their parent with strokes at their width; `InkScaling::Fit` drawings keep their proportions.
2. **Follow the appearance.** Pick `tone.light` or `tone.dark` with the host's light or dark mode, or emit both as a dark-mode class.
3. **Lay out each component.** Put the recipe's ink behind real, accessible controls, and give the ink room:

<!-- {=rustInkRoom} -->

Buttons and controls are at least 44 pixels tall and grow with their text. Content keeps at least 12 pixels from the ink at the sides and 8 above and below. The padding also covers the few pixels the outline sits inside its component, which grow as the ink stretches, so a box pads 20 at the sides and 12 above and below, and buttons and fields pad 12 above and below.

<!-- {/rustInkRoom} -->

[leptoskit](https://github.com/leptoskit/leptoskit) apps get skribble through leptoskit's own `leptoskit_skribble` crate, which draws these primitives as leptoskit `Vector` elements on the web, macOS, iOS, Android, Windows, and Linux.

## License

MIT
