# skribble_emoji

skribble's own hand-drawn emoji for Flutter. Every fully-qualified emoji in Unicode Emoji 18.0 (3,963, with skin tones, gendered variants, families, keycaps, and flags) is drawn for skribble in one style, then inked live by the theme's pen: outlines taper and swell, fills sit a hair off the line like marker, and everything wavers with the theme's roughness.

```dart
import 'package:skribble_emoji/skribble_emoji.dart';

const WiredEmoji('🎉', size: 32);
const WiredEmoji('👩🏽‍💻', size: 48, weight: 600);
const WiredEmojiText('Shipped it 🚀 and the team ❤️ it');
```

- `WiredEmoji` draws one emoji and reads its Unicode name to screen readers. Text that is not an emoji falls back to the platform's rendering.
- `WiredEmojiText` draws text with every emoji in it replaced by a `WiredEmoji` sized to the font.
- `SkribbleEmoji` is the catalog: `lookup`, `named`, `inGroup`, `search`, and `withTone`.
- `EmojiPalette` restyles every emoji at once by changing what each colour role (`ink`, `yellow`, `skin`, …) looks like.
- `EmojiDrawing` prepares an emoji for your own painters, with named parts (`eyes`, `mouth`, `hand`, …) that a pose can move.

See the [emoji guide](https://openbudgetfun.github.io/skribble/widgets/emoji) for live examples.

## The art

Each drawing is a small SVG in `art/`, written against the rules in [`art/STYLE.md`](art/STYLE.md). Shared pieces (the smiley face, a person's head, the keycap) are included rather than copied. Gendered emoji share one drawing whose hair switches between person, man, and woman, and skin tones and "facing right" emoji are applied at runtime. That is how 3,963 emoji come from far fewer drawings.

The art is not shipped in the package. `skribble_emoji_gen` compiles it, with Unicode's pinned `emoji-test.txt`, into the generated Dart catalog. From the repository root:

```bash
dart run packages/skribble_emoji_gen/bin/generate_emoji.dart
```

To review art, render contact sheets of any folder or set of art keys into `.screenshots/emoji/`:

```bash
cd packages/skribble_emoji
EMOJI_GALLERY=animals flutter test test/art_gallery_test.dart
```

## Provenance

| Field     | Value                                                                   |
| --------- | ----------------------------------------------------------------------- |
| Art       | skribble's own, in `art/`                                               |
| License   | MIT, like the rest of skribble                                          |
| Emoji set | Unicode Emoji 18.0 `emoji-test.txt`, SHA-256 `8f3735cda1f9…d9bc57ab21a` |
| Generator | `dart run packages/skribble_emoji_gen/bin/generate_emoji.dart`          |
| Registry  | `tool/asset_sources.txt`                                                |

Generation is deterministic, and CI regenerates the catalog and fails on any difference. It also fails when any emoji in the pinned list has no drawing.
