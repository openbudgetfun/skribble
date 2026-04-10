# skribble_icons

Comprehensive hand-drawn icon library for the [Skribble](https://github.com/openbudgetfun/skribble) design system.

Provides unified access to **all 8,600+ roughened Flutter Material icons** plus 30 curated custom icons through a single API. Every icon is rendered with the Skribble hand-drawn aesthetic.

## Installation

```yaml
dependencies:
  skribble: ^0.3.4
  skribble_icons: ^0.1.0
```

## Usage

### Unified lookup (recommended)

Search custom icons first, then fall back to the full Material set:

```dart
import 'package:skribble/skribble.dart';
import 'package:skribble_icons/skribble_icons.dart';

// Any Material icon identifier works:
final alarm = lookupSkribbleIconByIdentifier('access_alarm');
final home = lookupSkribbleIconByIdentifier('home');

// Render it:
if (alarm != null) {
  WiredIcon.custom(data: alarm);
}
```

### Custom icons only

Access just the 30 curated custom icons:

```dart
final star = lookupSkribbleCustomIconByIdentifier('star');
```

### Material icons directly

Access the full Material rough icon set:

```dart
// By identifier
final icon = lookupMaterialRoughIconByIdentifier('favorite');

// By codepoint
final icon = kMaterialRoughIcons[0xe87d];

// All available identifiers
final names = materialRoughIconIdentifiers; // 8,600+ names
```

### Icon count

```dart
print(skribbleIconCount); // custom + Material total
print(kSkribbleCustomIcons.length); // 30 curated icons
print(kMaterialRoughIcons.length); // 8,600+ Material icons
```

## Custom icons

The 30 curated custom icons cover common app patterns:

| Identifier     | Codepoint | Description                    |
| -------------- | --------- | ------------------------------ |
| `home`         | `0xf001`  | House shape                    |
| `search`       | `0xf002`  | Magnifying glass               |
| `settings`     | `0xf003`  | Gear                           |
| `star`         | `0xf004`  | 5-point star                   |
| `heart`        | `0xf005`  | Heart shape (favorite)         |
| `user`         | `0xf006`  | Person silhouette              |
| `menu`         | `0xf007`  | 3 horizontal lines (hamburger) |
| `close`        | `0xf008`  | X shape                        |
| `check`        | `0xf009`  | Checkmark                      |
| `plus`         | `0xf00a`  | Plus sign                      |
| `minus`        | `0xf00b`  | Minus sign                     |
| `arrow_left`   | `0xf00c`  | Left arrow                     |
| `arrow_right`  | `0xf00d`  | Right arrow                    |
| `arrow_up`     | `0xf00e`  | Up arrow                       |
| `arrow_down`   | `0xf00f`  | Down arrow                     |
| `edit`         | `0xf010`  | Pencil                         |
| `delete`       | `0xf011`  | Trash can                      |
| `share`        | `0xf012`  | Share icon                     |
| `copy`         | `0xf013`  | Two overlapping squares        |
| `mail`         | `0xf014`  | Envelope                       |
| `phone`        | `0xf015`  | Phone handset                  |
| `camera`       | `0xf016`  | Camera                         |
| `image`        | `0xf017`  | Landscape / mountain           |
| `calendar`     | `0xf018`  | Calendar grid                  |
| `clock`        | `0xf019`  | Clock face                     |
| `lock`         | `0xf01a`  | Padlock (closed)               |
| `unlock`       | `0xf01b`  | Padlock (open)                 |
| `eye`          | `0xf01c`  | Open eye                       |
| `eye_off`      | `0xf01d`  | Eye with line through          |
| `notification` | `0xf01e`  | Bell                           |

## Regenerating custom icons

The curated icons are generated from SVG sources via the rough icon pipeline:

```bash
# From the workspace root:
melos run rough-icons-skribble

# Or directly:
cd packages/skribble
dart run tool/generate_rough_icons.dart \
  --kit svg-manifest \
  --manifest ../skribble_icons/tool/skribble_icons.manifest.json \
  --output ../skribble_icons/lib/src/generated/skribble_icons.g.dart \
  --map-name kSkribbleCustomIcons
```

## Adding custom icons

1. Add a 24x24 SVG file to `icons/`.
2. Add an entry to `tool/skribble_icons.manifest.json`:
   ```json
   {
     "identifier": "my_icon",
     "codePoint": "0xf01f",
     "svgPath": "../icons/my_icon.svg"
   }
   ```
3. Run `melos run rough-icons-skribble`.
4. Update the `kSkribbleCustomIconsCodePoints` map in `lib/skribble_icons.dart`.

## License

Same as the root Skribble repository — see [LICENSE](../../LICENSE) for details.
