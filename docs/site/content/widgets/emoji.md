---
title: Emoji
description: Hand-drawn emoji from OpenMoji, rendered as rough SVG icons with the WiredEmoji widget.
---

# Emoji

The `skribble_emoji` package provides hand-drawn emoji sourced from [OpenMoji](https://openmoji.org/), rendered through the same rough SVG pipeline used for icons. Emoji are displayed with hand-drawn strokes and optional fill styles, matching the Skribble design language.

---

## Installation

```bash
dart pub add skribble_emoji
```

Import the package:

```dart
import 'package:skribble_emoji/skribble_emoji.dart';
```

---

## WiredEmoji

The primary widget for rendering a hand-drawn emoji. When the requested emoji data is `null` (not yet generated), a placeholder circle with a "?" character is shown.

```dart
// From explicit data
WiredEmoji(data: lookupSkribbleEmojiByName('grinning_face'))

// From name lookup
WiredEmoji.fromName('grinning_face', size: 32)

// From Unicode codepoint lookup
WiredEmoji.fromUnicode(0x1f600, size: 32)
```

### Constructor parameters

| Parameter | Type                | Default | Description                                          |
| --------- | ------------------- | ------- | ---------------------------------------------------- |
| `data`    | `WiredSvgIconData?` | `null`  | The emoji SVG data. Shows a placeholder when `null`. |
| `size`    | `double`            | `24.0`  | The logical size of the emoji.                       |

### Named constructors

| Constructor              | Description                                                         |
| ------------------------ | ------------------------------------------------------------------- |
| `WiredEmoji.fromName`    | Looks up emoji by identifier string via `kSkribbleEmojiCodePoints`. |
| `WiredEmoji.fromUnicode` | Looks up emoji by Unicode codepoint via `kSkribbleEmoji`.           |

---

## Available emoji

The emoji catalog is generated from OpenMoji SVG sources through the Skribble rough icon pipeline. The catalog is populated by running the generator against the emoji manifest.

The `kSkribbleEmoji` map contains all generated emoji keyed by Unicode codepoint, and `kSkribbleEmojiCodePoints` maps human-readable names to their codepoints.

---

## Lookup functions

| Function                         | Return type         | Description                                 |
| -------------------------------- | ------------------- | ------------------------------------------- |
| `lookupSkribbleEmojiByName()`    | `WiredSvgIconData?` | Look up emoji by identifier string.         |
| `lookupSkribbleEmojiByUnicode()` | `WiredSvgIconData?` | Look up emoji by Unicode codepoint integer. |

### Examples

```dart
import 'package:skribble_emoji/skribble_emoji.dart';

// Look up by name
final grinning = lookupSkribbleEmojiByName('grinning_face');
if (grinning != null) {
  WiredEmoji(data: grinning, size: 48);
}

// Look up by Unicode codepoint
final thumbsUp = lookupSkribbleEmojiByUnicode(0x1f44d);

// Check available emoji count
print('${kSkribbleEmoji.length} emoji available');

// Iterate all emoji names
for (final name in kSkribbleEmojiCodePoints.keys) {
  print(name);
}
```

---

## How to add more emoji

To add emoji to the catalog:

1. Download SVG sources from [OpenMoji](https://openmoji.org/) or create your own simple path-based SVG files.
2. Place the SVG files in the `packages/skribble_emoji/emoji/` directory.
3. Create or update the emoji manifest JSON file with the mapping of names to SVG filenames and Unicode codepoints.
4. Run the rough icon generator against the manifest:

```bash
cd packages/skribble &&
dart run tool/generate_rough_icons.dart \
  --kit svg-manifest \
  --manifest ../skribble_emoji/tool/emoji.manifest.json \
  --output ../skribble_emoji/lib/src/generated/skribble_emoji.g.dart \
  --map-name kSkribbleEmoji
```

5. Update the `kSkribbleEmojiCodePoints` map in `skribble_emoji.dart` with entries for each new emoji.

### SVG requirements

- Emoji SVGs should use simple path, circle, and ellipse elements.
- Complex SVG features (gradients, filters, masks, embedded images) are not supported.
- Fill rules (`nonZero` and `evenOdd`) are preserved from the source SVG.
- Keep SVGs clean and path-based for the best rough rendering results.
