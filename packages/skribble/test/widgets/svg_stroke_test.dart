import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  test('dash phase restarts for every contour', () {
    const shape = WiredSvgPrimitive.path(
      'M0 0H24M0 10H24',
      strokeDashArray: [4, 4],
      strokeDashOffset: 2,
    );
    final metrics = shape.buildStrokePath().computeMetrics().toList();
    expect(metrics.map((metric) => metric.length), [2, 4, 4, 2, 2, 4, 4, 2]);
    expect(metrics[1].getTangentForOffset(0)!.position.dx, 6);
    expect(metrics[4].getTangentForOffset(0)!.position.dy, 10);
  });
  test('odd dash arrays repeat to form a complete pattern', () {
    const shape = WiredSvgPrimitive.path('M0 0H18', strokeDashArray: [3]);
    expect(
      shape.buildStrokePath().computeMetrics().map((metric) => metric.length),
      [3, 3, 3],
    );
  });
  test('zero dash arrays keep a solid stroke', () {
    const shape = WiredSvgPrimitive.path('M0 0H18', strokeDashArray: [0, 0]);
    expect(shape.buildStrokePath().computeMetrics().single.length, 18);
  });
  test('zero painted lengths do not loop forever', () {
    const shape = WiredSvgPrimitive.path('M0 0H18', strokeDashArray: [0, 4]);
    expect(shape.buildStrokePath().computeMetrics(), isEmpty);
  });
  test('invalid dash lengths fail at the data boundary', () {
    const shape = WiredSvgPrimitive.path('M0 0H18', strokeDashArray: [-1, 4]);
    expect(shape.buildStrokePath, throwsFormatException);
  });
}
