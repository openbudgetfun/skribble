import 'package:flutter/widgets.dart';

/// Shared interaction keys for the studio and its Patrol journeys.
abstract final class QualityKeys {
  static const ValueKey<String> add = ValueKey('studio-add');
  static const ValueKey<String> checkbox = ValueKey('studio-checkbox');
  static const ValueKey<String> dark = ValueKey('studio-dark');
  static const ValueKey<String> input = ValueKey('studio-input');
  static const ValueKey<String> inputResult = ValueKey('studio-input-result');
  static const ValueKey<String> reset = ValueKey('studio-reset');
  static const ValueKey<String> reminderStatus = ValueKey(
    'studio-reminder-status',
  );
  static const ValueKey<String> scroll = ValueKey('studio-scroll');
  static const ValueKey<String> status = ValueKey('studio-status');
  static const ValueKey<String> switchControl = ValueKey('studio-switch');
  static const ValueKey<String> title = ValueKey('studio-title');
}
