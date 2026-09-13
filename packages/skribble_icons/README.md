# skribble_icons

Every skribble hand-drawn icon set behind one import.

The sets live in separate packages so an app only pays for the artwork it
renders. This package depends on all of them, re-exports their catalogs, and
adds a cross-set lookup.

| Set            | Package                   | Names  | Style                   | License    |
| -------------- | ------------------------- | ------ | ----------------------- | ---------- |
| Curated        | `skribble_icons_curated`  | 30     | app vocabulary          | Apache-2.0 |
| Simple Icons   | `skribble_icons_simple`   | 3,472  | brand marks             | CC0-1.0    |
| Material       | `skribble_icons_material` | 8,600+ | Flutter's `Icons`       | Apache-2.0 |
| Lucide         | `skribble_icons_lucide`   | 2,056  | 2px open outlines       | ISC        |
| Boxicons Solid | `skribble_icons_bxs`      | 665    | filled silhouettes      | MIT        |
| CoreUI Brands  | `skribble_icons_cib`      | 831    | brand and product marks | CC0-1.0    |

## Installation

```bash
dart pub add skribble_icons
```

Installing a single set instead is often the better trade:

```bash
dart pub add skribble_icons_lucide
```

## Usage

```dart
import 'package:skribble/skribble.dart';
import 'package:skribble_icons/skribble_icons.dart';

void main() {
  registerSkribbleIcons();
  runApp(const MyApp());
}

// Any set, by identifier:
final icon = lookupSkribbleIconByIdentifier('home');

// Or find out which set supplied it:
final match = lookupSkribbleIcon('a-arrow-down');
print(match?.set); // SkribbleIconSet.lucide
```

### Activating Material icons

`registerSkribbleIcons()` installs the Material catalog so that
`WiredIcon(icon: Icons.search)` draws hand-drawn geometry. Without it,
`WiredIcon` falls back to Flutter's plain `Icon` widget and renders the font
glyph. The call is idempotent and safe before `runApp`.

The Iconify sets and the simple set need no registration — they are looked up
by identifier, which this package reads directly.

## Lookup order

`lookupSkribbleIcon` searches in a fixed order and reports the winner:

1. `curated` — hand-authored names that match the component library's own
   vocabulary
2. `simple` — Simple Icons brand marks, whose slugs are unambiguous (`github`
   always means the logo, never a UI glyph)
3. `material` — so existing Flutter identifiers keep resolving
4. `lucide`, then `bxs`, then `cib`

## Regenerating catalogs

Every set regenerates in pure Dart — no headless browser involved:

```bash
melos run icons-curated   # the 30 curated icons
melos run icons-iconify   # simple, lucide, bxs, cib from pinned sources
melos run icons-check     # verify the committed catalogs are current
```

## Provenance and determinism

Every set is generated from a source pinned by version and checksum, recorded in
each package's README and in [`tool/asset_sources.txt`](../../tool/asset_sources.txt).
Regeneration is byte-for-byte deterministic — see
[docs/asset-provenance.md](../../docs/asset-provenance.md).

```bash
melos run icons-check   # verify every committed catalog is current
```

## Licenses

Each set retains its upstream license, recorded in the header of its generated
catalog. Artwork is warped by Skribble; the derivative keeps the source license.
See each package's README for attribution details.

## License

Same as the root skribble repository — see [LICENSE](../../LICENSE).
