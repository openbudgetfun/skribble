part of 'catalog.dart';

/// @docs-example emoji
Widget _emoji(ExampleSettings settings) => Wrap(
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
);

/// @docs-example emoji-sequences
Widget _emojiSequences(ExampleSettings settings) => Wrap(
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
);
