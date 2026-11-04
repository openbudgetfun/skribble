import 'package:flutter/widgets.dart';

/// Shared interaction keys for the studio and its Patrol journeys.
abstract final class QualityKeys {
  /// The button that saves the typed idea.
  static const ValueKey<String> add = ValueKey('studio-add');

  /// The checkbox that marks the task as done.
  static const ValueKey<String> checkbox = ValueKey('studio-checkbox');

  /// The button that toggles the dark theme.
  static const ValueKey<String> dark = ValueKey('studio-dark');

  /// The text field for a new idea.
  static const ValueKey<String> input = ValueKey('studio-input');

  /// The text that shows the last saved idea.
  static const ValueKey<String> inputResult = ValueKey('studio-input-result');

  /// The button that clears the field, the task and the saved idea.
  static const ValueKey<String> reset = ValueKey('studio-reset');

  /// The text that reflects the reminder switch.
  static const ValueKey<String> reminderStatus = ValueKey(
    'studio-reminder-status',
  );

  /// The scroll view that holds the studio content.
  static const ValueKey<String> scroll = ValueKey('studio-scroll');

  /// The text that reflects the task checkbox.
  static const ValueKey<String> status = ValueKey('studio-status');

  /// The switch that turns the reminder on or off.
  static const ValueKey<String> switchControl = ValueKey('studio-switch');

  /// The studio title.
  static const ValueKey<String> title = ValueKey('studio-title');
}
