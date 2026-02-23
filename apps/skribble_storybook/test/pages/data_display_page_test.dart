import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_storybook/app.dart';
import 'package:skribble_storybook/pages/data_display_page.dart';

void main() {
  group('DataDisplayPage', () {
    Future<void> navigateToDataDisplay(WidgetTester tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();
      // Data Display is at the bottom; scroll it into view first.
      await tester.scrollUntilVisible(find.text('Data Display'), 200);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Data Display'));
      await tester.pumpAndSettle();
    }

    testWidgets('renders DataDisplayPage', (tester) async {
      await navigateToDataDisplay(tester);
      expect(find.byType(DataDisplayPage), findsOneWidget);
    });

    testWidgets('shows WiredCalendar section', (tester) async {
      await navigateToDataDisplay(tester);
      expect(find.text('WiredCalendar'), findsOneWidget);
    });

    testWidgets('has back button', (tester) async {
      await navigateToDataDisplay(tester);
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('renders WiredAppBar', (tester) async {
      await navigateToDataDisplay(tester);
      expect(find.byType(WiredAppBar), findsOneWidget);
    });
  });
}
