import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_storybook/app.dart';
import 'package:skribble_storybook/components/component_showcase.dart';
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

    testWidgets('shows WiredCupertinoTimerPicker section on scroll', (
      tester,
    ) async {
      await navigateToSelection(tester);

      // The page contains nested scrollables (picker wheels), so jump the
      // outer ListView directly to the end. ListView estimates its extent
      // lazily, so keep jumping until the end of the list is reached.
      var attempts = 0;
      while (find.text('WiredCupertinoTimerPicker').evaluate().isEmpty &&
          attempts < 20) {
        final scrollableState = tester.state<ScrollableState>(
          find.byType(Scrollable).first,
        );
        scrollableState.position.jumpTo(
          scrollableState.position.maxScrollExtent,
        );
        await tester.pumpAndSettle();
        attempts++;
      }

      expect(find.text('WiredCupertinoTimerPicker'), findsOneWidget);
      expect(find.text('00 minutes'), findsOneWidget);
    });

    testWidgets('navigates back to home', (tester) async {
      await navigateToSelection(tester);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Skribble Storybook'), findsOneWidget);
    });

    testWidgets('renders multiple ComponentShowcase sections', (tester) async {
      await navigateToSelection(tester);
      expect(find.byType(ComponentShowcase), findsWidgets);
    });
  });
}
