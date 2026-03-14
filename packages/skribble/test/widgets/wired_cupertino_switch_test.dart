import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  Future<void> pumpSubject(
    WidgetTester tester, {
    bool value = false,
    ValueChanged<bool>? onChanged,
    Color? activeTrackColor,
    Color? inactiveTrackColor,
    Color? thumbColor,
    String? semanticLabel,
  }) {
    return pumpApp(
      tester,
      Center(
        child: WiredCupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: activeTrackColor,
          inactiveTrackColor: inactiveTrackColor,
          thumbColor: thumbColor,
          semanticLabel: semanticLabel,
        ),
      ),
    );
  }

  group('WiredCupertinoSwitch', () {
    testWidgets('renders without error', (tester) async {
      await pumpSubject(tester, onChanged: (_) {});
      expect(find.byType(WiredCupertinoSwitch), findsOneWidget);
    });

    testWidgets('calls onChanged when tapped', (tester) async {
      bool? toggled;
      await pumpSubject(tester, onChanged: (v) => toggled = v);
      await tester.tap(find.byType(WiredCupertinoSwitch));
      expect(toggled, isTrue);
    });

    testWidgets('does not call onChanged when disabled', (tester) async {
      bool? toggled;
      await pumpSubject(tester);
      await tester.tap(find.byType(WiredCupertinoSwitch));
      expect(toggled, isNull);
    });

    testWidgets('animates thumb on value change', (tester) async {
      var current = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: WiredCupertinoSwitch(
                    value: current,
                    onChanged: (v) => setState(() => current = v),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(WiredCupertinoSwitch));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
    });

    testWidgets('renders with custom active track color', (tester) async {
      await pumpSubject(
        tester,
        value: true,
        onChanged: (_) {},
        activeTrackColor: Colors.purple,
      );
      expect(find.byType(WiredCupertinoSwitch), findsOneWidget);
    });

    testWidgets('renders with custom thumb color', (tester) async {
      await pumpSubject(tester, onChanged: (_) {}, thumbColor: Colors.yellow);
      expect(find.byType(WiredCupertinoSwitch), findsOneWidget);
    });

    testWidgets('has reduced opacity when disabled', (tester) async {
      await pumpSubject(tester);
      final opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(opacity.opacity, 0.4);
    });

    testWidgets('has semantic label when provided', (tester) async {
      await pumpSubject(
        tester,
        onChanged: (_) {},
        semanticLabel: 'Dark mode toggle',
      );
      expect(find.bySemanticsLabel('Dark mode toggle'), findsOneWidget);
    });
  });
}
