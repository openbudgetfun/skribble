import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A time picker with a hand-drawn clock face.
///
/// Drag the hour or minute field up or down to change it, or focus it and
/// press the up and down arrow keys. Screen readers announce each field by
/// name and value and can raise or lower it with their adjust gestures.
class WiredTimePicker extends HookWidget {
  final TimeOfDay? initialTime;
  final ValueChanged<TimeOfDay>? onTimeSelected;

  /// <!-- {=dartSemanticLabelOptional|trim|linePrefix:"  /// "} -->
  /// Optional semantic label for accessibility.
  /// <!-- {/dartSemanticLabelOptional} -->
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
      container: true,
      child: buildWiredElement(
        child: SizedBox(
          width: 280,
          height: 340,
          child: Column(
            children: [
              // Time display. Large text shrinks the fields to fit the
              // picker's width instead of pushing them past its edge.
              Padding(
                padding: const EdgeInsets.all(16),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                        label: 'Hour',
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
                        label: 'Minute',
                      ),
                    ],
                  ),
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

  /// The field's name for screen readers, such as `Hour`.
  final String label;

  const _TimeField({
    required this.value,
    required this.onChanged,
    required this.max,
    required this.label,
  });

  int _stepped(int delta) => (value + delta + max + 1) % (max + 1);

  static String _digits(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final focused = useState(false);
    void step(int delta) => onChanged(_stepped(delta));

    return Semantics(
      label: label,
      value: _digits(value),
      increasedValue: _digits(_stepped(1)),
      decreasedValue: _digits(_stepped(-1)),
      onIncrease: () => step(1),
      onDecrease: () => step(-1),
      excludeSemantics: true,
      child: FocusableActionDetector(
        onShowFocusHighlight: (value) => focused.value = value,
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.arrowUp): _StepIntent(1),
          SingleActivator(LogicalKeyboardKey.arrowDown): _StepIntent(-1),
        },
        actions: {
          _StepIntent: CallbackAction<_StepIntent>(
            onInvoke: (intent) {
              step(intent.delta);
              return null;
            },
          ),
        },
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.delta.dy < -2) {
              step(1);
            } else if (details.delta.dy > 2) {
              step(-1);
            }
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 72, minHeight: 56),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: WiredCanvas(
                    painter: WiredRectangleBase(
                      // A keyboard focus shows as a heavier pen.
                      strokeWidth: focused.value
                          ? theme.strokeWidth * 2
                          : theme.strokeWidth,
                      fillColor: theme.fillColor,
                      borderColor: theme.borderColor,
                    ),
                    fillerType: RoughFilter.noFiller,
                  ),
                ),
                // The digits keep the ink's breathing room as text grows.
                Padding(
                  padding: kWiredInkPadding,
                  child: Text(
                    _digits(value),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: theme.textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Moves a time field by [delta].
class _StepIntent extends Intent {
  const _StepIntent(this.delta);

  final int delta;
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
                  strokeWidth: theme.strokeWidth,
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
                    strokeWidth: theme.strokeWidth,
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
