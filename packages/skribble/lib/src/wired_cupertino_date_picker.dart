import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn date picker corresponding to Flutter's [CupertinoDatePicker].
///
/// Wraps [CupertinoDatePicker] with a sketchy rounded rectangle border
/// for API parity with the Cupertino date picker.
class WiredCupertinoDatePicker extends HookWidget {
  /// Called when the selected date/time changes.
  final ValueChanged<DateTime> onDateTimeChanged;

  /// The initial date/time to display.
  final DateTime? initialDateTime;

  /// The minimum selectable date.
  final DateTime? minimumDate;

  /// The maximum selectable date.
  final DateTime? maximumDate;

  /// Minimum year for the picker.
  final int minimumYear;

  /// Maximum year for the picker.
  final int? maximumYear;

  /// The mode of the date picker (date, time, dateAndTime).
  final CupertinoDatePickerMode mode;

  /// Whether to use 24-hour format for time.
  final bool use24hFormat;

  /// Height of each item in the picker wheels.
  final double itemExtent;

  /// Total height of the picker.
  final double height;

  /// Border radius of the outer container.
  final BorderRadius borderRadius;

  const WiredCupertinoDatePicker({
    super.key,
    required this.onDateTimeChanged,
    this.initialDateTime,
    this.minimumDate,
    this.maximumDate,
    this.minimumYear = 1,
    this.maximumYear,
    this.mode = CupertinoDatePickerMode.dateAndTime,
    this.use24hFormat = false,
    this.itemExtent = 32,
    this.height = 216,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return buildWiredElement(
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            // Sketchy outer border
            Positioned.fill(
              child: WiredCanvas(
                painter: WiredRoundedRectangleBase(
                  borderRadius: borderRadius,
                  borderColor: theme.borderColor,
                ),
                fillerType: RoughFilter.noFiller,
              ),
            ),
            // Selection highlight at center
            Center(
              child: SizedBox(
                height: itemExtent,
                child: WiredCanvas(
                  painter: WiredRectangleBase(
                    fillColor: theme.borderColor.withValues(alpha: 0.08),
                    borderColor: theme.borderColor,
                  ),
                  fillerType: RoughFilter.noFiller,
                ),
              ),
            ),
            // The actual Cupertino picker
            ClipRRect(
              borderRadius: borderRadius,
              child: CupertinoDatePicker(
                mode: mode,
                onDateTimeChanged: onDateTimeChanged,
                initialDateTime: initialDateTime,
                minimumDate: minimumDate,
                maximumDate: maximumDate,
                minimumYear: minimumYear,
                maximumYear: maximumYear,
                use24hFormat: use24hFormat,
                itemExtent: itemExtent,
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
