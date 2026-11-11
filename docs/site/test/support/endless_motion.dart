import 'package:flutter_test/flutter_test.dart';

/// Live examples whose motion loops for as long as they are shown, so
/// `pumpAndSettle` never returns while they are on screen.
const endlessExamples = {'emoji-animated', 'boil-doodle'};

/// Pages that show an endless example.
const endlessPages = {'/widgets/emoji', '/core/motion'};

/// Pumps frames for [duration], for when endless motion is on screen.
///
/// Long enough for scrolling, routes, and theme changes to finish.
Future<void> pumpFrames(
  WidgetTester tester, [
  Duration duration = const Duration(seconds: 3),
]) async {
  const frame = Duration(milliseconds: 100);
  for (var elapsed = Duration.zero; elapsed < duration; elapsed += frame) {
    await tester.pump(frame);
  }
}
