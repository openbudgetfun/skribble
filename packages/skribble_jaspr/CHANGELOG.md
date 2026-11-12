# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.4.1](https://github.com/openbudgetfun/skribble/releases/tag/v0.4.1) (2026-11-12)

### Features

#### Vivid colourways and lively motion by default

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #283](https://github.com/openbudgetfun/skribble/pull/283)

skribble now looks like a sticker book out of the box instead of a pencil sketch on grey paper, and the docs and agent instructions steer people and coding agents toward colour and motion rather than safe, muted designs.

**Colour.** `WiredColorway` (`sunny`, `berry`, `ocean`, `citrus`, and the calm `quiet`) and `WiredThemeData.colorway(...)` build light and dark themes from a set of vivid washes added to `WiredPalette` (`sunshine`, `tomato`, `tangerine`, `sky`, `aqua`, `mint`, `lime`, `bubblegum`, `grape`, `cobalt`, `cherry`, `cherryGlow`). Every wash keeps 4.5:1 contrast with plum ink and night text. `WiredThemeData` gains `accentColor` and `accents`, with `accentAt(index)` for colour-coding content, and `onColor`, `onMarkerColor`, `onAccentColor`, and `inkOn` for labels on a wash. `cuddly()` is the sunny colourway.

The defaults change: the marker is `sunshine` (was `lilac`), errors use `cherry`, `WiredFilledButton`, `WiredFloatingActionButton`, and `WiredBadge` fill with the accent (tomato), and selected choice and filter chips are coloured in with the marker instead of solid ink. Selected navigation, segmented, toggle, and stepper items use `onMarkerColor`. Pass `WiredThemeData.colorway(WiredColorway.quiet)` to keep the earlier lilac look. `WiredCard` takes a `color` and inks its content to match. The Material bridge maps `accentColor` to and from `ColorScheme.tertiary`.

**Motion.** `WiredEntrance` springs a child in while its ink draws on, `WiredEntrance.staggered` and `WiredCascade` bring lists and columns in one after another, `WiredBoil` gives focal drawings the wriggle of hand-drawn animation, `WiredHighlight` swipes a marker or underline behind words, and `WiredCurves` (`springy`, `snappy`, `bouncy`, `pen`) and `WiredSpringCurve` time your own animations. All of it settles at once when `WiredMotion` is off or the platform asks for reduced motion.

**Web.** `skribble_jaspr`'s stylesheet uses the sunny colours, adds `--skribble-marker`, `--skribble-on-marker`, and six `--skribble-wash-*` properties with matching `skribble-wash-1` to `skribble-wash-6` classes, and adds the `skribble-draw`, `skribble-pop`, and `skribble-lift` motion classes, all behind `prefers-reduced-motion: no-preference`. Stroked paths carry `pathLength="1"` so they can draw on.

The new [Vivid and alive](https://openbudgetfun.github.io/skribble/guides/vivid-design) guide holds the design rules, shared with `AGENTS.md` and the agents reference page.

## [0.4.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.4.0) (2026-11-07)

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

#### Jaspr components keep their attributes, respect reduced motion, and give content room

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #276](https://github.com/openbudgetfun/skribble/pull/276)

- **Reduced motion is honoured.** The button's line boil kept running under `prefers-reduced-motion: reduce`, because the reduce rule had lower specificity than the hover rule. All hover and press motion now sits behind `prefers-reduced-motion: no-preference`, and disabled or `aria-disabled="true"` buttons and links stay still.
- **No repeated attributes.** A `class` or `style` entry in `WiredBox`, `WiredCircle`, or `WiredButton` `attributes` rendered a second `class` or `style` attribute, which browsers ignore, so the caller's classes and styles were lost. They are now merged with the component's own.
- **CSS values cannot inject declarations.** `fill` and `color` values containing `;`, `{`, or `}` now fail the build with an `ArgumentError` instead of adding declarations to the inline style.
- **Room for the ink.** `WiredBox` now pads its content `0.75rem 1.25rem` through a zero-specificity `:where(.skribble-box)` rule, and `WiredButton` pads `0.7em 1.3em` (was `0.55em`), so content keeps at least 8px above and below and 12px beside the drawn line.
- **Forced colours.** Under `forced-colors: active` the ink uses system colours and solid fills are dropped, so forced text never lands on the accent fill.
- Adds a runnable `example/main.dart`.
