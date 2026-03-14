import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

/// A simple CustomPainter that exercises Canvas.drawRough.
class _RoughTestPainter extends CustomPainter {
  final Drawable drawable;

  _RoughTestPainter(this.drawable);

  @override
  void paint(Canvas canvas, Size size) {
    final pathPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final fillPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawRough(drawable, pathPaint, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

void main() {
  final config = DrawConfig.defaultValues;
  final filler = NoFiller(FillerConfig.defaultConfig);
  final generator = Generator(config, filler);

  group('Rough Canvas extension', () {
    testWidgets('drawRough renders a line without error', (tester) async {
      final drawable = generator.line(0, 0, 100, 100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(200, 200),
              painter: _RoughTestPainter(drawable),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('drawRough renders a rectangle without error', (tester) async {
      final drawable = generator.rectangle(10, 10, 80, 40);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(200, 200),
              painter: _RoughTestPainter(drawable),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('drawRough renders a circle without error', (tester) async {
      final drawable = generator.circle(50, 50, 30);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(200, 200),
              painter: _RoughTestPainter(drawable),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('drawRough renders an ellipse without error', (tester) async {
      final drawable = generator.ellipse(50, 50, 40, 20);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(200, 200),
              painter: _RoughTestPainter(drawable),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('drawRough renders a polygon without error', (tester) async {
      final drawable = generator.polygon([
        PointD(0, 0),
        PointD(50, 0),
        PointD(25, 50),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(200, 200),
              painter: _RoughTestPainter(drawable),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('drawRough renders with HachureFiller', (tester) async {
      final hGen = Generator(
        config,
        HachureFiller(FillerConfig.defaultConfig),
      );
      final drawable = hGen.rectangle(10, 10, 80, 40);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(200, 200),
              painter: _RoughTestPainter(drawable),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('drawRough renders with SolidFiller', (tester) async {
      final sGen = Generator(
        config,
        SolidFiller(FillerConfig.defaultConfig),
      );
      final drawable = sGen.rectangle(10, 10, 80, 40);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(200, 200),
              painter: _RoughTestPainter(drawable),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('drawRough handles empty drawable', (tester) async {
      final drawable = Drawable(sets: []);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(200, 200),
              painter: _RoughTestPainter(drawable),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('drawRough handles null sets', (tester) async {
      final drawable = Drawable();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(200, 200),
              painter: _RoughTestPainter(drawable),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    test('Drawable with fillPath OpSetType is handled', () {
      // fillPath type uses PaintingStyle.fill and closes the path
      final ops = [
        Op.move(PointD(0, 0)),
        Op.lineTo(PointD(10, 0)),
        Op.lineTo(PointD(10, 10)),
      ];
      final drawable = Drawable(
        sets: [OpSet(type: OpSetType.fillPath, ops: ops)],
      );
      expect(drawable.sets!.first.type, OpSetType.fillPath);
      expect(drawable.sets!.first.ops!.length, 3);
    });
  });
}
