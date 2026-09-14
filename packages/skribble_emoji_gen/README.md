# skribble_emoji_gen

Generates the pinned emoji and icon assets shipped by skribble. The tools read OpenMoji SVG and metadata sources, convert their paths into rough drawing data, and write deterministic Dart catalogs for `skribble_emoji` and `skribble_icons`.

Run the full asset rebuild from the skribble repository root:

```bash
dart run packages/skribble_emoji_gen/bin/update_assets.dart
```

`update_assets.dart` downloads the pinned OpenMoji release, verifies its SHA-256 hashes, regenerates emoji and icon catalogs, rebuilds the bundled skribble fonts, and formats the generated Dart files. Upstream updates require an explicit source version and checksum change.

The lower-level generators are repository tools:

- `generate_emoji.dart` builds an emoji catalog from an extracted OpenMoji SVG directory and CSV file.
- `generate_icons.dart` rebuilds the curated simple icon catalog from its checked-in SVG manifest, emitting the geometry map and the identifier map from one run so the two cannot drift. Both generators accept `--check`, which re-derives the catalog into memory and fails on any byte difference.
- `generate_iconify_set.dart` converts a pinned Iconify `icons.json` payload into a catalog for one of the `skribble_icons_*` packages. It resolves Iconify aliases, applies per-icon geometry and flip overrides, and warps every outline with the same deterministic rough pass the other generators use. All three sets together finish in seconds, because the conversion is pure Dart rather than a headless-browser round trip per icon.

## Verification

```bash
cd packages/skribble_emoji_gen
dart test
```

OpenMoji artwork is available under the CC BY-SA 4.0 license. Generated packages retain the required attribution and license files.
