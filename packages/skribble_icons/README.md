# skribble_icons

Hand-drawn icon set for the Skribble design system. This package provides 30 curated SVG icons that are processed through the Skribble rough icon pipeline to produce hand-drawn variants.

## Icons

| Identifier | Codepoint | Description |
| --- | --- | --- |
| `home` | `0xf001` | House shape |
| `search` | `0xf002` | Magnifying glass |
| `settings` | `0xf003` | Gear |
| `star` | `0xf004` | 5-point star |
| `heart` | `0xf005` | Heart shape (favorite) |
| `user` | `0xf006` | Person silhouette |
| `menu` | `0xf007` | 3 horizontal lines (hamburger) |
| `close` | `0xf008` | X shape |
| `check` | `0xf009` | Checkmark |
| `plus` | `0xf00a` | Plus sign |
| `minus` | `0xf00b` | Minus sign |
| `arrow_left` | `0xf00c` | Left arrow |
| `arrow_right` | `0xf00d` | Right arrow |
| `arrow_up` | `0xf00e` | Up arrow |
| `arrow_down` | `0xf00f` | Down arrow |
| `edit` | `0xf010` | Pencil |
| `delete` | `0xf011` | Trash can |
| `share` | `0xf012` | Share icon |
| `copy` | `0xf013` | Two overlapping squares |
| `mail` | `0xf014` | Envelope |
| `phone` | `0xf015` | Phone handset |
| `camera` | `0xf016` | Camera |
| `image` | `0xf017` | Landscape / mountain |
| `calendar` | `0xf018` | Calendar grid |
| `clock` | `0xf019` | Clock face |
| `lock` | `0xf01a` | Padlock (closed) |
| `unlock` | `0xf01b` | Padlock (open) |
| `eye` | `0xf01c` | Open eye |
| `eye_off` | `0xf01d` | Eye with line through |
| `notification` | `0xf01e` | Bell |

## Usage

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  skribble_icons: ^0.1.0
```

Import and use the icons:

```dart
import 'package:skribble_icons/skribble_icons.dart';

// Access the full icon map by codepoint.
final homeIcon = kSkribbleIcons[0xf001];

// Look up an icon by its string identifier.
final starIcon = lookupSkribbleIconByIdentifier('star');

// Iterate over all available codepoints.
for (final entry in kSkribbleIconsCodePoints.entries) {
  print('${entry.key}: 0x${entry.value.toRadixString(16)}');
}
```

## Regeneration

The generated Dart file at `lib/src/generated/skribble_icons.g.dart` is produced by the Skribble rough icon pipeline. To regenerate it, run from the workspace root:

```bash
cd packages/skribble && dart run tool/generate_rough_icons.dart \
  --kit svg-manifest \
  --manifest ../skribble_icons/tool/skribble_icons.manifest.json \
  --output ../skribble_icons/lib/src/generated/skribble_icons.g.dart \
  --map-name kSkribbleIcons
```

## Adding new icons

1. Create a 24x24 SVG file in the `icons/` directory.
2. Add an entry to `tool/skribble_icons.manifest.json` with a unique `identifier`, the next available `codePoint`, and the relative `svgPath`.
3. Add the identifier and codepoint to `kSkribbleIconsCodePoints` in `lib/skribble_icons.dart`.
4. Run the regeneration command above.
5. Update the test expectations in `test/skribble_icon_catalog_test.dart`.
