import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_storybook/app.dart';
import 'package:skribble_storybook/pages/navigation_page.dart';

void main() {
  group('NavigationPage', () {
    Future<void> navigateToNavigation(WidgetTester tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Navigation'));
      await tester.pumpAndSettle();
    }

    testWidgets('renders NavigationPage', (tester) async {
      await navigateToNavigation(tester);
      expect(find.byType(NavigationPage), findsOneWidget);
    });

    testWidgets('shows WiredAppBar section', (tester) async {
      await navigateToNavigation(tester);
      expect(find.text('WiredAppBar'), findsOneWidget);
    });

    testWidgets('has back button', (tester) async {
      await navigateToNavigation(tester);
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('shows WiredPopupMenuButton section and interactions', (
      tester,
    ) async {
      await navigateToNavigation(tester);

      await tester.scrollUntilVisible(find.text('WiredPopupMenuButton'), 200);
      await tester.pumpAndSettle();

      expect(find.text('WiredPopupMenuButton'), findsOneWidget);
      expect(find.text('Selected: None'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.more_vert).last);
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsWidgets);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);

      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();

      expect(find.text('Selected: Settings'), findsOneWidget);
    });
  });
}
