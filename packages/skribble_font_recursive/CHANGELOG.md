# Changelog

Earlier unpublished versions are documented in [the pre-release development history](PRE_RELEASE_HISTORY.md).

## [0.4.1](https://github.com/openbudgetfun/skribble/releases/tag/v0.4.1) (2026-11-12)

### Changed

- **No package-specific changes were recorded; `skribble_font_recursive` was updated to 0.4.1 as part of group `main`.**

## [0.4.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.4.0) (2026-11-07)

### Features

#### Calm the Recursive lettering and protect the Noto Sketch default

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #273](https://github.com/openbudgetfun/skribble/pull/273)

Regenerate all Recursive Casual, Linear, and Mono faces with broader outline waves, no independent letter tilt, and smaller vertical movement that keeps base-outline extrema steady. Gentle, Playful, and Expressive now use strengths 6, 10, and 14 instead of 18, 27, and 36. Font names, coverage, advance widths, shaping features, and variable axes stay compatible.

The roughener CLI and `FontRoughener` now default to strength 14. Noto Sketch remains the default across light and dark themes and all roughness levels, with regression coverage for app startup and explicit Recursive selection. A reproducible specimen harness captures the bundled faces at reading sizes in both themes and narrow and wide layouts.

#### Give the Recursive lettering a gentle lean

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #274](https://github.com/openbudgetfun/skribble/pull/274)

Regenerate all 126 static faces and three variable faces with shorter, smooth waves and a deterministic per-glyph lean of at most 0.045 degrees per strength unit. Gentle, Playful, and Expressive now use strengths 12, 20, and 28, with maximum leans of 0.54, 0.9, and 1.26 degrees. Vertical movement is 0.3 of the strength, fades to zero at the base outline's top and bottom, and is reduced for short punctuation; there is no baseline bounce. Font names, coverage, advance widths, shaping, and variation axes stay compatible.

`FontRoughener` and the standalone CLI now default to strength 20 (Playful). The legacy Expressive tool and storybook copies are synchronized with the regenerated faces. Noto Sketch remains the system default, and no Noto font changed.

### Fixes

#### The package READMEs start with a working app

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #276](https://github.com/openbudgetfun/skribble/pull/276)

The `skribble` README on pub.dev now opens with the Flutter and Dart minimums, one `flutter pub add skribble skribble_font_noto_sketch` command, and the same minimal `SkribbleApp` the docs use, including the `WiredMaterialTheme` builder that `WiredInput` and the other Material-wrapping widgets need. It adds the typeface table and the package catalog, drops the contributor-only rough icon pipeline flags (they live in `docs/rough-icon-pipeline.md`), and fixes links that pointed at files outside the package.

The font package READMEs install with `flutter pub add` instead of a pinned version; `skribble_font_recursive` still asked for `^0.1.1`.

- **The Recursive README names the right licence file and version.** The install snippet asked for `skribble_font_recursive: ^0.1.1`, which never resolves to a current release, and the licence row named a `RECURSIVE-OFL.txt` that the package does not ship. It now asks for `^0.3.1` and points at `assets/fonts/OFL.txt`. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #276](https://github.com/openbudgetfun/skribble/pull/276)

## [0.3.1](https://github.com/openbudgetfun/skribble/releases/tag/v0.3.1) (2026-10-08)

### Changed

- **No package-specific changes were recorded; `skribble_font_recursive` was updated to 0.3.1 as part of group `main`.**

## [0.3.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.3.0) (2026-10-08)

### Changed

#### No package-specific changes were recorded; `skribble_font_recursive` was updated to 0.3.0 as part of group `main`.

## [0.2.1](https://github.com/openbudgetfun/skribble/releases/tag/v0.2.1) (2026-09-22)

### Changed

- **No package-specific changes were recorded; `skribble_font_recursive` was updated to 0.2.1 as part of group `main`.**

## [0.2.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.2.0) (2026-09-14)

### Features

#### Split the icon catalog into per-set packages

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

## 0.1.1

- Initial split of the bundled typefaces out of the `skribble` package: 126 static faces and 3 variable fonts across the Casual, Linear, and Mono Linear families at Gentle, Playful, and Expressive roughness.
