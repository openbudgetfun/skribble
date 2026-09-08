import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

/// Renders a hand-drawn emoji from [WiredSvgIconData].
///
/// When [data] is `null` (e.g. the requested emoji has not been generated yet),
/// a placeholder is rendered: a "?" character inside a hand-drawn circle.
///
/// Named constructors [WiredEmoji.fromName] and [WiredEmoji.fromUnicode]
/// provide convenient lookup-based construction.
class WiredEmoji extends HookWidget {
  /// Creates a [WiredEmoji] from explicit [data].
  ///
  /// If [data] is `null`, a placeholder is shown.
  const WiredEmoji({
    super.key,
    this.data,
    this.size = 24.0,
    this.semanticLabel,
  });

  /// Creates a [WiredEmoji] by looking up the emoji [name] in
  /// [kSkribbleEmojiCodePoints].
  ///
  /// If the name is not found, a placeholder is rendered.
  WiredEmoji.fromName(
    String name, {
    super.key,
    this.size = 24.0,
    this.semanticLabel,
  }) : data = lookupSkribbleEmojiByName(name);

  /// Creates a [WiredEmoji] by looking up the Unicode [codePoint] in
  /// [kSkribbleEmoji].
  ///
  /// If the codepoint is not found, a placeholder is rendered.
  WiredEmoji.fromUnicode(
    int codePoint, {
    super.key,
    this.size = 24.0,
    this.semanticLabel,
  }) : data = lookupSkribbleEmojiByUnicode(codePoint);

  /// Creates an emoji from a complete Unicode string or hexadecimal sequence.
  WiredEmoji.fromSequence(
    String sequence, {
    super.key,
    this.size = 24.0,
    this.semanticLabel,
  }) : data = lookupSkribbleEmojiBySequence(sequence);

  /// Accessible description of the emoji, including its meaning in context.
  final String? semanticLabel;

  /// The emoji icon data to render, or `null` to show a placeholder.
  final WiredSvgIconData? data;

  /// The logical size of the emoji. Defaults to 24.0.
  final double size;

  @override
  Widget build(BuildContext context) => PrecomputedEmoji(
    data: data,
    size: size,
    semanticLabel: semanticLabel,
  );
}
