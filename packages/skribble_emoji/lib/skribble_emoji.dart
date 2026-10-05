/// skribble's own hand-drawn emoji.
///
/// Every fully-qualified Unicode 18 emoji, drawn for skribble and inked live
/// by the theme pen: skin tones, gendered variants, keycaps, and flags
/// included. Colours come from an `EmojiPalette`, so the whole set can be
/// restyled without redrawing it.
///
/// ```dart
/// import 'package:skribble_emoji/skribble_emoji.dart';
///
/// const WiredEmoji('🎉', size: 32);
/// WiredEmojiText('Ship it 🚀');
/// SkribbleEmoji.search('cat');
/// ```
library;

export 'src/emoji_art.dart' show EmojiArt, EmojiShape, EmojiVariant;
export 'src/emoji_catalog.dart' show EmojiEntry, EmojiGroup, SkribbleEmoji;
export 'src/emoji_drawing.dart' show EmojiDrawing, kEmojiArtSize;
export 'src/emoji_motion.dart'
    show EmojiMotion, EmojiMove, EmojiPose, EmojiTrack;
export 'src/emoji_motions.dart' show EmojiMotions;
export 'src/emoji_palette.dart'
    show EmojiPaint, EmojiPalette, EmojiSkinTone, EmojiToken;
export 'src/wired_animated_emoji.dart' show WiredAnimatedEmoji;
export 'src/wired_emoji.dart' show WiredEmoji, emojiDrawConfig, emojiDrawingFor;
export 'src/wired_emoji_text.dart' show WiredEmojiText, emojiSpans;
