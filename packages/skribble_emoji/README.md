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

## Provenance

This catalog is generated, never hand-edited. The table records exactly what it
was built from. Bumping a value means editing `tool/asset_sources.txt` in the
same commit as the regenerated catalog.

| Field | Value |
| --- | --- |
| Source | [OpenMoji](https://openmoji.org) |
| Upstream version | `17.0.0` |
| SVG archive SHA-256 | `59b0cd9f6fe0…5cc3805689` |
| Catalog CSV SHA-256 | `28375217b92f…d4032cbe7e` |
| License | CC-BY-SA-4.0 (retained by the warped derivative) |
| Names generated | 4,495, including skin-tone, flag, and ZWJ sequences |
| Generator | `dart run packages/skribble_emoji_gen/bin/update_assets.dart` |
| Registry | `tool/asset_sources.txt` |

Generation is deterministic: rebuilding from the same source bytes reproduces
this catalog byte for byte. CI re-derives every catalog and fails on any diff,
so an upstream change can never land silently.
