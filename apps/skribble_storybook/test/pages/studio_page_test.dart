import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_storybook/pages/studio_page.dart';
import 'package:skribble_storybook/testing/quality_keys.dart';

void main() {
  for (final size in [
    const Size(320, 740),
    const Size(390, 844),
    const Size(820, 1180),
    const Size(1440, 900),
  ]) {
    testWidgets('notebook lays out at $size', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const WiredStudioPage());
      await tester.pumpAndSettle();
      expect(find.byKey(QualityKeys.title), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byKey(QualityKeys.switchControl));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('disabled save becomes actionable after typing', (tester) async {
    await tester.pumpWidget(const WiredStudioPage());
    expect(
      tester.widget<WiredElevatedButton>(find.byKey(QualityKeys.add)).onPressed,
      isNull,
    );
    await tester.ensureVisible(find.byKey(QualityKeys.input));
    await tester.enterText(
      find.descendant(
        of: find.byKey(QualityKeys.input),
        matching: find.byType(EditableText),
      ),
      'An idea',
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<WiredElevatedButton>(find.byKey(QualityKeys.add)).onPressed,
      isNotNull,
    );
    await tester.tap(find.byKey(QualityKeys.add));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(QualityKeys.inputResult)).data,
      'An idea',
    );
  });

  testWidgets('long note survives theme changes and reset', (tester) async {
    await tester.pumpWidget(const WiredStudioPage());
    await tester.ensureVisible(find.byKey(QualityKeys.input));
    await tester.enterText(
      find.descendant(
        of: find.byKey(QualityKeys.input),
        matching: find.byType(EditableText),
      ),
      'A very long idea with café, piñata, £12.50, and room for something unexpected.',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(QualityKeys.add));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(QualityKeys.dark));
    await tester.tap(find.byKey(QualityKeys.dark));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(QualityKeys.inputResult)).data,
      contains('café'),
    );
    await tester.ensureVisible(find.byKey(QualityKeys.reset));
    await tester.tap(find.byKey(QualityKeys.reset));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(QualityKeys.inputResult)).data,
      'Pick something small. Make it yours.',
    );
    expect(tester.takeException(), isNull);
  });
}
