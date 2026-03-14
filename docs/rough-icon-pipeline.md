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
3. Normalizes source SVGs to a large viewBox (`--rough-normalize-viewbox`, default `128`).
4. Runs `svg2roughjs` through a Deno TypeScript wrapper script:
   - `packages/skribble/tool/deno/svg2roughjs_cli.ts`
5. Scales rough output back down to original icon dimensions.
6. Optionally:
   - emits Dart map (`material_rough_icons.g.dart`)
   - emits rough SVG files (`--rough-output-dir`)
   - generates icon fonts with `fantasticon` (`--font-output-dir`)

## Extensibility seam

The script uses `IconKitProvider` (`packages/skribble/tool/icon_kit_provider.dart`).

Current provider:

- `flutter-material`

To inspect available providers from CLI:

```bash
cd packages/skribble
dart run tool/generate_rough_icons.dart --list-kits
```

To add another icon kit, implement a provider that:

- loads declarations (`loadDeclarations`)
- resolves a declaration to SVG source + parsed icon metadata (`resolveIcon`)

The roughing and font stages remain unchanged.

## Runtime prerequisites

- `deno` available on PATH
- A Chrome/Chromium executable discoverable on PATH or via `CHROME_PATH`
