# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## rust [0.1.1](https://github.com/openbudgetfun/skribble/releases/tag/rust/v0.1.1) (2026-11-12)

### Features

#### Compact ink for drawings that ship to a browser

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #278](https://github.com/openbudgetfun/skribble/pull/278)

`skribble_rough` can write pen-shaped ink compactly: `CompactSvgInkOutline`, `InkStroke::compact_svg_path_data`, `DrawableInk::compact_svg_paths`, and `SketchOptions::tolerance`. The pen samples a stroke about every pen width, which keeps the taper smooth but writes far more points than a screen shows. Compact ink drops the samples within the tolerance of the line through their neighbours, draws through the rest with the same midpoint curves, and writes two decimals. The default output is unchanged, so ink still matches the Dart and TypeScript engines.

`skribble_leptoskit`'s `Sketch` now draws compact ink within a quarter of a logical pixel. Its paths are about a sixth of their old size: a server-rendered page of sketches dropped from 1.2 MB to 370 KB.

## rust [0.1.0](https://github.com/openbudgetfun/skribble/releases/tag/rust/v0.1.0) (2026-11-07)

### Features

#### Draw skribble_leptoskit ink natively on leptoskit 0.3

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #277](https://github.com/openbudgetfun/skribble/pull/277)

`skribble_leptoskit` now builds on leptoskit 0.3 from crates.io and draws its ink with leptoskit's `Vector` element, which the web renderer shows as inline SVG and every native backend (macOS, iOS, Android, Windows, Linux) draws with its own path API. Native apps get the same rough borders, sketched fills, and ticks as the web, and `Sketch` draws on native too. Ink paints with the element's text colour, so `dark:` classes recolour it on every platform.

The `web` feature is gone: there is nothing to turn on. `skribble_rough` and `skribble_leptoskit` are now published to crates.io and release together under `rust/v<version>` tags.
