# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.4.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.4.0) (2026-10-21)

### Features

#### Move the rough engine into the pure-Dart skribble_rough package

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #247](https://github.com/openbudgetfun/skribble/pull/247)

The Flutter-free half of the rough engine (`DrawConfig`, `Generator`, the fillers, `RoughPen`, `InkStroke`, `DrawableInk`, geometry, and the op-set data structures) now lives in the new `skribble_rough` package, which depends on nothing but the Dart SDK. Command-line tools, servers, and web frameworks can draw the same seeded shapes as the Flutter widgets without pulling in Flutter.

`skribble` depends on `skribble_rough` and re-exports exactly the names it exported before, so `import 'package:skribble/skribble.dart'` keeps working unchanged. The `dart:ui` painting layer (`RoughDrawing`, the `Rough` canvas extension, and `RoughBoxDecoration`) stays in `skribble`. Code that imported the engine's private `package:skribble/src/rough/...` files should import `package:skribble_rough/skribble_rough.dart` instead.

#### Serialize rough drawables to scalable SVG path data

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #247](https://github.com/openbudgetfun/skribble/pull/247)

`skribble_rough` adds `opSetToSvgPath`, which writes one `OpSet` as an SVG `d` attribute, and `RoughSvg.fromDrawable`, which splits a `Drawable` into the three groups the Flutter painter uses: the stroked outline, the stroked sketch fill, and the filled solid polygon. `RoughSvg.toPathElements` renders them as `<path>` elements, optionally with `vector-effect="non-scaling-stroke"` so strokes stay crisp when the SVG stretches. The new `RoughFillStyle` enum names each fill pattern and builds its `Filler` from a seeded `FillerConfig`.

Coordinates are rounded to two decimals, so the same seed always produces the same markup and server-rendered pages stay byte-stable between builds.

#### Softer, lighter ink by default

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #255](https://github.com/openbudgetfun/skribble/pull/255)

skribble now draws like a careful notebook drawing instead of a heavy marker sketch. Apps that keep the default theme see the change without touching their code:

- **A finer pen.** `WiredThemeData.strokeWidth` defaults to the new `kWiredStrokeWidth`, 1.6 logical pixels instead of 2.4. Icons follow the theme pen, so they lighten in proportion.
- **Neater lines.** Playful, the default level, wavers less: roughness 1.1, offset 1.2, and line wobble 0.35 (was 1.5, 1.6, and 0.65). Gentle is tidier still at roughness 0.9 and offset 1. `DrawConfig.defaultValues` uses the playful geometry, so fills and standalone drawings match the borders around them.
- **A lighter second pass.** `RoughPen.ink` retraces less of each shape (`repeatWidth` 0.5 and `repeatCoverage` 0.45, was 0.6 and 0.7), so outlines read as one confident line with an occasional retrace.
- **Rounder corners.** Buttons default to 10 px corners (was 6), cards 16 (was 12), text fields 12 (was 8), checkboxes 6 (was 4), and `WiredTextArea` now has the same rounded corners as `WiredInput`.
- **Colour instead of ink slabs.** `WiredFilledButton`, `WiredFloatingActionButton`, and `WiredBadge` are washed with `markerColor` under ink text instead of being filled with `borderColor`. Pass `fillColor` or `backgroundColor` to keep a darker fill. A selected `WiredRadio` shows a neat solid dot, and `WiredElevatedButton` has a paper face over a light pencil shadow.
- **Colouring stays inside the lines.** Hachure no longer spills past rounded corners: the scanline fill in `skribble_rough` now starts a shallow edge at the scanline it joins. `WiredCanvas` draws fills with the theme's hand unless a `fillerConfig` says otherwise, and `WiredCard(fill: true)` colours in with even strokes 7 px apart.
- **Labelled badges fit their text.** A `WiredBadge` with a label draws a pill that grows with it, so "new" no longer spills past a 16 px circle.

To return to the heavier look, set `strokeWidth: 2.4` and `roughnessLevel: WiredRoughness.expressive` on `WiredThemeData`, or pass explicit `roughness` and `pen` values.

Icons look drawn, too. Filled icons (Material, Boxicons and brand marks such as GitHub, Dart, Flutter and Figma) used to paint as smooth stock silhouettes. They now default to the new `WiredIconFillStyle.marker`: coloured in with broad, overlapping marker strokes that darken where they cross, then outlined with the theme pen along an edge that wavers visibly. Brand marks that fill with `currentColor` now follow `fillStyle` like every other silhouette, so `hachure` and `none` work on them as well. Pass `fillStyle: WiredIconFillStyle.solid` for the previous flat fill.

### Other

- **Add parity fixtures for the npm rough engine.** `tool/js_parity_fixtures.dart` writes hashed SVG output for every shape, fill style, and pen, plus Dart's `Random(seed)` stream. The new `@skribble.dev/rough` npm package replays these fixtures in its tests and must draw byte-identical SVG, so the JavaScript port and this engine stay in step. The package's public API is unchanged. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #254](https://github.com/openbudgetfun/skribble/pull/254)
