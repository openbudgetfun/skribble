# skribble_icons_lucide

The Lucide outline icon set: 1,837 icons plus 219 aliases, all drawn as open outlines at a uniform 2px stroke. Because every path is a stroke rather than a silhouette, it reads as the lightest of the bundled catalogs.

Part of the [skribble](https://github.com/openbudgetfun/skribble) design system. Artwork comes from **Lucide** ([homepage](https://lucide.dev)) under **ISC**, warped through the shared skribble rough pass at generation time. Every path in the catalog is precomputed, so rendering never runs the rough engine.

## Installation

```bash
dart pub add skribble_icons_lucide
```

To pull in every skribble icon set at once, use [`skribble_icons`](https://pub.dev/packages/skribble_icons) instead.

## Usage

```dart
import 'package:skribble/skribble.dart';
import 'package:skribble_icons_lucide/skribble_icons_lucide.dart';

final data = lookupLucideIconByIdentifier('home');
if (data != null) {
  WiredSvgIcon(data: data, size: 32);
}
```

Every identifier is also available through the umbrella package's `lookupSkribbleIconByIdentifier`, which searches all sets.

## Catalog

|                |                           |
| -------------- | ------------------------- |
| Names          | 2,056                     |
| Grid           | 24x24, uniform 2px stroke |
| Codepoint band | `0xE000–0xEFFF`           |
| License        | ISC                       |

`kLucideIcons` maps codepoints to `WiredSvgIconData`. `kLucideIconCodePoints` maps identifiers to codepoints. Names include upstream aliases, so several identifiers can resolve to the same artwork.

## Regenerating

The catalog is generated from a pinned upstream payload. The version and SHA-256 checksum live in `tool/asset_sources.txt` at the repository root, so an upstream bump is an explicit edit rather than a silent drift.

```bash
melos run icons-iconify          # regenerate
melos run icons-check            # verify the committed catalog is current
```

`--check` re-derives the catalog into memory and fails on any byte difference, which is what CI enforces.

## Attribution

The Lucide outline icon set: 1,837 icons plus 219 aliases, all drawn as open outlines at a uniform 2px stroke. Because every path is a stroke rather than a silhouette, it reads as the lightest of the bundled catalogs.

The generated catalog header records the source project, homepage, and license. Keep that header when redistributing.

## License

skribble is licensed under the root repository's [LICENSE](../../LICENSE). The icon artwork in this package is ISC, copyright Lucide and its contributors.

## Provenance

This catalog is generated, never hand-edited. The table records exactly what it was built from. Bumping a value means editing `tool/asset_sources.txt` in the same commit as the regenerated catalog.

| Field                     | Value                                                              |
| ------------------------- | ------------------------------------------------------------------ |
| Source                    | [Lucide](https://lucide.dev)                                       |
| Upstream version          | `1.2.132`                                                          |
| Source checksum (SHA-256) | `57e7242abc5244f9a21ecd0d195f958f39fd1c5757fe87c3b279d628f9239049` |
| License                   | ISC                                                                |
| Codepoint band            | `0xE000-0xEFFF`                                                    |
| Icons generated           | 2,056                                                              |
| Generator                 | `scripts/generate_iconify_sets.sh`                                 |
| Registry                  | `tool/asset_sources.txt`                                           |

Generation is deterministic: rebuilding from the same source bytes reproduces this catalog byte for byte. CI re-derives every catalog and fails on any diff, so an upstream change can never land silently.
