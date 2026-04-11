import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_icons/skribble_icons.dart';

/// Benchmark comparing runtime roughening vs pre-computed path drawing.
///
/// Run with: flutter test test/icon_paint_benchmark_test.dart
void main() {
  final icons = kSkribbleCustomIcons.values.toList();

  /// Pump a widget and force N paint cycles, measuring total time.
  Future<_BenchResult> measurePaintCycles({
    required WidgetTester tester,
    required Widget widget,
    required int cycles,
    required String label,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WiredTheme(
          data: WiredThemeData(),
          child: Scaffold(body: Center(child: widget)),
        ),
      ),
    );
    await tester.pump();

    // Warm up
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    final sw = Stopwatch()..start();
    for (var i = 0; i < cycles; i++) {
      // Mark the render object as needing repaint
      tester.allRenderObjects
          .whereType<RenderCustomPaint>()
          .forEach((r) => r.markNeedsPaint());
      await tester.pump(const Duration(milliseconds: 16));
    }
    sw.stop();

    return _BenchResult(
      label: label,
      cycles: cycles,
      totalMicroseconds: sw.elapsedMicroseconds,
    );
  }

  group('Single icon paint performance', () {
    testWidgets('runtime roughened — single icon', (tester) async {
      final icon = icons.first;
      final result = await measurePaintCycles(
        tester: tester,
        widget: WiredSvgIcon(data: icon, size: 48),
        cycles: 200,
        label: 'Runtime single',
      );
      result.print();
      // Just ensure it completes — the timing data is the output.
      expect(result.avgMicroseconds, greaterThan(0));
    });

    testWidgets('pre-computed — single icon', (tester) async {
      final icon = icons.first;
      final result = await measurePaintCycles(
        tester: tester,
        widget: _PrecomputedIcon(data: icon, size: 48),
        cycles: 200,
        label: 'Precomputed single',
      );
      result.print();
      expect(result.avgMicroseconds, greaterThan(0));
    });
  });

  group('Grid paint performance (30 icons)', () {
    testWidgets('runtime roughened — 30 icon grid', (tester) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final result = await measurePaintCycles(
        tester: tester,
        widget: _IconGrid(icons: icons, useRuntime: true),
        cycles: 100,
        label: 'Runtime 30-grid',
      );
      result.print();
      expect(result.avgMicroseconds, greaterThan(0));
    });

    testWidgets('pre-computed — 30 icon grid', (tester) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final result = await measurePaintCycles(
        tester: tester,
        widget: _IconGrid(icons: icons, useRuntime: false),
        cycles: 100,
        label: 'Precomputed 30-grid',
      );
      result.print();
      expect(result.avgMicroseconds, greaterThan(0));
    });
  });

  group('Large grid paint performance (100 icons)', () {
    testWidgets('runtime roughened — 100 icon grid', (tester) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Repeat the 30 icons to fill 100 slots
      final manyIcons = List.generate(100, (i) => icons[i % icons.length]);

      final result = await measurePaintCycles(
        tester: tester,
        widget: _IconGrid(icons: manyIcons, useRuntime: true),
        cycles: 60,
        label: 'Runtime 100-grid',
      );
      result.print();
      expect(result.avgMicroseconds, greaterThan(0));
    });

    testWidgets('pre-computed — 100 icon grid', (tester) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final manyIcons = List.generate(100, (i) => icons[i % icons.length]);

      final result = await measurePaintCycles(
        tester: tester,
        widget: _IconGrid(icons: manyIcons, useRuntime: false),
        cycles: 60,
        label: 'Precomputed 100-grid',
      );
      result.print();
      expect(result.avgMicroseconds, greaterThan(0));
    });
  });

  group('Scrolling list paint performance (200 items)', () {
    testWidgets('runtime roughened — scrolling list', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final result = await _measureScrollPerformance(
        tester: tester,
        useRuntime: true,
        icons: icons,
        label: 'Runtime scroll-200',
      );
      result.print();
      expect(result.avgMicroseconds, greaterThan(0));
    });

    testWidgets('pre-computed — scrolling list', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final result = await _measureScrollPerformance(
        tester: tester,
        useRuntime: false,
        icons: icons,
        label: 'Precomputed scroll-200',
      );
      result.print();
      expect(result.avgMicroseconds, greaterThan(0));
    });
  });
}

