import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  Future<void> pumpSubject(
    WidgetTester tester, {
    bool animating = true,
    double radius = 10,
    Color? color,
    int segmentCount = 12,
    String? semanticLabel,
  }) {
    return pumpApp(
      tester,
      Center(
        child: WiredCupertinoActivityIndicator(
          animating: animating,
          radius: radius,
          color: color,
          segmentCount: segmentCount,
          semanticLabel: semanticLabel,
        ),
      ),
    );
  }

  group('WiredCupertinoActivityIndicator', () {
    testWidgets('renders without error', (tester) async {
      await pumpSubject(tester, animating: false);
      expect(
        find.byType(WiredCupertinoActivityIndicator),
        findsOneWidget,
      );
    });

    testWidgets('occupies a 2*radius square', (tester) async {
      await pumpSubject(tester, radius: 14);
      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(WiredCupertinoActivityIndicator),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(sizedBox.width, 28);
      expect(sizedBox.height, 28);
    });

    testWidgets('paints segments via a CustomPaint', (tester) async {
      await pumpSubject(tester, animating: false);
      final customPaint = tester.widget<CustomPaint>(
        find
            .descendant(
              of: find.byType(WiredCupertinoActivityIndicator),
              matching: find.byType(CustomPaint),
            )
            .first,
      );
      expect(customPaint.painter, isNotNull);
    });

    testWidgets('animating false does not schedule frames', (tester) async {
      await pumpSubject(tester, animating: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('animating true keeps scheduling frames', (tester) async {
      await pumpSubject(tester, animating: true);
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isTrue);

      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.binding.hasScheduledFrame, isTrue);
    });

    testWidgets('stops animating when animating flips to false', (
      tester,
    ) async {
      await pumpSubject(tester, animating: true);
      await tester.pump();

      await pumpSubject(tester, animating: false);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('progress advances over time while animating', (tester) async {
      await pumpSubject(tester, animating: true);
      await tester.pump(const Duration(milliseconds: 100));

      final paint = find.descendant(
        of: find.byType(WiredCupertinoActivityIndicator),
        matching: find.byType(CustomPaint),
      );

      final first = tester.widget<CustomPaint>(paint.first).painter!;
      await tester.pump(const Duration(milliseconds: 300));
      final second = tester.widget<CustomPaint>(paint.first).painter!;

      final firstProgress = (first as dynamic).progress as double;
      final secondProgress = (second as dynamic).progress as double;
      expect(secondProgress, isNot(firstProgress));
    });

    testWidgets('uses theme border color by default', (tester) async {
      await pumpSubject(tester, animating: false);
      final paint = find.descendant(
        of: find.byType(WiredCupertinoActivityIndicator),
        matching: find.byType(CustomPaint),
      );
      final painter = tester.widget<CustomPaint>(paint.first).painter!;
      expect((painter as dynamic).color, const Color(0xFF1A2B3C));
    });

    testWidgets('applies the provided color', (tester) async {
      await pumpSubject(tester, animating: false, color: Colors.red);
      final paint = find.descendant(
        of: find.byType(WiredCupertinoActivityIndicator),
        matching: find.byType(CustomPaint),
      );
      final painter = tester.widget<CustomPaint>(paint.first).painter!;
      expect((painter as dynamic).color, Colors.red);
    });

    testWidgets('supports tiny radii without crashing', (tester) async {
      await pumpSubject(tester, radius: 3, animating: false);
      expect(tester.takeException(), isNull);
    });

    testWidgets('supports many segments without crashing', (tester) async {
      await pumpSubject(tester, segmentCount: 30, animating: false);
      expect(tester.takeException(), isNull);
    });

    testWidgets('rejects fewer than two segments', (tester) async {
      expect(
        () => WiredCupertinoActivityIndicator(segmentCount: 1),
        throwsAssertionError,
      );
    });

    testWidgets('sets a semantic label when provided', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSubject(tester, semanticLabel: 'Loading data');
      expect(find.bySemanticsLabel('Loading data'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('defaults to animating', (tester) async {
      const indicator = WiredCupertinoActivityIndicator();
      expect(indicator.animating, isTrue);
      expect(indicator.radius, 10);
      expect(indicator.segmentCount, 12);
    });
  });
}
