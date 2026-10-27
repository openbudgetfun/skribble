# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [1.0.0](https://github.com/openbudgetfun/skribble/releases/tag/skribble_site/v1.0.0) (2026-10-27)

### Features

- **The website releases and deploys with monochange.** `skribble_site` is now a monochange package that is never published to a registry. It is tagged `skribble_site/v<version>` and gets a GitHub release. Every release deploys the website (landing page, docs, and storybook) through the `Docs Pages` workflow instead of every push to `main`. Changesets with the `user_feat` and `user_fix` types go to the new `user` stream, which is written to the docs' What's new page. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #259](https://github.com/openbudgetfun/skribble/pull/259)

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