Future<_BenchResult> _measureScrollPerformance({
  required WidgetTester tester,
  required bool useRuntime,
  required List<WiredSvgIconData> icons,
  required String label,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: WiredTheme(
        data: WiredThemeData(),
        child: Scaffold(
          body: ListView.builder(
            itemCount: 200,
            itemBuilder: (context, index) {
              final icon = icons[index % icons.length];
              return ListTile(
                leading: useRuntime
                    ? WiredSvgIcon(data: icon, size: 32)
                    : _PrecomputedIcon(data: icon, size: 32),
                title: Text('Item $index'),
              );
            },
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  // Measure scroll performance
  final sw = Stopwatch()..start();
  var frames = 0;
  for (var i = 0; i < 40; i++) {
    await tester.drag(find.byType(ListView), const Offset(0, -120));
    await tester.pump(const Duration(milliseconds: 16));
    frames++;
  }
  sw.stop();

  return _BenchResult(
    label: label,
    cycles: frames,
    totalMicroseconds: sw.elapsedMicroseconds,
  );
}

// ---------------------------------------------------------------------------
// Pre-computed icon (simulates zero-cost paint)
// ---------------------------------------------------------------------------

class _PrecomputedIcon extends StatelessWidget {
  const _PrecomputedIcon({required this.data, this.size = 24});

  final WiredSvgIconData data;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _PrecomputedPainter(data: data, size: size)),
    );
  }
}

class _PrecomputedPainter extends CustomPainter {
  const _PrecomputedPainter({required this.data, required this.size});

  final WiredSvgIconData data;
  final double size;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final scale = size / data.width;
    // Using deprecated scale() because scaleByDouble requires 4 args.
    // ignore: deprecated_member_use
    final transform = Matrix4.identity()..scale(scale, scale);

    final fillPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (final primitive in data.primitives) {
      final path = primitive.buildPath().transform(transform.storage);
      canvas
        ..drawPath(path, fillPaint)
        ..drawPath(path, outlinePaint);
    }
  }

  @override
  bool shouldRepaint(_PrecomputedPainter oldDelegate) =>
      data != oldDelegate.data || size != oldDelegate.size;
}

// ---------------------------------------------------------------------------
// Icon grid widget
// ---------------------------------------------------------------------------

class _IconGrid extends StatelessWidget {
  const _IconGrid({required this.icons, required this.useRuntime});

  final List<WiredSvgIconData> icons;
  final bool useRuntime;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final icon in icons)
          useRuntime
              ? WiredSvgIcon(data: icon, size: 32)
              : _PrecomputedIcon(data: icon, size: 32),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Benchmark result
// ---------------------------------------------------------------------------

class _BenchResult {
  const _BenchResult({
    required this.label,
    required this.cycles,
    required this.totalMicroseconds,
  });

  final String label;
  final int cycles;
  final int totalMicroseconds;

  double get avgMicroseconds => totalMicroseconds / cycles;
  double get avgMilliseconds => avgMicroseconds / 1000;

  void print() {
    final buffer = StringBuffer()
      ..writeln('╔══════════════════════════════════════════════╗')
      ..writeln('║ BENCHMARK: $label')
      ..writeln('║ Cycles: $cycles')
      ..writeln(
        '║ Total: ${(totalMicroseconds / 1000).toStringAsFixed(1)}ms',
      )
      ..writeln('║ Avg/frame: ${avgMilliseconds.toStringAsFixed(2)}ms')
      ..writeln(
        '║ Budget: ${avgMilliseconds < 16.0 ? "✅ UNDER 16ms" : "❌ OVER 16ms"}',
      )
      ..writeln('╚══════════════════════════════════════════════╝');
    debugPrint(buffer.toString());
  }
}
