# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.1.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.1.0) (2026-09-10)

Grouped release for `main`.

### Features

- **skribble**: **Expand `skribble_emoji` from 50 to 1,827 emoji sourced from OpenMoji.** Includes generation pipeline script, download helper, and comprehensive lookup by name and Unicode codepoint. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #123](https://github.com/openbudgetfun/skribble/pull/123)
- **skribble**: **Add theme font families and brand icon contours.** Add `WiredFont.casual`, `linear`, and `mono` as theme-level font choices, each following Gentle, Playful, and Expressive roughness with genuine regular, bold, italic, and bold italic faces. Preserve the existing Casual default and explicit font-family overrides. Improve small vector icons with coherent contour deformation and shared fill/outline geometry. Add curated Simple Icons brand artwork through `WiredBrandIcon`, with live docs and storybook examples. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #162](https://github.com/openbudgetfun/skribble/pull/162)
- **skribble**: **Add bold, italic, and bold-italic variants of the Skribble font.** Generated from Recursive Casual Static via FontForge. Update `roughen_font.py` to accept a variant parameter for generating different weights/styles. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #122](https://github.com/openbudgetfun/skribble/pull/122)

#### Add ink interaction styles and rich-text selection

_Packages:_ _skribble_

Default to Gentle roughness and its bundled font. Add WiredSelectionArea for native rich-text selection with Wired handles and a localized copy toolbar. Add cascading WiredInkInteraction styles for still ink, pressure feedback, and optional button redraws, while preserving reduced motion and consumer-owned animations.

Preserve slightly uneven solid polygon fills without the large spline bulge on wide buttons.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #159](https://github.com/openbudgetfun/skribble/pull/159)

- _Packages:_ _skribble_, _skribble_emoji_, _skribble_font_roughen_**Generate the Skribble font from Recursive Casual outlines.** Improve themed pen widths, typography inheritance, clipping, and repaint stability. Preserve complete OpenMoji 17 sequences and source artwork, regenerate curated icons in their correct view boxes, and retain icon counters. Add reproducible asset generation, pixel regressions, and a responsive notebook exercised by Patrol in Chromium. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #148](https://github.com/openbudgetfun/skribble/pull/148)
- **skribble**: **Add ink borders and hatch drawing with WiredDraw.** Add opt-in border and hatch drawing with WiredDraw and WiredDrawTransition, using standard Flutter animations. Motion settings cascade from the theme and respect reduced motion. Buttons reinforce their ink on hover, focus, and press. Cache prepared geometry for paint-only updates and preserve legacy custom painters. Let naturally sized cards contain responsive LayoutBuilder content. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #152](https://github.com/openbudgetfun/skribble/pull/152)

#### Add Material long tail batch A parity widgets

_Packages:_ _skribble_

Add "Material long tail" batch A widgets to close four M3 parity gaps:

