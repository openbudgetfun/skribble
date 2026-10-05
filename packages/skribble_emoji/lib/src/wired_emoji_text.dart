import 'package:flutter/widgets.dart';

import 'package:skribble_emoji/src/emoji_catalog.dart';
import 'package:skribble_emoji/src/emoji_palette.dart';
import 'package:skribble_emoji/src/wired_emoji.dart';

/// Text whose emoji are drawn by hand.
///
/// Every emoji in [text] becomes a [WiredEmoji] sitting on the line, sized to
/// the text, so chat messages, labels, and headings pick up skribble's emoji
/// without any markup:
///
/// ```dart
/// WiredEmojiText('Ship it 🚀 then celebrate 🎉')
/// ```
///
/// Screen readers hear each drawn emoji's Unicode name.
class WiredEmojiText extends StatelessWidget {
  /// Creates text that draws its emoji.
  const WiredEmojiText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.emojiScale = 1.15,
    this.palette = EmojiPalette.skribble,
  });

  /// The text to show.
  final String text;

  /// The text style; emoji follow its font size.
  final TextStyle? style;

  /// How lines are aligned.
  final TextAlign? textAlign;

  /// The maximum number of lines.
  final int? maxLines;

  /// How overflowing text is shown.
  final TextOverflow? overflow;

  /// Emoji size relative to the font size. Slightly larger than the text
  /// reads best, because the drawings have generous margins.
  final double emojiScale;

  /// The colours the emoji are drawn with.
  final EmojiPalette palette;

  @override
  Widget build(BuildContext context) {
    final effective = DefaultTextStyle.of(context).style.merge(style);
    final fontSize = effective.fontSize ?? 14;
    final emojiSize =
        MediaQuery.textScalerOf(context).scale(fontSize) * emojiScale;
    return Text.rich(
      TextSpan(children: emojiSpans(text, emojiSize, palette: palette)),
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Splits [text] into text spans and hand-drawn emoji spans.
///
/// Useful for building your own rich text. Each emoji becomes a
/// [WidgetSpan] holding a [WiredEmoji] of [size] logical pixels.
List<InlineSpan> emojiSpans(
  String text,
  double size, {
  EmojiPalette palette = EmojiPalette.skribble,
}) {
  final spans = <InlineSpan>[];
  final buffer = StringBuffer();
  void flush() {
    if (buffer.isEmpty) return;
    spans.add(TextSpan(text: buffer.toString()));
    buffer.clear();
  }

  for (final character in text.characters) {
    if (SkribbleEmoji.lookup(character) == null) {
      buffer.write(character);
      continue;
    }
    flush();
    spans.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: WiredEmoji(character, size: size, palette: palette),
      ),
    );
  }
  flush();
  return spans;
}
