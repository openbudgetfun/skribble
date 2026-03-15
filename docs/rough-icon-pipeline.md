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
     including legacy alias identifiers that share resolved codepoints
   - emits unresolved icon reports as JSON (`--unresolved-output`)
   - emits supplemental manifest templates (`--supplemental-manifest-output`)
   - can fail CI on unresolved icons (`--fail-on-unresolved`, `--max-unresolved`, `--fail-on-new-unresolved`, `--max-new-unresolved`)

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
- `codePoint` (int, decimal string, or hex string like `"0xe001"`, `"e001"`, `"U+E001"`; must be unique)
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

This repo includes a committed supplemental manifest for known upstream gaps:

- `packages/skribble/tool/examples/material_rough_icons.supplemental.manifest.json`

## Unresolved report output

To emit a machine-readable unresolved report for follow-up work, pass:

- `--unresolved-output <path>`

The JSON report includes:

- `kit`
- `resolvedCount`
- `unresolvedCount`
- `wouldFail` (whether configured unresolved gates would fail this run)
- `unresolvedGateFailed` / `newUnresolvedGateFailed` (per-gate failure booleans)
- `activeGates[]` summary list (`unresolved`, `newUnresolved`) for configured/enabled gates
- `failedGates[]` summary list (`unresolved`, `newUnresolved`) for gates that failed
- `unresolved[]` entries with `codePoint` and `identifiers`
- `unresolvedCodePoints[]` summary list (hex strings)
- optional `baselineUnresolvedCount`
- optional `newUnresolvedCount` / `newUnresolved[]` when baseline comparison is enabled
- optional `newUnresolvedCodePoints[]` summary list (hex strings)
- optional `resolvedSinceBaselineCount` / `resolvedSinceBaseline[]` (codepoint strings)
- `unresolvedThresholdMode` (`disabled`, `strict`, or `threshold`)
- `newUnresolvedThresholdMode` (`disabled`, `strict`, or `threshold`)
- optional `maxUnresolved` / `maxUnresolvedExceeded` when unresolved threshold gating is configured
- optional `maxNewUnresolved` / `maxNewUnresolvedExceeded` when baseline-regression threshold gating is configured

## Normalized unresolved baseline output

To emit a baseline file dedicated to regression checks, pass:

- `--unresolved-baseline-output <path>`

By default, this output contains only an `unresolved[]` list so baseline
updates are smaller and avoid churn in unrelated report metadata.

To emit an even smaller baseline with only codepoint strings, pass:

- `--unresolved-baseline-output-format codepoints`

This repo’s committed baseline uses this `codePoints[]` output format.

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

Use either strict mode or threshold mode (these flags are mutually exclusive).

To detect only regressions relative to an existing unresolved baseline:

- `--unresolved-baseline <path>`
- `--fail-on-new-unresolved` (strict; equivalent to allowing 0 newly unresolved)
- `--max-new-unresolved <int>` (bounded; fail only when newly unresolved count exceeds threshold)

Use either strict baseline-regression mode or threshold baseline-regression mode
(these flags are mutually exclusive).

Baseline input supports:

- unresolved report JSON (`unresolved[]`)
- supplemental manifest JSON (`icons[]`)
- minimal baseline JSON (`unresolvedCodePoints[]`/`unresolvedCodepoints[]`/`unresolved_code_points[]`/`unresolved_codepoints[]`/`unresolved-code-points[]`/`codePoints[]`, also accepts `codepoints[]`/`code_points[]`/`code-points[]`)

For object entries inside `unresolved[]` or `icons[]`, the code point field
may be `codePoint`, `codepoint`, `code_point`, or `code-point`.

When code points are provided as strings, decimal, `0x`-prefixed hex, bare
hex, and `U+`-prefixed hex forms are accepted.

This is useful in CI while tightening coverage incrementally.

Workspace shortcuts:

- `melos run rough-icons`
- `melos run rough-icons-font`
- `melos run rough-icons-baseline`
- `melos run rough-icons-ci-check`

`rough-icons` and `rough-icons-font` both apply the committed supplemental
manifest `packages/skribble/tool/examples/material_rough_icons.supplemental.manifest.json`
and enforce `--max-new-unresolved 0` (strict-mode equivalent) against
`packages/skribble/tool/examples/material_rough_icons.unresolved-baseline.json`.

`rough-icons-ci-check` runs the same rough icon regression/sync checks used by
CI via `./scripts/check_rough_icons_ci.sh all`.

For targeted local debugging, run an individual CI-equivalent check:

- `./scripts/check_rough_icons_ci.sh regression`
- `./scripts/check_rough_icons_ci.sh baseline-sync`
- `./scripts/check_rough_icons_ci.sh generated-sync`

On sync-check failures, the script prints `git diff` output and saves it to:

- `rough-icons-baseline-sync.diff`
- `rough-icons-generated-sync.diff`

`regression` cleans up `packages/skribble/unresolved-report.json` after a
successful local run. Set `ROUGH_ICONS_KEEP_UNRESOLVED_REPORT=1` to keep it.
Set `ROUGH_ICONS_MAX_UNRESOLVED=<int>` to enable total unresolved gating via
`--max-unresolved` (default: disabled).
By default, regression/generated-sync checks use
`--max-new-unresolved 0` (strict-mode equivalent). Set
`ROUGH_ICONS_MAX_NEW_UNRESOLVED=<int>` to relax or tighten that threshold.

Pull-request CI explicitly sets `ROUGH_ICONS_MAX_NEW_UNRESOLVED=0` for those
checks to keep the workflow configuration aligned with local defaults.

CI also enforces the same unresolved regression gate on pull requests using
`--rough-only`, `--supplemental-manifest`, and `--unresolved-baseline`, and
uploads an `rough-icons-unresolved-report` artifact (from
`--unresolved-output`) to aid regression diagnosis.

CI also verifies the committed baseline file is up to date by regenerating
`packages/skribble/tool/examples/material_rough_icons.unresolved-baseline.json`
and failing if a diff remains. On failure, CI uploads a
`rough-icons-baseline-sync-diff` artifact with the baseline diff.

CI additionally verifies generated rough icon catalogs are committed and up to
date by regenerating:

- `packages/skribble/lib/src/generated/material_rough_icons.g.dart`
- `packages/skribble/lib/src/generated/material_rough_icon_font.g.dart`

On generated-sync failures, CI uploads a
`rough-icons-generated-sync-diff` artifact with catalog diffs.

To refresh the committed `codePoints[]` baseline after intentional coverage
changes:

```bash
melos run rough-icons-baseline
```

## Runtime prerequisites

- `deno` available on PATH
- A Chrome/Chromium executable discoverable on PATH or via `CHROME_PATH`
