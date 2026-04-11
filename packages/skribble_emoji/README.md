# skribble_emoji

Hand-drawn emoji for the [Skribble](https://github.com/openbudgetfun/skribble)
design system.

## Overview

`skribble_emoji` provides **1,800+** hand-drawn emoji rendered as SVG path data
using the `WiredSvgIcon` pipeline from the `skribble` package.

Emoji artwork is sourced from [OpenMoji](https://openmoji.org/) and licensed
under **CC-BY-SA 4.0**.

### Categories covered

| Category | Examples |
|---|---|
| Smileys & Emotion | grinning face, face with tears of joy, thinking face |
| People & Body | thumbs up, waving hand, folded hands |
| Animals & Nature | dog face, cat face, sun, rainbow |
| Food & Drink | pizza, hamburger, hot beverage |
| Travel & Places | rocket, house, world map |
| Activities | trophy, direct hit, party popper |
| Objects | laptop, key, memo, camera |
| Symbols | red heart, star, check mark, fire |
| Flags | regional indicator symbols |

## Usage

```dart
import 'package:skribble_emoji/skribble_emoji.dart';

// Render an emoji by name
WiredEmoji.fromName('grinning_face', size: 32);

// Render by Unicode codepoint
WiredEmoji.fromUnicode(0x1f600, size: 32);

// Look up data and render manually
final data = lookupSkribbleEmojiByName('fire');
if (data != null) {
  WiredEmoji(data: data, size: 48);
}
```

## API

| Symbol | Description |
|---|---|
| `kSkribbleEmoji` | `Map<int, WiredSvgIconData>` -- all emoji keyed by codepoint |
| `kSkribbleEmojiCodePoints` | `Map<String, int>` -- name to codepoint lookup |
| `lookupSkribbleEmojiByName` | Look up emoji data by string identifier |
| `lookupSkribbleEmojiByUnicode` | Look up emoji data by Unicode codepoint |
| `WiredEmoji` | Widget that renders a hand-drawn emoji |

## Regeneration

The generated Dart files are committed to the repository. To regenerate from
scratch (e.g. after an OpenMoji update):

1. Download OpenMoji SVGs:

```bash
bash tool/download_openmoji.sh /tmp/openmoji-svgs
```

2. Run the generation script:

```bash
python3 tool/generate_emoji.py \
    --svg-dir /tmp/openmoji-svgs \
    --output-dir lib/src/generated/
```

The script downloads the OpenMoji CSV catalog automatically, filters out
skin-tone variants and complex ZWJ sequences, parses each SVG, and produces:

- `lib/src/generated/skribble_emoji.g.dart` -- the codepoint-to-icon-data map
- `lib/src/generated/skribble_emoji_codepoints.g.dart` -- the name-to-codepoint map

## Attribution

Emoji artwork: [OpenMoji](https://openmoji.org/) -- the open-source emoji and
icon project. License: [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).
