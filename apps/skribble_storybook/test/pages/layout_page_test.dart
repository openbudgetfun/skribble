import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_storybook/app.dart';
import 'package:skribble_storybook/components/component_showcase.dart';
import 'package:skribble_storybook/pages/layout_page.dart';

void main() {
  group('LayoutPage', () {
    Future<void> navigateToLayout(WidgetTester tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();
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

    testWidgets('shows WiredDivider section on scroll', (tester) async {
      await navigateToLayout(tester);
      await tester.scrollUntilVisible(
        find.text('WiredDivider'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('WiredDivider'), findsOneWidget);
    });

    testWidgets('shows WiredExpansionTile section on scroll', (tester) async {
      await navigateToLayout(tester);
      await tester.scrollUntilVisible(
        find.text('WiredExpansionTile'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('WiredExpansionTile'), findsOneWidget);
    });

    testWidgets('renders multiple ComponentShowcase sections', (tester) async {
      await navigateToLayout(tester);
      expect(find.byType(ComponentShowcase), findsWidgets);
    });
  });
}
