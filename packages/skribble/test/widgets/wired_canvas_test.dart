import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredCanvas', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(
        tester,
        WiredCanvas(
          painter: WiredRectangleBase(),
          fillerType: RoughFilter.noFiller,
        ),
      );

      expect(find.byType(WiredCanvas), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders with hachure filler', (tester) async {
      await pumpApp(
        tester,
        SizedBox(
          width: 100,
          height: 50,
          child: WiredCanvas(
            painter: WiredRectangleBase(),
            fillerType: RoughFilter.hachureFiller,
          ),
        ),
      );

      expect(find.byType(WiredCanvas), findsOneWidget);
    });

    testWidgets('accepts explicit size parameter', (tester) async {
      await pumpApp(
        tester,
        WiredCanvas(
          painter: WiredRectangleBase(),
          fillerType: RoughFilter.noFiller,
          size: const Size(200, 100),
        ),
      );

      final canvas = tester.widget<WiredCanvas>(find.byType(WiredCanvas));
      expect(canvas.size, const Size(200, 100));
    });

    testWidgets('renders with circle painter', (tester) async {
      await pumpApp(
        tester,
        SizedBox(
          width: 60,
          height: 60,
          child: WiredCanvas(
            painter: WiredCircleBase(),
            fillerType: RoughFilter.noFiller,
          ),
        ),
      );

      expect(find.byType(WiredCanvas), findsOneWidget);
    });

    testWidgets('renders with line painter', (tester) async {
      await pumpApp(
        tester,
        SizedBox(
          width: 200,
          height: 2,
          child: WiredCanvas(
            painter: WiredLineBase(x1: 0, y1: 0, x2: 200, y2: 0),
            fillerType: RoughFilter.noFiller,
          ),
        ),
      );

      expect(find.byType(WiredCanvas), findsOneWidget);
    });

    testWidgets('renders with rounded rectangle painter', (tester) async {
      await pumpApp(
        tester,
        SizedBox(
          width: 120,
          height: 60,
          child: WiredCanvas(
            painter: WiredRoundedRectangleBase(
              borderRadius: BorderRadius.circular(12),
            ),
            fillerType: RoughFilter.noFiller,
          ),
        ),
      );

      expect(find.byType(WiredCanvas), findsOneWidget);
    });

    testWidgets('renders with custom draw config', (tester) async {
      await pumpApp(
        tester,
        SizedBox(
          width: 100,
          height: 50,
          child: WiredCanvas(
            painter: WiredRectangleBase(),
            fillerType: RoughFilter.noFiller,
            drawConfig: DrawConfig.build(roughness: 2, maxRandomnessOffset: 3),
          ),
        ),
      );

      expect(find.byType(WiredCanvas), findsOneWidget);
    });

    testWidgets('renders with custom filler config', (tester) async {
      await pumpApp(
        tester,
        SizedBox(
          width: 100,
          height: 50,
          child: WiredCanvas(
            painter: WiredRectangleBase(),
            fillerType: RoughFilter.hachureFiller,
            fillerConfig: FillerConfig.build(hachureGap: 4),
          ),
        ),
      );

      expect(find.byType(WiredCanvas), findsOneWidget);
    });

    testWidgets('each RoughFilter type renders without error', (tester) async {
      for (final filter in RoughFilter.values) {
        await pumpApp(
          tester,
          SizedBox(
            width: 80,
            height: 40,
            child: WiredCanvas(
              painter: WiredRectangleBase(),
              fillerType: filter,
            ),
          ),
        );

        expect(
          find.byType(WiredCanvas),
          findsOneWidget,
          reason: 'Failed for $filter',
        );
      }
    });

    testWidgets('renders with custom border color', (tester) async {
      await pumpApp(
        tester,
        SizedBox(
          width: 100,
          height: 50,
          child: WiredCanvas(
            painter: WiredRectangleBase(borderColor: Colors.red),
            fillerType: RoughFilter.noFiller,
          ),
        ),
      );

      expect(find.byType(WiredCanvas), findsOneWidget);
    });
  });

  group('WiredPainter', () {
    testWidgets('shouldRepaint returns true for different configs', (
      tester,
    ) async {
      final config1 = DrawConfig.defaultValues;
      final config2 = DrawConfig.build(roughness: 5);
      final filler = NoFiller(FillerConfig.defaultConfig);
      final painter = WiredRectangleBase();

      final p1 = WiredPainter(config1, filler, painter);
      final p2 = WiredPainter(config2, filler, painter);

      expect(p1.shouldRepaint(p2), isTrue);
    });

    testWidgets('shouldRepaint returns false for same config', (tester) async {
      final config = DrawConfig.defaultValues;
      final filler = NoFiller(FillerConfig.defaultConfig);
      final painter = WiredRectangleBase();

      final p1 = WiredPainter(config, filler, painter);
      final p2 = WiredPainter(config, filler, painter);

      expect(p1.shouldRepaint(p2), isFalse);
    });

    testWidgets('shouldRepaint returns true for different filler type', (
      tester,
    ) async {
      final config = DrawConfig.defaultValues;
      final fillerConfig = FillerConfig.defaultConfig;
      final painter = WiredRectangleBase();

      final p1 = WiredPainter(config, NoFiller(fillerConfig), painter);
      final p2 = WiredPainter(config, HachureFiller(fillerConfig), painter);

      expect(p1.shouldRepaint(p2), isTrue);
    });
  });
}
