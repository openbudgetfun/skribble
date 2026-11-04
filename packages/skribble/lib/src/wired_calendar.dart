import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A full month calendar with hand-drawn cell borders.
///
/// The currently [selected] date is circled. Changing
/// [selected] from the parent moves the circle, and the calendar shows that
/// date's month. Tapping a day selects it and calls [onSelected] with the
/// new value.
///
/// Every day is a button for screen readers, named by its full date, such
/// as `Monday, June 15, 2026`, and reporting whether it is selected.
///
/// See also:
///  * `WiredCalendarDatePicker`, which wraps Flutter's `CalendarDatePicker`.
///  * `WiredDatePicker`, which shows a date picker dialog.
class WiredCalendar extends HookWidget {
  /// The selected date, or null for none. Accepts any string
  /// `DateTime.tryParse` reads, such as `20260915` or `2026-09-15`.
  final String? selected;

  /// Called with the tapped date as `YYYYMMDD`.
  final void Function(String selected)? onSelected;

  const WiredCalendar({super.key, this.selected, this.onSelected});

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final selectedDate = useState<String?>(selected);
    final firstOfMonthDate = useState(_monthOf(_parse(selected)));

    // A new value from the parent replaces the selection and brings its
    // month into view; the calendar's own taps already match it.
    useEffect(() {
      if (selected != selectedDate.value) {
        selectedDate.value = selected;
        firstOfMonthDate.value = _monthOf(_parse(selected));
      }
      return null;
    }, [selected]);

    final weeks = useMemoized(
      () => _computeCalendar(
        firstOfMonthDate.value,
        _parse(selectedDate.value),
        theme,
      ),
      [firstOfMonthDate.value, selectedDate.value, theme],
    );
    final date = firstOfMonthDate.value;

    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _buildWeekdaysNav(
            monthYear: '${_months[date.month - 1]} ${date.year}',
            color: theme.textColor,
            onPre: () {
              final d = firstOfMonthDate.value;
              firstOfMonthDate.value = DateTime(d.year, d.month - 1, 1);
            },
            onNext: () {
              final d = firstOfMonthDate.value;
              firstOfMonthDate.value = DateTime(d.year, d.month + 1, 1);
            },
          ),
          const SizedBox(height: 20.0),
          _buildWeeksHeaderUI(theme: theme),
          Expanded(
            child: _buildWeekdaysUI(
              weeks: weeks,
              theme: theme,
              onSelect: (cell) {
                if (selectedDate.value == cell.value) return;
                selectedDate.value = cell.value;
                onSelected?.call(cell.value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Parses a `YYYYMMDD` value, or returns null when [value] is null or not a
/// date.
DateTime? _parse(String? value) {
  if (value == null) return null;
  final parsed = DateTime.tryParse(value);
  return parsed == null
      ? null
      : DateTime(parsed.year, parsed.month, parsed.day);
}

/// The first day of [date]'s month, or of the current month.
DateTime _monthOf(DateTime? date) {
  final d = date ?? DateTime.now();
  return DateTime(d.year, d.month, 1);
}

List<CalendarCell> _computeCalendar(
  DateTime month,
  DateTime? selected,
  WiredThemeData theme,
) {
  final firstDayInMonth = DateTime(month.year, month.month, 1);
  final leading = firstDayInMonth.weekday % 7;
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final amountOfWeeks = ((leading + daysInMonth) / 7).ceil();

  return [
    for (var index = 0; index < amountOfWeeks * 7; index++)
      () {
        // Calendar arithmetic, not milliseconds: a day is not always 24
        // hours long, and adding 24-hour steps across a daylight-saving
        // change lands on the wrong date.
        final day = DateTime(month.year, month.month, 1 - leading + index);
        final inMonth = day.month == firstDayInMonth.month;
        return CalendarCell(
          value: _format(day),
          text: day.day.toString(),
          selected: selected != null && day == selected,
          dimmed: !inMonth,
          color: inMonth ? theme.textColor : theme.disabledTextColor,
          semanticLabel:
              '${_weekdays[day.weekday % 7]}, '
              '${_months[day.month - 1]} ${day.day}, ${day.year}',
        );
      }(),
  ];
}

Widget _buildWeekdaysNav({
  required String monthYear,
  required Color color,
  required VoidCallback onPre,
  required VoidCallback onNext,
}) {
  Widget navButton(String glyph, String label, VoidCallback onTap) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: _wiredText(
          glyph,
          fontWeight: FontWeight.bold,
          fontSize: 24.0,
          color: color,
        ),
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        navButton('<<', 'Previous month', onPre),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Semantics(
              liveRegion: true,
              // The month shrinks to one line rather than stacking its words.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  monthYear,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: color,
                  ),
                ),
              ),
            ),
          ),
        ),
        navButton('>>', 'Next month', onNext),
      ],
    ),
  );
}

