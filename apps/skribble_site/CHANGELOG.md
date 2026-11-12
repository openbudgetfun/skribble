# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [1.1.0](https://github.com/openbudgetfun/skribble/releases/tag/skribble_site/v1.1.0) (2026-11-12)

### Changed

- **No package-specific changes were recorded; `skribble_site` was updated to 1.1.0.**

## [1.0.0](https://github.com/openbudgetfun/skribble/releases/tag/skribble_site/v1.0.0) (2026-11-07)

### Features

- **The website releases and deploys with monochange.** `skribble_site` is now a monochange package that is never published to a registry. It is tagged `skribble_site/v<version>` and gets a GitHub release. Every release deploys the website (landing page, docs, and storybook) through the `Docs Pages` workflow instead of every push to `main`. Changesets with the `user_feat` and `user_fix` types go to the new `user` stream, which is written to the docs' What's new page. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #259](https://github.com/openbudgetfun/skribble/pull/259)

### Fixes

- **leptoskit boxes, buttons, and fields keep content clear of their ink.** `skribble_leptoskit` measured its padding from the component's edge, but the hand-drawn outline sits a few pixels inside that edge and moves further in as the ink stretches. Text in a `WiredBox`, a `WiredButton`, or a `WiredInput` could end up 4 or 5 pixels from the line. These components now pad far enough that content keeps at least 12 pixels from the ink at the sides and 8 above and below, as skribble's Flutter widgets and Jaspr components do. `WiredBox` pads 20 at the sides and 12 above and below, buttons pad 12 above and below, and fields pad 16 at the sides and 12 above and below. Cards, circles, badges, and toggles already had the room. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #276](https://github.com/openbudgetfun/skribble/pull/276)
- **skribble_rough finishes on empty arcs and zero-length dashes.** The Rust engine in `rust/rough` takes the Dart engine's arc fix, so the three engines agree again: an arc whose sweep is empty, reversed, or not finite draws nothing and runs no filler, where it drew a stub before, and a start angle far below zero is normalised in one step instead of a turn at a time. A `Generator` used directly also finishes for a sweep a hair above zero, a huge `curve_step_count`, an infinite edge (no ink, no hachure), and a `dashed` fill whose `dash_offset` and `dash_gap` add up to less than 0.1 (undashed hachure). A negative `rounded_rectangle` keeps square corners. Ordinary shapes draw exactly as before, and the parity tests still match the Dart fixtures byte for byte. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #276](https://github.com/openbudgetfun/skribble/pull/276)
- **The site build rejects options it does not know.** `dart run apps/skribble_site/bin/build.dart` used to ignore any option it did not recognize, so a typo such as `--basepath=/skribble/` quietly built the site for `/`. It now prints the unknown option and the usage, and exits with status 64. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #276](https://github.com/openbudgetfun/skribble/pull/276)

#### The storybook fits phones at large text sizes

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #276](https://github.com/openbudgetfun/skribble/pull/276)

A tour of the storybook on an Android emulator, the iOS Simulator, and macOS found pages that broke at 2× text. The emoji page overflowed by 214 pixels because its header did not scroll; it now scrolls as one page, and its category chips no longer clip. Icon names on the glyph page broke mid-word in fixed 64-pixel tiles; the tiles now grow with the text and shrink their content rather than overflow. The form demo's status moves below its button instead of squeezing into a narrow column. Pages no longer add the status-bar inset a second time under the ink-style toolbar.

The storybook also gains a device tour, `integration_test/device_tour_test.dart`, which visits every page on a real platform, checks each screen for cramped and squeezed text, and saves the captures on the host.

### Other

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
