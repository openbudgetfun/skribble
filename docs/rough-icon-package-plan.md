# Plan: extract a new rough icon set into its own Dart package

## Goal

Create a **new Dart package** in this workspace that publishes a standalone
hand-drawn icon set generated from SVG sources, instead of baking the new set
into `packages/skribble`.

Suggested placeholder package name:

- `packages/skribble_icons_<set>`

Examples:

- `packages/skribble_icons_brand`
- `packages/skribble_icons_phosphor`
- `packages/skribble_icons_custom`

## Why this shape

The existing rough icon pipeline already supports non-Material icon sets via:

- `packages/skribble/tool/generate_rough_icons.dart`
- `--kit svg-manifest --manifest <path>`

That means the fastest, lowest-risk path is:

1. keep the roughing/generation logic in `packages/skribble`
2. define the new icon set through a manifest
3. generate outputs into a **new package**
4. have the new package depend on `skribble` for `WiredSvgIconData`

This avoids duplicating the roughing tool while still shipping a clean,
separate package for the icon set.

## Proposed package structure

```text
packages/
  skribble/
  skribble_lints/
  skribble_icons_<set>/
    pubspec.yaml
    README.md
    analysis_options.yaml
    lib/
      skribble_icons_<set>.dart
      src/
        generated/
          <set>_rough_icons.g.dart
          <set>_rough_icon_font.g.dart   # optional
    icons/
      ... source svg files or vendored subset ...
    tool/
      <set>.manifest.json
    test/
      <set>_icon_catalog_test.dart
```

## Package API shape

Mirror the Material rough icon API from `packages/skribble` as closely as
possible so usage feels familiar.

Public API should expose:

- `Map<int, WiredSvgIconData>` constant for SVG-backed icons
- `lookup<SetName>RoughIconByIdentifier(String identifier)`
- `lookup<SetName>RoughIconData(String identifier)` for font icons, if font output is generated
- optional `k<SetName>RoughIconsFontFamily`

Example export surface:

```dart
export 'src/generated/<set>_rough_icons.g.dart'
    show
        kMySetRoughIcons,
        lookupMySetRoughIconByIdentifier;

export 'src/generated/<set>_rough_icon_font.g.dart'
    show
        kMySetRoughIconsFontFamily,
        lookupMySetRoughIconsIconData;
```

## Generation strategy

Use the existing `svg-manifest` kit.

### Inputs

Create a manifest at:

- `packages/skribble_icons_<set>/tool/<set>.manifest.json`

Each entry must provide:

- `identifier`
- `codePoint`
- `svgPath`

Example:

```json
{
  "icons": [
    {
      "identifier": "brand_github",
      "codePoint": "0xe001",
      "svgPath": "icons/github.svg"
    }
  ]
}
```

### Outputs

Generate into the new package:

- `lib/src/generated/<set>_rough_icons.g.dart`
- optionally `lib/src/generated/<set>_rough_icon_font.g.dart`
- optionally `tool/icon_exports/rough-svg/`
- optionally `tool/icon_exports/font/`

### Example command

```bash
cd packages/skribble

dart run tool/generate_rough_icons.dart \
  --kit svg-manifest \
  --manifest ../skribble_icons_<set>/tool/<set>.manifest.json \
  --output ../skribble_icons_<set>/lib/src/generated/<set>_rough_icons.g.dart \
  --font-output-dir ../skribble_icons_<set>/tool/icon_exports/font \
  --font-dart-output ../skribble_icons_<set>/lib/src/generated/<set>_rough_icon_font.g.dart \
  --rough-output-dir ../skribble_icons_<set>/tool/icon_exports/rough-svg
```

## Workspace changes required

Update root `pubspec.yaml` workspace list to include the new package:

```yaml
workspace:
  - packages/skribble
  - packages/skribble_lints
  - packages/skribble_icons_<set>
  - apps/skribble_storybook
```

## New package pubspec

The new package should:

- depend on `flutter`
- depend on `skribble` via workspace path/version, because generated files use
  `WiredSvgIconData`
- depend on `flutter_test` in dev dependencies
- depend on `skribble_lints` in dev dependencies

Example outline:

```yaml
name: skribble_icons_<set>
description: Hand-drawn <set> icon set for Skribble.
version: 0.1.0
publish_to: none
resolution: workspace

environment:
  sdk: ^3.11.0
  flutter: ^3.41.0

dependencies:
  flutter:
    sdk: flutter
  skribble:
    path: ../skribble

dev_dependencies:
  flutter_test:
    sdk: flutter
  skribble_lints:
    path: ../skribble_lints
```

## Test plan

Add focused tests in the new package:

- generated lookup returns expected icon by identifier
- generated font lookup returns expected `IconData` when font output exists
- exported map is non-empty
- a sample `WiredIcon.custom(data: ...)` render test succeeds for one icon

Suggested files:

- `packages/skribble_icons_<set>/test/<set>_icon_catalog_test.dart`
- `packages/skribble_icons_<set>/test/<set>_icon_render_test.dart`

## Documentation plan

Update:

- root `README.md` with a short section on standalone icon packages
- new package `README.md` with:
  - install/use instructions
  - sample lookups
  - sample `WiredIcon.custom(...)` usage
  - note that icons are generated via Skribble’s rough icon pipeline

## Release / publishing plan

Ship this as a separate package release rather than a core `skribble` API
expansion.

Changeset strategy:

- one changeset for the new package
- if root docs mention the package, include that in the same PR

## Recommended execution order

1. Create `packages/skribble_icons_<set>/`
2. Add package to root workspace in `pubspec.yaml`
3. Add `pubspec.yaml`, `README.md`, and barrel export file
4. Add source SVGs under `icons/`
5. Add `tool/<set>.manifest.json`
6. Run `generate_rough_icons.dart` with `--kit svg-manifest`
7. Add tests for identifier lookup / render
8. Run:
   - `melos run analyze`
   - package-specific tests
9. Add changeset
10. Open PR focused only on the new package

## Scope boundaries

This plan intentionally does **not** include:

- more `WiredMaterialApp` work
- screenshots for PR review
- changing the Material rough icon catalog in `packages/skribble`

## First PR recommendation

Make the first PR only about scaffolding and generating one small icon set:

- 10–30 icons max
- SVG-manifest based
- no custom provider code

If that lands cleanly, follow with:

- larger icon set expansion
- optional font generation
- storybook/demo integration
