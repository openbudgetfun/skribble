# skribble_icons_dynamic

Dynamic hand-drawn icon rendering for Skribble. This package applies the rough engine at runtime to clean SVG paths, giving you full control over fill styles, roughness, and draw configuration.

## When to use this vs `skribble_icons`

| Feature | `skribble_icons` | `skribble_icons_dynamic` |
| --- | --- | --- |
| Rendering | Pre-computed rough paths | Runtime roughening |
| Performance | Faster (no computation) | Slower (rough engine runs per paint) |
| Customization | Fixed rough appearance | Full control over roughness, fill style |
| Fill styles | Solid only | Solid, hachure, crossHatch, none |
| DrawConfig | Not applicable | Fully configurable |
| Bundle size | Larger (stores rough paths) | Smaller (stores clean paths) |

## Usage

```dart
import 'package:skribble_icons_dynamic/skribble_icons_dynamic.dart';

// Basic usage with default solid fill:
SkribbleDynamicIcon(
  data: kSkribbleDynamicIcons[0xf001]!,
)

// Hachure fill style:
SkribbleDynamicIcon(
  data: kSkribbleDynamicIcons[0xf005]!,
  fillStyle: WiredIconFillStyle.hachure,
  size: 48,
  color: Colors.red,
)

// Look up by identifier:
final icon = lookupSkribbleDynamicIconByIdentifier('heart');
if (icon != null) {
  SkribbleDynamicIcon(data: icon);
}

// Access Material rough icons (8,600+):
final alarm = lookupMaterialRoughIconByIdentifier('access_alarm');
```

## Available icons

30 curated custom icons are included, covering common UI actions:

home, search, settings, star, heart, user, menu, close, check, plus, minus,
arrow_left, arrow_right, arrow_up, arrow_down, edit, delete, share, copy,
mail, phone, camera, image, calendar, clock, lock, unlock, eye, eye_off,
notification.

All 8,600+ Material rough icons are also available via the re-exported
`lookupMaterialRoughIconByIdentifier` function.
