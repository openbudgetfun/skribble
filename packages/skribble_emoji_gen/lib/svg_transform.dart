import 'dart:math' as math;

import 'package:path_parsing/path_parsing.dart';

/// An SVG affine transform, composed in document order.
final class SvgTransform {
  /// Creates an identity transform by default.
  const SvgTransform([
    this.a = 1,
    this.b = 0,
    this.c = 0,
    this.d = 1,
    this.e = 0,
    this.f = 0,
  ]);

  /// Horizontal scale.
  final double a;

  /// Vertical component of the transformed x axis.
  final double b;

  /// Horizontal component of the transformed y axis.
  final double c;

  /// Vertical scale.
  final double d;

  /// Horizontal translation.
  final double e;

  /// Vertical translation.
  final double f;

  /// Composes [child] after the current parent transform.
  SvgTransform multiply(SvgTransform child) => SvgTransform(
    a * child.a + c * child.b,
    b * child.a + d * child.b,
    a * child.c + c * child.d,
    b * child.c + d * child.d,
    a * child.e + c * child.f + e,
    b * child.e + d * child.f + f,
  );

  /// Parses the SVG transform attribute.
  static SvgTransform parse(String? value) {
    var result = const SvgTransform();
    for (final match in RegExp(
      r'([a-zA-Z]+)\s*\(([^)]*)\)',
    ).allMatches(value ?? '')) {
      final values = RegExp(r'[-+]?(?:\d*\.\d+|\d+\.?\d*)(?:[eE][-+]?\d+)?')
          .allMatches(match[2]!)
          .map((m) => double.parse(m[0]!))
          .toList();
      final angle = values.first * math.pi / 180;
      final operation = switch (match[1]) {
        'matrix' => SvgTransform(
          values[0],
          values[1],
          values[2],
          values[3],
          values[4],
          values[5],
        ),
        'translate' => SvgTransform(
          1,
          0,
          0,
          1,
          values[0],
          values.length > 1 ? values[1] : 0,
        ),
        'scale' => SvgTransform(
          values[0],
          0,
          0,
          values.length > 1 ? values[1] : values[0],
        ),
        'rotate' =>
          SvgTransform(
                1,
                0,
                0,
                1,
                values.length > 1 ? values[1] : 0,
                values.length > 2 ? values[2] : 0,
              )
              .multiply(
                SvgTransform(
                  math.cos(angle),
                  math.sin(angle),
                  -math.sin(angle),
                  math.cos(angle),
                ),
              )
              .multiply(
                SvgTransform(
                  1,
                  0,
                  0,
                  1,
                  values.length > 1 ? -values[1] : 0,
                  values.length > 2 ? -values[2] : 0,
                ),
              ),
        'skewX' => SvgTransform(1, 0, math.tan(angle)),
        'skewY' => SvgTransform(1, math.tan(angle)),
        _ => throw FormatException('Unsupported SVG transform: ${match[1]}'),
      };
      result = result.multiply(operation);
    }
    return result;
  }

  /// Transforms and gently bends an outline before code generation.
  /// Shared coordinate displacement preserves joins and overlapping fills.
  String path(String source) {
    final proxy = _PathWriter(this);
    writeSvgPathDataToPath(source, proxy);
    return proxy.output.toString();
  }

  /// Scale used for isotropic source stroke widths.
  double get strokeScale => math.sqrt((a * d - b * c).abs());
}

final class _PathWriter extends PathProxy {
  _PathWriter(this.transform);
  final SvgTransform transform;
  final StringBuffer output = StringBuffer();
  math.Point<double> cursor = const math.Point(0, 0);
  math.Point<double> start = const math.Point(0, 0);

  math.Point<double> point(double x, double y) => math.Point(
    transform.a * x + transform.c * y + transform.e,
    transform.b * x + transform.d * y + transform.f,
  );

  String coordinate(double value) {
    // ARM and x64 arithmetic can land on opposite sides of a decimal tie.
    // Discard insignificant drift before rounding to the catalog precision.
    final stable = double.parse(value.toStringAsFixed(9));
    return (stable == 0 ? 0.0 : stable).toStringAsFixed(3);
  }

  String format(math.Point<double> point) =>
      '${coordinate(point.x)} ${coordinate(point.y)}';

  @override
  void moveTo(double x, double y) {
    cursor = start = point(x, y);
    output.write('M${format(cursor)}');
  }

  @override
  void lineTo(double x, double y) => line(point(x, y));

  void line(math.Point<double> end) {
    final delta = end - cursor;
    final length = delta.magnitude;
    if (length == 0) return;

    // Opposing control offsets leave the endpoints and average direction
    // intact. A height-dependent displacement of endpoints made every set
    // lean like italic lettering, especially at a 24-unit viewBox.
    final amount = math.min(0.7, length / 8);
    final normal = math.Point(-delta.y / length, delta.x / length) * amount;
    final first = cursor + delta * (1 / 3) + normal;
    final second = cursor + delta * (2 / 3) - normal;
    output.write('C${format(first)} ${format(second)} ${format(end)}');
    cursor = end;
  }

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    final first = point(x1, y1);
    final second = point(x2, y2);
    final end = point(x3, y3);
    final delta = end - cursor;
    final length = delta.magnitude;
    final normal = length == 0
        ? const math.Point<double>(0, 0)
        : math.Point(-delta.y / length, delta.x / length) *
              math.min(0.4, length / 12);
    output.write(
      'C${format(first + normal)} ${format(second - normal)} ${format(end)}',
    );
    cursor = end;
  }

  @override
  void close() {
    line(start);
    output.write('Z');
  }
}
