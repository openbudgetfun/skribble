import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_storybook/app.dart';
import 'package:skribble_storybook/components/component_showcase.dart';
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

      await tester.scrollUntilVisible(
        find.text('WiredPopupMenuButton'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('WiredPopupMenuButton'), findsOneWidget);
      expect(find.text('Selected: None'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.more_vert).last);
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsWidgets);
      expect(find.text('Sign out'), findsOneWidget);

      // Tap 'Settings' in the popup — use .last to target the popup entry
      // (other 'Settings' texts exist in WiredCupertinoTabBar and nav bar)
      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();

      expect(find.text('Selected: Settings'), findsOneWidget);
    });

    testWidgets('contains ListView', (tester) async {
      await navigateToNavigation(tester);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('navigates back to home', (tester) async {
      await navigateToNavigation(tester);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationPage), findsNothing);
    });

    testWidgets('renders multiple ComponentShowcase sections', (tester) async {
      await navigateToNavigation(tester);
      expect(find.byType(ComponentShowcase), findsWidgets);
    });
  });
}
