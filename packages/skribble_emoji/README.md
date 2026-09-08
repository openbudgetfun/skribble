# skribble_emoji

Hand-drawn, colored emoji for Flutter from OpenMoji 17.0.0. The catalog contains 4,495 names, including complete skin-tone, flag, and joined sequences.

```dart
import 'package:skribble_emoji/skribble_emoji.dart';

WiredEmoji.fromName('grinning_face', size: 32);
WiredEmoji.fromSequence('👩🏽‍💻', semanticLabel: 'Developer');
PrecomputedEmoji.fromSequence('🇬🇧', size: 48);
```

Both widgets render precomputed paths that are gently roughened during generation. Colors, strokes, transparency, clipping, and contour holes remain intact. `PrecomputedEmoji.color` only supplies fallback color for uncolored data or a placeholder.

`kSkribbleEmojiNames` includes every name and full hexadecimal sequence. `lookupSkribbleEmojiBySequence` accepts either actual emoji text or hyphenated hexadecimal scalars. The existing `kSkribbleEmoji` and `kSkribbleEmojiCodePoints` maps cover single scalars. Search results include the full `sequence` and the legacy first `codePoint`.

From the workspace root, run `dart run packages/skribble_emoji_gen/bin/update_assets.dart` to verify pinned downloads and rebuild emoji, icons, and fonts. The generator's SVG tests and this package's corpus/pixel tests validate the conversion. Do not edit generated maps manually.

Artwork by [OpenMoji](https://openmoji.org/), licensed [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). The gently warped derivatives retain that license; keep the attribution when redistributing artwork.

Source stroke dashes, cap/join styles, miter limits, hidden layers, and stroke-first paint ordering are preserved. Dash gaps and square caps are verified in both Flutter rendering paths.
