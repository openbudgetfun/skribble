---
title: Custom Icon Sets
description: How to generate hand-drawn icon fonts from Material Icons or custom SVGs using Skribble's rough icon pipeline, and how to use them with WiredIcon.
---

# Custom Icon Sets

Skribble includes a CLI tool that converts vector icons into rough, hand-drawn versions. The pipeline takes SVG sources, runs them through `svg2roughjs` to add wobble and imperfection, and optionally generates an icon font with Dart helper code.

## Overview of the rough icon pipeline

The pipeline runs in these stages:

1. **Resolve declarations** -- load icon identifiers and code points from a provider
2. **Resolve SVG sources** -- find the source SVG file for each icon
3. **Normalize** -- scale source SVGs to a larger viewBox for better rough detail
4. **Rough** -- run `svg2roughjs` (via a Deno wrapper) to produce sketchy SVG output
5. **Scale down** -- scale rough output back to original icon dimensions
6. **Generate outputs** -- emit Dart maps, rough SVG files, icon fonts, and reports

The CLI entry point is:

```
packages/skribble/tool/generate_rough_icons.dart
```

## Icon kit providers

The CLI uses an `IconKitProvider` abstraction. Each provider knows how to load declarations and resolve SVG sources for a particular icon set.

List available providers:

```bash
cd packages/skribble
dart run tool/generate_rough_icons.dart --list-kits
```

### flutter-material kit

Generates rough icons from the Flutter Material icon set. This is the default kit used by the main Skribble package.

How it works:

1. Reads `IconData` declarations from the Flutter SDK
2. Resolves source SVGs from `@material-design-icons/svg` and `@material-symbols/svg-400`
3. Falls back to `simple-icons` for brand/social icons not covered by Material SVG packages
4. Generates the `material_rough_icons.g.dart` catalog and optional icon font

```bash
cd packages/skribble
dart run tool/generate_rough_icons.dart \
  --kit flutter-material \
  --output lib/src/generated/material_rough_icons.g.dart \
  --rough-output-dir tool/icon_exports/material-rough-svg \
  --font-output-dir tool/icon_exports/material-rough-font \
  --font-dart-output lib/src/generated/material_rough_icon_font.g.dart
```

### svg-manifest kit

Generates rough icons from any custom SVG collection defined by a JSON manifest. This is the kit you use for your own icon sets.

```bash
cd packages/skribble
dart run tool/generate_rough_icons.dart \
  --kit svg-manifest \
  --manifest path/to/my_icons.manifest.json \
  --output lib/src/generated/my_rough_icons.g.dart \
  --rough-output-dir tool/icon_exports/my-rough-svg \
  --font-dart-output lib/src/generated/my_rough_icon_font.g.dart
```

## Creating a manifest JSON file

The manifest file defines icons for the `svg-manifest` kit. It can use either a top-level list or an object with an `icons` key.

### Object format

```json
{
  "icons": [
    {
      "identifier": "app_logo",
      "codePoint": "0xe001",
      "svgPath": "assets/icons/app_logo.svg"
    },
    {
      "identifier": "notification_bell",
      "codePoint": "0xe002",
      "svgPath": "assets/icons/notification_bell.svg"
    },
    {
      "identifier": "settings_gear",
      "codePoint": "0xe003",
      "svgPath": "assets/icons/settings_gear.svg"
    }
  ]
}
```

### List format

```json
[
  {
    "identifier": "app_logo",
    "codePoint": "0xe001",
    "svgPath": "assets/icons/app_logo.svg"
  }
]
```

### Field reference

| Field        | Required | Description                                                                                                                  |
| ------------ | -------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `identifier` | Yes      | Unique string identifier for the icon (used as the Dart field name)                                                          |
| `codePoint`  | Yes      | Unique code point -- accepts decimal (`57345`), hex string (`"0xe001"`), bare hex (`"e001"`), or Unicode format (`"U+E001"`) |
| `svgPath`    | Yes      | Path to the source SVG file (relative to the manifest file location)                                                         |

The `svgPath` field also accepts the aliases `svg` and `path`.

## Running the generator CLI

### Full options

```bash
dart run tool/generate_rough_icons.dart \
  --kit <flutter-material|svg-manifest> \
  --manifest <path>                        # required for svg-manifest kit
  --output <path>                          # Dart map output file
  --rough-output-dir <path>                # directory for rough SVG files
  --font-output-dir <path>                 # directory for icon font files
  --font-dart-output <path>                # Dart helpers for the icon font
  --rough-normalize-viewbox <int>          # viewBox size for normalization (default: 128)
  --unresolved-output <path>               # JSON report of unresolved icons
  --supplemental-manifest <path>           # fallback manifest for unresolved icons
  --supplemental-manifest-output <path>    # template manifest for unresolved icons
  --unresolved-baseline <path>             # baseline file for regression checks
  --unresolved-baseline-output <path>      # updated baseline output
  --unresolved-baseline-output-format <full|codepoints>
  --fail-on-unresolved                     # fail if any icon is unresolved
  --max-unresolved <int>                   # fail if unresolved count exceeds threshold
  --fail-on-new-unresolved                 # fail if new unresolved icons appear vs baseline
  --max-new-unresolved <int>               # fail if new unresolved count exceeds threshold
  --brand-icons-source <path>              # path to simple-icons package
  --rough-only                             # skip font generation
```

### Melos shortcuts

From the repository root:

```bash
# Generate rough icon catalog and font
melos run rough-icons

# Generate icon font only
melos run rough-icons-font

# Refresh the unresolved baseline file
melos run rough-icons-baseline

# Run full CI-equivalent checks locally
melos run rough-icons-ci-check
```

