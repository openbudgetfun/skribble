import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'wired_cupertino_picker.dart';

/// The wheels shown by a `WiredCupertinoTimerPicker`.
///
/// * `hm` — hours and minutes.
/// * `hms` — hours, minutes, and seconds.
/// * `ms` — minutes and seconds.
enum WiredCupertinoTimerPickerMode { hm, hms, ms }

/// A hand-drawn timer picker corresponding to Flutter's
/// `CupertinoTimerPicker`.
///
/// Composes hour / minute / second wheels on top of
/// `WiredCupertinoPicker`, keeping the hand-drawn border and selection
/// highlight from the sketchy picker internals.
///
/// Wheel values respect [minuteInterval] and [secondInterval]; hour
/// wheels always cover 0–23. The selected [Duration] is reported via
/// [onTimerDurationChanged] whenever any wheel settles.
///
/// ## Example
///
/// ```dart
/// WiredCupertinoTimerPicker(
///   mode: WiredCupertinoTimerPickerMode.hms,
///   initialTimerDuration: const Duration(hours: 1, minutes: 30),
///   onTimerDurationChanged: (duration) => setState(...),
/// )
/// ```
class WiredCupertinoTimerPicker extends HookWidget {
  /// The initial duration to display.
  ///
  /// Note: like `CupertinoTimerPicker`, this is used only when the
  /// widget is first built.
  final Duration initialTimerDuration;

  /// Which wheels to display.
  final WiredCupertinoTimerPickerMode mode;

  /// The granularity of the minute wheel. Must evenly divide 60.
  final int minuteInterval;

  /// The granularity of the second wheel. Must evenly divide 60.
  final int secondInterval;

  /// Called with the new duration whenever a wheel selection changes.
  final ValueChanged<Duration> onTimerDurationChanged;

  /// Height of each item in the wheels.
  final double itemExtent;

  /// Total height of the picker widget.
  final double height;

  /// Creates a hand-drawn Cupertino-style timer picker.
  const WiredCupertinoTimerPicker({
    super.key,
    this.initialTimerDuration = Duration.zero,
    this.mode = WiredCupertinoTimerPickerMode.hm,
    this.minuteInterval = 1,
    this.secondInterval = 1,
    required this.onTimerDurationChanged,
    this.itemExtent = 32,
    this.height = 216,
  }) : assert(
         minuteInterval > 0 && 60 % minuteInterval == 0,
         'minuteInterval must evenly divide 60',
       ),
       assert(
         secondInterval > 0 && 60 % secondInterval == 0,
         'secondInterval must evenly divide 60',
       );

  @override
  Widget build(BuildContext context) {
    // Store actual unit values (not wheel indices) in state.
    final hour = useState(initialTimerDuration.inHours.clamp(0, 23));
    final minute = useState(initialTimerDuration.inMinutes % 60);
    final second = useState(initialTimerDuration.inSeconds % 60);

    void update({int? newHour, int? newMinute, int? newSecond}) {
      final h = newHour ?? hour.value;
      final m = newMinute ?? minute.value;
      final s = newSecond ?? second.value;
      hour.value = h;
      minute.value = m;
      second.value = s;
      onTimerDurationChanged(Duration(hours: h, minutes: m, seconds: s));
    }

    return SizedBox(
      height: height,
      child: Row(
        children: [
          if (mode != WiredCupertinoTimerPickerMode.ms)
            Expanded(
              child: WiredCupertinoPicker(
                height: height,
                itemExtent: itemExtent,
                initialItem: hour.value,
                onSelectedItemChanged: (i) => update(newHour: i),
                children: [
                  for (var i = 0; i < 24; i++) Text('${_twoDigits(i)} hours'),
                ],
              ),
            ),
          Expanded(
            child: WiredCupertinoPicker(
              height: height,
              itemExtent: itemExtent,
              initialItem: minute.value ~/ minuteInterval,
              onSelectedItemChanged: (i) =>
                  update(newMinute: i * minuteInterval),
              children: [
                for (var i = 0; i < 60 ~/ minuteInterval; i++)
                  Text('${_twoDigits(i * minuteInterval)} minutes'),
              ],
            ),
          ),
          if (mode != WiredCupertinoTimerPickerMode.hm)
            Expanded(
              child: WiredCupertinoPicker(
                height: height,
                itemExtent: itemExtent,
                initialItem: second.value ~/ secondInterval,
                onSelectedItemChanged: (i) =>
                    update(newSecond: i * secondInterval),
                children: [
                  for (var i = 0; i < 60 ~/ secondInterval; i++)
                    Text('${_twoDigits(i * secondInterval)} seconds'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
