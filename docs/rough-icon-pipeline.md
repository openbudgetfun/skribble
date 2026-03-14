# Rough Icon Pipeline

This repository ships a Dart CLI at:

- `packages/skribble/tool/generate_rough_icons.dart`

Compatibility alias (backward compatible):

- `packages/skribble/tool/generate_material_rough_icons.dart`

## What it does

1. Resolves Flutter Material `IconData` declarations from Flutter SDK.
2. Resolves source SVGs from:
   - `@material-design-icons/svg`
   - `@material-symbols/svg-400`
   - optional brand fallback from `simple-icons` (for names missing in Material SVG packages)
3. Normalizes source SVGs to a large viewBox (`--rough-normalize-viewbox`, default `128`).
4. Runs `svg2roughjs` through a Deno TypeScript wrapper script:
   - `packages/skribble/tool/deno/svg2roughjs_cli.ts`
5. Scales rough output back down to original icon dimensions.
6. Optionally:
   - emits Dart map (`material_rough_icons.g.dart`)
   - emits rough SVG files (`--rough-output-dir`)
   - generates icon fonts with `fantasticon` (`--font-output-dir`)
   - emits Dart helpers for generated icon fonts (`--font-dart-output`)
   - emits unresolved icon reports as JSON (`--unresolved-output`)
   - emits supplemental manifest templates (`--supplemental-manifest-output`)
   - can fail CI on unresolved icons (`--fail-on-unresolved`, `--max-unresolved`, `--fail-on-new-unresolved`)

## Extensibility seam

The script uses `IconKitProvider` (`packages/skribble/tool/icon_kit_provider.dart`).

Current providers:

- `flutter-material`
- `svg-manifest`

To inspect available providers from CLI:

```bash
cd packages/skribble
dart run tool/generate_rough_icons.dart --list-kits
```

### `svg-manifest` kit format

Use `--kit svg-manifest --manifest <path>` to rough any icon set without
writing Dart provider code.

Manifest supports either a top-level list or `{ "icons": [...] }`, where each
entry includes:

- `identifier` (string, must be unique)
- `codePoint` (int or hex string like `"0xe001"`, must be unique)
- `svgPath` (preferred) or `svg`/`path` alias

Example:

```json
{
  "icons": [
    {
      "identifier": "my_star",
      "codePoint": "0xe001",
      "svgPath": "icons/my_star.svg"
    }
  ]
}
```

Run:

```bash
cd packages/skribble
dart run tool/generate_rough_icons.dart \
  --kit svg-manifest \
  --manifest tool/examples/custom_icons.manifest.json \
  --output lib/src/generated/custom_rough_icons.g.dart \
  --rough-output-dir tool/icon_exports/custom-rough-svg \
  --font-dart-output lib/src/generated/custom_rough_icon_font.g.dart
```

To add another icon kit, implement a provider that:

- loads declarations (`loadDeclarations`)
- resolves a declaration to SVG source + parsed icon metadata (`resolveIcon`)

The roughing and font stages remain unchanged.

## Brand icon fallback source

When a Flutter Material icon identifier does not exist in Material SVG packages
(e.g. social/brand icons), the CLI can also resolve from `simple-icons`.

- Auto mode (default): tries `npm pack simple-icons` best-effort.
- Manual source override: `--brand-icons-source <path>`.

## Supplemental manifest source

For unresolved Flutter Material icons that are absent from both Material SVG
packages and brand fallback packages, pass a custom manifest file:

- `--supplemental-manifest <path>`

This uses the same JSON schema as `--kit svg-manifest` (`identifier`,
`codePoint`, `svgPath`) and is applied as a fallback during
`--kit flutter-material` resolution.

## Unresolved report output

To emit a machine-readable unresolved report for follow-up work, pass:

- `--unresolved-output <path>`

The JSON report includes:

- `kit`
- `resolvedCount`
- `unresolvedCount`
- `unresolved[]` entries with `codePoint` and `identifiers`
- optional `newUnresolvedCount` / `newUnresolved[]` when baseline comparison is enabled

## Supplemental manifest template output

To emit a starter supplemental manifest for unresolved icons, pass:

- `--supplemental-manifest-output <path>`

The output uses the same `icons[]` schema as `--kit svg-manifest` and can be
edited by replacing placeholder `svgPath` values before passing it back via
`--supplemental-manifest`.

## Strict unresolved mode

To control failure behavior for unresolved icons:

- `--fail-on-unresolved` (strict; equivalent to allowing 0 unresolved)
- `--max-unresolved <int>` (bounded; fail only when unresolved count exceeds threshold)

To detect only regressions relative to an existing unresolved baseline:

- `--unresolved-baseline <path>`
- `--fail-on-new-unresolved`

This is useful in CI while tightening coverage incrementally.

## Runtime prerequisites

- `deno` available on PATH
- A Chrome/Chromium executable discoverable on PATH or via `CHROME_PATH`
