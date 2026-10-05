---
skribble_emoji: major
skribble_emoji_gen: major
skribble: minor
---

# skribble draws its own emoji

`skribble_emoji` no longer converts OpenMoji. Every fully-qualified emoji in Unicode Emoji 18.0 (3,963, including skin tones, gendered variants, families, keycaps, and flags) is drawn for skribble as SVG art in one style and inked at runtime by the theme pen, so emoji follow the theme's roughness, pen, and `weight`. The art is MIT.

```dart
// Before
WiredEmoji.fromName('grinning_face', size: 32);
PrecomputedEmoji.fromSequence('🇬🇧', size: 32);
lookupSkribbleEmojiByName('red_heart');
EmojiSearch.search('cat');

// After
const WiredEmoji('😀', size: 32);
const WiredEmoji('🇬🇧', size: 32);
SkribbleEmoji.named('red_heart');
SkribbleEmoji.search('cat');
```

`SkribbleEmoji` is the catalog (`all`, `defaults`, `lookup`, `named`, `inGroup`, `search`, `withTone`), and `EmojiEntry` carries each emoji's name, group, subgroup, and art. `WiredEmojiText` draws emoji inside text. `EmojiPalette` restyles every emoji by colour role and compares by value; `EmojiDrawing` prepares an emoji for custom painters with named parts that a pose can move. `PrecomputedEmoji`, `EmojiSearch`, `EmojiSearchResult`, the `kSkribbleEmoji*` maps, the `lookupSkribbleEmojiBy*` functions, and the `WiredSvgIconData` re-exports are removed.

`skribble_emoji_gen` replaces the OpenMoji conversion with `EmojiArtCompiler`, which enforces the authoring rules in `art/STYLE.md`, and `parseEmojiTest` and `planEmoji`, which plan the pinned Unicode list onto art. `generate_emoji.dart` takes `--art`, `--output`, `--unicode`, `--report`, `--allow-missing`, and `--check`, and `update_assets.dart` no longer downloads OpenMoji.

`skribble` exports `waverPath`, `waveredPolygons`, and `WaveredContour`, the smooth wavering that icons and emoji share.
