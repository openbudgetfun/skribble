---
title: Emoji
description: Hand-drawn emoji from OpenMoji, rendered as rough SVG icons with the WiredEmoji widget.
---

# Emoji

The `skribble_emoji` package provides hand-drawn emoji sourced from [OpenMoji](https://openmoji.org/), roughened during generation and rendered as colored paths with pen strokes.

---

## Installation

```bash
dart pub add skribble_emoji
```

Import the package:

```dart
// Static example: setup
import 'package:skribble_emoji/skribble_emoji.dart';
```

---

## WiredEmoji

The primary widget for rendering a hand-drawn emoji. When the requested emoji data is `null` (not yet generated), a placeholder circle with a "?" character is shown.

```dart
// Live example: emoji
Wrap(
  spacing: 20,
  runSpacing: 20,
  children: [
    WiredEmoji.fromName('grinning_face', size: 56),
    WiredEmoji.fromSequence(
      '👩🏽‍💻',
      size: 56,
      semanticLabel: 'Developer',
    ),
    WiredEmoji.fromSequence(
      '🇬🇧',
      size: 56,
      semanticLabel: 'United Kingdom',
    ),
  ],
)
```

### Constructor parameters

| Parameter | Type                | Default | Description                                          |
| --------- | ------------------- | ------- | ---------------------------------------------------- |
| `data`    | `WiredSvgIconData?` | `null`  | The emoji SVG data. Shows a placeholder when `null`. |
| `size`    | `double`            | `24.0`  | The logical size of the emoji.                       |

### Named constructors

| Constructor              | Description                                                    |
| ------------------------ | -------------------------------------------------------------- |
| `WiredEmoji.fromName`    | Looks up emoji by identifier string via `kSkribbleEmojiNames`. |
| `WiredEmoji.fromUnicode` | Looks up emoji by Unicode codepoint via `kSkribbleEmoji`.      |

---

## Available emoji

The emoji catalog is generated from OpenMoji SVG sources through the Skribble rough icon pipeline. The catalog is populated by running the generator against the emoji manifest.

The `kSkribbleEmoji` and `kSkribbleEmojiCodePoints` maps cover single Unicode scalars. `kSkribbleEmojiNames` contains every name, including full joined sequences.

---

## Lookup functions

| Function                         | Return type         | Description                                 |
| -------------------------------- | ------------------- | ------------------------------------------- |
| `lookupSkribbleEmojiByName()`    | `WiredSvgIconData?` | Look up emoji by identifier string.         |
| `lookupSkribbleEmojiByUnicode()` | `WiredSvgIconData?` | Look up emoji by Unicode codepoint integer. |

### Examples

```dart
// Static example: api
import 'package:skribble_emoji/skribble_emoji.dart';

// Look up by name
final grinning = lookupSkribbleEmojiByName('grinning_face');
if (grinning != null) {
  WiredEmoji(data: grinning, size: 48);
}

// Look up by Unicode codepoint
final thumbsUp = lookupSkribbleEmojiByUnicode(0x1f44d);

// Check available emoji count
print('${kSkribbleEmojiNames.length} emoji available');

// Iterate all emoji names
for (final name in kSkribbleEmojiNames.keys) {
  print(name);
}
```

---

## OpenMoji 17 and complete sequences

The generated catalog contains **4,495 named OpenMoji 17.0.0 entries**, including Unicode 17 additions, joined professions, skin tones, flags, and keycaps. `kSkribbleEmoji` and `kSkribbleEmojiCodePoints` remain single-scalar compatibility maps; use `kSkribbleEmojiNames` for the complete name list.

```dart
// Live example: emoji-sequences
Wrap(
  spacing: 20,
  runSpacing: 20,
  children: [
    WiredEmoji.fromSequence(
      '👩🏽‍💻',
      size: 64,
      semanticLabel: 'Developer',
    ),
    PrecomputedEmoji.fromSequence(
      '🇬🇧',
      size: 64,
      semanticLabel: 'United Kingdom',
    ),
  ],
)
```

`lookupSkribbleEmojiBySequence` accepts literal emoji or hyphenated hexadecimal scalars. Optional FE0F presentation selectors are normalized; ZWJ, skin tones, and regional indicators are retained. `EmojiSearchResult.sequence` exposes the full sequence, while `codePoint` remains its first scalar for compatibility.

Both widget entry points render the same precomputed, gently warped artwork. Source colors, unfilled strokes, transforms, transparency, clip paths, and fill rules are preserved. `PrecomputedEmoji.color` is a fallback for uncolored data and placeholders, not a palette override.

Regenerate from the repository root with `dart run packages/skribble_emoji_gen/bin/update_assets.dart`. The command checks pinned source hashes before writing output. The source artwork is by [OpenMoji](https://openmoji.org/) under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/); Skribble's modified artwork retains that license. Preserve attribution when redistributing it.