Widget _buildWeeksHeaderUI({required WiredThemeData theme}) {
  return ExcludeSemantics(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final weekday in _weekdaysShort)
          Expanded(
            // A narrow screen or large text shrinks the name rather than
            // breaking it over two lines.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _buildCell(
                weekday,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
                color: theme.textColor,
                theme: theme,
              ),
            ),
          ),
      ],
    ),
  );
}

Widget _buildWeekdaysUI({
  required List<CalendarCell> weeks,
  required void Function(CalendarCell) onSelect,
  required WiredThemeData theme,
}) {
  return GridView.count(
    crossAxisCount: 7,
    children: [
      for (final week in weeks)
        Semantics(
          button: true,
          selected: week.selected,
          label: week.semanticLabel ?? week.text,
          excludeSemantics: true,
          onTap: () => onSelect(week),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelect(week),
            child: _buildCell(
              week.text,
              selected: week.selected,
              color: week.color,
              theme: theme,
            ),
          ),
        ),
    ],
  );
}

Widget _buildCell(
  String text, {
  bool selected = false,
  double width = 45.0,
  double height = 50.0,
  FontWeight fontWeight = FontWeight.w500,
  // Smaller than a heading so the selection circle keeps its ink padding
  // with tall typefaces.
  double fontSize = 18.0,
  Color? color,
  required WiredThemeData theme,
}) {
  final label = SizedBox(
    width: width,
    height: height,
    child: Center(
      child: _wiredText(
        text,
        fontWeight: fontWeight,
        fontSize: fontSize,
        color: color,
      ),
    ),
  );
  if (!selected) return label;
  return Stack(
    fit: StackFit.expand,
    children: [
      Positioned.fill(
        child: WiredCanvas(
          painter: WiredCircleBase(
            diameterRatio: .8,
            strokeWidth: theme.strokeWidth,
            borderColor: theme.borderColor,
          ),
          fillerType: RoughFilter.noFiller,
        ),
      ),
      label,
    ],
  );
}

Widget _wiredText(
  String text, {
  FontWeight fontWeight = FontWeight.w500,
  double fontSize = 18.0,
  Color? color,
}) {
  return Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(
      fontWeight: fontWeight,
      fontSize: fontSize,
      color: color,
    ),
  );
}

String _format(DateTime d) {
  return '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
}

const _weekdaysShort = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
const _weekdays = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];
const _months = [
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

/// A data object representing a single cell in a `WiredCalendar` grid.
///
/// Each cell has a display [text], a [value] for selection callbacks,
/// and flags for [selected], [dimmed], and [disabled] states.
class CalendarCell {
  /// The cell's date as `YYYYMMDD`.
  final String value;

  /// The day number shown in the cell.
  final String text;

  /// Whether the cell is the selected date.
  final bool selected;

  /// Whether the cell belongs to a neighbouring month.
  final bool dimmed;

  /// Whether the cell cannot be selected.
  final bool disabled;

  /// The colour of [text].
  final Color? color;

  /// The full date read by screen readers, such as `Monday, June 15, 2026`.
  /// Null falls back to [text].
  final String? semanticLabel;

  CalendarCell({
    required this.value,
    required this.text,
    required this.selected,
    required this.dimmed,
    this.color,
    this.disabled = false,
    this.semanticLabel,
  });
}
