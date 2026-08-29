import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_button.dart';
import 'wired_theme.dart';

/// Default header shown above the month grid of a
/// [WiredDateRangePickerDialog] until the range is complete.
const String _kRangeHeaderHint = 'Select range';

const List<String> _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> _shortMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const List<String> _weekdaysShort = [
  'Sun',
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
];

const int _cDay = 24 * 60 * 60 * 1000;

const double _kCellWidth = 45.0;

DateTime _dateOf(DateTime d) => DateTime(d.year, d.month, d.day);

String _formatShort(DateTime d) =>
    '${_shortMonths[d.month - 1]} ${d.day}, ${d.year}';

TextStyle _wiredTextStyle({
  double fontSize = 18,
  FontWeight fontWeight = FontWeight.w500,
  Color? color,
}) {
  return TextStyle(
    fontFamily: skribbleFontFamily,
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  );
}

/// A hand-drawn dialog for selecting a date range, analogous to Material's
/// `showDateRangePicker`.
///
/// The month grid follows the `WiredCalendar` pattern: a rough circle marks
/// each range endpoint and hachure-filled rectangles highlight the days in
/// between. Days outside [firstDate]..[lastDate] (and days from neighbouring
/// months) are dimmed and disabled.
///
/// Prefer showing it via [showWiredDateRangePicker], which pops the completed
/// range (or `null`) through the route:
///
/// ```dart
/// final range = await showWiredDateRangePicker(
///   context: context,
///   initialDateRange: DateTimeRange(
///     start: DateTime(2026, 6, 5),
///     end: DateTime(2026, 6, 12),
///   ),
/// );
/// ```
///
/// See also:
///  * `WiredDatePicker`, the single-date dialog equivalent.
///  * `WiredCalendar`, the month grid this dialog follows.
class WiredDateRangePickerDialog extends HookWidget {
  /// Pre-selected range shown when the dialog opens.
  final DateTimeRange<DateTime>? initialDateRange;

  /// The earliest selectable date. Defaults to the first day of the month of
  /// [initialDateRange] (or the current month when no range is given).
  final DateTime? firstDate;

  /// The latest selectable date. Defaults to one year after [firstDate].
  final DateTime? lastDate;

  /// Optional semantic label describing the dialog for accessibility.
  final String? semanticLabel;

