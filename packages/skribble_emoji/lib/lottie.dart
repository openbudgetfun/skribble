/// Exports skribble's emoji as Lottie animations, for players outside
/// Flutter's own rendering: lottie-web, the iOS and Android players, and
/// Rive's Lottie import.
///
/// ```dart
/// import 'dart:convert';
///
/// import 'package:skribble/skribble.dart';
/// import 'package:skribble_emoji/lottie.dart';
/// import 'package:skribble_emoji/skribble_emoji.dart';
///
/// final json = jsonEncode(
///   emojiLottie(
///     SkribbleEmoji.lookup('🔥')!,
///     config: emojiDrawConfig(WiredThemeData(), 72),
///   ),
/// );
/// ```
library;

export 'src/emoji_lottie.dart' show emojiLottie;
