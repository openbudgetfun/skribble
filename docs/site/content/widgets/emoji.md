---
title: Emoji
description: skribble's own hand-drawn emoji, every Unicode emoji, inked live by the theme pen with skin tones, a themeable palette, and inline emoji text.
---

# Emoji

`skribble_emoji` is skribble's own emoji set. Every fully-qualified emoji in Unicode Emoji 18.0 (3,963 of them, including skin tones, gendered variants, families, keycaps, and flags) is drawn for skribble in one style: bold friendly shapes, flat marker colours, and ink outlines.

The drawings are not pictures. Each one is a handful of shapes that the app inks at runtime with the theme's pen, so outlines taper and swell, fills sit a hair off the line like marker, and the whole emoji wavers with the theme's roughness. An emoji in a calm theme looks calm; the same emoji in a scribbly theme looks scribbled.

---

## Installation

```bash
dart pub add skribble_emoji
```

```dart
// Static example: setup
import 'package:skribble_emoji/skribble_emoji.dart';
```

---

## WiredEmoji

Pass the emoji itself. `WiredEmoji` fills a square of `size` logical pixels and reads the emoji's Unicode name to screen readers.

```dart
// Live example: emoji
Wrap(
  spacing: 20,
  runSpacing: 20,
  children: [
    for (final emoji in ['😀', '🎉', '👩🏽‍💻', '🐱', '🍕', '🚀', '🇯🇵'])
      WiredEmoji(emoji, size: 56, weight: 400),
  ],
)
```

Variation selectors are optional: `'❤'` and `'❤️'` draw the same heart. Text that is not an emoji falls back to the platform's own rendering, so passing user input is safe.

### Parameters

| Parameter       | Type           | Default                 | Description                                                 |
| --------------- | -------------- | ----------------------- | ----------------------------------------------------------- |
| `emoji`         | `String`       | required                | The emoji to draw, such as `'🎉'` or `'👩🏽‍💻'`.                |
| `size`          | `double`       | `24`                    | The side of the square, in logical pixels.                  |
| `semanticLabel` | `String?`      | the Unicode name        | Accessible description.                                     |
| `palette`       | `EmojiPalette` | `EmojiPalette.skribble` | The colours the emoji is drawn with.                        |
| `weight`        | `double?`      | `IconTheme` weight, 400 | Pen weight from 100 to 700, as for [icons](/widgets/icons). |
| `drawConfig`    | `DrawConfig?`  | from the theme          | Overrides the theme's wavering and pen for this emoji only. |

`WiredEmoji.named('red_heart')` looks an emoji up by its snake-case Unicode name instead.

Prepared drawings are cached by emoji, size, theme, palette, and weight, so a chat list that shows the same reaction a hundred times prepares it once.

---

## Skin tones

People and hands take the five Fitzpatrick skin tones. A toned emoji is just text, so `'👋🏾'` works directly; `SkribbleEmoji.withTone` builds one from its base emoji.

```dart
// Live example: emoji-tones
Wrap(
  spacing: 16,
  runSpacing: 16,
  children: [
    for (final tone in EmojiSkinTone.values)
      WiredEmoji(
        SkribbleEmoji.withTone(SkribbleEmoji.lookup('👋')!, tone)!.emoji,
        size: 48,
      ),
  ],
)
```

The tone colours the skin and the hair together. Two-person emoji such as couples and handshakes take a tone for each person.

---

## Emoji in text

`WiredEmojiText` draws text with every emoji in it replaced by a `WiredEmoji` sized to the font. Use it for messages, labels, and anything else that mixes words with emoji.

```dart
// Live example: emoji-text
const WiredEmojiText(
  'Shipped it 🚀 and the whole team ❤️ it 🎉',
  style: TextStyle(fontSize: 24),
)
```

`emojiScale` sets how large emoji are compared with the font size (default `1.15`). `emojiSpans` returns the same spans for building your own `Text.rich`.

---

## Looking emoji up

`SkribbleEmoji` is the catalog. Every entry carries its Unicode name, group, subgroup, and the art it is drawn with.

