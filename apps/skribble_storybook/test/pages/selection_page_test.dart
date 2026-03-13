import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_storybook/app.dart';
import 'package:skribble_storybook/pages/selection_page.dart';

void main() {
  group('SelectionPage', () {
    Future<void> navigateToSelection(WidgetTester tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Selection'));
      await tester.pumpAndSettle();
    }

    testWidgets('renders SelectionPage', (tester) async {
      await navigateToSelection(tester);
      expect(find.byType(SelectionPage), findsOneWidget);
    });

    testWidgets('shows WiredChip section', (tester) async {
      await navigateToSelection(tester);
      expect(find.text('WiredChip'), findsOneWidget);
    });

    testWidgets('has back button', (tester) async {
      await navigateToSelection(tester);
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('renders WiredAppBar', (tester) async {
      await navigateToSelection(tester);
      expect(find.byType(WiredAppBar), findsOneWidget);
    });

    testWidgets('page contains ListView with content', (tester) async {
      await navigateToSelection(tester);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('navigates back to home', (tester) async {
      await navigateToSelection(tester);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Skribble Storybook'), findsOneWidget);
    });
  });
}
