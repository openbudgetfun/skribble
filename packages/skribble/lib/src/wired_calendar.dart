import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A full month calendar with hand-drawn cell borders.
///
/// Each day cell is drawn with a sketchy `WiredRectangleBase` border.
/// The currently [selected] date is highlighted with a hachure fill.
///
/// See also:
///  * `WiredCalendarDatePicker`, which wraps Flutter's `CalendarDatePicker`.
///  * `WiredDatePicker`, which shows a date picker dialog.
class WiredCalendar extends HookWidget {
  final String? selected;
  final void Function(String selected)? onSelected;

  const WiredCalendar({super.key, this.selected, this.onSelected});

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final selectedDate = useState<String?>(selected);
    final firstOfMonthDate = useState(DateTime.now());
    final weeks = useState<List<CalendarCell>>([]);
    final monthYear = useState('');

    void computeCalendar() {
      final date = firstOfMonthDate.value;
      monthYear.value = '${_months[date.month - 1]} ${date.year}';

      final firstDayInMonth = DateTime(date.year, date.month, 1);
      var dayInMonthOffset = 0 - (firstDayInMonth.weekday % 7);
      final amountOfWeeks =
          (DateTime(date.year, date.month + 1, 0).day - dayInMonthOffset) / 7;

      final newWeeks = <CalendarCell>[];
      for (var weekIndex = 0; weekIndex < amountOfWeeks; weekIndex++) {
        for (var dayOfWeekIndex = 0; dayOfWeekIndex < 7; dayOfWeekIndex++) {
          final day = DateTime.fromMillisecondsSinceEpoch(
            firstDayInMonth.millisecondsSinceEpoch + _cDay * dayInMonthOffset,
          );
          final formattedDate = _format(day);
          final sel = selectedDate.value;

          newWeeks.add(
            CalendarCell(
              value: formattedDate,
              text: day.day.toString(),
              selected: sel != null && day == DateTime.parse(sel),
              dimmed: day.month != firstDayInMonth.month,
              color: day.month == firstDayInMonth.month
                  ? theme.textColor
                  : theme.disabledTextColor,
            ),
          );

          dayInMonthOffset++;
        }
      }
      weeks.value = newWeeks;
    }

    void setInitialConditions() {
      DateTime d;
      final sel = selectedDate.value;
      if (sel != null) {
        try {
          d = DateTime.parse(sel);
        } catch (_) {
          d = DateTime.now();
        }
      } else {
        d = DateTime.now();
      }
      firstOfMonthDate.value = DateTime(d.year, d.month, 1);
    }

    // Navigate to the selected date's month when selection changes.
    useEffect(() {
      setInitialConditions();
      return null;
    }, [selectedDate.value]);

    // Recompute the calendar grid when the month or selection changes.
    useEffect(() {
      computeCalendar();
      return null;
    }, [selectedDate.value, firstOfMonthDate.value]);

    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _buildWeekdaysNav(
            monthYear: monthYear.value,
            onPre: () {
              final d = firstOfMonthDate.value;
              firstOfMonthDate.value = DateTime(d.year, d.month - 1, 1);
            },
            onNext: () {
              final d = firstOfMonthDate.value;
              firstOfMonthDate.value = DateTime(d.year, d.month + 1, 1);
            },
          ),
          SizedBox(height: 20.0),
          _buildWeeksHeaderUI(borderColor: theme.borderColor),
          Expanded(
            child: _buildWeekdaysUI(
              weeks: weeks.value,
              borderColor: theme.borderColor,
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

Widget _buildWeekdaysNav({
  required String monthYear,
  required VoidCallback onPre,
  required VoidCallback onNext,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: onPre,
          child: _wiredText('<<', fontWeight: FontWeight.bold, fontSize: 24.0),
        ),
        _wiredText(monthYear, fontWeight: FontWeight.bold, fontSize: 22.0),
        InkWell(
          onTap: onNext,
          child: _wiredText('>>', fontWeight: FontWeight.bold, fontSize: 24.0),
        ),
      ],
    ),
  );
}

Widget _buildWeeksHeaderUI({required Color borderColor}) {
  final headers = <Widget>[];
  for (final weekday in _weekdaysShort) {
    headers.add(
      _buildCell(
        weekday,
        fontWeight: FontWeight.bold,
        fontSize: 18.0,
        borderColor: borderColor,
      ),
    );
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: headers,
  );
}

Widget _buildWeekdaysUI({
  required List<CalendarCell> weeks,
  required void Function(CalendarCell) onSelect,
  required Color borderColor,
}) {
  final weekdays = <Widget>[];
  for (final week in weeks) {
    weekdays.add(
      InkWell(
        onTap: () => onSelect(week),
        child: _buildCell(
          week.text,
          selected: week.selected,
          color: week.color,
          borderColor: borderColor,
        ),
      ),
    );
  }

  return GridView.count(crossAxisCount: 7, children: [...weekdays]);
}

Widget _buildCell(
  String text, {
  bool selected = false,
  double width = 45.0,
  double height = 50.0,
  FontWeight fontWeight = FontWeight.w500,
  double fontSize = 20.0,
  Color? color,
  required Color borderColor,
}) {
  return selected
      ? Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: 0,
              top: 0,
              width: width,
              height: height,
              child: WiredCanvas(
                painter: WiredCircleBase(
                  diameterRatio: .8,
                  borderColor: borderColor,
                ),
                fillerType: RoughFilter.noFiller,
              ),
            ),
            SizedBox(
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
            ),
          ],
        )
      : SizedBox(
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
      fontFamily: skribbleFontFamily,
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

const _cSecond = 1000;
const int _cMinute = _cSecond * 60;
const int _cHour = _cMinute * 60;
const int _cDay = _cHour * 24;

/// A data object representing a single cell in a `WiredCalendar` grid.
///
/// Each cell has a display [text], a [value] for selection callbacks,
/// and flags for [selected], [dimmed], and [disabled] states.
class CalendarCell {
  final String value;
  final String text;
  final bool selected;
  final bool dimmed;
  final bool disabled;
  final Color? color;

  CalendarCell({
    required this.value,
    required this.text,
    required this.selected,
    required this.dimmed,
    this.color,
    this.disabled = false,
  });
}
