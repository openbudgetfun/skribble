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
  });
}
