/// Checks for skribble interfaces: whether text keeps the ink's breathing
/// room inside hand-drawn borders, and whether it reflows on narrow screens.
///
/// The checks read a laid-out render tree, so they work in widget tests and
/// need no extra dependencies:
///
/// ```dart
/// // Static example: test
/// testWidgets('the settings screen keeps the ink padding', (tester) async {
///   await tester.pumpWidget(const SettingsApp());
///   final root = tester.binding.renderViews.first;
///   expect(crampedText(root), isEmpty);
///   expect(squeezedText(root), isEmpty);
/// });
/// ```
library;

export 'src/testing/breathing_room.dart'
    show CrampedText, crampedText, squeezedText;
