import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
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
    this.itemExtent = 40,
    this.height = 216,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  /// The narrowest width Cupertino lays out this mode's columns in.
  double get _minimumWidth => switch (mode) {
    CupertinoDatePickerMode.time => 220,
    CupertinoDatePickerMode.dateAndTime => 370,
    _ => 300,
  };

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
                  strokeWidth: theme.strokeWidth,
                  borderRadius: borderRadius,
                  borderColor: theme.borderColor,
                ),
                fillerType: RoughFilter.noFiller,
              ),
            ),
            // The selected row's band. The ink sits inside its box, so the
            // box is a little taller than a row to draw its lines around it.
            Center(
              child: SizedBox(
                height: itemExtent + 8,
                child: WiredCanvas(
                  painter: WiredRectangleBase(
                    strokeWidth: theme.strokeWidth,
                    fillColor: theme.borderColor.withValues(alpha: 0.08),
                    borderColor: theme.borderColor,
                  ),
                  fillerType: RoughFilter.noFiller,
                ),
              ),
            ),
            // The wheels, inside the ink. Cupertino needs a minimum width for
            // its columns, so a narrow picker scales down instead of failing.
            ClipRRect(
              borderRadius: borderRadius,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: LayoutBuilder(
                  // Centred, so a scaled-down wheel keeps its selected row
                  // in the band.
                  builder: (context, box) => Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: math.max(box.maxWidth, _minimumWidth),
                        height: box.maxHeight,
                        // The wheels write in the theme's hand, at the size
                        // their rows were designed for.
                        child: MediaQuery.withNoTextScaling(
                          child: CupertinoTheme(
                            data: CupertinoThemeData(
                              textTheme: CupertinoTextThemeData(
                                dateTimePickerTextStyle: TextStyle(
                                  fontFamily: theme.fontFamily,
                                  package: theme.fontPackage,
                                  fontSize: 21,
                                  color: theme.textColor,
                                ),
                              ),
                            ),
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
                              backgroundColor: const Color(0x00000000),
                              // The hand-drawn band replaces Cupertino's grey
                              // one.
                              selectionOverlayBuilder: (
                                context, {
                                required columnCount,
                                required selectedIndex,
                              }) => null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
