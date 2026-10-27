# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.4.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.4.0) (2026-10-27)

### Features

#### Add hand-drawn Jaspr components that render with zero client JavaScript

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #247](https://github.com/openbudgetfun/skribble/pull/247)

The new `skribble_jaspr` package brings skribble to Jaspr sites. `WiredBox`, `WiredCard`, `WiredCircle`, `WiredButton`, `WiredHighlight`, `WiredDivider`, and `WiredSketch` draw their rough ink on the server into inline SVG, so static and server-rendered pages ship no drawing JavaScript and the same `seed` always produces the same markup.

Each overlay stretches to its element with `preserveAspectRatio="none"` and keeps strokes crisp with `vector-effect="non-scaling-stroke"`. The `skribbleCss` stylesheet themes everything through CSS custom properties (`--skribble-ink`, `--skribble-paper`, `--skribble-accent`, `--skribble-stroke-width`, `--skribble-font`), switches palettes for dark mode, draws a dashed keyboard focus ring, and adds a hover tilt and two-frame "line boil" on buttons that stop under `prefers-reduced-motion`. Ink is decorative and hidden from assistive technology; buttons and links keep native semantics.

#### Noto Sketch is the default lettering outside Flutter too

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #263](https://github.com/openbudgetfun/skribble/pull/263)

`skribbleCss` now lists `SkribbleNotoSketch` first in `--skribble-font`, then a locally installed "Skribble Noto Sketch", then the previous Recursive `Skribble` family, so pages that self-host only the old font keep working. Self-host `SkribbleNotoSketch-Regular.ttf` from `skribble_font_noto_sketch` to use the default.

`WiredLoadingScreen`, `WiredCupertinoPicker`, and `WiredCupertinoDatePicker` now pass the theme's `fontFamilyFallback` through with the qualified family, so kit scripts such as Japanese or Korean render in Noto Sketch there as well. The design kit exported by `packages/skribble/tool/design_kit.dart` includes the three Skribble Noto faces, with Noto Sketch marked as the default.

### Fixes

#### Cached rough geometry, per-widget seeds, a shipped refresh indicator

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #271](https://github.com/openbudgetfun/skribble/pull/271)

##### Performance, held by regression gates

Every shape painter (`WiredRectangleBase`, `WiredCircleBase`, `WiredLineBase`, `WiredRoundedRectangleBase`, `WiredInvertedTriangleBase`) now has a const constructor and value equality, so the 128 call sites that build painters inline in `build` reuse their prepared rough geometry across ancestor rebuilds instead of re-running the generator, filler, and ink sampler. `WiredToggle`'s 250 ms thumb travel animates inside an `AnimatedBuilder` around a prebuilt child: a tick repositions the thumb and regenerates nothing. Icons whose `WiredSvgIconData` is built at runtime compare structurally, so they hit the icon painter cache that only const glyphs hit before. Loaders and skeletons stopped allocating `Paint` objects on every frame.

`package:skribble/testing.dart` ships `RoughGenerationCounter` and icon-cache stats so widget tests can pin all of this: rebuilding with an equal painter, a stable seed, or a runtime-equal icon must not move the counter, and a toggle animation must hold it flat. Those gates live in `test/perf/`.

##### Per-widget seeds

Same-sized shapes of the same kind drew identical wobbles — a column of cards read as photocopies. `WiredCard`, `WiredChip`, `WiredChoiceChip`, `WiredBadge`, `WiredInput`, `WiredToggle`, `WiredRadio`, and `WiredOutlinedButton` now take a `seed` (null keeps the theme's), and `WiredCanvas` derives a memoised seeded config from it.

##### WiredInput grows the common TextField surface

`enabled`, `keyboardType`, `textInputAction`, `inputFormatters`, `onSubmitted`, `maxLength`, `autofocus`, `prefix`/`suffix`, `prefixIcon`/`suffixIcon`, and `errorText` (which draws the ink and the message in the new `WiredThemeData.errorColor`); the doc comment no longer overstates the surface.

##### Callbacks follow the framework convention

`WiredRadio.onChanged` is now an optional `ValueChanged<T?>` — null disables the radio — and `WiredToggle` takes `onChanged`; the boolean-returning `onChange` is deprecated but keeps its veto semantics for one migration window.

##### WiredRefreshIndicator ships

Exported, tested, and documented. `WiredCustomRefreshIndicator` clears its spinner when a refresh fails (it wedged forever before), no longer announces its label twice, and `WiredContextMenu` ignores a long press that arrives after unmounting instead of throwing.

##### Engine types stop lying about null

`OpSet`, `Drawable`, `EllipseParams`, `EllipseResult`, `ComputedEllipsePoints`, and `Edge` have required, non-nullable fields (breaking in the pre-1.0 sense), and a filler built without a configuration owns a fresh default random stream instead of advancing one shared global stream — identical calls now draw identically regardless of construction order. The Dart-to-JS parity fixtures are unchanged.

- **Circle and marker highlights cover their whole word under an `svg` reset.** Many sites reset `svg { max-width: 100% }`. That capped the ink of a `WiredHighlight` at the width of its text, so a circle was drawn to the left of its word and a marker stopped short of the last letter. `skribbleCss` now gives every ink overlay `max-width: none`, so highlights keep their margin around the text whatever the page's own resets. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #257](https://github.com/openbudgetfun/skribble/pull/257)
