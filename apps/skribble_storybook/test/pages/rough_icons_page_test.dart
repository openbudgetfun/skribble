import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_storybook/app.dart';
import 'package:skribble_storybook/pages/rough_icons_page.dart';

void main() {
  group('RoughIconsPage', () {
    Future<void> navigateToRoughIcons(WidgetTester tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Rough Icons'), 200);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rough Icons'));
      await tester.pumpAndSettle();
    }

    testWidgets('renders RoughIconsPage', (tester) async {
      await navigateToRoughIcons(tester);

      expect(find.byType(RoughIconsPage), findsOneWidget);
    });

    testWidgets('shows title and subtitle text', (tester) async {
      await navigateToRoughIcons(tester);

      expect(find.text('Rough Icons'), findsOneWidget);
      expect(
        find.text('Generated rough Material icon catalog'),
        findsOneWidget,
      );
    });

    testWidgets('has back button', (tester) async {
      await navigateToRoughIcons(tester);

      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('renders WiredAppBar', (tester) async {
      await navigateToRoughIcons(tester);

      expect(find.byType(WiredAppBar), findsOneWidget);
    });

    testWidgets('renders rough icons and codepoint labels', (tester) async {
      await navigateToRoughIcons(tester);

      expect(find.byType(WiredIcon), findsWidgets);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data != null &&
              widget.data!.startsWith('0x'),
        ),
        findsWidgets,
      );
    });

    testWidgets('shows icon count text', (tester) async {
      await navigateToRoughIcons(tester);

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data != null &&
              widget.data!.contains(' icons'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('navigates back to home', (tester) async {
      await navigateToRoughIcons(tester);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(RoughIconsPage), findsNothing);
      expect(find.text('Skribble Storybook'), findsOneWidget);
    });
  });
}
