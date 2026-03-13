import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredCanvas', () {
    testWidgets('renders CustomPaint widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              height: 100,
              child: WiredCanvas(
                painter: WiredRectangleBase(),
                fillerType: RoughFilter.noFiller,
              ),
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(WiredCanvas),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });

    testWidgets('creates correct filler from RoughFilter enum', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              height: 100,
              child: WiredCanvas(
                painter: WiredRectangleBase(),
                fillerType: RoughFilter.hachureFiller,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(WiredCanvas), findsOneWidget);
      expect(find.byType(CustomPaint), findsAtLeast(1));
    });

    testWidgets('supports all RoughFilter values', (tester) async {
      for (final filter in RoughFilter.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 100,
                height: 100,
                child: WiredCanvas(
                  painter: WiredRectangleBase(),
                  fillerType: filter,
                ),
              ),
            ),
          ),
        );

        expect(
          find.byType(WiredCanvas),
          findsOneWidget,
          reason: 'WiredCanvas should render with RoughFilter.${filter.name}',
        );
      }
    });

    testWidgets('accepts optional drawConfig and fillerConfig', (tester) async {
      final drawConfig = DrawConfig.build(roughness: 2, bowing: 2, seed: 42);
      final fillerConfig = FillerConfig.build(hachureGap: 5);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              height: 100,
              child: WiredCanvas(
                painter: WiredRectangleBase(),
                fillerType: RoughFilter.hachureFiller,
                drawConfig: drawConfig,
                fillerConfig: fillerConfig,
              ),
            ),
          ),
        ),
      );

      final canvas = tester.widget<WiredCanvas>(find.byType(WiredCanvas));
      expect(canvas.drawConfig, drawConfig);
      expect(canvas.fillerConfig, fillerConfig);
    });

    testWidgets('accepts optional size', (tester) async {
      const customSize = Size(200, 50);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCanvas(
              painter: WiredRectangleBase(),
              fillerType: RoughFilter.noFiller,
              size: customSize,
            ),
          ),
        ),
      );

      final canvas = tester.widget<WiredCanvas>(find.byType(WiredCanvas));
      expect(canvas.size, customSize);

      // Verify the CustomPaint receives the specified size.
      final customPaint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(WiredCanvas),
          matching: find.byType(CustomPaint),
        ),
      );
      expect(customPaint.size, customSize);
    });
  });
}
