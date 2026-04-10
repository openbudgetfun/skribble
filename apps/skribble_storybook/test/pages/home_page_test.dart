import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_storybook/app.dart';
import 'package:skribble_storybook/pages/home_page.dart';

void main() {
  group('HomePage', () {
    testWidgets('renders app title', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      expect(find.text('Skribble Storybook'), findsOneWidget);
    });

    testWidgets('renders subtitle', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      expect(find.text('Hand-drawn UI components for Flutter'), findsOneWidget);
    });

    testWidgets('renders all ten category cards', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      // First few categories are visible without scrolling.
      expect(find.text('Buttons'), findsOneWidget);
      expect(find.text('Inputs'), findsOneWidget);
      expect(find.text('Navigation'), findsOneWidget);

      // Scroll down to find middle categories.
      await tester.scrollUntilVisible(find.text('Selection'), 200);
      await tester.pumpAndSettle();
      expect(find.text('Selection'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Feedback'), 200);
      await tester.pumpAndSettle();
      expect(find.text('Feedback'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Layout'), 200);
      await tester.pumpAndSettle();
      expect(find.text('Layout'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Data Display'), 200);
      await tester.pumpAndSettle();
      expect(find.text('Data Display'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Rough Icons'), 200);
      await tester.pumpAndSettle();
      expect(find.text('Rough Icons'), findsOneWidget);

      // Scroll down to find the new categories.
      await tester.scrollUntilVisible(find.text('Skribble Icons'), 200);
      await tester.pumpAndSettle();
      expect(find.text('Skribble Icons'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Emoji'), 200);
      await tester.pumpAndSettle();
      expect(find.text('Emoji'), findsOneWidget);
    });

    testWidgets('uses WiredAppBar', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      expect(find.byType(WiredAppBar), findsOneWidget);
    });

    testWidgets('contains HomePage widget', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('navigates to Buttons page on card tap', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Buttons'));
      await tester.pumpAndSettle();

      // Should navigate away from home page
      expect(find.byType(HomePage), findsNothing);
    });

    testWidgets('navigates to Rough Icons page on card tap', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Rough Icons'), 200);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rough Icons'));
      await tester.pumpAndSettle();

      expect(
        find.text('Generated rough Material icon catalog'),
        findsOneWidget,
      );
    });

    testWidgets('renders WiredCard widgets for categories', (tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      expect(find.byType(WiredCard), findsWidgets);
    });
  });
}
