part of 'catalog.dart';

/// @docs-example emoji
Widget _emoji(ExampleSettings settings) => Wrap(
  spacing: 20,
  runSpacing: 20,
  children: [
    for (final emoji in ['😀', '🎉', '👩🏽‍💻', '🐱', '🍕', '🚀', '🇯🇵'])
      WiredEmoji(emoji, size: 56, weight: settings.weight),
  ],
);

/// @docs-example emoji-tones
Widget _emojiTones(ExampleSettings settings) => Wrap(
  spacing: 16,
  runSpacing: 16,
  children: [
    for (final tone in EmojiSkinTone.values)
      WiredEmoji(
        SkribbleEmoji.withTone(SkribbleEmoji.lookup('👋')!, tone)!.emoji,
        size: 48,
      ),
  ],
);

/// @docs-example emoji-text
Widget _emojiText(ExampleSettings settings) => const WiredEmojiText(
  'Shipped it 🚀 and the whole team ❤️ it 🎉',
  style: TextStyle(fontSize: 24),
);

/// @docs-example emoji-animated
Widget _emojiAnimated(ExampleSettings settings) => Wrap(
  spacing: 20,
  runSpacing: 20,
  children: [
    for (final emoji in ['❤️', '😂', '👋', '🔥', '🎉', '🚀'])
      WiredAnimatedEmoji(emoji, size: 56, loops: 3),
  ],
);