  const WiredDateRangePickerDialog({
    super.key,
    this.initialDateRange,
    this.firstDate,
    this.lastDate,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);

    // Selection state: `start` is set on the first tap; `end` on the second.
    final start = useState<DateTime?>(initialDateRange?.start);
    final end = useState<DateTime?>(initialDateRange?.end);

    // The displayed month defaults to the month of the initial range (or the
    // first selectable date when no range is given).
    final anchorCandidate = _dateOf(
      initialDateRange?.start ?? firstDate ?? DateTime.now(),
    );
    final displayedMonth = useState(anchorCandidate);

    final first = _dateOf(
      firstDate ?? DateTime(anchorCandidate.year, anchorCandidate.month, 1),
    );
    final last = _dateOf(
      lastDate ?? DateTime(first.year + 1, first.month, first.day),
    );

    final firstMonth = DateTime(first.year, first.month, 1);
    final lastMonth = DateTime(last.year, last.month, 1);
    final displayedStartOfMonth = DateTime(
      displayedMonth.value.year,
      displayedMonth.value.month,
      1,
    );

    void selectDay(DateTime day) {
      final s = start.value;
      final e = end.value;
      if (s != null && e != null) {
        // A complete range is on display; start a new selection.
        start.value = day;
        end.value = null;
        return;
      }
      if (s == null || _dateOf(day).isBefore(_dateOf(s))) {
        start.value = day;
      } else {
        end.value = day;
      }
    }

    return Semantics(
      label: semanticLabel ?? 'Date range picker',
      container: true,
      child: Dialog(
        child: SizedBox(
          width: 330,
          child: Stack(
            children: [
              Positioned.fill(
                child: WiredCanvas(
                  painter: WiredRectangleBase(
                    fillColor: theme.fillColor,
                    borderColor: theme.borderColor,
                  ),
                  fillerType: RoughFilter.noFiller,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(
                      theme: theme,
                      start: start.value,
                      end: end.value,
                    ),
                    const SizedBox(height: 12),
                    _buildMonthNav(
                      theme: theme,
                      displayedMonth: displayedStartOfMonth,
                      canGoPrev: displayedStartOfMonth.isAfter(firstMonth),
                      canGoNext: displayedStartOfMonth.isBefore(lastMonth),
                      onPrev: () => displayedMonth.value = DateTime(
                        displayedStartOfMonth.year,
                        displayedStartOfMonth.month - 1,
                        1,
                      ),
                      onNext: () => displayedMonth.value = DateTime(
                        displayedStartOfMonth.year,
                        displayedStartOfMonth.month + 1,
                        1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildWeekdayHeader(theme: theme),
                    const SizedBox(height: 8),
                    _buildDayGrid(
                      theme: theme,
                      displayedMonth: displayedStartOfMonth,
                      start: start.value,
                      end: end.value,
                      first: first,
                      last: last,
                      onSelect: selectDay,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        WiredButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        if (start.value != null && end.value != null)
                          WiredButton(
                            onPressed: () => Navigator.of(context).pop(
                              DateTimeRange<DateTime>(
                                start: start.value!,
                                end: end.value!,
                              ),
                            ),
                            child: const Text('OK'),
                          )
                        else
                          TextButton(
                            onPressed: null,
                            child: Text(
                              'OK',
                              style: TextStyle(
                                color: theme.disabledTextColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required WiredThemeData theme,
    required DateTime? start,
    required DateTime? end,
  }) {
    final text = start == null
        ? _kRangeHeaderHint
        : end == null
        ? '${_formatShort(start)} – ...'
        : '${_formatShort(start)} – ${_formatShort(end)}';

    return Text(
      text,
      textAlign: TextAlign.center,
      style: _wiredTextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: theme.textColor,
      ),
    );
  }

  Widget _buildMonthNav({
    required WiredThemeData theme,
    required DateTime displayedMonth,
    required bool canGoPrev,
    required bool canGoNext,
    required VoidCallback onPrev,
    required VoidCallback onNext,
  }) {
    final monthYear =
        '${_months[displayedMonth.month - 1]} ${displayedMonth.year}';

    const navTextStyle = TextStyle(
      fontFamily: skribbleFontFamily,
      fontWeight: FontWeight.bold,
      fontSize: 22,
    );

    Widget navButton(String glyph, bool enabled, VoidCallback onTap) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Semantics(
          button: enabled,
          label: glyph == '<<' ? 'Previous month' : 'Next month',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              glyph,
              style: navTextStyle.copyWith(
                color: enabled ? theme.textColor : theme.disabledTextColor,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        navButton('<<', canGoPrev, onPrev),
        Flexible(
          child: Text(
            monthYear,
            textAlign: TextAlign.center,
            style: _wiredTextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
        ),
        navButton('>>', canGoNext, onNext),
      ],
    );
  }

  Widget _buildWeekdayHeader({required WiredThemeData theme}) {
    // Expanded cells follow the same 7-column layout as the day grid's
    // cross axis, so they can never overflow the dialog width.
    return Row(
      children: [
        for (final weekday in _weekdaysShort)
          Expanded(
            child: Text(
              weekday,
              textAlign: TextAlign.center,
              style: _wiredTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.textColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDayGrid({
    required WiredThemeData theme,
    required DateTime displayedMonth,
    required DateTime? start,
    required DateTime? end,
    required DateTime first,
    required DateTime last,
    required void Function(DateTime day) onSelect,
  }) {
    final firstDayInMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month,
      1,
    );
    var dayOffset = 0 - (firstDayInMonth.weekday % 7);
    final amountOfWeeks =
        (DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day -
            dayOffset) /
        7;

    final cells = <Widget>[];
    for (var week = 0; week < amountOfWeeks; week++) {
      for (var dayOfWeek = 0; dayOfWeek < 7; dayOfWeek++) {
        final day = DateTime.fromMillisecondsSinceEpoch(
          firstDayInMonth.millisecondsSinceEpoch + _cDay * dayOffset,
        );
        cells.add(
          _buildDayCell(
            theme: theme,
            day: day,
            displayedMonth: displayedMonth,
            start: start,
            end: end,
            enabled:
                day.month == displayedMonth.month &&
                !day.isBefore(_dateOf(first)) &&
                !day.isAfter(_dateOf(last)),
            onSelect: onSelect,
          ),
        );
        dayOffset++;
      }
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      childAspectRatio: _kCellWidth / 46,
      children: cells,
    );
  }

  Widget _buildDayCell({
    required WiredThemeData theme,
    required DateTime day,
    required DateTime displayedMonth,
    required DateTime? start,
    required DateTime? end,
    required bool enabled,
    required void Function(DateTime day) onSelect,
  }) {
    final dayDate = _dateOf(day);
    final isSelected =
        (start != null && dayDate == _dateOf(start)) ||
        (end != null && dayDate == _dateOf(end));
    final isInRange =
        start != null &&
        end != null &&
        dayDate.isAfter(_dateOf(start)) &&
        dayDate.isBefore(_dateOf(end));
    final dimmed = !enabled || day.month != displayedMonth.month;

    return Semantics(
      button: enabled,
      label: 'Select ${_formatShort(day)}',
      child: InkWell(
        onTap: enabled ? () => onSelect(day) : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (isInRange)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: WiredCanvas(
                    painter: WiredRectangleBase(
                      fillColor: Colors.transparent,
                    ),
                    fillerType: RoughFilter.hachureFiller,
                  ),
                ),
              ),
            if (isSelected)
              Positioned.fill(
                child: WiredCanvas(
                  painter: WiredCircleBase(
                    diameterRatio: 0.8,
                    fillColor: Colors.transparent,
                  ),
                  fillerType: RoughFilter.noFiller,
                ),
              ),
            Center(
              child: Text(
                '${day.day}',
                textAlign: TextAlign.center,
                style: _wiredTextStyle(
                  color: dimmed ? theme.disabledTextColor : theme.textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows a hand-drawn date range picker dialog.
///
/// Returns the selected [DateTimeRange<DateTime>] once the user confirms with
/// OK, or
/// `null` when the dialog is dismissed (Cancel).
Future<DateTimeRange<DateTime>?> showWiredDateRangePicker({
  required BuildContext context,
  DateTimeRange<DateTime>? initialDateRange,
  DateTime? firstDate,
  DateTime? lastDate,
  String? semanticLabel,
}) {
  return showDialog<DateTimeRange<DateTime>>(
    context: context,
    builder: (context) => WiredDateRangePickerDialog(
      initialDateRange: initialDateRange,
      firstDate: firstDate,
      lastDate: lastDate,
      semanticLabel: semanticLabel,
    ),
  );
}
