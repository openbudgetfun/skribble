import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_calendar.dart';
import 'wired_theme.dart';

/// A date picker dialog with hand-drawn styling, extending the calendar pattern.
///
/// The date picker is wrapped in [Semantics] for accessibility, providing
/// screen readers with the selected date information.
class WiredDatePicker extends HookWidget {
  final DateTime? initialDate;
  final void Function(DateTime)? onDateSelected;

  /// Optional semantic label for accessibility.
  final String? semanticLabel;

  const WiredDatePicker({super.key, this.initialDate, this.onDateSelected, this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final selectedDateStr = useState<String?>(
      initialDate != null ? _formatDate(initialDate!) : null,
    );

    return Semantics(
      label: semanticLabel ?? 'Date picker',
      button: true,
      child: buildWiredElement(
        child: SizedBox(
        width: 320,
        height: 400,
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
            WiredCalendar(
              selected: selectedDateStr.value,
              onSelected: (selected) {
                selectedDateStr.value = selected;
                final dt = DateTime.tryParse(selected);
                if (dt != null) {
                  onDateSelected?.call(dt);
                }
              },
            ),
          ],
        ),
      ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    return '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
  }
}

/// Shows a hand-drawn date picker dialog.
Future<DateTime?> showWiredDatePicker({
  required BuildContext context,
  DateTime? initialDate,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (context) => Dialog(
      child: WiredDatePicker(
        initialDate: initialDate ?? DateTime.now(),
        onDateSelected: (date) => Navigator.of(context).pop(date),
      ),
    ),
  );
}
