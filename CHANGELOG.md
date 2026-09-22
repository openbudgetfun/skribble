# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.2.1](https://github.com/openbudgetfun/skribble/releases/tag/v0.2.1) (2026-09-22)

Grouped release for `main`.

### Features

#### Coordinate icon roughness across every catalog

_Packages:_ _skribble_

Give filled and outline icons distinct Gentle, Playful, and Expressive treatments through the existing theme. Make SkribbleIcon use the shared cached SVG renderer, preserving source stroke metadata and supporting an explicit drawConfig override.

The storybook applies the selected level to all six icon catalogs and compares all three levels at 24, 48, and 96 pixels in each icon preview.

_Owner:_ Ifiok Jr. · _Introduced in:_ [c9b137d](https://github.com/openbudgetfun/skribble/commit/c9b137da11973f4b00f9bd59d3b30d75e30f6046)

### Fixes

- **skribble**: **Fix loading message typography during startup.** Prevent startup loading messages from inheriting yellow underlines and bold fallback text styles. _Owner:_ Ifiok Jr. · _Introduced in:_ [ec8413d](https://github.com/openbudgetfun/skribble/commit/ec8413d791692b9e8fc6a724e6a627b7df6f6196)

#### Keep hand-drawn icons upright and rounded borders visibly irregular

_Packages:_ _skribble_, _skribble_icons_curated_, _skribble_icons_simple_, _skribble_icons_lucide_, _skribble_icons_bxs_, _skribble_icons_cib_, _skribble_emoji_, _skribble_emoji_gen_

Preserve authored icon endpoints while adding small bends along each stroke. Remove the shared displacement that made unrelated icon sets lean to the right, and regenerate the icon and emoji catalogs. Runtime icon drawing removes overall tilt, while wide rounded borders gain local variation with smooth corner joins.

Normalize insignificant floating-point drift so ARM and x64 generate identical icon and emoji coordinates.

The documentation and storybook activate the rough icon catalog at startup. The storybook bundles the current font package, exposes all six icon catalogs, and adds the missing loading, doodle, fill, typography, and table demonstrations.

_Owner:_ Ifiok Jr. · _Introduced in:_ [26f116a](https://github.com/openbudgetfun/skribble/commit/26f116ae5da5dcdfc1b29b90c341b62ba1fb17f4)

## [0.2.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.2.0) (2026-09-14)

Grouped release for `main`.

### Breaking changes

#### Split the icon catalog into per-set packages

_Packages:_ _skribble_, _skribble_icons_

Icon data used to live in two places: the full Material catalog sat inside `skribble` itself, and `skribble_icons` bundled the 30 curated icons together with re-exports of that Material catalog. Every app paid for 8,600 Material codepoints whether or not it rendered one.

Each set now ships as its own package:

| Package                   | Names  | Style                   | License    |
| ------------------------- | ------ | ----------------------- | ---------- |
| `skribble_icons_simple`   | 3,472  | brand marks             | CC0-1.0    |
| `skribble_icons_curated`  | 30     | curated app vocabulary  | Apache-2.0 |
| `skribble_icons_material` | 8,600+ | Flutter's `Icons`       | Apache-2.0 |
| `skribble_icons_lucide`   | 2,056  | 2px open outlines       | ISC        |
| `skribble_icons_bxs`      | 665    | filled silhouettes      | MIT        |
| `skribble_icons_cib`      | 831    | brand and product marks | CC0-1.0    |

`skribble_icons` keeps its name but becomes the umbrella over all of them.

##### Breaking changes

**The Material catalog moved out of `skribble`.** `material_rough_icons.g.dart` and `material_rough_icon_font.g.dart` now live in `skribble_icons_material`, and `skribble` shrank from a ~31 MiB compressed archive to roughly 1.5 MiB. The catalog's identifier accessors (`materialRoughFontFamily`, `materialRoughFontCodePoints`, `materialRoughIconIdentifiers`, `materialRoughIconCodePoints`, `lookupMaterialRoughFontIcon`) moved with it.

**`WiredIcon` needs a one-time registration.** `WiredIcon(icon: Icons.search)` resolves `IconData` through a catalog that the core library no longer owns. An icon-set package registers it:

```dart
import 'package:skribble_icons/skribble_icons.dart';

void main() {
  registerSkribbleIcons(); // or registerSkribbleMaterialIcons() directly
  runApp(const MyApp());
}
```

Without the call, `WiredIcon` falls back to Flutter's plain `Icon` widget, which renders the Material font glyph. Nothing throws, so this degrades quietly rather than crashing.

##### The typefaces moved to `skribble_font_recursive`

`skribble` was 26 MiB compressed, and 25 of those megabytes were font files. All 129 Recursive-derived faces plus `OFL.txt` now ship from `skribble_font_recursive`; and the `ArchitectsDaughter` placeholder font is deleted outright. Core drops from 26 MB compressed to 432 KB and declares no font families.

Unlike the icon catalogs, no code change is needed to keep the look: declare the package and Flutter registers the families from its pubspec.

```yaml
dependencies:
  skribble_font_recursive: ^0.1.1
```

Apps that skip it fall back to the platform font, which is the point — text-only consumers stop downloading 25 MB of outlines. `WiredFont`, `WiredRoughness`, and `WiredTheme` stay in core and still own the family names; `WiredTheme.fontPackage` now resolves bundled families to `skribble_font_recursive`. Any TextStyle that pinned these faces with `package: 'skribble'` must switch to `package: 'skribble_font_recursive'`.

##### Other changes

**The 30 curated icons are generated once, not twice.** They were previously emitted by both the `svg2roughjs` browser pipeline and the pure-Dart warper, with the runtime reading only the Dart output. The duplicate `skribble_icons.g.dart` is gone, along with the `rough-icons-skribble` and `rough-icons-custom` melos scripts.

**Codepoint bands are allocated per set** so a future merged catalog cannot collide: simple `0xF001–0xF0FF`, lucide `0xE000–0xEFFF`, bxs `0xF100–0xF3FF`, cib `0xF400–0xF7FF`. Material keeps its upstream codepoints.

**The generators emit the identifier map too.** It used to be hand-maintained alongside generated geometry, so the two could drift. Both now come from one run, and `melos run icons-check` re-derives every catalog and fails on a diff.

**SVG `currentColor` renders correctly.** `WiredSvgIcon` treated any parsed colour as "this primitive paints itself", so a `currentColor` stroke resolved to no colour at all and the icon drew nothing. It now maps `currentColor` to the ambient icon colour, which is what makes the Lucide outline set themeable.

##### Provenance and determinism

Every icon and font catalog now records exactly what it was built from. Each package README carries a provenance table, and `tool/asset_sources.txt` is the single registry those tables come from — upstream version, SHA-256, license, and codepoint band.

Regeneration is byte-for-byte deterministic, which is what makes the pinning meaningful: without it, a rebuild would shimmer and review would be meaningless. There is no `Random` in the pipeline. Icon and emoji outlines warp through a fixed sum of sine terms evaluated at each coordinate; font glyphs use an integer hash of a seed and a point index; Material icons derive each seed from `1337 + codePoint`; and every generator sorts entries before assigning codepoints. Verified empirically: regenerating all four icon catalogs twice yields identical digests, and `roughen_fonts.dart --check` rebuilds all 130 font files with zero byte differences.

`dart run packages/skribble_emoji_gen/bin/update_assets.dart` now rebuilds the Iconify catalogs too, so one command refreshes every visual asset. See `docs/asset-provenance.md`.

##### Removals

- `skribble_icons_custom` (5-icon example package, zero dependents)
- `packages/skribble_icons/lib/src/skribble_icon_font.dart`, which documented a `SkribbleIcons.ttf` asset that was never shipped, and `wired_cupertino_icons.dart`, which imported a path that no longer resolved
- `packages/skribble_emoji/tool/download_openmoji.sh`, which pinned OpenMoji 15.1.0 while `update_assets.dart` pinned 17.0.0

_Owner:_ Ifiok Jr. · _Introduced in:_ [77bb664](https://github.com/openbudgetfun/skribble/commit/77bb6649c58d5be1876aec0eb1cc3a2389c7dc89)

### Features

#### Remove internal machinery from the public barrel

_Packages:_ _skribble_

The `package:skribble/skribble.dart` barrel is now grouped (canvas/motion/rough engine extension points, then widgets & theme) and only exports the surface the documentation promises.

Symbols removed from the public barrel:

- `WiredPainter` (in `src/canvas/wired_painter.dart`) — the internal `CustomPainter` adapter that `WiredCanvas` creates. Custom painters extend `WiredPainterBase`, which remains exported.
- `Line`, `IntersectionInfo`, `FillStyle`, `RoughDecorationPainter`, and the rough engine's free geometry/filler helper functions (`src/rough/core.dart`, `src/rough/filler.dart`, `src/rough/decoration.dart`) — pure engine plumbing that no guide, example, or custom painter needs.

All documented engine symbols stay exported: `DrawConfig`, `Randomizer`, `Generator`, `Drawable`, `PointD`, `Filler`, `FillerConfig`, the seven concrete fillers, `Op`/`OpSet`/`OpType`/`OpSetType`, the `drawRough` extension, `RoughDrawing`, and the rough decoration types. `WiredSvgIconData` and `WiredSvgPrimitive` remain exported and unchanged.

This is breaking only for code that imported the removed internals through the barrel. Tests or tools that genuinely need them should import the defining `package:skribble/src/…` library directly.

_Owner:_ Ifiok Jr. · _Introduced in:_ [e248129](https://github.com/openbudgetfun/skribble/commit/e248129304eadb1bc9be97c902ee422a85479fe6)

- **skribble**: **Add WiredLoadingScreen and the brand mark loader rhythm.** WiredLoadingScreen fills the viewport with themed paper, centers one loader, and announces an optional status message as a single live region. WiredLoaderStyle.mark sketches the shipped logo outlines at the logo's pen weight, so a splash can hand over to WiredLogo without the mark jumping. The documentation site now opens with the same mark: an HTML shell sketches it before Flutter starts, then the app keeps it drawing while the page catalog resolves. _Owner:_ Ifiok Jr. · _Introduced in:_ [5b5d1a1](https://github.com/openbudgetfun/skribble/commit/5b5d1a198aff9f3b43d927c994c38d47c51138b4)

#### Add a quarantined Material/Cupertino compatibility layer

_Packages:_ _skribble_

Material and Cupertino interop now lives in one clearly-labelled group, exported from `package:skribble/skribble.dart` and sourced from `lib/src/compat/`. It is the single sanctioned exception to the rule that Skribble core imports only `flutter/widgets.dart` and below.

What it exposes:

- `WiredThemeInterop` converts theme objects both ways: `fromThemeData`, `fromColorScheme`, and `fromCupertinoTheme` derive Skribble tokens (colors, disabled state, stroke width from the shape language, font family), while the existing `toThemeData`/`toColorScheme` gain `toCupertinoThemeData`. `WiredThemeModeInterop` converts `SkribbleThemeMode` to and from Material's `ThemeMode`.
- `WiredMaterialTheme` installs the Material theme and English Material localizations a `SkribbleApp` cannot provide, so Material widgets keep working inside a Skribble app.
- `WiredThemeFromMaterial` and `WiredThemeFromCupertino` let existing Material and Cupertino apps give Wired widgets the host app's palette a screen at a time.
- `WiredMaterialApp` remains for apps that keep `MaterialApp` while migrating.

The compatibility group's job is interop and migration, not Material parity: it does not add new `MaterialApp` passthroughs to `WiredMaterialApp`.

_Owner:_ Ifiok Jr. · _Introduced in:_ [01c60f1](https://github.com/openbudgetfun/skribble/commit/01c60f1043e5db81e893ded768d3ab12367ee95c)

#### Add `SkribbleApp`, a widgets-based app shell

_Packages:_ _skribble_

`SkribbleApp` (and `SkribbleApp.router`) is a new application shell built on Flutter's widgets-layer `WidgetsApp` instead of `MaterialApp`. A Skribble app no longer needs a Material ancestor to run, and the shell installs the Skribble theme by default so `WiredTheme.of(context)` works inside it.

The shell exposes the app-level capability a real app needs using Flutter's own widgets-layer types: `home`, `routes`, `initialRoute`, `onGenerateRoute`, `onGenerateInitialRoutes`, `onUnknownRoute`, `navigatorKey`, `navigatorObservers`, `routerConfig` and the other `Router` hooks, `title`, `onGenerateTitle`, `color`, `builder`, `locale`, `localizationsDelegates`, `supportedLocales`, locale resolution callbacks, `shortcuts`, `actions`, `restorationScopeId`, `pageRouteBuilder`, and the debug switches. `themeMode` uses the new `SkribbleThemeMode` because `ThemeMode` lives in Material; the compatibility layer converts between them.

Two supporting additions:

- `WiredThemeScope` is the Material-free theme boundary behind `WiredTheme`. `WiredTheme.of(context)` now finds either boundary, and `WiredTheme` builds on the scope. Existing behaviour is unchanged.
- `SkribbleLocalizations` and `SkribbleLocalizationsDelegate` provide a widgets-only default localization delegate with correct right-to-left text direction. The shell appends it after any callers' delegates, so apps that pass `flutter_localizations` delegates keep full per-locale strings; the core still does not depend on `flutter_localizations`.

`WiredMaterialApp` remains available with an unchanged public API and is now documented as the transitional Material bridge. It shares the new theme-resolution code path and moved to `lib/src/compat/wired_material_app.dart` (the export from `package:skribble/skribble.dart` is unchanged).

_Owner:_ Ifiok Jr. · _Introduced in:_ [01c60f1](https://github.com/openbudgetfun/skribble/commit/01c60f1043e5db81e893ded768d3ab12367ee95c)

- **skribble**: **Let `WiredButton` render a disabled state.** `WiredButton.onPressed` is now nullable, matching `WiredFilledButton`, `WiredElevatedButton`, `WiredOutlinedButton`, `WiredTextButton`, and `WiredIconButton`. Passing null disables the button: taps are ignored and the label renders with the theme's `disabledTextColor`. Existing callers that pass a non-null callback are unaffected. _Owner:_ Ifiok Jr. · _Introduced in:_ [21befe1](https://github.com/openbudgetfun/skribble/commit/21befe1766f46d939034dd0aa90722d5567d0fbb)

#### Align the button and boolean-input APIs with Material where it is additive

_Packages:_ _skribble_

Auditing the public `Wired*` constructor surfaces against their Material counterparts found places where a migration needed manual edits because the Wired parameter was required or named differently. The additive, source-compatible fixes:

- `WiredCheckbox.onChanged` and `WiredCheckboxListTile.onChanged` are now optional `ValueChanged<bool?>?` instead of required. Passing null disables the control the Material way: the box renders disabled, the tile's tap action is dropped, and neither advertises a tap to assistive technology. Existing callers are unaffected.
- `WiredSlider.onChanged` and `WiredRangeSlider.onChanged` are now optional. Omitting them disables the slider; previously you had to pass `null` explicitly because the parameter was `required`.
- `WiredIconButton` accepts `iconSize` and `color`, mirroring `IconButton.iconSize` and `IconButton.color`. `iconSize` defaults to half of `size`, and `color` takes precedence over the existing `iconColor`, so existing callers are unaffected.

The changeset does not change the bool-returning change callbacks (`WiredToggle.onChange`, `WiredRadio.onChanged`, `WiredRadioListTile.onChanged`, `WiredSlider.onChanged`, `WiredRangeSlider.onChanged`), the `WiredToggle.onChange` name, or the `WiredIconButton.size`/`iconColor` names: those match Material's types and names only with a source-breaking change. They are documented as known deviations in the widget catalog instead.

_Owner:_ Ifiok Jr. · _Introduced in:_ [01c60f1](https://github.com/openbudgetfun/skribble/commit/01c60f1043e5db81e893ded768d3ab12367ee95c)

#### Split the icon catalog into per-set packages

_Packages:_ _skribble_icons_curated_, _skribble_icons_material_, _skribble_icons_lucide_, _skribble_icons_bxs_, _skribble_icons_cib_, _skribble_emoji_gen_, _skribble_font_recursive_

Icon data used to live in two places: the full Material catalog sat inside `skribble` itself, and `skribble_icons` bundled the 30 curated icons together with re-exports of that Material catalog. Every app paid for 8,600 Material codepoints whether or not it rendered one.

Each set now ships as its own package:

| Package                   | Names  | Style                   | License    |
| ------------------------- | ------ | ----------------------- | ---------- |
| `skribble_icons_simple`   | 3,472  | brand marks             | CC0-1.0    |
| `skribble_icons_curated`  | 30     | curated app vocabulary  | Apache-2.0 |
| `skribble_icons_material` | 8,600+ | Flutter's `Icons`       | Apache-2.0 |
| `skribble_icons_lucide`   | 2,056  | 2px open outlines       | ISC        |
| `skribble_icons_bxs`      | 665    | filled silhouettes      | MIT        |
| `skribble_icons_cib`      | 831    | brand and product marks | CC0-1.0    |

`skribble_icons` keeps its name but becomes the umbrella over all of them.

##### Breaking changes

**The Material catalog moved out of `skribble`.** `material_rough_icons.g.dart` and `material_rough_icon_font.g.dart` now live in `skribble_icons_material`, and `skribble` shrank from a ~31 MiB compressed archive to roughly 1.5 MiB. The catalog's identifier accessors (`materialRoughFontFamily`, `materialRoughFontCodePoints`, `materialRoughIconIdentifiers`, `materialRoughIconCodePoints`, `lookupMaterialRoughFontIcon`) moved with it.

**`WiredIcon` needs a one-time registration.** `WiredIcon(icon: Icons.search)` resolves `IconData` through a catalog that the core library no longer owns. An icon-set package registers it:

```dart
import 'package:skribble_icons/skribble_icons.dart';

void main() {
  registerSkribbleIcons(); // or registerSkribbleMaterialIcons() directly
  runApp(const MyApp());
}
```

Without the call, `WiredIcon` falls back to Flutter's plain `Icon` widget, which renders the Material font glyph. Nothing throws, so this degrades quietly rather than crashing.

##### The typefaces moved to `skribble_font_recursive`

`skribble` was 26 MiB compressed, and 25 of those megabytes were font files. All 129 Recursive-derived faces plus `OFL.txt` now ship from `skribble_font_recursive`; and the `ArchitectsDaughter` placeholder font is deleted outright. Core drops from 26 MB compressed to 432 KB and declares no font families.

Unlike the icon catalogs, no code change is needed to keep the look: declare the package and Flutter registers the families from its pubspec.

```yaml
dependencies:
  skribble_font_recursive: ^0.1.1
```

Apps that skip it fall back to the platform font, which is the point — text-only consumers stop downloading 25 MB of outlines. `WiredFont`, `WiredRoughness`, and `WiredTheme` stay in core and still own the family names; `WiredTheme.fontPackage` now resolves bundled families to `skribble_font_recursive`. Any TextStyle that pinned these faces with `package: 'skribble'` must switch to `package: 'skribble_font_recursive'`.

##### Other changes

**The 30 curated icons are generated once, not twice.** They were previously emitted by both the `svg2roughjs` browser pipeline and the pure-Dart warper, with the runtime reading only the Dart output. The duplicate `skribble_icons.g.dart` is gone, along with the `rough-icons-skribble` and `rough-icons-custom` melos scripts.

**Codepoint bands are allocated per set** so a future merged catalog cannot collide: simple `0xF001–0xF0FF`, lucide `0xE000–0xEFFF`, bxs `0xF100–0xF3FF`, cib `0xF400–0xF7FF`. Material keeps its upstream codepoints.

**The generators emit the identifier map too.** It used to be hand-maintained alongside generated geometry, so the two could drift. Both now come from one run, and `melos run icons-check` re-derives every catalog and fails on a diff.

**SVG `currentColor` renders correctly.** `WiredSvgIcon` treated any parsed colour as "this primitive paints itself", so a `currentColor` stroke resolved to no colour at all and the icon drew nothing. It now maps `currentColor` to the ambient icon colour, which is what makes the Lucide outline set themeable.

##### Provenance and determinism

Every icon and font catalog now records exactly what it was built from. Each package README carries a provenance table, and `tool/asset_sources.txt` is the single registry those tables come from — upstream version, SHA-256, license, and codepoint band.

Regeneration is byte-for-byte deterministic, which is what makes the pinning meaningful: without it, a rebuild would shimmer and review would be meaningless. There is no `Random` in the pipeline. Icon and emoji outlines warp through a fixed sum of sine terms evaluated at each coordinate; font glyphs use an integer hash of a seed and a point index; Material icons derive each seed from `1337 + codePoint`; and every generator sorts entries before assigning codepoints. Verified empirically: regenerating all four icon catalogs twice yields identical digests, and `roughen_fonts.dart --check` rebuilds all 130 font files with zero byte differences.

`dart run packages/skribble_emoji_gen/bin/update_assets.dart` now rebuilds the Iconify catalogs too, so one command refreshes every visual asset. See `docs/asset-provenance.md`.

##### Removals

- `skribble_icons_custom` (5-icon example package, zero dependents)
- `packages/skribble_icons/lib/src/skribble_icon_font.dart`, which documented a `SkribbleIcons.ttf` asset that was never shipped, and `wired_cupertino_icons.dart`, which imported a path that no longer resolved
- `packages/skribble_emoji/tool/download_openmoji.sh`, which pinned OpenMoji 15.1.0 while `update_assets.dart` pinned 17.0.0

_Owner:_ Ifiok Jr. · _Introduced in:_ [77bb664](https://github.com/openbudgetfun/skribble/commit/77bb6649c58d5be1876aec0eb1cc3a2389c7dc89)

### Fixes

- **skribble**: **Fix disabled, RTL, and controlled-value behaviour in input widgets.** Button-family widgets now expose `enabled: false` to assistive technology when their callback is null, `WiredSwitch`, `WiredToggle`, and `WiredRadio` no longer advertise a tap action while disabled, `WiredSwitch` and `WiredToggle` mirror their thumb travel in right-to-left layouts, `WiredToggle` follows external value changes, and `WiredSlider` no longer asserts when laid out at zero width. Widget tests for the button, boolean-input, and value-input families were rewritten against Skribble's public API and semantics, with a new guard that blocks reintroducing Material type coupling. _Owner:_ Ifiok Jr. · _Introduced in:_ [a240845](https://github.com/openbudgetfun/skribble/commit/a240845de52e640e6aaa8d40ee66e85398f318f5)

#### Narrow Material imports in files that only needed widgets-layer APIs

_Packages:_ _skribble_

Several files in `packages/skribble/lib` imported `package:flutter/material.dart` (or `flutter/cupertino.dart`) only for APIs that also exist in `flutter/widgets.dart` or `dart:ui`. They now import the narrowest correct dependency, and the Material dependency audit tool classifies `lib/src/compat/` as the sanctioned compatibility layer instead of counting it as rewrite debt.

No public API or rendering behaviour changes.

_Owner:_ Ifiok Jr. · _Introduced in:_ [01c60f1](https://github.com/openbudgetfun/skribble/commit/01c60f1043e5db81e893ded768d3ab12367ee95c)

#### Deduplicate wired base, button, tile, and doodle internals

_Packages:_ _skribble_

Internal-only refactor with no behaviour or API change:

- `wired_base.dart` is split into `wired_paint.dart` (paint factories), `wired_element.dart` (repaint isolation), and `wired_painter_bases.dart` (shape painter bases); `wired_base.dart` re-exports them so existing imports keep working.
- The button family shares one internal `WiredButtonBase`; the checkbox, switch, and radio list tiles share an internal `WiredControlListTile`; both switches share the `useWiredThumbOffset` hook (with new RTL thumb-travel regression tests).
- The logo, loader, and doodle widgets rasterize `DoodleStroke` geometry through one shared `walkDoodleStroke`/`doodleStrokePath` implementation in `doodles/doodle_raster.dart`.

_Owner:_ Ifiok Jr. · _Introduced in:_ [e248129](https://github.com/openbudgetfun/skribble/commit/e248129304eadb1bc9be97c902ee422a85479fe6)

### Documentation

- _Packages:_ _skribble_, _skribble_icons_, _skribble_icons_curated_, _skribble_emoji_, _skribble_emoji_gen_, _skribble_font_roughen_, _skribble_lints_ **Lowercase the skribble brand word across documentation.** READMEs, docs site pages and titles, package descriptions, and source comments now write the brand word as lowercase skribble. Dart identifiers, bundled font families such as SkribbleGentle, asset names, and runtime strings keep their casing, so no API or behaviour changes. _Owner:_ Ifiok Jr. · _Introduced in:_ [5e3937c](https://github.com/openbudgetfun/skribble/commit/5e3937ccb6db77bc38e9ac95d273e018def98843) · _Last updated in:_ [77bb664](https://github.com/openbudgetfun/skribble/commit/77bb6649c58d5be1876aec0eb1cc3a2389c7dc89)

## [0.1.1](https://github.com/openbudgetfun/skribble/releases/tag/v0.1.1) (2026-09-13)

Grouped release for `main`.

### Features

#### Add a shared design kit, bracketed smile, and seeded flourishes

_Packages:_ _skribble_

Add WiredDoodle, WiredDoodleKind, WiredLogo, WiredPalette, and the light/dark WiredThemeData.cuddly factory. The pure Dart flourish and logo geometry also produces the downloadable SVG assets used by Figma and the documentation site.

Rounded outlines now follow two continuous pen passes to avoid tangled corner joins at small sizes. Inputs, cards, and checkboxes have configurable soft corners. Choice, filter, and input chips use solid selected fills to keep small labels readable.

_Owner:_ test · _Introduced in:_ [ea5297d](https://github.com/openbudgetfun/skribble/commit/ea5297df5b179c8cb3acb51c7ab6772a374b78f7)

- **skribble**: **Add animated ink loaders and pencil skeletons.** Add six WiredLoader rhythms, including animated flower and scribble doodles, with reduced-motion support and borrowed animation control. Add hatched skeleton blocks and layout-preserving overlays that hide and disable loading content. Update the original loading indicator to use the orbit renderer and add an interactive loading catalog. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #192](https://github.com/openbudgetfun/skribble/pull/192)
- _Packages:_ _skribble_, _skribble_font_roughen_**Add variable lettering and dedicated weights 300–900.** Ship shared variable fonts for all three roughness levels, with continuous weight, casualness, monospace, and slant axes plus cursive letterform selection. Generate matching upright and italic static weights for every bundled family. Add an interactive comparison, preserve expanded variation deltas while roughening, validate intermediate outlines and shaping, and expose variable family lookup through WiredFont. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #191](https://github.com/openbudgetfun/skribble/pull/191)

### Fixes

- **skribble**: **Reuse displaced icon contours between repaints.** `WiredSvgIcon` sampled every contour and rebuilt its displaced path on each repaint. Sampling runs a tangent evaluation roughly every 0.6 logical pixels, so a 96 px icon re-did thousands of them per frame. The contours are now displaced once per painter and reused, which roughly halves the cost of painting a filled icon. Rendering is unchanged: a fresh painter and a cached one produce identical pixels. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #181](https://github.com/openbudgetfun/skribble/pull/181)
- **skribble**: **Give combo fields consistent spacing and a legible indicator.** Separate the field border from menu rows, inset and center the selected label, and replace the cramped hatched arrow with an outlined triangle. Field and menu height grow with text scaling. Long selections keep space for the indicator, right-to-left layouts place it on the trailing edge, and empty fields retain their border. Wrapped menu items preserve their enabled state and callbacks. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #190](https://github.com/openbudgetfun/skribble/pull/190)
- **skribble**: **Tighten three rough-engine edge cases.** `DrawConfig.copyWith` accepted `fillWeight` and `combineNestedSvgPaths` and dropped both on the floor, so a caller could pass them and silently get nothing; the parameters are gone and passing them is now a compile error. `Filler.buildFillLines` closed the polygon ring by appending to the caller's point list, which corrupted the polygon for the connecting-line pass whenever the hachure angle skipped rotation. `OpSetBuilder.linearPath` copied its accumulated operation list once per edge, making a polygon quadratic in its vertex count; it now appends in place. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #181](https://github.com/openbudgetfun/skribble/pull/181)
- **skribble**: **Export the widgets the API reference already documents.** `WiredLoadingIndicator` and `WiredCircularProgressIndicator` were documented in the API reference but missing from `skribble.dart`, so the only way to reach them was a `package:skribble/src/...` import. `WiredExpansionPanelList`, `WiredExpansionPanel`, and `WiredPaginatedDataTable` had widget tests that imported them the same way. All five are now exported, and the tests import the public library. The unused `wired_transitions.dart` and the `utils/` icon helpers, which nothing imported or documented, are gone. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #181](https://github.com/openbudgetfun/skribble/pull/181)
- **skribble**: **Fix picker dragging and hand-drawn typography.** Enable mouse dragging on WiredCupertinoPicker and the timer wheels built from it. Apply the Wired theme's font family and bundled font package to wheel labels so roughness and typeface choices appear correctly. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #193](https://github.com/openbudgetfun/skribble/pull/193)
- **skribble**: **Keep the hand-drawn fill pattern stable across repaints.** The filler carried its own random stream, separate from the painter's, and nothing replayed it. A card, switch, or slider could hatch differently after a rebuild than it did on first paint, and its pattern depended on which other filled widgets had painted before it. Both streams now reset before each shape is prepared, so a shape reproduces its ink exactly. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #181](https://github.com/openbudgetfun/skribble/pull/181)
- **skribble**: **Stop rebuilding a themed subtree when the theme has not changed.** `WiredThemeData` had no value equality, so the inherited theme compared object identity and notified every descendant on each rebuild — the documented `copyWith`-per-build pattern rebuilt the whole subtree every frame. Theme data now compares by value and builds its `DrawConfig` once per instance, and `WiredMaterialApp` caches its four `ThemeData` conversions instead of re-running `ColorScheme.fromSeed` on each frame. System dark mode and high contrast are read through `MediaQuery`, so toggling either repaints the app rather than waiting for an unrelated rebuild. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #181](https://github.com/openbudgetfun/skribble/pull/181)

### Other

- _Packages:_ _skribble_, _skribble_font_roughen_**Compare experimental Casual and coding fonts.** Add a repository-only font experiment with real text ligatures, optional Casual swashes, a hand-drawn Recursive Code Casual family, and an interactive comparison. The CI job checks shaping, font metadata, character coverage and monospace advances. Published font assets and package font choices are unchanged. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #185](https://github.com/openbudgetfun/skribble/pull/185)

## [0.1.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.1.0) (2026-09-11)

Grouped release for `main`.

### Features

- **skribble**: **Add the hand-drawn emoji package with the complete OpenMoji set.** The `skribble_emoji` package ships 1,827 emoji generated from OpenMoji artwork — early scaffolds served 50 — with lookup by name and Unicode codepoint, a generation pipeline and download helper, complete OpenMoji 17 sequences, and source colour palettes preserved through the rough pipeline. `PrecomputedEmoji` draws the same API (fromName, fromUnicode, placeholder fallback) directly via `canvas.drawPath` for performance-critical screens, and the `skribble_emoji_gen` package hosts the asset generation in the workspace. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #123](https://github.com/openbudgetfun/skribble/pull/123) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)

#### Add ink interaction styles and rich-text selection

_Packages:_ _skribble_

Default to Gentle roughness and its bundled font. Add WiredSelectionArea for native rich-text selection with Wired handles and a localized copy toolbar. Add cascading WiredInkInteraction styles for still ink, pressure feedback, and optional button redraws, while preserving reduced motion and consumer-owned animations.

Preserve slightly uneven solid polygon fills without the large spline bulge on wide buttons.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #159](https://github.com/openbudgetfun/skribble/pull/159) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)

- _Packages:_ _skribble_, _skribble_font_roughen_**Generate the skribble fonts from Recursive Casual outlines.** All skribble typefaces are generated from Recursive Casual outlines via the FontForge `roughen_font.py` script, replacing the earlier Architects Daughter bundling and the `google_fonts` runtime dependency. Each family ships genuine regular, bold, italic, and bold-italic styles, produced with aggressive contour displacement applied to on-curve and off-curve Bezier control points. `WiredFont.casual`, `linear`, and `mono` are theme-level font choices, each following the Gentle, Playful, and Expressive roughness levels with matching four-style families, while `WiredThemeData.fontFamily` overrides and the Casual default are preserved. Themed pen widths, typography inheritance, clipping, and repaint stability were reworked, font spacing and shaping are preserved, the numeric roughening tool accepts named custom font families, and asset generation is reproducible with pixel regressions and a responsive notebook exercised by Patrol in Chromium. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #148](https://github.com/openbudgetfun/skribble/pull/148) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)
- **skribble**: **Add ink borders and hatch drawing with WiredDraw.** Add opt-in border and hatch drawing with WiredDraw and WiredDrawTransition, using standard Flutter animations. Motion settings cascade from the theme and respect reduced motion. Buttons reinforce their ink on hover, focus, and press. Cache prepared geometry for paint-only updates and preserve legacy custom painters. Let naturally sized cards contain responsive LayoutBuilder content. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #152](https://github.com/openbudgetfun/skribble/pull/152) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)
- **skribble**: **Add the Material long-tail parity widgets.** The final Material parity audit batches add hand-drawn widgets mirroring the M3 APIs: `WiredCarouselView` (itemExtent/height/children/shrinkWrap with optional hachure fill), `WiredSearchAnchor` and `WiredSearchController` pairing a collapsible `WiredSearchBar` (with `onTap` and `autoFocus`) with an in-place suggestions view, `WiredDateRangePickerDialog` plus `showWiredDateRangePicker` reusing the calendar's month-grid language, `WiredLicensePage` plus `showWiredLicensePage` rendered from `LicenseRegistry`, `WiredGridTile` and `WiredGridTileBar` with rough borders and the publicly exported `WiredInkSplashFactory`, `WiredMergeableMaterial` with its slice/gap API family and animated merging, `WiredCheckboxMenuButton` and `WiredRadioMenuButton` wired into menu anchoring with tristate and toggleable semantics, `WiredAboutListTile`, and the top-level `showWiredTimePicker` dialog helper. Storybook showcases, widget catalog entries, and widget tests cover every widget. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #136](https://github.com/openbudgetfun/skribble/pull/136) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)

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

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #138](https://github.com/openbudgetfun/skribble/pull/138) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)

#### Make Playful the default roughness with executable docs

_Packages:_ _skribble_

Make Playful the default roughness and lettering, with Gentle and Expressive still available through `WiredThemeData`. Add executable documentation examples with matching highlighted source, editable parameters, persistent roughness choices, and a comparison of roughened Recursive Casual and Sans Linear.

Fix long chip and grid-tile labels on narrow layouts and calendar headers and weekday columns on mobile. Range-slider thumbs now use the rough painter; disabled sliders ignore input and external endpoint changes update the displayed range.

Add `WiredRangeSlider.between`, `WiredCombo.options`, `WiredCupertinoTabBar.destinations`, and `WiredAnimatedIcon.menuClose` convenience constructors so those examples do not require Material types in consumer code.

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #161](https://github.com/openbudgetfun/skribble/pull/161) · _Related issues:_ [#160](https://github.com/openbudgetfun/skribble/issues/160), [#174](https://github.com/openbudgetfun/skribble/issues/174)

- **skribble**: **Add rough icon rendering and the generation pipeline.** `WiredIcon` and `WiredSvgIcon` render sketch-style icons and wire into `WiredIconButton` and `WiredFloatingActionButton`. The kit-agnostic CLI (keeping `generate_material_rough_icons.dart` as a compatibility alias, with `--list-kits` for discoverability) converts icon kits through a pluggable provider seam with a Deno conversion script and an optional SVG-to-TTF rough icon font step. `--font-dart-output` emits a Dart helper containing the font family constant, codepoint map, and lookup function, including every resolved Flutter identifier that shares a codepoint so legacy aliases such as `trending_neutral` resolve. Public catalog helpers expose identifier-based rough SVG and font `IconData` lookup plus font family and codepoint accessors, and generated Dart uses single-quoted string literals so output passes `dart analyze --fatal-infos`. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #14](https://github.com/openbudgetfun/skribble/pull/14) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)
- **skribble**: **Build the storybook, example app, and documentation experience.** The storybook renders every gallery with lazy grids, search, and per-item detail popups — covering the full Material rough icon catalog (with `materialRoughIconCodePoints` exposed for tooling and showcase use), the emoji set, and companion icon, emoji, and font documentation pages. A "Sketch Notes" example app demonstrates `WiredMaterialApp`, `WiredScaffold`, navigation drawer, search, forms, dismissible cards, settings, and the about dialog using only Wired widgets. A font specimen page shows every glyph of the bundled typeface across weights, styles, and sizes; the storybook deploys as a live web preview beside the docs site on GitHub Pages with a Live Showcase section; and the documentation adds the Jaspr usage guide plus the Iconify and simple-icons expansion roadmap. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #119](https://github.com/openbudgetfun/skribble/pull/119) · _Closed issues:_ [#114](https://github.com/openbudgetfun/skribble/issues/114), [#115](https://github.com/openbudgetfun/skribble/issues/115) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)
- **skribble**: **Preserve source colours through the roughened rendering pipeline.** `WiredSvgPrimitive` carries `fillColor`, `strokeColor`, and `strokeWidth`, SVG paint attributes parse with group inheritance, and every primitive paints with its own colour — rough solid fill for enclosed areas (now the icon default, replacing hachure) and wobbled outlines for strokes. Rough engine parameters were amplified for a clearly hand-drawn look at any size: maxRandomnessOffset 3x, roughness 2.4, bowing 2.2, curveFitting 0 for jagged polylines, fill wobble amplitude up to shortestSide/8, and a double-pass canvas translate that layers pen strokes on per-colour primitives while keeping visible centres in small circular controls. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #141](https://github.com/openbudgetfun/skribble/pull/141) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)
- **skribble_icons_custom**: **Add the skribble_icons and skribble_icons_custom icon packages.** `skribble_icons` makes the full Material icon catalogue available as rough icons — more than 8,600 codepoints alongside a curated custom set — with roughened paths baked in at build time for 10-18x faster rendering and a unified `lookupSkribbleIconByIdentifier()` that searches custom artwork before falling back to Material. A runtime-roughening `skribble_icons_dynamic` variant was evaluated and removed again as deprioritized with zero dependents. `skribble_icons_custom` is the standalone icon-set package (hand-drawn home, search, settings, star, and favorite) generated through the `svg-manifest` kit workflow, exposing `kCustomRoughIcons`, codepoint and identifier lookups, and a `melos run rough-icons-custom` regeneration script. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #116](https://github.com/openbudgetfun/skribble/pull/116) · _Closed issues:_ [#111](https://github.com/openbudgetfun/skribble/issues/111) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)

### Fixes

- **skribble**: **Add a hand-drawn corner radius to the button widgets.** Give `WiredButton`, `WiredElevatedButton`, `WiredFilledButton`, and `WiredOutlinedButton` a small, hand-drawn 6 px corner radius. Set `borderRadius: BorderRadius.zero` for square corners or use `BorderRadius.only` for different corners. Both straight edges and corner arcs inherit the theme's roughness. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #131](https://github.com/openbudgetfun/skribble/pull/131) · _Related issues:_ [#130](https://github.com/openbudgetfun/skribble/issues/130), [#174](https://github.com/openbudgetfun/skribble/issues/174)
- _Packages:_ _skribble_, _skribble_font_roughen_**Correct the font notice and add a portable design kit.** Correct the Recursive-derived font notice and preserve it beside distributed font copies. Add a reproducible design kit with all bundled fonts, editable SVG pen specimens, layout metadata, and static motion references. Document Figma font upload and separate verified font and SVG icon export commands. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #164](https://github.com/openbudgetfun/skribble/pull/164) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)
- **skribble**: **Add Patrol end-to-end journeys to the storybook.** Add Patrol + integration test configuration and journeys for the storybook: a `patrol:` pubspec block, cross-page journey tests (icons, emoji, font specimen, long-tail widgets), gitignored patrol artifacts, and a new "E2E Testing" guide documenting the three testing tiers. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #139](https://github.com/openbudgetfun/skribble/pull/139) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)

#### Upgrade the workspace to Flutter 3.47 / Dart 3.13

_Packages:_ _skribble_

- Bump the pinned SDK in `.fvmrc` from 3.41.1 to 3.47.0
- Raise Dart SDK constraints to `^3.13.0` and Flutter constraints to `^3.47.0`
- Regenerate rough-icon catalogs with the Dart 3.13 formatter (canonical output shape changes for long single-argument calls)
- Resolve new analyzer diagnostics (`unnecessary_unawaited`, `prefer_initializing_formals`, `prefer_if_elements_to_conditional_expressions`, deprecated `one_member_abstracts`, `strict_top_level_inference` batch)

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #130](https://github.com/openbudgetfun/skribble/pull/130) · _Related issues:_ [#130](https://github.com/openbudgetfun/skribble/issues/130), [#174](https://github.com/openbudgetfun/skribble/issues/174)

- **skribble**: **Accept flexible key and format spellings in unresolved baselines.** Baseline files load as unresolved reports (`unresolved[]`), supplemental manifests (`icons[]`), or minimal top-level codepoint lists, with the list key accepted in every common spelling: `unresolvedCodePoints`, `unresolvedCodepoint`, `unresolved_code_points`, `unresolved_codepoint`, `unresolved-code-points`, `unresolved-codepoints`, `codePoints`, `codePoint`, `codepoints`, `codepoint`, `code_points`, and `code-points`, including the singular forms of each family. Object entries accept `codePoint`, `codepoint`, `code_point`, and `code-point` field aliases. Parser diagnostics name the keys found in unrecognized JSON objects, report recognized keys carrying non-list values, and raise a targeted `FormatException` when an entry lacks any codepoint field; every spelling and failure mode has parser test coverage. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #48](https://github.com/openbudgetfun/skribble/pull/48) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)
- **skribble**: **Gate rough icon regressions in CI with a committed baseline.** `melos run rough-icons` and `rough-icons-font` generate against the committed baseline `material_rough_icons.unresolved-baseline.json` with `--max-new-unresolved 0`, and `melos run rough-icons-baseline` refreshes it from normalized output (`--unresolved-baseline-output`, with `--unresolved-baseline-output-format codepoints` as the default shape). `scripts/check_rough_icons_ci.sh` drives `regression`, `baseline-sync`, and `generated-sync` modes (workspace shortcut `melos run rough-icons-ci-check`) with optional `ROUGH_ICONS_MAX_UNRESOLVED` and `ROUGH_ICONS_MAX_NEW_UNRESOLVED` thresholds that default to zero, prints and saves sync diffs, and cleans up report files on success. CI runs the same checks, uploads the unresolved report plus baseline and generated sync-diff artifacts on failure, and verifies the committed generated catalogs stay in sync with the current generator. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #39](https://github.com/openbudgetfun/skribble/pull/39) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)
- **skribble**: **Complete rough icon coverage with fallback sources and supplemental manifests.** Resolution falls back from Material SVG sources to a best-effort `simple-icons` source (`--brand-icons-source`, with slug mappings such as `woo_commerce` to `woocommerce`) and then to a user-supplied supplemental manifest (`--supplemental-manifest`) whose identifier, codePoint, and svgPath entries close remaining gaps; committed supplemental assets cover the `face_unlock*` and `adobe*` families and are passed by default in workspace scripts and CI. `--supplemental-manifest-output` emits an editable starter manifest from unresolved results, `--kit svg-manifest --manifest <path>` processes arbitrary SVG sets with `--map-name` naming the generated constant, alias mappings recover `label_outline` and `wifi_tethering_error` variants, codepoint strings parse as bare hex, `U+`-prefixed, `0x`, and decimal forms, and duplicate manifest codepoints fail fast with a clear `FormatException`. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #29](https://github.com/openbudgetfun/skribble/pull/29) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)
- **skribble**: **Report unresolved icons and gate generation on thresholds.** `--unresolved-output` writes a JSON report containing `resolvedCount`, `unresolvedCount`, unresolved entries with identifiers, hex summaries (`unresolvedCodePoints[]` and, with a baseline, `newUnresolvedCodePoints[]`), gate configuration and outcomes (`activeGates[]`, `failedGates[]`, per-gate failure booleans, and the aggregate `wouldFail`), and threshold metadata including each gate's mode (`disabled`, `strict`, or `threshold`) and configured maxima. Gating comes in strict and threshold forms for both total unresolved icons (`--fail-on-unresolved` / `--max-unresolved`) and baseline regressions (`--fail-on-new-unresolved` / `--max-new-unresolved` against `--unresolved-baseline`, reporting `baselineUnresolvedCount`, `resolvedSinceBaseline*`, and `newUnresolved*` diff fields). Mutually exclusive flag combinations, negative thresholds, and thresholds without a baseline fail fast. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #30](https://github.com/openbudgetfun/skribble/pull/30) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)
- **skribble**: **Add the skribble_icons and skribble_icons_custom icon packages.** `skribble_icons` makes the full Material icon catalogue available as rough icons — more than 8,600 codepoints alongside a curated custom set — with roughened paths baked in at build time for 10-18x faster rendering and a unified `lookupSkribbleIconByIdentifier()` that searches custom artwork before falling back to Material. A runtime-roughening `skribble_icons_dynamic` variant was evaluated and removed again as deprioritized with zero dependents. `skribble_icons_custom` is the standalone icon-set package (hand-drawn home, search, settings, star, and favorite) generated through the `svg-manifest` kit workflow, exposing `kCustomRoughIcons`, codepoint and identifier lookups, and a `melos run rough-icons-custom` regeneration script. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #116](https://github.com/openbudgetfun/skribble/pull/116) · _Closed issues:_ [#111](https://github.com/openbudgetfun/skribble/issues/111) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)
- **skribble**: **Build the WiredMaterialApp shell and Material theme bridge.** `WiredMaterialApp` syncs `MaterialApp` with `WiredTheme`, including a `.router` constructor that keeps `MaterialApp.router` configuration and the hand-drawn theme synchronized. The bootstrapping surface covers locale resolution, restoration, scroll behaviour, shortcuts and actions, generated titles, `onGenerateInitialRoutes`, theme animation style, navigation notifications, performance and semantics debug flags, and checkerboard overlays for near drop-in parity with `MaterialApp`. `WiredThemeData` gains `paperBackgroundColor`, `toColorScheme()`, and `toThemeData()` helpers for aligning app-level `ThemeData` with the hand-drawn palette, and `WiredScaffold` provides the hand-drawn scaffold. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #86](https://github.com/openbudgetfun/skribble/pull/86) · _Closed issues:_ [#85](https://github.com/openbudgetfun/skribble/issues/85) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)
- **skribble**: **Adopt rough icons across wired widgets.** `WiredIcon` replaces `Icon` for destination and action icons across the library so icon visuals stay consistently hand-drawn: navigation bars, bottom navigation, and navigation rail; combo boxes, expansion tiles, segmented buttons, and input chips; search bars, filter chips, popup menus, and steppers; and context menus, the colour picker, avatar fallbacks, the navigation drawer, dismissible, and reorderable list views — with fallback behaviour preserved for unsupported glyphs. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #17](https://github.com/openbudgetfun/skribble/pull/17) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)

### Other

- **skribble**: **Harden release and CI infrastructure.** Release automation attaches versioned font zips to every GitHub release: the release tag job creates a draft release, the publish workflow packages each font family (`SkribbleRecursive`, `SkribbleGentle`, `SkribblePlayful`, `ArchitectsDaughter`) via `scripts/release/package_fonts.sh`, and the release publishes only after the packages exist on pub.dev and the assets are attached. CI gains `publish-check` and `publish-check-release` jobs that dry-run pub.dev publishing for every package as-is and on the would-be release commit, and the devenv git-hooks inputs were fixed so the lint, test, and coverage jobs run. Changeset and manifest lint rules are enforced by `monochange check` on every pull request, and the release PR branch prefix stays at `chore/release` — renaming it while a release PR is open orphans the long-running request, and recreating it exceeds GitHub's 65536-character body limit. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #168](https://github.com/openbudgetfun/skribble/pull/168) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)

### Changed

#### Publish the full skribble package family

Make all seven workspace packages publicly publishable through a grouped Monochange release PR. Releases now use the shared `publisher` trusted-publishing environment, verify readiness, and run package dry-runs before publishing the complete package group.

```text
monochange step tag-release --from HEAD --push=true
monochange step publish-packages --all
```

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #150](https://github.com/openbudgetfun/skribble/pull/150) · _Related issues:_ [#174](https://github.com/openbudgetfun/skribble/issues/174)
