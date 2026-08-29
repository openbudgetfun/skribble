import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A time picker with a hand-drawn clock face.
///
/// The time picker is wrapped in [Semantics] for accessibility, providing
/// screen readers with the selected time information.
class WiredTimePicker extends HookWidget {
  final TimeOfDay? initialTime;
  final ValueChanged<TimeOfDay>? onTimeSelected;

  /// Optional semantic label for accessibility.
  final String? semanticLabel;

  const WiredTimePicker({
    super.key,
    this.initialTime,
    this.onTimeSelected,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final time = useState(initialTime ?? TimeOfDay.now());

    return Semantics(
      label: semanticLabel ?? 'Time picker',
      button: true,
      child: buildWiredElement(
        child: SizedBox(
          width: 280,
          height: 340,
          child: Column(
            children: [
              // Time display
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TimeField(
                      value: time.value.hour,
                      onChanged: (h) {
                        time.value = TimeOfDay(
                          hour: h,
                          minute: time.value.minute,
                        );
                        onTimeSelected?.call(time.value);
                      },
                      max: 23,
                    ),
                    Text(
                      ' : ',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: theme.textColor,
                      ),
                    ),
                    _TimeField(
                      value: time.value.minute,
                      onChanged: (m) {
                        time.value = TimeOfDay(
                          hour: time.value.hour,
                          minute: m,
                        );
                        onTimeSelected?.call(time.value);
                      },
                      max: 59,
                    ),
                  ],
                ),
              ),
              // Clock face
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _ClockFace(time: time.value),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeField extends HookWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int max;

  const _TimeField({
    required this.value,
    required this.onChanged,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.delta.dy < -2) {
          onChanged((value + 1) % (max + 1));
        } else if (details.delta.dy > 2) {
          onChanged((value - 1 + max + 1) % (max + 1));
        }
      },
      child: SizedBox(
        width: 64,
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            WiredCanvas(
              painter: WiredRectangleBase(
                fillColor: theme.fillColor,
                borderColor: theme.borderColor,
              ),
              fillerType: RoughFilter.noFiller,
            ),
            Text(
              value.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClockFace extends HookWidget {
  final TimeOfDay time;

  const _ClockFace({required this.time});

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              WiredCanvas(
                painter: WiredCircleBase(
                  diameterRatio: 0.95,
                  borderColor: theme.borderColor,
                ),
                fillerType: RoughFilter.noFiller,
              ),
              // Hour hand
              CustomPaint(
                size: Size(size, size),
                painter: _HandPainter(
                  angle: (time.hour % 12 + time.minute / 60) * 30 * pi / 180,
                  length: size * 0.25,
                  strokeWidth: 3,
                  color: theme.borderColor,
                ),
              ),
              // Minute hand
              CustomPaint(
                size: Size(size, size),
                painter: _HandPainter(
                  angle: time.minute * 6 * pi / 180,
                  length: size * 0.35,
                  strokeWidth: 2,
                  color: theme.borderColor,
                ),
              ),
              // Center dot
              SizedBox(
                width: 8,
                height: 8,
                child: WiredCanvas(
                  painter: WiredCircleBase(
                    fillColor: theme.borderColor,
                    diameterRatio: 0.9,
                    borderColor: theme.borderColor,
                  ),
                  fillerType: RoughFilter.hachureFiller,
                  fillerConfig: FillerConfig.build(hachureGap: 1.0),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HandPainter extends CustomPainter {
  final double angle;
  final double length;
  final double strokeWidth;

  final Color color;

  _HandPainter({
    required this.angle,
    required this.length,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Offset by -pi/2 so 0 degrees points up
    final adjustedAngle = angle - pi / 2;
    final end = Offset(
      center.dx + length * cos(adjustedAngle),
      center.dy + length * sin(adjustedAngle),
    );
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(center, end, paint);
  }

  @override
  bool shouldRepaint(_HandPainter oldDelegate) =>
      angle != oldDelegate.angle || length != oldDelegate.length;
}

/// A hand-drawn time picker dialog with Cancel/Confirm actions.
class _WiredTimePickerDialog extends HookWidget {
  const _WiredTimePickerDialog({this.initialTime});

  final TimeOfDay? initialTime;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final selected = useState<TimeOfDay>(
      initialTime ?? TimeOfDay.now(),
    );

    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: WiredTimePicker(
              initialTime: selected.value,
              onTimeSelected: (time) => selected.value = time,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: theme.disabledTextColor),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(selected.value),
                  child: Text('OK', style: TextStyle(color: theme.textColor)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows a hand-drawn time picker dialog.
///
/// Returns the selected [TimeOfDay] when the user confirms, or `null` if
/// the dialog is dismissed or cancelled.
///
/// ```dart
/// final time = await showWiredTimePicker(
///   context: context,
///   initialTime: TimeOfDay.now(),
/// );
/// if (time != null) {
///   debugPrint('Selected ${time.format(context)}');
/// }
/// ```
Future<TimeOfDay?> showWiredTimePicker({
  required BuildContext context,
  TimeOfDay? initialTime,
}) {
  return showDialog<TimeOfDay>(
    context: context,
    builder: (context) => _WiredTimePickerDialog(initialTime: initialTime),
  );
}
