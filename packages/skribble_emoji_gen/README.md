# skribble_emoji_gen

Generates the pinned emoji and icon assets shipped by Skribble. The tools read OpenMoji SVG and metadata sources, convert their paths into rough drawing data, and write deterministic Dart catalogs for `skribble_emoji` and `skribble_icons`.

Run the full asset rebuild from the Skribble repository root:

```bash
dart run packages/skribble_emoji_gen/bin/update_assets.dart
```

`update_assets.dart` downloads the pinned OpenMoji release, verifies its SHA-256 hashes, regenerates emoji and icon catalogs, rebuilds the bundled Skribble fonts, and formats the generated Dart files. Upstream updates require an explicit source version and checksum change.

The lower-level generators are repository tools. Use `generate_emoji.dart` to build an emoji catalog from an extracted OpenMoji SVG directory and CSV file. Use `generate_icons.dart` to rebuild the curated icon catalog.

## Verification

```bash
cd packages/skribble_emoji_gen
dart test
```

OpenMoji artwork is available under the CC BY-SA 4.0 license. Generated packages retain the required attribution and license files.
