# skribble_emoji_gen

The repository tools that compile skribble's art and pinned icon sets into deterministic Dart catalogs for `skribble_emoji`, `skribble`, and the `skribble_icons_*` packages.

Run the full asset rebuild from the skribble repository root:

```bash
dart run packages/skribble_emoji_gen/bin/update_assets.dart
```

`update_assets.dart` runs every generator below and rebuilds the bundled skribble fonts. Each generator verifies its own pinned inputs, so an upstream update always needs an explicit version and checksum change.

- `generate_emoji.dart` builds skribble's emoji catalog. It downloads Unicode's `emoji-test.txt` (pinned by version and SHA-256), plans every fully-qualified emoji onto a drawing in `packages/skribble_emoji/art`, compiles those SVGs, and writes the catalog, the skin-tone map, and the art. Gendered emoji share one drawing, skin tones and "facing right" are applied at runtime, and flags are waved and outlined here. The run fails when any emoji has no drawing; `--allow-missing` lists them instead, and `--report <path>` writes a JSON coverage report.
- `generate_glyphs.dart` rebuilds `SkribbleGlyphs` in the core package from the stroke SVGs and `glyphs.json` in `packages/skribble/tool/glyphs`, emitting the named glyphs and their Material codepoint fallbacks from one run so they cannot drift.
- `generate_iconify_set.dart` converts a pinned Iconify `icons.json` payload into a catalog for one of the `skribble_icons_*` packages. It resolves Iconify aliases, applies per-icon geometry and flip overrides, and warps every outline with a deterministic rough pass.

Every generator accepts `--check`, which re-derives its output in memory and fails on any byte difference without writing.

The library side is `EmojiArtCompiler` (the SVG authoring rules in `packages/skribble_emoji/art/STYLE.md`, enforced), `parseEmojiTest` and `planEmoji` (Unicode's list onto art keys), and the SVG shape and transform helpers the icon generators share.

## Verification

```bash
cd packages/skribble_emoji_gen
dart test
```
