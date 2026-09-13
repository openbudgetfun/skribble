# skribble_icons_curated

The curated hand-drawn icon set for [Skribble](https://github.com/openbudgetfun/skribble).

Thirty icons covering the vocabulary a typical screen needs — home, search,
navigation arrows, editing, media, and status. Each one is authored as a 24x24
SVG and warped through the shared Skribble rough pass at generation time, so the
geometry is already hand-drawn and rendering never runs the rough engine.

## Installation

```bash
dart pub add skribble_icons_curated
```

To pull in every Skribble icon set at once, use
[`skribble_icons`](https://pub.dev/packages/skribble_icons) instead.

## Usage

```dart
import 'package:skribble/skribble.dart';
import 'package:skribble_icons_curated/skribble_icons_curated.dart';

final data = lookupSkribbleCuratedIconByIdentifier('search');
if (data != null) {
  WiredSvgIcon(data: data, size: 32);
}
```

`SkribbleIcon` is the fast path when you already hold the geometry: it paints
precomputed paths with no runtime displacement.

```dart
SkribbleIcon(data: kSkribbleCuratedIcons[0xf001]!, size: 32)
```

## Icons

| Identifier     | Code     | Description         |
| -------------- | -------- | ------------------- |
| `home`         | `0xf001` | House               |
| `search`       | `0xf002` | Magnifying glass    |
| `settings`     | `0xf003` | Gear                |
| `star`         | `0xf004` | Five-point star     |
| `heart`        | `0xf005` | Heart               |
| `user`         | `0xf006` | Person silhouette   |
| `menu`         | `0xf007` | Hamburger           |
| `close`        | `0xf008` | X                   |
| `check`        | `0xf009` | Checkmark           |
| `plus`         | `0xf00a` | Plus                |
| `minus`        | `0xf00b` | Minus               |
| `arrow_left`   | `0xf00c` | Left arrow          |
| `arrow_right`  | `0xf00d` | Right arrow         |
| `arrow_up`     | `0xf00e` | Up arrow            |
| `arrow_down`   | `0xf00f` | Down arrow          |
| `edit`         | `0xf010` | Pencil              |
| `delete`       | `0xf011` | Trash can           |
| `share`        | `0xf012` | Share               |
| `copy`         | `0xf013` | Overlapping squares |
| `mail`         | `0xf014` | Envelope            |
| `phone`        | `0xf015` | Handset             |
| `camera`       | `0xf016` | Camera              |
| `image`        | `0xf017` | Landscape           |
| `calendar`     | `0xf018` | Calendar grid       |
| `clock`        | `0xf019` | Clock face          |
| `lock`         | `0xf01a` | Closed padlock      |
| `unlock`       | `0xf01b` | Open padlock        |
| `eye`          | `0xf01c` | Open eye            |
| `eye_off`      | `0xf01d` | Eye with a line     |
| `notification` | `0xf01e` | Bell                |

Codepoints occupy the reserved band `0xF001–0xF0FF`.

## Adding an icon

1. Add a 24x24 SVG to `icons/`.
2. Add an entry to `tool/skribble_icons.manifest.json` with a free codepoint in
   the band above.
3. Run `melos run icons-curated`.
4. Commit the regenerated `lib/src/generated/skribble_curated_icons.g.dart`.

The generator writes the geometry map and the identifier map from the same run,
so the two cannot drift.

## License

Skribble is licensed under the root repository's [LICENSE](../../LICENSE).

## Provenance

This catalog is generated, never hand-edited. The table records exactly what it
was built from. Bumping a value means editing `tool/asset_sources.txt` in the
same commit as the regenerated catalog.

| Field | Value |
| --- | --- |
| Source | 30 curated SVGs checked into `icons/` |
| Artwork derived from | [Material Design icons](https://fonts.google.com/icons) |
| Source license | Apache-2.0 |
| Manifest | `tool/skribble_icons.manifest.json` |
| Codepoint band | `0xF001-0xF0FF` |
| Icons generated | 30 |
| Generator | `dart run packages/skribble_emoji_gen/bin/generate_icons.dart` |
| Melos shortcut | `melos run icons-curated` |
| Registry | `tool/asset_sources.txt` |

Generation is deterministic: rebuilding from the same source bytes reproduces
this catalog byte for byte. CI re-derives every catalog and fails on any diff,
so an upstream change can never land silently.
