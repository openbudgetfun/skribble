import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:skribble_storybook/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> scrollToAndTap(WidgetTester tester, String text) async {
    await tester.scrollUntilVisible(find.text(text), 200);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  group('Storybook navigation', () {
    testWidgets('home page renders visible category cards', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      expect(find.text('Skribble Storybook'), findsOneWidget);
      expect(find.text('Buttons'), findsOneWidget);
      expect(find.text('Inputs'), findsOneWidget);
      expect(find.text('Navigation'), findsOneWidget);

      // Scroll to reveal remaining categories.
      await tester.scrollUntilVisible(find.text('Data Display'), 200);
      await tester.pumpAndSettle();

      expect(find.text('Data Display'), findsOneWidget);
    });

    testWidgets('navigates to Buttons page and back', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Buttons'));
      await tester.pumpAndSettle();

      expect(find.text('WiredButton'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('Skribble Storybook'), findsOneWidget);
    });

    testWidgets('navigates to Inputs page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Inputs'));
      await tester.pumpAndSettle();

      expect(find.text('WiredInput'), findsOneWidget);
    });

    testWidgets('navigates to Navigation page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Navigation'));
      await tester.pumpAndSettle();

      expect(find.text('WiredAppBar'), findsOneWidget);
    });

    testWidgets('navigates to Selection page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      await scrollToAndTap(tester, 'Selection');

      expect(find.text('WiredChip'), findsOneWidget);
    });

    testWidgets('navigates to Feedback page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      await scrollToAndTap(tester, 'Feedback');

      expect(find.text('WiredProgress'), findsOneWidget);
    });

    testWidgets('navigates to Layout page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      await scrollToAndTap(tester, 'Layout');

      expect(find.text('WiredCard'), findsOneWidget);
    });

    testWidgets('navigates to Data Display page', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      await scrollToAndTap(tester, 'Data Display');

      expect(find.text('WiredCalendar'), findsOneWidget);
    });
  });
}
