# skribble_icons_cib

CoreUI brand marks: 830 logos covering products, platforms, languages, and social networks, for sign-in buttons, footer links, and tech-stack sections.

Part of the [Skribble](https://github.com/openbudgetfun/skribble) design system.
Artwork comes from **CoreUI** ([homepage](https://github.com/coreui/coreui-icons)) under **CC0-1.0**, warped
through the shared Skribble rough pass at generation time. Every path in the
catalog is precomputed, so rendering never runs the rough engine.

## Installation

```bash
dart pub add skribble_icons_cib
```

To pull in every Skribble icon set at once, use
[`skribble_icons`](https://pub.dev/packages/skribble_icons) instead.

## Usage

```dart
import 'package:skribble/skribble.dart';
import 'package:skribble_icons_cib/skribble_icons_cib.dart';

final data = lookupCibIconByIdentifier('github');
if (data != null) {
  WiredSvgIcon(data: data, size: 32);
}
```

Every identifier is also available through the umbrella package's
`lookupSkribbleIconByIdentifier`, which searches all sets.

## Catalog

| | |
| --- | --- |
| Names | 831 |
| Grid | 32x32, filled |
| Codepoint band | `0xF400–0xF7FF` |
| License | CC0-1.0 |

`kCibIcons` maps codepoints to `WiredSvgIconData`.
`kCibIconCodePoints` maps identifiers to codepoints. Names include upstream
aliases, so several identifiers can resolve to the same artwork.

## Regenerating

The catalog is generated from a pinned upstream payload. The version and
SHA-256 checksum live in `tool/iconify_sources.txt` at the repository root, so
an upstream bump is an explicit edit rather than a silent drift.

```bash
melos run icons-iconify          # regenerate
melos run icons-check            # verify the committed catalog is current
```

`--check` re-derives the catalog into memory and fails on any byte difference,
which is what CI enforces.

## Attribution

CoreUI brand marks: 830 logos covering products, platforms, languages, and social networks, for sign-in buttons, footer links, and tech-stack sections.

The generated catalog header records the source project, homepage, and license.
Keep that header when redistributing.

## License

Skribble is licensed under the root repository's [LICENSE](../../LICENSE).
The icon artwork in this package is CC0-1.0, copyright CoreUI and its
contributors.

## Provenance

This catalog is generated, never hand-edited. The table records exactly what it
was built from. Bumping a value means editing `tool/asset_sources.txt` in the
same commit as the regenerated catalog.

| Field | Value |
| --- | --- |
| Source | [CoreUI-Brands](https://github.com/coreui/coreui-icons) |
| Upstream version | `1.2.3` |
| Source checksum (SHA-256) | `1ca1a73bb741c5fcf73e112d5ce74e5577b43ef7a17facf11529d9356e2a6f82` |
| License | CC0-1.0 |
| Codepoint band | `0xF400-0xF7FF` |
| Icons generated | 831 |
| Generator | `scripts/generate_iconify_sets.sh` |
| Registry | `tool/asset_sources.txt` |

Generation is deterministic: rebuilding from the same source bytes reproduces
this catalog byte for byte. CI re-derives every catalog and fails on any diff,
so an upstream change can never land silently.