```dart
// Static example: api
import 'package:skribble_emoji/skribble_emoji.dart';

final party = SkribbleEmoji.lookup('🎉')!;
print(party.name); // party popper
print(party.group.label); // Activities

// Every emoji in a group, without skin-tone variants: one picker tab.
final animals = SkribbleEmoji.inGroup(EmojiGroup.animalsAndNature);

// Search by name. Word starts and shorter names rank first.
final hearts = SkribbleEmoji.search('heart');

// Skin tones.
final wave = SkribbleEmoji.withTone(
  SkribbleEmoji.lookup('👋')!,
  EmojiSkinTone.medium,
);
print(wave?.emoji); // 👋🏽
```

| Member                        | Description                                                       |
| ----------------------------- | ----------------------------------------------------------------- |
| `SkribbleEmoji.all`           | Every fully-qualified emoji, in Unicode order.                    |
| `SkribbleEmoji.defaults`      | Every emoji without a skin-tone modifier, in Unicode order.       |
| `SkribbleEmoji.lookup(text)`  | The entry for an emoji, ignoring variation selectors.             |
| `SkribbleEmoji.named(id)`     | The entry for a snake-case name such as `grinning_face`.          |
| `SkribbleEmoji.inGroup(g)`    | The emoji in one `EmojiGroup`, without skin-tone variants.        |
| `SkribbleEmoji.search(query)` | Emoji whose names contain every word of the query, best first.    |
| `SkribbleEmoji.withTone(e,t)` | The entry drawn with skin tone `t`, or null when it has no tones. |

---

## Palettes

Art paints with colour roles (`ink`, `yellow`, `skin`, `hair`, and so on) rather than colours, and `EmojiPalette` decides what each role looks like. Restyle every emoji at once without redrawing anything:

```dart
// Static example: api
import 'package:flutter/widgets.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

final pastel = EmojiPalette.skribble.copyWith(
  colors: {
    EmojiToken.ink: const Color(0xFF5B4B6E),
    EmojiToken.yellow: const Color(0xFFFFE08A),
    EmojiToken.red: const Color(0xFFF08A8A),
  },
);

final heart = WiredEmoji('❤️', size: 48, palette: pastel);
```

Palettes compare by value, so building one inside `build` still reuses cached drawings.

---

## Drawing emoji yourself

`EmojiDrawing` prepares an emoji once and paints it onto any canvas, which is how you put emoji into custom painters, charts, or animations. Drawings are split into named parts (`eyes`, `mouth`, `hand`, `flame`, …), and `paint` takes a pose that moves parts as rigid groups:

```dart
// Static example: api
import 'package:flutter/widgets.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

void paintWink(Canvas canvas, WiredThemeData theme) {
  final drawing = EmojiDrawing(
    SkribbleEmoji.lookup('😀')!,
    size: 96,
    config: emojiDrawConfig(theme, 96),
  );
  drawing.paint(
    canvas,
    pose: {'eyes': Matrix4.diagonal3Values(1, 0.2, 1)},
  );
}
```

`drawing.parts` lists the parts a drawing has.

---

## How the art is made

Each drawing is a small SVG on a 36-unit grid in `packages/skribble_emoji/art/`, written by hand against the rules in `art/STYLE.md`: which colour roles to use, line widths, where the shade falls, and how parts are named. Shared pieces, such as the smiley face, a person's head, and the keycap, are included rather than copied, and one drawing serves many emoji:

- Gendered emoji share a drawing whose hair and clothing switch between person, man, and woman.
- Skin tones and the "facing right" emoji are applied at runtime, not drawn again.
- Flags are drawn flat with their official colours, then waved, clipped, and outlined by the generator.

`skribble_emoji_gen` compiles the SVGs and the pinned Unicode `emoji-test.txt` into the Dart catalog. Regenerate from the repository root:

```bash
dart run packages/skribble_emoji_gen/bin/generate_emoji.dart
```

The art is skribble's own, under the same MIT license as the rest of the project.