## Using generated icon maps with WiredIcon

The generated catalog maps code points to `WiredSvgIconData` objects. The `WiredIcon` widget looks up icons in this catalog automatically:

```dart
import 'package:flutter/material.dart';
import 'package:skribble/skribble.dart';

// WiredIcon automatically renders a rough version of Material Icons
WiredIcon(
  icon: Icons.home,
  size: 32,
  color: Colors.black,
  semanticLabel: 'Home',
)
```

When a Material icon exists in the generated `kMaterialRoughIcons` map, `WiredIcon` renders the rough SVG version. When the icon is not in the catalog, it falls back to Flutter's standard `Icon` widget.

### Fill styles

`WiredIcon` supports four fill styles:

```dart
// Solid fill (default)
WiredIcon(icon: Icons.star, fillStyle: WiredIconFillStyle.solid)

// No fill -- outline only
WiredIcon(icon: Icons.star, fillStyle: WiredIconFillStyle.none)

// Hachure fill -- parallel diagonal strokes
WiredIcon(icon: Icons.star, fillStyle: WiredIconFillStyle.hachure)

// Cross-hatch fill -- two overlapping hachure passes
WiredIcon(icon: Icons.star, fillStyle: WiredIconFillStyle.crossHatch)
```

### WiredSvgIcon for direct SVG icon data

If you have a `WiredSvgIconData` object (from a custom-generated catalog), use `WiredSvgIcon` directly:

```dart
WiredSvgIcon(
  data: myCustomIconData,
  size: 24,
  color: Colors.blue,
  semanticLabel: 'Custom icon',
  fillStyle: WiredIconFillStyle.hachure,
  strokeWidth: 1.6,
  hachureGap: 2.25,
  hachureAngle: 320,
)
```

### Lookup functions

The generated code provides several lookup utilities:

```dart
// Look up rough icon data by IconData
final data = lookupMaterialRoughIcon(Icons.home);

// Look up by identifier string
final data = lookupMaterialRoughIconByIdentifier('home');

// Look up font icon data by identifier
final iconData = lookupMaterialRoughFontIcon('home');

// Get all identifiers and code points
final identifiers = materialRoughIconIdentifiers;
final codePoints = materialRoughIconCodePoints;

// Get the font family name
final fontFamily = materialRoughFontFamily;
```

## The skribble_icons_custom package

The `packages/skribble_icons_custom/` directory is a working example of a custom icon package built on the `svg-manifest` kit. Use it as a template for your own icon packages:

```
packages/skribble_icons_custom/
  lib/
    src/
      generated/
        custom_rough_icons.g.dart        # generated icon catalog
        custom_rough_icon_font.g.dart    # generated font helpers
  tool/
    icons/                               # source SVG files
    custom_icons.manifest.json           # manifest file
```

## Regression gating and baseline management

The CLI supports regression detection to prevent accidental loss of icon coverage.

### Baseline file

The baseline file records which icons are currently unresolved. Generate it with:

```bash
melos run rough-icons-baseline
```

This writes the baseline to:

```
packages/skribble/tool/examples/material_rough_icons.unresolved-baseline.json
```

### CI regression checks

In CI, the pipeline compares current unresolved icons against the baseline. New unresolved icons cause the build to fail:

```bash
dart run tool/generate_rough_icons.dart \
  --kit flutter-material \
  --rough-only \
  --unresolved-baseline packages/skribble/tool/examples/material_rough_icons.unresolved-baseline.json \
  --fail-on-new-unresolved
```

The `--max-new-unresolved 0` flag (used by the workspace Melos scripts) is equivalent to `--fail-on-new-unresolved`.

### Local CI-equivalent checks

Run the same checks locally:

```bash
# Run all checks
./scripts/check_rough_icons_ci.sh all

# Individual checks
./scripts/check_rough_icons_ci.sh regression
./scripts/check_rough_icons_ci.sh baseline-sync
./scripts/check_rough_icons_ci.sh generated-sync
```

On sync-check failures, the script prints `git diff` output and saves diff files for inspection.

### Unresolved report

The `--unresolved-output` flag emits a JSON report with details about every unresolved icon:

```json
{
  "kit": "flutter-material",
  "resolvedCount": 2450,
  "unresolvedCount": 12,
  "wouldFail": false,
  "unresolved": [
    { "codePoint": "0xe001", "identifiers": ["some_icon"] }
  ]
}
```

CI uploads this as an artifact for debugging.

## Brand icons via simple-icons fallback

Some Flutter Material icon identifiers (like social media brand icons) do not have corresponding SVGs in the Material SVG packages. The CLI can resolve these from the `simple-icons` npm package:

- **Auto mode** (default): the CLI tries to `npm pack simple-icons` and extract the needed SVGs
- **Manual source**: pass `--brand-icons-source <path>` to point at a local `simple-icons` directory

For icons that are missing from both Material SVG packages and `simple-icons`, use a supplemental manifest:

```bash
dart run tool/generate_rough_icons.dart \
  --kit flutter-material \
  --supplemental-manifest tool/examples/material_rough_icons.supplemental.manifest.json
```

The supplemental manifest uses the same JSON format as the `svg-manifest` kit.

## Runtime prerequisites

The rough icon generator requires these tools on PATH:

- **deno** -- runs the `svg2roughjs` wrapper script
- **Chrome/Chromium** -- required by `svg2roughjs` for headless SVG rendering (discoverable via PATH or `CHROME_PATH` environment variable)
- **npm** -- needed for `fantasticon` (icon font generation) and `simple-icons` (brand icon fallback)
