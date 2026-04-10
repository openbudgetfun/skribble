# skribble_emoji

Hand-drawn emoji for the [Skribble](https://github.com/openbudgetfun/skribble)
design system.

> **Scaffold package** -- this package provides the infrastructure for
> hand-drawn emoji but does not yet contain any emoji SVG sources. Emoji will be
> added in a future update.

## Overview

`skribble_emoji` follows the same SVG-manifest pipeline used by
`skribble_icons_custom`. Once emoji SVG sources are added to the `emoji/`
directory and registered in the manifest, the rough icon generator produces a
Dart map of `WiredSvgIconData` entries that the `WiredEmoji` widget can render.

## Adding emoji

1. Place clean SVG source files in the `emoji/` directory.
2. Register each emoji in `tool/skribble_emoji.manifest.json`:

```json
{
  "icons": [
    {
      "identifier": "grinning_face",
      "codePoint": "0x1f600",
      "svgPath": "../emoji/grinning_face.svg"
    }
  ]
}
```

3. Run the rough icon generator from the workspace root:

```bash
cd packages/skribble && dart run tool/generate_rough_icons.dart \
  --kit svg-manifest \
  --manifest ../skribble_emoji/tool/skribble_emoji.manifest.json \
  --output ../skribble_emoji/lib/src/generated/skribble_emoji.g.dart \
  --map-name kSkribbleEmoji
```

4. Update the `kSkribbleEmojiCodePoints` map in `lib/skribble_emoji.dart` with
   the new identifier-to-codepoint mappings.

## Usage

```dart
import 'package:skribble_emoji/skribble_emoji.dart';

// Render an emoji by data (once emoji are generated)
final data = lookupSkribbleEmojiByName('grinning_face');
if (data != null) {
  WiredEmoji(data: data, size: 32);
}

// Render by name (shows placeholder if not found)
WiredEmoji.fromName('grinning_face', size: 32);

// Render by Unicode codepoint
WiredEmoji.fromUnicode(0x1f600, size: 32);
```

## API

| Symbol | Description |
| --- | --- |
| `kSkribbleEmoji` | `Map<int, WiredSvgIconData>` -- all generated emoji keyed by codepoint |
| `kSkribbleEmojiCodePoints` | `Map<String, int>` -- identifier to codepoint lookup |
| `lookupSkribbleEmojiByName` | Look up emoji data by string identifier |
| `lookupSkribbleEmojiByUnicode` | Look up emoji data by Unicode codepoint |
| `WiredEmoji` | Widget that renders a hand-drawn emoji |
