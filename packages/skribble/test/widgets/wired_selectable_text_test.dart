import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredSelectableText', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(tester, WiredSelectableText('Hello World'));
      expect(find.byType(WiredSelectableText), findsOneWidget);
      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('renders with custom style', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WiredSelectableText(
              'Styled',
              style: TextStyle(fontSize: 24, color: Colors.blue),
            ),
          ),
        ),
      );
      expect(find.text('Styled'), findsOneWidget);
    });

    testWidgets('is selectable', (tester) async {
      await pumpApp(tester, WiredSelectableText('Select me'));
      // SelectableText should be present
      expect(find.byType(SelectableText), findsOneWidget);
    });

    testWidgets('respects maxLines', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WiredSelectableText('Line 1\nLine 2\nLine 3', maxLines: 2),
          ),
        ),
      );
      final selectableText = tester.widget<SelectableText>(
        find.byType(SelectableText),
      );
      expect(selectableText.maxLines, 2);
    });

    testWidgets('respects textAlign', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WiredSelectableText('Centered', textAlign: TextAlign.center),
          ),
        ),
      );
      final selectableText = tester.widget<SelectableText>(
        find.byType(SelectableText),
      );
      expect(selectableText.textAlign, TextAlign.center);
    });

    testWidgets('shows cursor when showCursor is true', (tester) async {
      await pumpApp(tester, WiredSelectableText('Cursor', showCursor: true));
      final selectableText = tester.widget<SelectableText>(
        find.byType(SelectableText),
      );
      expect(selectableText.showCursor, isTrue);
    });
  });
}
