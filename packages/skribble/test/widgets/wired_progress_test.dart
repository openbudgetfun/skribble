import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

class _TestVSync extends Fake implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

void main() {
  group('WiredProgress', () {
    late AnimationController controller;

    setUp(() {
      controller = AnimationController(
        vsync: _TestVSync(),
        duration: const Duration(seconds: 1),
      );
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders without error', (tester) async {
      await pumpApp(tester, WiredProgress(controller: controller));

      expect(find.byType(WiredProgress), findsOneWidget);
    });

    testWidgets('contains LinearProgressIndicator', (tester) async {
      await pumpApp(tester, WiredProgress(controller: controller));

      expect(
        find.descendant(
          of: find.byType(WiredProgress),
          matching: find.byType(LinearProgressIndicator),
        ),
        findsOneWidget,
      );
    });

    testWidgets('accepts value parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredProgress(controller: controller, value: 0.5),
          ),
        ),
      );

      final progress = tester.widget<WiredProgress>(find.byType(WiredProgress));
      expect(progress.value, 0.5);
    });

    testWidgets('contains WiredCanvas for border', (tester) async {
      await pumpApp(tester, WiredProgress(controller: controller));

      expect(
        find.descendant(
          of: find.byType(WiredProgress),
          matching: find.byType(WiredCanvas),
        ),
        findsWidgets,
      );
    });

    testWidgets('contains RepaintBoundary', (tester) async {
      await pumpApp(tester, WiredProgress(controller: controller));

      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('defaults value to 0.0', (tester) async {
      await pumpApp(tester, WiredProgress(controller: controller));

      final progress = tester.widget<WiredProgress>(find.byType(WiredProgress));
      expect(progress.value, 0.0);
    });
  });
}
