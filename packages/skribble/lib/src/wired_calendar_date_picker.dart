import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn calendar date picker that wraps Flutter's
/// [CalendarDatePicker] for full API parity.
///
/// Provides the same parameters as [CalendarDatePicker] while adding
/// a sketchy rounded-rectangle border around the picker.
class WiredCalendarDatePicker extends HookWidget {
  /// The initially selected date.
  final DateTime initialDate;

  /// The earliest selectable date.
  final DateTime firstDate;

  /// The latest selectable date.
  final DateTime lastDate;

  /// Called when the user selects a date.
  final ValueChanged<DateTime> onDateChanged;

  /// Called when the displayed month changes.
  final ValueChanged<DateTime>? onDisplayedMonthChanged;

  /// The initial calendar mode (day or year).
  final DatePickerMode initialCalendarMode;

  /// Optional predicate to control which dates are selectable.
  final bool Function(DateTime)? selectableDayPredicate;

  const WiredCalendarDatePicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateChanged,
    this.onDisplayedMonthChanged,
    this.initialCalendarMode = DatePickerMode.day,
    this.selectableDayPredicate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return buildWiredElement(
      child: Stack(
        children: [
          Positioned.fill(
            child: WiredCanvas(
              painter: WiredRoundedRectangleBase(
                borderRadius: BorderRadius.circular(16),
                borderColor: theme.borderColor,
              ),
              fillerType: RoughFilter.noFiller,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: CalendarDatePicker(
              initialDate: initialDate,
              firstDate: firstDate,
              lastDate: lastDate,
              onDateChanged: onDateChanged,
              onDisplayedMonthChanged: onDisplayedMonthChanged,
              initialCalendarMode: initialCalendarMode,
              selectableDayPredicate: selectableDayPredicate,
            ),
          ),
        ],
      ),
    );
  }
}
