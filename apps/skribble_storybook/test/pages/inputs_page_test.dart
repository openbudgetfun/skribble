import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_storybook/app.dart';
import 'package:skribble_storybook/components/component_showcase.dart';
import 'package:skribble_storybook/pages/inputs_page.dart';

void main() {
  group('InputsPage', () {
    Future<void> navigateToInputs(WidgetTester tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inputs'));
      await tester.pumpAndSettle();
    }

    testWidgets('renders InputsPage', (tester) async {
      await navigateToInputs(tester);
      expect(find.byType(InputsPage), findsOneWidget);
    });

    testWidgets('shows WiredInput section', (tester) async {
      await navigateToInputs(tester);
      expect(find.text('WiredInput'), findsOneWidget);
    });

    testWidgets('has back button', (tester) async {
      await navigateToInputs(tester);
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('renders WiredAppBar', (tester) async {
      await navigateToInputs(tester);
      expect(find.byType(WiredAppBar), findsOneWidget);
    });

    testWidgets('shows WiredCheckbox section on scroll', (tester) async {
      await navigateToInputs(tester);
      await tester.scrollUntilVisible(
        find.text('WiredCheckbox'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('WiredCheckbox'), findsOneWidget);
    });

    testWidgets('shows WiredCupertinoTextField section on scroll', (
      tester,
    ) async {
      await navigateToInputs(tester);
      await tester.scrollUntilVisible(
        find.text('WiredCupertinoTextField'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('WiredCupertinoTextField'), findsOneWidget);
    });

    testWidgets('renders multiple ComponentShowcase sections', (tester) async {
      await navigateToInputs(tester);
      expect(find.byType(ComponentShowcase), findsWidgets);
    });
  });
}
