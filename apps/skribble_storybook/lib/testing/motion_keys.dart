import 'package:flutter/widgets.dart';

/// Shared keys for motion gallery interactions and browser tests.
abstract final class MotionKeys {
  /// The demo button in the preview card that counts kept ideas.
  static const ValueKey<String> action = ValueKey('motion-action');

  /// The checkbox that turns motion on or off.
  static const ValueKey<String> enabled = ValueKey('motion-enabled');

  /// The button that moves the pen to the halfway point.
  static const ValueKey<String> half = ValueKey('motion-half');

  /// The preview card that draws itself in.
  static const ValueKey<String> preview = ValueKey('motion-preview');

  /// The button that replays the drawing from the start.
  static const ValueKey<String> replay = ValueKey('motion-replay');

  /// The button that unwinds the ink back to the start.
  static const ValueKey<String> reverse = ValueKey('motion-reverse');

  /// The slider that scrubs the pen progress.
  static const ValueKey<String> scrub = ValueKey('motion-scrub');

  /// The checkbox that slows the drawing down.
  static const ValueKey<String> slow = ValueKey('motion-slow');

  /// The text that describes the current motion state.
  static const ValueKey<String> status = ValueKey('motion-status');

  /// The page title.
  static const ValueKey<String> title = ValueKey('motion-title');
}
