import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  Widget buildSubject({
    bool value = false,
    ValueChanged<bool>? onChanged,
    Color? activeTrackColor,
    Color? inactiveTrackColor,
    Color? thumbColor,
    String? semanticLabel,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: WiredCupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: activeTrackColor,
            inactiveTrackColor: inactiveTrackColor,
            thumbColor: thumbColor,
            semanticLabel: semanticLabel,
          ),
        ),
      ),
    );
  }

  group('WiredCupertinoSwitch', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildSubject(onChanged: (_) {}));
      expect(find.byType(WiredCupertinoSwitch), findsOneWidget);
    });

    testWidgets('calls onChanged when tapped', (tester) async {
      bool? toggled;
      await tester.pumpWidget(buildSubject(onChanged: (v) => toggled = v));
      await tester.tap(find.byType(WiredCupertinoSwitch));
      expect(toggled, isTrue);
    });

    testWidgets('does not call onChanged when disabled', (tester) async {
      bool? toggled;
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byType(WiredCupertinoSwitch));
      expect(toggled, isNull);
    });

    testWidgets('animates thumb on value change', (tester) async {
      var current = false;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildSubject(
              value: current,
              onChanged: (v) => setState(() => current = v),
            );
          },
        ),
      );

      // Tap to toggle on
      await tester.tap(find.byType(WiredCupertinoSwitch));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // Animation in progress
      await tester.pumpAndSettle();
    });

    testWidgets('renders with custom active track color', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          value: true,
          onChanged: (_) {},
          activeTrackColor: Colors.purple,
        ),
      );
      expect(find.byType(WiredCupertinoSwitch), findsOneWidget);
    });

    testWidgets('renders with custom thumb color', (tester) async {
      await tester.pumpWidget(
        buildSubject(onChanged: (_) {}, thumbColor: Colors.yellow),
      );
      expect(find.byType(WiredCupertinoSwitch), findsOneWidget);
    });

    testWidgets('has reduced opacity when disabled', (tester) async {
      await tester.pumpWidget(buildSubject());
      final opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(opacity.opacity, 0.4);
    });

    testWidgets('has semantic label when provided', (tester) async {
      await tester.pumpWidget(
        buildSubject(onChanged: (_) {}, semanticLabel: 'Dark mode toggle'),
      );
      expect(find.bySemanticsLabel('Dark mode toggle'), findsOneWidget);
    });
  });
}
