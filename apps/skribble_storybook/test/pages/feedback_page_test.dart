import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_storybook/app.dart';
import 'package:skribble_storybook/pages/feedback_page.dart';

void main() {
  group('FeedbackPage', () {
    Future<void> navigateToFeedback(WidgetTester tester) async {
      await tester.pumpWidget(const SkribbleStorybookApp());
      await tester.pumpAndSettle();
      // Feedback is offscreen; scroll it into view first.
      await tester.scrollUntilVisible(find.text('Feedback'), 200);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Feedback'));
      await tester.pumpAndSettle();
    }

    testWidgets('renders FeedbackPage', (tester) async {
      await navigateToFeedback(tester);
      expect(find.byType(FeedbackPage), findsOneWidget);
    });

    testWidgets('shows WiredAnimatedIcon section', (tester) async {
      await navigateToFeedback(tester);
      expect(find.text('WiredAnimatedIcon'), findsOneWidget);
    });

    testWidgets('has back button', (tester) async {
      await navigateToFeedback(tester);
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('renders WiredAppBar', (tester) async {
      await navigateToFeedback(tester);
      expect(find.byType(WiredAppBar), findsOneWidget);
    });
  });
}
