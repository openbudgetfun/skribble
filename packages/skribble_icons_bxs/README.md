# skribble_icons_bxs

The solid weight of Boxicons: 665 filled silhouettes. It pairs with an outline set the way a filled Material icon pairs with its outlined counterpart.

Part of the [skribble](https://github.com/openbudgetfun/skribble) design system. Artwork comes from **Boxicons** ([homepage](https://boxicons.com)) under **MIT**, warped through the shared skribble rough pass at generation time. Every path in the catalog is precomputed, so rendering never runs the rough engine.

## Installation

```bash
dart pub add skribble_icons_bxs
```

To pull in every skribble icon set at once, use [`skribble_icons`](https://pub.dev/packages/skribble_icons) instead.

## Usage

```dart
import 'package:skribble/skribble.dart';
import 'package:skribble_icons_bxs/skribble_icons_bxs.dart';

final data = lookupBxsIconByIdentifier('analyse');
if (data != null) {
  WiredSvgIcon(data: data, size: 32);
}
```

Every identifier is also available through the umbrella package's `lookupSkribbleIconByIdentifier`, which searches all sets.

## Catalog

|                |                 |
| -------------- | --------------- |
| Names          | 665             |
| Grid           | 24x24, filled   |
| Codepoint band | `0xF100–0xF3FF` |
| License        | MIT             |

`kBxsIcons` maps codepoints to `WiredSvgIconData`. `kBxsIconCodePoints` maps identifiers to codepoints. Names include upstream aliases, so several identifiers can resolve to the same artwork.

## Regenerating

The catalog is generated from a pinned upstream payload. The version and SHA-256 checksum live in `tool/asset_sources.txt` at the repository root, so an upstream bump is an explicit edit rather than a silent drift.

```bash
melos run icons-iconify          # regenerate
melos run icons-check            # verify the committed catalog is current
```

`--check` re-derives the catalog into memory and fails on any byte difference, which is what CI enforces.

## Attribution

The solid weight of Boxicons: 665 filled silhouettes. It pairs with an outline set the way a filled Material icon pairs with its outlined counterpart.

The generated catalog header records the source project, homepage, and license. Keep that header when redistributing.

## License

skribble is licensed under the root repository's [LICENSE](../../LICENSE). The icon artwork in this package is MIT, copyright Boxicons and its contributors.

## Provenance

This catalog is generated, never hand-edited. The table records exactly what it was built from. Bumping a value means editing `tool/asset_sources.txt` in the same commit as the regenerated catalog.

| Field                     | Value                                                              |
| ------------------------- | ------------------------------------------------------------------ |
| Source                    | [Boxicons](https://boxicons.com)                                   |
| Upstream version          | `1.2.3`                                                            |
| Source checksum (SHA-256) | `063965b251bd366adf94316fe3980f74fb5e7dad58e2c67f5876300967c7e2a5` |
| License                   | MIT                                                                |
| Codepoint band            | `0xF100-0xF3FF`                                                    |
| Icons generated           | 665                                                                |
| Generator                 | `scripts/generate_iconify_sets.sh`                                 |
| Registry                  | `tool/asset_sources.txt`                                           |

Generation is deterministic: rebuilding from the same source bytes reproduces this catalog byte for byte. CI re-derives every catalog and fails on any diff, so an upstream change can never land silently.
