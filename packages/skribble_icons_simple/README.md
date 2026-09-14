# skribble_icons_simple

[Simple Icons](https://simpleicons.org) for [skribble](https://github.com/openbudgetfun/skribble).

3,472 brand and product marks — the logos an app needs for sign-in buttons, footer links, tech-stack sections, and "works with" lists. GitHub, Slack, Postgres, Nintendo, Vercel, and everything else the project tracks.

This package holds **logos, not interface icons**. Despite the name, it is not where `home`, `search`, and friends live — those are in [`skribble_icons_curated`](https://pub.dev/packages/skribble_icons_curated).

## Installation

```bash
dart pub add skribble_icons_simple
```

To pull in every skribble icon set at once, use [`skribble_icons`](https://pub.dev/packages/skribble_icons) instead.

## Usage

```dart
import 'package:skribble/skribble.dart';
import 'package:skribble_icons_simple/skribble_icons_simple.dart';

final data = lookupSimpleIconByIdentifier('github');
if (data != null) {
  WiredSvgIcon(data: data, size: 32);
}
```

Identifiers use Simple Icons' own slug form — `'github'`, `'visualstudiocode'`, `'flutter'` — the same strings the Simple Icons site and its search box use. So an existing slug list can be dropped in without translation.

Every identifier is also available through the umbrella package's `lookupSkribbleIconByIdentifier`, which searches all sets.

## Catalog

|                |                           |
| -------------- | ------------------------- |
| Names          | 3,472                     |
| Grid           | 24x24, filled silhouettes |
| Codepoint band | `0xF0000-0xF0FFF`         |
| License        | CC0-1.0                   |

`kSimpleIcons` maps codepoints to `WiredSvgIconData`. `kSimpleIconCodePoints` maps identifiers to codepoints. Names include upstream aliases, so several identifiers can resolve to the same artwork.

The band sits in the supplementary private-use plane rather than the BMP one the other sets share, because 3,460 names do not fit in the 6,400 codepoints the BMP area has left after Curated, Lucide, Boxicons, and CoreUI. Codepoints here are internal keys, not font glyphs, so the higher plane has no practical effect.

## Regenerating

The catalog is generated from a pinned upstream payload. The version and SHA-256 checksum live in `tool/asset_sources.txt` at the repository root, so an upstream bump is an explicit edit rather than a silent drift.

```bash
melos run icons-iconify          # regenerate
melos run icons-check            # verify the committed catalog is current
```

## Attribution

Artwork comes from [Simple Icons](https://simpleicons.org) and is released under CC0-1.0. Brand names and logos remain trademarks of their respective owners; Simple Icons provides the artwork, and this package warps it. Check a mark's usage guidelines before shipping it in a commercial product — a free license on the artwork does not grant trademark rights.

## License

skribble is licensed under the root repository's [LICENSE](../../LICENSE). The icon artwork in this package is CC0-1.0.

## Provenance

This catalog is generated, never hand-edited. The table records exactly what it was built from. Bumping a value means editing `tool/asset_sources.txt` in the same commit as the regenerated catalog.

| Field                     | Value                                                              |
| ------------------------- | ------------------------------------------------------------------ |
| Source                    | [Simple Icons](https://simpleicons.org)                            |
| Upstream version          | `1.2.96`                                                           |
| Source checksum (SHA-256) | `6eea755f8cf3a9f6482fcbb6d291746c9133ed4ed2d94dc0814e9529675e2bbd` |
| License                   | CC0-1.0                                                            |
| Codepoint band            | `0xF0000-0xF0FFF`                                                  |
| Icons generated           | 3,472                                                              |
| Generator                 | `scripts/generate_iconify_sets.sh`                                 |
| Registry                  | `tool/asset_sources.txt`                                           |

Generation is deterministic: rebuilding from the same source bytes reproduces this catalog byte for byte. CI re-derives every catalog and fails on any diff, so an upstream change can never land silently.
