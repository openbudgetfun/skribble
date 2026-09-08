import 'package:flutter/widgets.dart';

/// Shared keys for motion gallery interactions and browser tests.
abstract final class MotionKeys {
  static const ValueKey<String> action = ValueKey('motion-action');
  static const ValueKey<String> enabled = ValueKey('motion-enabled');
  static const ValueKey<String> half = ValueKey('motion-half');
  static const ValueKey<String> preview = ValueKey('motion-preview');
  static const ValueKey<String> replay = ValueKey('motion-replay');
  static const ValueKey<String> reverse = ValueKey('motion-reverse');
  static const ValueKey<String> scrub = ValueKey('motion-scrub');
  static const ValueKey<String> slow = ValueKey('motion-slow');
  static const ValueKey<String> status = ValueKey('motion-status');
  static const ValueKey<String> title = ValueKey('motion-title');
}
