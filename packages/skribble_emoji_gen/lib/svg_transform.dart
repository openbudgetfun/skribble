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

  String point(double x, double y) {
    final px = transform.a * x + transform.c * y + transform.e;
    final py = transform.b * x + transform.d * y + transform.f;
    // Less than one source unit at a 72-unit em: a small pen wobble that
    // preserves the source's expression even when rendered at 24 pixels.
    final dx = 0.55 * math.sin(py / 5.5) + 0.2 * math.sin((px + py) / 3);
    final dy = 0.4 * math.sin(px / 6.5);
    return '${(px + dx).toStringAsFixed(3)} ${(py + dy).toStringAsFixed(3)}';
  }

  @override
  void moveTo(double x, double y) => output.write('M${point(x, y)}');
  @override
  void lineTo(double x, double y) => output.write('L${point(x, y)}');
  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) => output.write('C${point(x1, y1)} ${point(x2, y2)} ${point(x3, y3)}');
  @override
  void close() => output.write('Z');
}
