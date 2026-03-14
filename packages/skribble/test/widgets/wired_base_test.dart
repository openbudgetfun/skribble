import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';
import '../helpers/pump_app.dart';

void main() {
  group('WiredBase', () {
    test('pathPainter has correct style properties', () {
      final paint = WiredBase.pathPainter(2);
      expect(paint.style, PaintingStyle.stroke);
      expect(paint.isAntiAlias, isTrue);
      expect(paint.strokeWidth, 2);
    });

    test('pathPainter default color matches borderColor', () {
      final paint = WiredBase.pathPainter(2);
      expect(paint.color.a, closeTo(1.0, 0.01));
      expect(paint.color.r, closeTo(0.102, 0.01));
    });

    test('pathPainter accepts custom color', () {
      const customColor = Color(0xFFFF0000);
      final paint = WiredBase.pathPainter(2, color: customColor);
      expect(paint.color, customColor);
    });

    test('fillPainter creates paint with given color', () {
      const color = Color(0xFFFF0000);
      final paint = WiredBase.fillPainter(color);
      expect(paint.color, color);
      expect(paint.style, PaintingStyle.stroke);
      expect(paint.isAntiAlias, isTrue);
      expect(paint.strokeWidth, 2);
    });

    test('pathPainter creates paint with given stroke width', () {
      final paint = WiredBase.pathPainter(4);
      expect(paint.style, PaintingStyle.stroke);
      expect(paint.strokeWidth, 4);
    });
  });

  group('WiredRectangleBase', () {
    testWidgets('renders via WiredCanvas', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              height: 50,
              child: WiredCanvas(
                painter: WiredRectangleBase(),
                fillerType: RoughFilter.noFiller,
              ),
            ),
          ),
        ),
      );
      expect(findWiredCanvas, findsOneWidget);
    });

    testWidgets('renders with left/right indent', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              height: 50,
              child: WiredCanvas(
                painter: WiredRectangleBase(leftIndent: 10, rightIndent: 10),
                fillerType: RoughFilter.noFiller,
              ),
            ),
          ),
        ),
      );
      expect(findWiredCanvas, findsOneWidget);
    });

    testWidgets('renders with custom fill color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              height: 50,
              child: WiredCanvas(
                painter: WiredRectangleBase(fillColor: Colors.blue),
                fillerType: RoughFilter.noFiller,
              ),
            ),
          ),
        ),
      );
      expect(findWiredCanvas, findsOneWidget);
    });
  });

  group('WiredRoundedRectangleBase', () {
    testWidgets('renders via WiredCanvas', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              height: 50,
              child: WiredCanvas(
                painter: WiredRoundedRectangleBase(
                  borderRadius: BorderRadius.circular(12),
                ),
                fillerType: RoughFilter.noFiller,
              ),
            ),
          ),
        ),
      );
      expect(findWiredCanvas, findsOneWidget);
    });

    testWidgets('renders with custom stroke width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              height: 50,
              child: WiredCanvas(
                painter: WiredRoundedRectangleBase(strokeWidth: 4),
                fillerType: RoughFilter.noFiller,
              ),
            ),
          ),
        ),
      );
      expect(findWiredCanvas, findsOneWidget);
    });
  });

  group('WiredCircleBase', () {
    testWidgets('renders via WiredCanvas', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 60,
              height: 60,
              child: WiredCanvas(
                painter: WiredCircleBase(),
                fillerType: RoughFilter.noFiller,
              ),
            ),
          ),
        ),
      );
      expect(findWiredCanvas, findsOneWidget);
    });

    testWidgets('renders with custom diameter ratio', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 60,
              height: 60,
              child: WiredCanvas(
                painter: WiredCircleBase(diameterRatio: 0.8),
                fillerType: RoughFilter.noFiller,
              ),
            ),
          ),
        ),
      );
      expect(findWiredCanvas, findsOneWidget);
    });
  });

  group('WiredLineBase', () {
    testWidgets('renders via WiredCanvas', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 10,
              child: WiredCanvas(
                painter: WiredLineBase(x1: 0, y1: 5, x2: 200, y2: 5),
                fillerType: RoughFilter.noFiller,
              ),
            ),
          ),
        ),
      );
      expect(findWiredCanvas, findsOneWidget);
    });

    testWidgets('clamps out-of-bounds coordinates', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              height: 10,
              child: WiredCanvas(
                painter: WiredLineBase(x1: -10, y1: -5, x2: 500, y2: 50),
                fillerType: RoughFilter.noFiller,
              ),
            ),
          ),
        ),
      );
      expect(findWiredCanvas, findsOneWidget);
    });
  });

  group('WiredInvertedTriangleBase', () {
    testWidgets('renders via WiredCanvas', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 30,
              height: 20,
              child: WiredCanvas(
                painter: WiredInvertedTriangleBase(),
                fillerType: RoughFilter.noFiller,
              ),
            ),
          ),
        ),
      );
      expect(findWiredCanvas, findsOneWidget);
    });
  });

  group('buildWiredElement', () {
    testWidgets('wraps child in RepaintBoundary', (tester) async {
      await pumpApp(tester, buildWiredElement(child: const Text('Hello')));
      expect(findRepaintBoundary, findsWidgets);
      expect(find.text('Hello'), findsOneWidget);
    });
  });
}
