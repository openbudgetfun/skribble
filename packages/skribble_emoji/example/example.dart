import 'package:flutter/widgets.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

/// Draws emoji by hand: on their own, inside running text, and animated.
void main() {
  runApp(
    SkribbleApp(
      wiredTheme: WiredThemeData(),
      home: const EmojiExample(),
    ),
  );
}

/// A small screen of hand-drawn emoji.
class EmojiExample extends StatelessWidget {
  /// Creates the example screen.
  const EmojiExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              WiredEmoji('🎉', size: 48),
              WiredEmoji('👩🏽‍💻', size: 48),
              WiredEmoji('🇯🇵', size: 48),
            ],
          ),
          // Emoji inside text follow its size and the reader's text scale.
          WiredEmojiText('Ship it 🚀 then celebrate 🎉'),
          // Each emoji has a motion; reduced-motion settings keep it still.
          WiredAnimatedEmoji('❤️', size: 64),
        ],
      ),
    );
  }
}
