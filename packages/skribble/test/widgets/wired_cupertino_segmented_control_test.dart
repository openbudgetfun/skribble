import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredCupertinoSegmentedControl', () {
    Future<void> pumpSubject(
      WidgetTester tester, {
      int? groupValue = 0,
      ValueChanged<int>? onValueChanged,
      Color? selectedColor,
    }) {
      return pumpApp(
        tester,
        Center(
          child: WiredCupertinoSegmentedControl<int>(
            children: const {0: Text('Day'), 1: Text('Week'), 2: Text('Month')},
            groupValue: groupValue,
            onValueChanged: onValueChanged,
            selectedColor: selectedColor,
          ),
        ),
      );
    }

    testWidgets('renders without error', (tester) async {
      await pumpSubject(tester, onValueChanged: (_) {});
      expect(find.byType(WiredCupertinoSegmentedControl<int>), findsOneWidget);
    });

    testWidgets('renders all segment labels', (tester) async {
      await pumpSubject(tester, onValueChanged: (_) {});
      expect(find.text('Day'), findsOneWidget);
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
    });

    testWidgets('calls onValueChanged when tapped', (tester) async {
      int? selected;
      await pumpSubject(tester, onValueChanged: (v) => selected = v);
      await tester.tap(find.text('Week'));
      expect(selected, 1);
    });

    testWidgets('does not call callback when null', (tester) async {
      int? selected;
      await pumpSubject(tester);
      await tester.tap(find.text('Month'));
      expect(selected, isNull);
    });

    testWidgets('renders with custom selected color', (tester) async {
      await pumpSubject(
        tester,
        onValueChanged: (_) {},
        selectedColor: Colors.green,
      );
      expect(find.byType(WiredCupertinoSegmentedControl<int>), findsOneWidget);
    });

    testWidgets('renders without selection', (tester) async {
      await pumpSubject(tester, groupValue: null, onValueChanged: (_) {});
      expect(find.byType(WiredCupertinoSegmentedControl<int>), findsOneWidget);
    });
  });

  group('WiredSlidingSegmentedControl', () {
    Future<void> pumpSubject(
      WidgetTester tester, {
      String? groupValue = 'a',
      ValueChanged<String>? onValueChanged,
      Color? thumbColor,
      Color? backgroundColor,
    }) {
      return pumpApp(
        tester,
        Center(
          child: WiredSlidingSegmentedControl<String>(
            children: const {
              'a': Text('First'),
              'b': Text('Second'),
              'c': Text('Third'),
            },
            groupValue: groupValue,
            onValueChanged: onValueChanged,
            thumbColor: thumbColor,
            backgroundColor: backgroundColor,
          ),
        ),
      );
    }

    testWidgets('renders without error', (tester) async {
      await pumpSubject(tester, onValueChanged: (_) {});
      expect(find.byType(WiredSlidingSegmentedControl<String>), findsOneWidget);
    });

    testWidgets('renders all segment labels', (tester) async {
      await pumpSubject(tester, onValueChanged: (_) {});
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('Third'), findsOneWidget);
    });

    testWidgets('calls onValueChanged when tapped', (tester) async {
      String? selected;
      await pumpSubject(tester, onValueChanged: (v) => selected = v);
      await tester.tap(find.text('Second'));
      expect(selected, 'b');
    });

    testWidgets('renders with custom thumb color', (tester) async {
      await pumpSubject(
        tester,
        onValueChanged: (_) {},
        thumbColor: Colors.amber,
      );
      expect(find.byType(WiredSlidingSegmentedControl<String>), findsOneWidget);
    });

    testWidgets('renders without selection', (tester) async {
      await pumpSubject(tester, groupValue: null, onValueChanged: (_) {});
      expect(find.byType(WiredSlidingSegmentedControl<String>), findsOneWidget);
    });

    testWidgets('renders with custom background', (tester) async {
      await pumpSubject(
        tester,
        onValueChanged: (_) {},
        backgroundColor: Colors.grey.shade300,
      );
      expect(find.byType(WiredSlidingSegmentedControl<String>), findsOneWidget);
    });
  });
}