- `WiredCarouselView`: hand-drawn horizontal carousel of rough-bordered cards mirroring M3 `CarouselView`'s `itemExtent` / `height` / `children` / `shrinkWrap` API, with optional hachure fill, tap callbacks, and item semantics.
- `WiredSearchAnchor` + `WiredSearchController`: search anchor pairing a collapsible `WiredSearchBar` with an in-place suggestions view (`builder` / `suggestionsBuilder` / `closeView(selection)` flow, analogous to Material's `SearchAnchor`). `WiredSearchBar` gains `onTap` and `autoFocus` parameters.
- `WiredDateRangePickerDialog` + `showWiredDateRangePicker`: hand-drawn range selection dialog reusing the calendar's month-grid visual language, with `firstDate`/`lastDate` clamping and month navigation.
- `WiredLicensePage` + `showWiredLicensePage`: license page rendered from `LicenseRegistry` data (alphabetical packages, rough-bordered headers, wired spinner while loading).

Storybook showcases were added to the Layout, Inputs, Data Display, and Feedback pages; docs catalog entries to `widgets/layout.md`, `widgets/inputs.md`, `widgets/selection.md`, `widgets/feedback.md`, and the API overview; plus ~54 new widget tests.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #136](https://github.com/openbudgetfun/skribble/pull/136)

#### Material long tail, batch B — new hand-drawn widgets

_Packages:_ _skribble_

Adds the final Material parity widgets from the audit backlog (PLANNING.md 1.3), plus the missing top-level time picker dialog helper:

- `WiredGridTile` + `WiredGridTileBar` (`wired_grid_tile.dart`) — grid tiles with header/footer bars, rough borders and a hand-drawn ink splash via `WiredInkSplashFactory` (now exported publicly).
- `WiredMergeableMaterial` (`wired_mergeable_material.dart`) — animated expand/collapse slices on top of rough borders. Ships `WiredMergeableMaterialItem`, `WiredMaterialSlice` and `WiredMaterialGap` mirroring Material's `MergeableMaterialItem` API family; gap size changes animate and a zero-size gap merges neighboring slices into one card.
- `WiredCheckboxMenuButton` and `WiredRadioMenuButton` (`wired_menu_bar.dart`) — menu items with hand-drawn checkbox/radio leading icons wired into the Material menu anchoring system (`MenuItemButton`), matching Material's default `closeOnActivate` behavior and tristate/toggleable semantics.
- `WiredAboutListTile` (`wired_about_list_tile.dart`) — a `WiredListTile` that opens `WiredAboutDialog` on tap, mirroring Material's `AboutListTile`.
- `showWiredTimePicker` (in `wired_time_picker.dart`) — top-level dialog helper matching `showWiredDatePicker`, with a hand-drawn Cancel/OK dialog around `WiredTimePicker`.

Also removes a stale `unreachable_from_main` ignore comment in `tool/generate_material_rough_icons.dart` (no longer needed under the current analyzer), and documents all of the above in the widget catalog (`layout.md`, `navigation.md`, `selection.md`) and the API overview.

Storybook coverage added for every new widget (data display, layout, and navigation pages).

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #137](https://github.com/openbudgetfun/skribble/pull/137)

#### Add hand-drawn Cupertino parity widgets

_Packages:_ _skribble_

Add a batch of hand-drawn Cupertino parity widgets, completing the highest priority cupertino gaps from the planning audit:

- `WiredCupertinoActivityIndicator` — iOS-style sunburst spinner drawn with jittered rough strokes; `animating` toggles the continuous rotation (idle-safe for `pumpAndSettle` tests) and supports semantic labels.
- `WiredCupertinoListSection` — inset-grouped list section with a hand-drawn card, sketchy separators between rows, and header/footer support.
- `WiredCupertinoListTile` — iOS list tile with leading/title/subtitle/ trailing/`additionalTrailingText` API, optional hand-drawn background fill, button semantics, and full-width tappable behavior.
- `WiredCupertinoSearchTextField` — stadium-shaped search input with a rough magnifier glyph, placeholder support, submit handling, and text-field semantics. Built on `EditableText` (widgets only).
- `WiredCupertinoTimerPicker` — hour/minute/second wheels composed on the `WiredCupertinoPicker` internals; `hm`/`hms`/`ms` modes with `minuteInterval`/`secondInterval` granularity.
- `WiredCupertinoFormSection` — grouped form rows with hand-drawn dividers plus header/footer support.

All new widgets are `HookWidget`s built exclusively on `flutter/widgets` and the rough engine (`WiredCanvas`/`WiredPainterBase`), keeping the new code free of material/cupertino imports. Includes 79 widget tests across six test files, five new storybook page tests, storybook demos for every new widget, a new `cupertino.md` catalog page (plus sidebar and API overview updates), and a minor bump.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #138](https://github.com/openbudgetfun/skribble/pull/138)

#### Make Playful the default roughness with executable docs

_Packages:_ _skribble_

Make Playful the default roughness and lettering, with Gentle and Expressive still available through `WiredThemeData`. Add executable documentation examples with matching highlighted source, editable parameters, persistent roughness choices, and a comparison of roughened Recursive Casual and Sans Linear.

Fix long chip and grid-tile labels on narrow layouts and calendar headers and weekday columns on mobile. Range-slider thumbs now use the rough painter; disabled sliders ignore input and external endpoint changes update the displayed range.

Add `WiredRangeSlider.between`, `WiredCombo.options`, `WiredCupertinoTabBar.destinations`, and `WiredAnimatedIcon.menuClose` convenience constructors so those examples do not require Material types in consumer code.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #161](https://github.com/openbudgetfun/skribble/pull/161) · _Related issues:_ [#160](https://github.com/openbudgetfun/skribble/issues/160)

- **skribble**: **Amplify rough engine parameters for hand-drawn wobble.** Amplify rough engine parameters for clearly hand-drawn appearance: maxRandomnessOffset 3×, roughness 1.8→2.4, bowing 1.6→2.2. Fill wobble amplitude boosted to shortestSide/8. Outline uses double-pass canvas translate for layered pen-stroke effect on per-colour primitives. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #142](https://github.com/openbudgetfun/skribble/pull/142)
- **skribble**: **Add rough hand-drawn Material icon support.** Introduces `WiredIcon` and `WiredSvgIcon` for sketch-style icon rendering, adds the Material SVG-to-Dart generation pipeline, and wires rough icon rendering into `WiredIconButton` and `WiredFloatingActionButton`. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #14](https://github.com/openbudgetfun/skribble/pull/14)
- _Packages:_ _skribble_, _skribble_font_roughen_**Add Gentle, Playful, and Expressive roughness levels.** Add app-wide Gentle, Playful, and Expressive roughness levels with matching four-style font families, nested typography inheritance, and theme-aware rough icons. Make expressive borders locally uneven with bounded wandering strokes while retaining the gentler bowed renderer. Preserve visible centres in small circular controls and font spacing and shaping. Support named custom font families in the numeric roughening tool. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #149](https://github.com/openbudgetfun/skribble/pull/149) · _Related issues:_ [#148](https://github.com/openbudgetfun/skribble/issues/148)
- **skribble**: **Bundle the Architects Daughter hand-drawn font with the theme.** Add `fontFamily` property to `WiredThemeData` (default: `skribbleFontFamily`) so all Wired widgets and Material text styles automatically use the hand-drawn font. Remove `google_fonts` runtime dependency in favor of the bundled asset. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #105](https://github.com/openbudgetfun/skribble/pull/105) · _Closed issues:_ [#101](https://github.com/openbudgetfun/skribble/issues/101)
- **skribble**: **Replace Architects Daughter with a custom Skribble font.** Roughened from Recursive (Casual axis) via FontForge. The new font has hand-drawn jitter on all glyph outlines while preserving readability and full Unicode coverage. Includes the `roughen_font.py` FontForge script for regeneration. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #118](https://github.com/openbudgetfun/skribble/pull/118) · _Closed issues:_ [#113](https://github.com/openbudgetfun/skribble/issues/113)
- **skribble**: **Rewrite storybook galleries with lazy grids and search.** Rewrite all three 1000+-item gallery pages with lazy GridView.builder rendering, search, and per-icon detail popup. Boost rough engine parameters (curveFitting 0.9→0.0 for jagged polylines, roughness 1.8→1.8, bowing 1.6→1.6). _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #143](https://github.com/openbudgetfun/skribble/pull/143)

#### Preserve source SVG colours through the rough pipeline

_Packages:_ _skribble_

Preserve colours from source SVG artwork through the rough rendering pipeline:

- Add `fillColor`/`strokeColor`/`strokeWidth` to `WiredSvgPrimitive`
- Parse SVG paint attributes with group inheritance in `generate_emoji.dart`
- Paint each precomputed primitive with its own colour (rough solid fill for enclosed areas, wobbled outline for strokes) instead of a single ambient colour
- Regenerate all 1,820 emoji with their OpenMoji colour palettes flowing through
- Icon default fill changed from hachure to the new rough solid wire fill
- Amplify rough engine defaults (maxRandomnessOffset, roughness, bowing) for clearly visible hand-drawn wobble at any icon size
- Improve font roughening: 4× more aggressive jitter, silhouette displacement applied to both on-curve and off-curve Bézier control points
- Regenerate all 4 Skribble typeface variants with aggressive contour displacement across all 1,479 foreground contours

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #141](https://github.com/openbudgetfun/skribble/pull/141)

#### Add the `skribble_icons_custom` standalone icon package

_Packages:_ _skribble_icons_custom_

Introduces `packages/skribble_icons_custom` — the first standalone Skribble icon set package, demonstrating the `svg-manifest` kit workflow for non-Material icon sets.

###### New package: `skribble_icons_custom`

- 5 hand-drawn icons: `home`, `search`, `settings`, `star`, `favorite`
- Generated from plain SVG sources via the Skribble rough icon pipeline
- Public API:
  - `kCustomRoughIcons` — compile-time `Map<int, WiredSvgIconData>`
  - `kCustomRoughIconsCodePoints` — identifier → codepoint lookup
  - `lookupCustomRoughIconByIdentifier(String)` → `WiredSvgIconData?`
- Full test coverage (11 tests)
- New `melos run rough-icons-custom` script for regeneration

###### Generator improvement: `--map-name`

Adds `--map-name <name>` flag to `generate_rough_icons.dart` so that non-Material icon sets can name their generated Dart map constant correctly. Defaults to `kMaterialRoughIcons` (no breaking change).

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #100](https://github.com/openbudgetfun/skribble/pull/100)

### Fixes

- **skribble**: **Add a hand-drawn corner radius to the button widgets.** Give `WiredButton`, `WiredElevatedButton`, `WiredFilledButton`, and `WiredOutlinedButton` a small, hand-drawn 6 px corner radius. Set `borderRadius: BorderRadius.zero` for square corners or use `BorderRadius.only` for different corners. Both straight edges and corner arcs inherit the theme's roughness. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #131](https://github.com/openbudgetfun/skribble/pull/131) · _Related issues:_ [#130](https://github.com/openbudgetfun/skribble/issues/130)

#### CI: fix devenv git-hooks inputs in GitHub Actions

_Packages:_ _skribble_

Fix GitHub Actions `devenv shell` evaluation failures by declaring the required `git-hooks` input and `pre-commit-hooks` alias in `devenv.yaml`.

This unblocks the `lint`, `test`, and `coverage` jobs, which were failing before any project checks actually ran.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #13](https://github.com/openbudgetfun/skribble/pull/13)

- _Packages:_ _skribble_, _skribble_font_roughen_**Correct the font notice and add a portable design kit.** Correct the Recursive-derived font notice and preserve it beside distributed font copies. Add a reproducible design kit with all bundled fonts, editable SVG pen specimens, layout metadata, and static motion references. Document Figma font upload and separate verified font and SVG icon export commands. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #164](https://github.com/openbudgetfun/skribble/pull/164)
- **skribble**: **Document the Jaspr guide and icon expansion plans.** Docs: Jaspr usage guide (webfont + rough SVG borders + planned skribble_jaspr package), Iconify/simple-icons expansion proposal, and session status in PLANNING.md. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #140](https://github.com/openbudgetfun/skribble/pull/140) · _Related issues:_ [#134](https://github.com/openbudgetfun/skribble/issues/134), [#135](https://github.com/openbudgetfun/skribble/issues/135), [#136](https://github.com/openbudgetfun/skribble/issues/136), [#137](https://github.com/openbudgetfun/skribble/issues/137), [#138](https://github.com/openbudgetfun/skribble/issues/138), [#139](https://github.com/openbudgetfun/skribble/issues/139)
- **skribble**: **Add Patrol end-to-end journeys to the storybook.** Add Patrol + integration test configuration and journeys for the storybook: a `patrol:` pubspec block, cross-page journey tests (icons, emoji, font specimen, long-tail widgets), gitignored patrol artifacts, and a new "E2E Testing" guide documenting the three testing tiers. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #139](https://github.com/openbudgetfun/skribble/pull/139)
- **skribble**: **Add a `PrecomputedEmoji` widget for fast emoji rendering.** Same API as `WiredEmoji` (fromName, fromUnicode, placeholder fallback) but draws SVG paths directly via canvas.drawPath for performance-critical screens. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #124](https://github.com/openbudgetfun/skribble/pull/124)

#### Upgrade the workspace to Flutter 3.47 / Dart 3.13

_Packages:_ _skribble_

- Bump the pinned SDK in `.fvmrc` from 3.41.1 to 3.47.0
- Raise Dart SDK constraints to `^3.13.0` and Flutter constraints to `^3.47.0`
- Regenerate rough-icon catalogs with the Dart 3.13 formatter (canonical output shape changes for long single-argument calls)
- Resolve new analyzer diagnostics (`unnecessary_unawaited`, `prefer_initializing_formals`, `prefer_if_elements_to_conditional_expressions`, deprecated `one_member_abstracts`, `strict_top_level_inference` batch)

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #130](https://github.com/openbudgetfun/skribble/pull/130) · _Related issues:_ [#130](https://github.com/openbudgetfun/skribble/issues/130)

- **skribble**: **Replace the Skribble font with Architects Daughter variants.** Replace Skribble font family with genuinely hand-drawn Architects Daughter. Generate Bold/Italic/BoldItalic variants via FontForge. Add app-local font declaration to storybook pubspec for reliable web loading. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #144](https://github.com/openbudgetfun/skribble/pull/144)
- **skribble**: **Add a kit-agnostic rough icon CLI entrypoint.** Keep `generate_material_rough_icons.dart` as a compatibility alias, and add `--list-kits` support for discoverability. Update docs and workspace scripts to use the new entrypoint. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #22](https://github.com/openbudgetfun/skribble/pull/22)
- **skribble**: **Split icon rendering into `skribble_icons` and `skribble_icons_dynamic`.** Static icons are 10-18x faster via the `SkribbleIcon` widget using roughened paths baked in at build time, and `skribble_icons_dynamic` with `SkribbleDynamicIcon` using runtime roughening via `WiredSvgIcon` for per-icon roughness and fill control. Both share the same API surface and identifiers. Includes benchmark app comparing both approaches across single icon, grid, and scrolling scenarios. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #120](https://github.com/openbudgetfun/skribble/pull/120)
- **skribble**: **Add a font specimen page and live storybook preview.** Add a font specimen page to the storybook (every glyph of the bundled Skribble typeface across weights/styles/sizes), deploy the storybook as a live web preview alongside the docs site on GitHub Pages, and add a Live Showcase section to the docs. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #134](https://github.com/openbudgetfun/skribble/pull/134)

#### Expose Material rough icon font catalog helpers from `skribble`

_Packages:_ _skribble_

Includes identifier-based lookup for rough SVG data and generated font `IconData`, along with public font family and codepoint catalog accessors.

Also update rough icon font Dart generation to emit single-quoted string literals so generated files pass `dart analyze --fatal-infos`.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #26](https://github.com/openbudgetfun/skribble/pull/26)

#### Improve Flutter Material rough icon SVG alias resolution

_Packages:_ _skribble_

- map `label_outline` variants to `label`
- map `wifi_tethering_error_rounded` variants to `wifi_tethering_error`

This recovers rough SVG coverage for these icon codepoints and reduces runtime fallback-to-`Icon` cases.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #27](https://github.com/openbudgetfun/skribble/pull/27)

- **skribble**: **Accept `code-points[]` as a minimal unresolved baseline key.** The `--unresolved-baseline` loader in `generate_material_rough_icons.dart` now also reads `code-points` as the codepoint list key for minimal baseline objects, alongside `codePoints`, `code_points`, `codepoints`, and `codepoint`, with parser test coverage. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #75](https://github.com/openbudgetfun/skribble/pull/75)
- **skribble**: **Accept `codePoint[]` as a minimal unresolved baseline key.** The `--unresolved-baseline` loader in `generate_material_rough_icons.dart` now also reads the singular camelCase `codePoint` key for minimal baseline objects, so baselines written with the one-entry spelling parse like the plural forms, with parser test coverage. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #80](https://github.com/openbudgetfun/skribble/pull/80)

#### Improve unresolved baseline parser errors for missing codepoints

_Packages:_ _skribble_

- Baseline object entries in `unresolved[]`/`icons[]` now throw a targeted `FormatException` when none of `codePoint`, `codepoint`, or `code_point` is present.
- This replaces the previous generic null-value error and clarifies accepted key names.
- Adds parser test coverage for this failure mode.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #71](https://github.com/openbudgetfun/skribble/pull/71)

- **skribble**: **Accept `codepoint[]` as a minimal unresolved baseline key.** The `--unresolved-baseline` loader in `generate_material_rough_icons.dart` now also reads the all-lowercase singular `codepoint` key for minimal baseline objects, completing the accepted lowercase spellings, with parser test coverage. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #79](https://github.com/openbudgetfun/skribble/pull/79)

#### Switch rough icon baseline sync defaults to codepoints output

_Packages:_ _skribble_

- `melos run rough-icons-baseline` now writes baseline JSON using `--unresolved-baseline-output-format codepoints`.
- CI/local baseline sync script (`scripts/check_rough_icons_ci.sh`) now uses the same `codepoints` baseline output format.
- Update committed baseline file `packages/skribble/tool/examples/material_rough_icons.unresolved-baseline.json` to `codePoints[]` shape.
- Update rough icon docs/README to note the committed baseline format.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #51](https://github.com/openbudgetfun/skribble/pull/51)

#### Extend unresolved baseline parsing to accept a codepoints list

_Packages:_ _skribble_

- `--unresolved-baseline` now accepts JSON objects with a top-level `codePoints` list (int or hex-string entries), in addition to existing `unresolved[]` report and `icons[]` manifest formats.
- Add parser coverage for the new baseline format.
- Update rough icon docs/README and CLI usage text accordingly.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #48](https://github.com/openbudgetfun/skribble/pull/48)

#### Accept `codePoints[]` and `codepoints[]` baseline keys

_Packages:_ _skribble_

- `--unresolved-baseline` now accepts either `codePoints[]` or `codepoints[]` keys when loading minimal baseline JSON objects.
- Add parser coverage for lowercase `codepoints[]` baseline input.
- Update rough icon docs/README and CLI help text to document the accepted key alias.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #52](https://github.com/openbudgetfun/skribble/pull/52)

#### Accept snake_case minimal baseline keys for rough icons

_Packages:_ _skribble_

- `--unresolved-baseline` now accepts `unresolved_code_points[]` and `code_points[]`.
- Existing key aliases continue to work (`unresolvedCodePoints`, `unresolvedCodepoints`, `codePoints`, `codepoints`).
- Adds parser test coverage and updates CLI/docs/README.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #68](https://github.com/openbudgetfun/skribble/pull/68)

#### Add regression and recovery fields to the unresolved baseline diff

_Packages:_ _skribble_

- `--unresolved-baseline` now records both regression and recovery context in unresolved JSON output
- New optional report fields when baseline comparison is enabled:
  - `baselineUnresolvedCount`
  - `resolvedSinceBaselineCount`
  - `resolvedSinceBaseline`

This makes baseline-driven CI runs easier to interpret by surfacing not only new unresolved regressions, but also baseline entries that are now resolved.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #36](https://github.com/openbudgetfun/skribble/pull/36)

- **skribble**: **Accept `code-point` as a baseline entry codepoint alias.** This applies to object entries inside baseline `unresolved[]` and `icons[]` lists. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #73](https://github.com/openbudgetfun/skribble/pull/73)

#### Accept additional codepoint field aliases in baseline entries

_Packages:_ _skribble_

- `--unresolved-baseline` now accepts `codepoint` and `code_point` for object entries in `unresolved[]` and `icons[]` (in addition to `codePoint`).
- Keeps existing minimal list-key aliases unchanged.
- Updates parser tests, CLI help, and docs/README.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #69](https://github.com/openbudgetfun/skribble/pull/69)

#### Allow unresolved baseline regression checks to accept JSON formats

_Packages:_ _skribble_

- `--unresolved-baseline` now supports:
  - unresolved report format (`unresolved[]`)
  - supplemental manifest format (`icons[]`)

This lets generated supplemental manifest templates be reused directly as baseline inputs for `--fail-on-new-unresolved` checks.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #35](https://github.com/openbudgetfun/skribble/pull/35)

- **skribble**: **Improve unresolved baseline parser diagnostics for non-list keys.** The parser now reports which recognized keys have non-list values (for example `codePoints (String)`). _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #78](https://github.com/openbudgetfun/skribble/pull/78)

#### Add a configurable unresolved baseline output format flag

_Packages:_ _skribble_

- New flag: `--unresolved-baseline-output-format <unresolved|codepoints>`.
- `--unresolved-baseline-output` defaults to existing `unresolved[]` shape.
- `codepoints` format emits a minimal top-level `codePoints[]` list.
- Add validation for unsupported formats and for using custom format without `--unresolved-baseline-output`.
- Add parser tests and docs/README updates for the new output format.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #50](https://github.com/openbudgetfun/skribble/pull/50)

- **skribble**: **Improve unresolved baseline diagnostics for bad top-level keys.** The `FormatException` now includes the keys found in the provided JSON object. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #77](https://github.com/openbudgetfun/skribble/pull/77)
- **skribble**: **Accept `unresolved-code-points[]` as a minimal baseline key.** The `--unresolved-baseline` loader in `generate_material_rough_icons.dart` now also reads `unresolved-code-points` as the unresolved list key for minimal baseline objects, alongside the existing camelCase, PascalCase, and snake_case spellings, with parser test coverage. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #74](https://github.com/openbudgetfun/skribble/pull/74)
- **skribble**: **Accept `unresolved-codepoints[]` as a minimal baseline key.** The `--unresolved-baseline` loader in `generate_material_rough_icons.dart` now also reads `unresolved-codepoints` as the unresolved list key for minimal baseline objects, completing the accepted kebab-case spellings, with parser test coverage. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #76](https://github.com/openbudgetfun/skribble/pull/76)

#### Accept `unresolvedCodePoints` as an unresolved baseline key

_Packages:_ _skribble_

- `--unresolved-baseline` now accepts minimal baseline objects keyed by `unresolvedCodePoints` (in addition to `codePoints`/`codepoints`).
- This lets baseline regression checks consume unresolved report summary shape more directly.
- Update parser tests and docs/README.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #66](https://github.com/openbudgetfun/skribble/pull/66)

#### Accept `unresolvedCodepoints` as an unresolved baseline key

_Packages:_ _skribble_

- `--unresolved-baseline` now accepts minimal baseline objects keyed by `unresolvedCodepoints` in addition to `unresolvedCodePoints`, `codePoints`, and `codepoints`.
- Improves compatibility when baseline JSON uses lowercased key conventions.
- Update parser tests, CLI help, docs, and README.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #67](https://github.com/openbudgetfun/skribble/pull/67)

- **skribble**: **Accept `unresolved_codepoints[]` as a minimal baseline key alias.** This adds another snake_case compatibility alias alongside existing baseline key variants. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #72](https://github.com/openbudgetfun/skribble/pull/72)
- **skribble**: **Accept singular `unresolvedCodePoint[]` minimal baseline keys.** The `--unresolved-baseline` loader in `generate_material_rough_icons.dart` now also reads the singular PascalCase `unresolvedCodePoint` key for minimal baseline objects, so one-entry baselines parse like the plural form, with parser test coverage. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #81](https://github.com/openbudgetfun/skribble/pull/81)
- **skribble**: **Accept singular `unresolvedCodepoint[]` minimal baseline keys.** The `--unresolved-baseline` loader in `generate_material_rough_icons.dart` now also reads the singular `unresolvedCodepoint` key for minimal baseline objects, so one-entry baselines written with the lower-Pascal spelling parse like the plural form, with parser test coverage. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #82](https://github.com/openbudgetfun/skribble/pull/82)
- **skribble**: **Accept singular `unresolved_codepoint[]` minimal baseline keys.** The `--unresolved-baseline` loader in `generate_material_rough_icons.dart` now also reads the singular snake_case `unresolved_codepoint` key for minimal baseline objects, completing the accepted snake_case spellings, with parser test coverage. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #100](https://github.com/openbudgetfun/skribble/pull/100)

#### Add workspace-level unresolved baseline gating for rough icons

_Packages:_ _skribble_

- Add committed baseline report:
  - `packages/skribble/tool/examples/material_rough_icons.unresolved-baseline.json`
- Update melos scripts:
  - `rough-icons` and `rough-icons-font` now pass `--unresolved-baseline ... --fail-on-new-unresolved`
  - add `rough-icons-baseline` to refresh the committed baseline report
- Document baseline workflow in rough icon docs and package README.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #37](https://github.com/openbudgetfun/skribble/pull/37)

#### Add a `simple-icons` fallback source to rough icon resolution

_Packages:_ _skribble_

- New CLI option: `--brand-icons-source <path>`
- Default behavior now attempts a best-effort `simple-icons` package fallback
- Adds `woo_commerce -> woocommerce` brand slug mapping for fallback lookup

This reduces unresolved Material rough icon codepoints when Flutter exposes brand identifiers that are not present in upstream Material SVG packages.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #28](https://github.com/openbudgetfun/skribble/pull/28)

#### Verify in CI that the committed rough icon baseline stays in sync

_Packages:_ _skribble_

- Add a new CI job (`rough-icons-baseline-sync`) that regenerates `packages/skribble/tool/examples/material_rough_icons.unresolved-baseline.json` using the committed supplemental manifest.
- Fail the job when baseline regeneration leaves a diff, ensuring baseline updates are committed with related icon-pipeline changes.
- Print the baseline diff in CI logs when the sync check fails.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #42](https://github.com/openbudgetfun/skribble/pull/42)

#### Improve rough icon CI/local parity ergonomics with a script

_Packages:_ _skribble_

- Add `scripts/check_rough_icons_ci.sh` with `regression`, `baseline-sync`, `generated-sync`, and `all` modes.
- Refactor rough icon CI jobs to use this script instead of duplicating command blocks.
- Add workspace shortcut `melos run rough-icons-ci-check`.
- Update rough icon docs/README with local CI-equivalent check commands.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #46](https://github.com/openbudgetfun/skribble/pull/46)

#### Add threshold-mode baseline regression gating to the CI script

_Packages:_ _skribble_

- `scripts/check_rough_icons_ci.sh` now supports optional env var `ROUGH_ICONS_MAX_NEW_UNRESOLVED=<int>`.
- When set, regression and generated-sync checks use `--max-new-unresolved <int>` instead of strict `--fail-on-new-unresolved`.
- Includes validation that the env var is a non-negative integer.
- Updates rough icon pipeline docs and package README with the new script option.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #56](https://github.com/openbudgetfun/skribble/pull/56)

#### Add optional total unresolved gating to rough icon CI checks

_Packages:_ _skribble_

- `scripts/check_rough_icons_ci.sh` now supports `ROUGH_ICONS_MAX_UNRESOLVED=<int>`.
- When set, regression/generated-sync checks pass `--max-unresolved <int>` to rough icon generation.
- Existing baseline-regression threshold behavior (`ROUGH_ICONS_MAX_NEW_UNRESOLVED`) is unchanged.
- Update rough icon docs and README.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #70](https://github.com/openbudgetfun/skribble/pull/70)

#### Enable rough icon unresolved regression gating in CI

_Packages:_ _skribble_

- Add a dedicated CI job (`rough-icons-regression`) that runs rough icon resolution in `--rough-only` mode against the committed unresolved baseline.
- The job fails pull requests when new unresolved icon regressions are introduced (`--fail-on-new-unresolved`).
- Update rough icon docs/README to note the CI enforcement behavior.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #39](https://github.com/openbudgetfun/skribble/pull/39)

#### Print and save sync diffs from rough icon CI checks

_Packages:_ _skribble_

- `scripts/check_rough_icons_ci.sh` now prints and writes sync diffs (`rough-icons-baseline-sync.diff`, `rough-icons-generated-sync.diff`) when baseline/catalog sync checks fail.
- `rough-icons-regression` local runs now clean up `packages/skribble/unresolved-report.json` on success by default (`ROUGH_ICONS_KEEP_UNRESOLVED_REPORT=1` keeps it).
- CI workflow now relies on the script for diff generation and keeps only the failure artifact upload steps.
- Update rough icon docs/README with the script’s diff and report behavior.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #47](https://github.com/openbudgetfun/skribble/pull/47)

#### Improve rough icon CI failure diagnostics for sync checks

_Packages:_ _skribble_

- `rough-icons-baseline-sync` now saves and uploads a `rough-icons-baseline-sync-diff` artifact when the regenerated baseline file differs from committed output.
- `rough-icons-generated-sync` now saves and uploads a `rough-icons-generated-sync-diff` artifact when regenerated rough icon catalogs differ from committed files.
- Update rough icon docs/README to describe these failure artifacts.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #45](https://github.com/openbudgetfun/skribble/pull/45)

#### Default rough icon CI gating thresholds to zero

_Packages:_ _skribble_

- Regression and generated-sync checks now default to `--max-new-unresolved 0` when `ROUGH_ICONS_MAX_NEW_UNRESOLVED` is unset.
- This keeps local script behavior aligned with CI/workspace threshold conventions.
- Docs and README were updated to reflect the new default.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #63](https://github.com/openbudgetfun/skribble/pull/63)

#### Wire rough icon CI checks to threshold-based gating

_Packages:_ _skribble_

- Set `ROUGH_ICONS_MAX_NEW_UNRESOLVED=0` in rough icon regression and generated-sync CI jobs.
- Keeps CI behavior strict (equivalent to `--fail-on-new-unresolved`) while exposing a single threshold knob in workflow config.
- Update rough icon docs/README to document the CI default and override path.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #57](https://github.com/openbudgetfun/skribble/pull/57)

#### Upload unresolved reports from rough icon CI regression runs

_Packages:_ _skribble_

- Update `rough-icons-regression` CI job to also pass `--unresolved-output` while running `--fail-on-new-unresolved` gating.
- Upload the generated report as a workflow artifact: `rough-icons-unresolved-report`.
- Document artifact availability in rough icon pipeline docs and README.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #40](https://github.com/openbudgetfun/skribble/pull/40)

- **skribble**: **Improve the Material rough icon tooling pipeline.** Add a Deno conversion script, a pluggable icon-kit provider seam, parser hardening, and an optional SVG-to-TTF font generation step for rough icon assets. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #19](https://github.com/openbudgetfun/skribble/pull/19)

#### Accept more string formats when parsing rough icon codepoints

_Packages:_ _skribble_

- `codePoint` parsing now accepts additional string forms:
  - bare hex (for example `"e001"`)
  - `U+`-prefixed hex (for example `"U+E001"`)
  - existing decimal and `0x`-prefixed formats remain supported
- `--unresolved-baseline` benefits from the same parsing support.
- Add parser tests for manifest and baseline codepoint string variants.
- Update rough icon pipeline docs/README with accepted `codePoint` formats.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #49](https://github.com/openbudgetfun/skribble/pull/49)

#### Ship a committed supplemental manifest and SVG assets

_Packages:_ _skribble_

Material rough icon gaps (`face_unlock*`, `adobe*`) in default workflows.

- Add committed supplemental manifest + assets under:
  - `packages/skribble/tool/examples/material_rough_icons.supplemental.manifest.json`
  - `packages/skribble/tool/examples/supplemental/material/*.svg`
- Update rough icon scripts and CI regression gate to pass `--supplemental-manifest` by default.
- Refresh normalized unresolved baseline (now empty with supplemental fallback).
- Improve supplemental matching to also consider full declaration identifiers.
- Regenerate material rough icon catalogs and add tests covering supplemental fallback lookups.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #41](https://github.com/openbudgetfun/skribble/pull/41)

#### Add a strict unresolved failure mode to rough icon generation

_Packages:_ _skribble_

- New CLI option: `--fail-on-unresolved`
- When unresolved icons remain, the generator now exits with `StateError` instead of warning-only behavior

This allows CI to enforce complete rough icon coverage once supplemental manifests are in place.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #31](https://github.com/openbudgetfun/skribble/pull/31)

#### Expand generated rough icon font identifier coverage

_Packages:_ _skribble_

- Update rough icon generator so `--font-dart-output` includes **all** resolved Flutter icon identifiers that share a codepoint, not just the first resolved identifier for that codepoint.
- This improves runtime lookup ergonomics for legacy aliases such as `trending_neutral` / `settings_display` while keeping codepoint behavior stable.
- Add parser + widget catalog tests for alias identifier lookups.
- Document alias-inclusive font helper behavior in rough icon docs.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #44](https://github.com/openbudgetfun/skribble/pull/44)

- **skribble**: **Add `--font-dart-output` to rough icon generation.** The flag emits a Dart helper file containing the generated font family constant, codepoint map, and lookup function. This prepares follow-up custom hand-drawn font integration. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #24](https://github.com/openbudgetfun/skribble/pull/24)

#### Sync and enforce committed rough icon generated catalogs

_Packages:_ _skribble_

- Regenerate committed rough icon catalogs with the current generator + supplemental manifest:
  - `packages/skribble/lib/src/generated/material_rough_icons.g.dart`
  - `packages/skribble/lib/src/generated/material_rough_icon_font.g.dart`
- Update `rough-icons-font` workspace script to also emit `material_rough_icon_font.g.dart`.
- Add CI verification job (`rough-icons-generated-sync`) that regenerates and checks these generated files are committed and up to date.
- Add widget test coverage for committed supplemental fallback icon lookups (`adobe`, `face_unlock_sharp`).

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #43](https://github.com/openbudgetfun/skribble/pull/43)

- **skribble**: **Validate `svg-manifest` icon entries for duplicate codepoints.** Duplicate `codePoint` values fail fast with clear `FormatException` details. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #25](https://github.com/openbudgetfun/skribble/pull/25)

#### Add threshold-based unresolved baseline regression gating

_Packages:_ _skribble_

- Add `--max-new-unresolved <int>` to allow bounded unresolved baseline regressions.
- Treat `--fail-on-new-unresolved` as strict mode (equivalent to `--max-new-unresolved 0`).
- Enforce parser validation:
  - `--max-new-unresolved` must be `>= 0`
  - `--max-new-unresolved` requires `--unresolved-baseline`
  - `--fail-on-new-unresolved` and `--max-new-unresolved` are mutually exclusive
- Update docs/README/CLI help and add parser+behavior tests.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #55](https://github.com/openbudgetfun/skribble/pull/55)

#### Add unresolved threshold control to rough icon generation

_Packages:_ _skribble_

- New CLI option: `--max-unresolved <int>`
- Generator fails only when unresolved icon count exceeds the configured threshold
- `--fail-on-unresolved` remains supported as strict mode (`max = 0`)

This enables gradual CI enforcement while unresolved icon remediation is still in progress.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #33](https://github.com/openbudgetfun/skribble/pull/33)

#### Add normalized unresolved baseline output for rough icons

_Packages:_ _skribble_

- New CLI option: `--unresolved-baseline-output <path>`
  - emits a minimal JSON file containing only `unresolved[]` entries
  - uses deterministic sorting for stable baseline diffs
- Keep `--unresolved-output` as the richer diagnostics report (counts, kit, etc.)
- Update workspace baseline refresh script (`melos run rough-icons-baseline`) to use normalized baseline output
- Update docs and README to describe the new flag and workflow.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #38](https://github.com/openbudgetfun/skribble/pull/38)

- **skribble**: **Add workspace scripts for rough icon generation and docs polish.** Add an icons snapshot category to the UI screenshot docs. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #21](https://github.com/openbudgetfun/skribble/pull/21)

#### Clarify and enforce unresolved failure mode flag usage

_Packages:_ _skribble_

- `--fail-on-unresolved` and `--max-unresolved` are now mutually exclusive.
- Running with both flags now fails fast with an `ArgumentError`.
- Add parser test coverage for the conflicting-flag case.
- Update rough icon docs/README and CLI help text to document exclusivity.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #54](https://github.com/openbudgetfun/skribble/pull/54)

#### Add a supplemental manifest fallback for icon resolution

_Packages:_ _skribble_

- New CLI option: `--supplemental-manifest <path>`
- Manifest entries (`identifier`, `codePoint`, `svgPath`) are used as a final fallback when Material and brand SVG sources cannot resolve an icon

This makes it possible to supply custom SVGs for remaining unresolved Material icon codepoints without switching to `--kit svg-manifest`.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #29](https://github.com/openbudgetfun/skribble/pull/29)

#### Add supplemental manifest template output to icon tooling

_Packages:_ _skribble_

- New CLI option: `--supplemental-manifest-output <path>`
- Emits a starter JSON manifest for unresolved icons using the same `icons[]` schema consumed by `--supplemental-manifest`

This streamlines unresolved icon remediation workflows by generating an editable manifest template directly from unresolved results.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #32](https://github.com/openbudgetfun/skribble/pull/32)

- **skribble**: **Add `svg-manifest` icon-kit support to icon generation.** SVG sets can be processed with `--kit svg-manifest --manifest <path>`. Includes manifest parser tests, docs updates, and an example manifest file. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #23](https://github.com/openbudgetfun/skribble/pull/23)

#### Add unresolved baseline regression gating to rough icons

_Packages:_ _skribble_

- New option: `--unresolved-baseline <path>` to load previous unresolved report
- New option: `--fail-on-new-unresolved` to fail only when new unresolved codepoints appear versus baseline
- Unresolved JSON output now includes optional baseline diff fields: `newUnresolvedCount` and `newUnresolved`

This supports incremental CI enforcement by preventing unresolved regressions without blocking on existing unresolved debt.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #34](https://github.com/openbudgetfun/skribble/pull/34)

#### Add `activeGates` to rough icon unresolved report JSON

_Packages:_ _skribble_

- `--unresolved-output` now includes `activeGates[]`, listing which unresolved gates are configured (`unresolved`, `newUnresolved`).
- `failedGates[]` continues to report only gates that actually failed.
- Adds parser coverage for inactive, single-gate, and dual-gate configurations.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #65](https://github.com/openbudgetfun/skribble/pull/65)

#### Add unresolved codepoint summaries to the unresolved report

_Packages:_ _skribble_

- `--unresolved-output` now includes `unresolvedCodePoints[]` (hex strings) alongside existing `unresolved[]` entries.
- When baseline comparison is enabled, reports now include `newUnresolvedCodePoints[]` in addition to `newUnresolved[]`.
- Add parser test coverage for the new summary fields.
- Update rough icon docs/README to document the report payload additions.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #53](https://github.com/openbudgetfun/skribble/pull/53)

#### Add `failedGates` to rough icon unresolved report JSON

_Packages:_ _skribble_

- `--unresolved-output` now includes `failedGates[]`, listing which configured gates failed (`unresolved`, `newUnresolved`).
- Existing booleans (`wouldFail`, `unresolvedGateFailed`, `newUnresolvedGateFailed`) remain unchanged.
- Adds parser coverage for single-gate and dual-gate failure scenarios.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #64](https://github.com/openbudgetfun/skribble/pull/64)

#### Add per-gate failure booleans to the unresolved report

_Packages:_ _skribble_

- `--unresolved-output` now includes `unresolvedGateFailed` and `newUnresolvedGateFailed`.
- The existing `wouldFail` field remains as the aggregate failure summary.
- Update parser tests and rough icon docs/README.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #62](https://github.com/openbudgetfun/skribble/pull/62)

#### Add unresolved report output to rough icon generation

_Packages:_ _skribble_

- New CLI option: `--unresolved-output <path>`
- Emits a JSON report with `resolvedCount`, `unresolvedCount`, and unresolved entries (`codePoint`, `identifiers`)

This helps author follow-up supplemental manifests for unresolved `flutter-material` icon codepoints.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #30](https://github.com/openbudgetfun/skribble/pull/30)

#### Add gating threshold metadata to the unresolved report

_Packages:_ _skribble_

- `--unresolved-output` reports now include threshold fields when configured:
  - `maxUnresolved`, `maxUnresolvedExceeded`
  - `maxNewUnresolved`, `maxNewUnresolvedExceeded`
- Applies to both strict and threshold modes (`--fail-on-unresolved` / `--max-unresolved`, `--fail-on-new-unresolved` / `--max-new-unresolved`).
- Update parser tests plus rough icon docs/README.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #59](https://github.com/openbudgetfun/skribble/pull/59)

#### Add gate mode metadata to the unresolved report JSON

_Packages:_ _skribble_

- `--unresolved-output` now includes:
  - `unresolvedThresholdMode` (`disabled|strict|threshold`)
  - `newUnresolvedThresholdMode` (`disabled|strict|threshold`)
- Keeps existing threshold fields (`maxUnresolved*`, `maxNewUnresolved*`) unchanged.
- Adds parser test coverage for strict/threshold/disabled mode reporting and updates docs/README.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #60](https://github.com/openbudgetfun/skribble/pull/60)

#### Add a `wouldFail` summary field to the unresolved report

_Packages:_ _skribble_

- `--unresolved-output` now includes `wouldFail`, indicating whether configured unresolved gates would fail the current run.
- Works with both unresolved thresholds and baseline-regression thresholds.
- Update rough icon docs/README and parser test coverage.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #61](https://github.com/openbudgetfun/skribble/pull/61)

#### Switch rough icon workspace shortcuts to explicit thresholds

_Packages:_ _skribble_

- Update `melos run rough-icons` and `melos run rough-icons-font` to use `--max-new-unresolved 0` instead of `--fail-on-new-unresolved`.
- Preserves strict behavior while matching the threshold-based workflow used in CI.
- Update rough icon docs/README to describe the strict-equivalent threshold mode.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #58](https://github.com/openbudgetfun/skribble/pull/58)

- **skribble**: **Populate `skribble_emoji` with 50 hand-drawn emoji.** Covers smileys, gestures, hearts/symbols, objects, nature, and activities. Lookup by name and Unicode codepoint now returns real data. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #117](https://github.com/openbudgetfun/skribble/pull/117) · _Closed issues:_ [#112](https://github.com/openbudgetfun/skribble/issues/112)
- **skribble**: **Add the `skribble_emoji` package scaffold.** Add name/codepoint lookup helpers and test infrastructure, ready to accept hand-drawn emoji SVG sources. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #107](https://github.com/openbudgetfun/skribble/pull/107) · _Closed issues:_ [#103](https://github.com/openbudgetfun/skribble/issues/103)
- **skribble**: **Add a "Sketch Notes" example app.** Demonstrate WiredMaterialApp, WiredScaffold, navigation drawer, search, forms, dismissible cards, settings, and about dialog — all using only hand-drawn Wired* widgets. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #108](https://github.com/openbudgetfun/skribble/pull/108) · _Closed issues:_ [#104](https://github.com/openbudgetfun/skribble/issues/104)
- **skribble**: **Make all 8,600+ Material icons available as rough icons.** unified lookup API. Re-exports Material rough icons from `skribble` package, keeps 30 curated custom icons, and provides `lookupSkribbleIconByIdentifier()` that searches custom first then falls back to Material. Adds `rough-icons-skribble` melos script for custom icon regeneration. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #116](https://github.com/openbudgetfun/skribble/pull/116) · _Closed issues:_ [#111](https://github.com/openbudgetfun/skribble/issues/111)

#### Add the `skribble_icons_custom` standalone icon package

_Packages:_ _skribble_

Introduces `packages/skribble_icons_custom` — the first standalone Skribble icon set package, demonstrating the `svg-manifest` kit workflow for non-Material icon sets.

###### New package: `skribble_icons_custom`

- 5 hand-drawn icons: `home`, `search`, `settings`, `star`, `favorite`
- Generated from plain SVG sources via the Skribble rough icon pipeline
- Public API:
  - `kCustomRoughIcons` — compile-time `Map<int, WiredSvgIconData>`
  - `kCustomRoughIconsCodePoints` — identifier → codepoint lookup
  - `lookupCustomRoughIconByIdentifier(String)` → `WiredSvgIconData?`
- Full test coverage (11 tests)
- New `melos run rough-icons-custom` script for regeneration

###### Generator improvement: `--map-name`

Adds `--map-name <name>` flag to `generate_rough_icons.dart` so that non-Material icon sets can name their generated Dart map constant correctly. Defaults to `kMaterialRoughIcons` (no breaking change).

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #100](https://github.com/openbudgetfun/skribble/pull/100)

- **skribble**: **Add the `skribble_icons` package with 30 curated icons.** common UI patterns: navigation, actions, media, communication, and status. Icons are manifest-driven and ready for rough pipeline generation. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #106](https://github.com/openbudgetfun/skribble/pull/106) · _Closed issues:_ [#102](https://github.com/openbudgetfun/skribble/issues/102)
- **skribble**: **Wire `skribble_icons` and `skribble_emoji` into the storybook.** pages, update docs with icon/emoji/font documentation, and add companion package installation instructions. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #119](https://github.com/openbudgetfun/skribble/pull/119) · _Closed issues:_ [#114](https://github.com/openbudgetfun/skribble/issues/114), [#115](https://github.com/openbudgetfun/skribble/issues/115)
- **skribble**: **Add a Rough Icons storybook gallery.** Render the full Material rough icon catalog, expose `materialRoughIconCodePoints` for tooling/showcase use, and include rough-icon screenshot coverage in the screenshot manifest. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #20](https://github.com/openbudgetfun/skribble/pull/20)
- **skribble**: **Expand `WiredMaterialApp` diagnostics and theme variants.** Add wired theme variants plus more of Flutter's `MaterialApp` diagnostics and configuration surface, including navigation notifications, theme animation style, performance / semantics debug flags, checkerboard overlays, and the remaining shared app bootstrapping options needed for near-drop-in parity. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #98](https://github.com/openbudgetfun/skribble/pull/98) · _Closed issues:_ [#95](https://github.com/openbudgetfun/skribble/issues/95) · _Related issues:_ [#85](https://github.com/openbudgetfun/skribble/issues/85)
- **skribble**: **Expand `WiredMaterialApp` with high-value `MaterialApp` parity.** Add high-value `MaterialApp` bootstrapping API, including locale resolution, restoration, scroll behavior, shortcuts/actions, generated titles, `onGenerateInitialRoutes`, and theme animation controls. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #94](https://github.com/openbudgetfun/skribble/pull/94) · _Closed issues:_ [#93](https://github.com/openbudgetfun/skribble/issues/93) · _Related issues:_ [#85](https://github.com/openbudgetfun/skribble/issues/85)
- **skribble**: **Add `WiredMaterialApp.router` for router-based Flutter apps.** Keep `MaterialApp.router` configuration and `WiredTheme` synchronized while using Skribble's hand-drawn app-level theming. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #92](https://github.com/openbudgetfun/skribble/pull/92) · _Closed issues:_ [#87](https://github.com/openbudgetfun/skribble/issues/87) · _Related issues:_ [#85](https://github.com/openbudgetfun/skribble/issues/85), [#86](https://github.com/openbudgetfun/skribble/issues/86)
- **skribble**: **Add `WiredScaffold` and the `WiredMaterialApp` theme bridge.** Introduce `WiredMaterialApp` for syncing `MaterialApp` with `WiredTheme`, and extend `WiredThemeData` with `paperBackgroundColor`, `toColorScheme()`, and `toThemeData()` helpers for aligning app-level `ThemeData` with the hand-drawn palette. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #86](https://github.com/openbudgetfun/skribble/pull/86) · _Closed issues:_ [#85](https://github.com/openbudgetfun/skribble/issues/85)
- **skribble**: **Adopt rough icons in combo, expansion, segmented, and chips.** Updates icon rendering in `WiredCombo`, `WiredExpansionTile`, `WiredSegmentedButton`, and `WiredInputChip` to use `WiredIcon` for a consistent hand-drawn icon style across controls. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #17](https://github.com/openbudgetfun/skribble/pull/17)
- **skribble**: **Adopt rough icons in navigation widgets.** Updates `WiredNavigationBar`, `WiredBottomNavigationBar`, and `WiredNavigationRail` to render destination icons with `WiredIcon` instead of `Icon`, keeping icon visuals consistent with the hand-drawn style and preserving fallback behavior for unsupported glyphs. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #15](https://github.com/openbudgetfun/skribble/pull/15)
- **skribble**: **Adopt rough icons in remaining Material-icon widgets.** Updates icon rendering in `WiredContextMenu`, `WiredColorPicker`, `WiredAvatar` fallback, `WiredNavigationDrawer`, `WiredDismissible`, and `WiredReorderableListView` to use `WiredIcon` for consistent hand-drawn icon styling. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #18](https://github.com/openbudgetfun/skribble/pull/18)
- **skribble**: **Adopt rough icons in search/chip/popup/stepper widgets.** Updates the default icon rendering in `WiredSearchBar`, `WiredChip`, `WiredFilterChip`, `WiredPopupMenuButton`, and `WiredStepper` to use `WiredIcon` for a consistent hand-drawn appearance. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #16](https://github.com/openbudgetfun/skribble/pull/16)
- **skribble**: **Remove skribble_icons_dynamic and add skribble_emoji_gen.** Workspace hygiene: remove skribble_icons_dynamic (deprioritized, zero dependents) and bring skribble_emoji_gen into the workspace. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #132](https://github.com/openbudgetfun/skribble/pull/132)
- **skribble_icons**: **Generate the Skribble font from Recursive Casual outlines.** Improve themed pen widths, typography inheritance, clipping, and repaint stability. Preserve complete OpenMoji 17 sequences and source artwork, regenerate curated icons in their correct view boxes, and retain icon counters. Add reproducible asset generation, pixel regressions, and a responsive notebook exercised by Patrol in Chromium. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #148](https://github.com/openbudgetfun/skribble/pull/148)

### Other

- **skribble**: **Enforce changeset and manifest lint rules on every check.** `monochange check` now fails when a changeset or package manifest violates the configured policy, and the CI `lint` job runs it on every pull request instead of the weaker `monochange step validate`. The enabled rules come from the `changesets/recommended` and `dart/recommended` presets layered with explicit policy: every changeset needs a single H1 summary heading of 8–90 characters with no trailing period and no Conventional Commit prefix, a description that adds information beyond the heading, at least an 80-character body (120 plus a code block for `major` bumps), inline `target: type` entries, and no duplicate targets or change-type section headings. Dart manifests must keep dependencies and assets sorted, keep internal dependency versions consistent with the workspace, declare required package fields and an SDK constraint, avoid git dependencies and unexpected `dependency_overrides` in publishable packages, and declare `publish_to: none` when unmanaged. Locally, `monochange check --fix` auto-fixes the fixable rules (entry and ordering style). _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #168](https://github.com/openbudgetfun/skribble/pull/168)
- **skribble**: **Ship bundled fonts as GitHub release assets.** Release automation now attaches versioned font zips to every GitHub release. The release tag job creates a draft release, the publish workflow packages each font family (`SkribbleRecursive`, `SkribbleGentle`, `SkribblePlayful`, `ArchitectsDaughter`) with `scripts/release/package_fonts.sh` and uploads the archives, and the release is published only after the packages exist on pub.dev and the assets are attached. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #168](https://github.com/openbudgetfun/skribble/pull/168)

### Changed

#### Publish the full Skribble package family

Make all seven workspace packages publicly publishable through a grouped Monochange release PR. Releases now use the shared `publisher` trusted-publishing environment, verify readiness, and run package dry-runs before publishing the complete package group.

```text
monochange step tag-release --from HEAD --push=true
monochange step publish-packages --all
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #150](https://github.com/openbudgetfun/skribble/pull/150)
