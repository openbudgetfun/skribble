import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_storybook/app.dart';
import 'package:skribble_storybook/pages/buttons_page.dart';

void main() {
  group('ButtonsPage', () {
    Future<void> navigateToButtons(WidgetTester tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buttons'));
      await tester.pumpAndSettle();
    }

    testWidgets('renders ButtonsPage', (tester) async {
      await navigateToButtons(tester);
      expect(find.byType(ButtonsPage), findsOneWidget);
    });

    testWidgets('shows WiredButton section', (tester) async {
      await navigateToButtons(tester);
      expect(find.text('WiredButton'), findsOneWidget);
    });

    testWidgets('has back button', (tester) async {
      await navigateToButtons(tester);
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('navigates back to home', (tester) async {
      await navigateToButtons(tester);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Skribble Storybook'), findsOneWidget);
    });

    testWidgets('renders WiredAppBar with Buttons title', (tester) async {
      await navigateToButtons(tester);
      expect(find.byType(WiredAppBar), findsOneWidget);
      expect(find.text('Buttons'), findsAtLeast(1));
    });

    testWidgets('shows WiredFilledButton section on scroll', (tester) async {
      await navigateToButtons(tester);
      await tester.scrollUntilVisible(
        find.text('WiredFilledButton'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('WiredFilledButton'), findsOneWidget);
    });

    testWidgets('shows WiredCupertinoButton section on scroll',
        (tester) async {
      await navigateToButtons(tester);
      await tester.scrollUntilVisible(
        find.text('WiredCupertinoButton'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('WiredCupertinoButton'), findsOneWidget);
    });
  });
}
