import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_storybook/app.dart';
import 'package:skribble_storybook/pages/layout_page.dart';

void main() {
  group('LayoutPage', () {
    Future<void> navigateToLayout(WidgetTester tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();
      // Layout is offscreen; scroll it into view first.
      await tester.scrollUntilVisible(find.text('Layout'), 200);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Layout'));
      await tester.pumpAndSettle();
    }

    testWidgets('renders LayoutPage', (tester) async {
      await navigateToLayout(tester);
      expect(find.byType(LayoutPage), findsOneWidget);
    });

    testWidgets('shows WiredCard section', (tester) async {
      await navigateToLayout(tester);
      expect(find.text('WiredCard'), findsOneWidget);
    });

    testWidgets('has back button', (tester) async {
      await navigateToLayout(tester);
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('renders WiredAppBar', (tester) async {
      await navigateToLayout(tester);
      expect(find.byType(WiredAppBar), findsOneWidget);
    });
  });
}
