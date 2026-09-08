import 'dart:ui';

import 'package:path_parsing/path_parsing.dart';

/// Fill rules supported by [WiredSvgPrimitive].
enum WiredSvgFillRule { nonZero, evenOdd }

/// A pre-parsed SVG icon description for rough icon rendering.
final class WiredSvgIconData {
  const WiredSvgIconData({
    required this.width,
    required this.height,
    required this.primitives,
  });

  final double width;
  final double height;
  final List<WiredSvgPrimitive> primitives;
}

/// A single drawable SVG primitive.
///
/// [fillColor] and [strokeColor] carry the source SVG paint attributes as
/// `#RRGGBB` strings (already resolved through group inheritance by the
/// generator). They exist on every primitive kind so emoji keep the colours
/// from their source artwork; precomputed Material icons leave them null and
/// render with the ambient single colour.
sealed class WiredSvgPrimitive {
  const WiredSvgPrimitive({
    this.fillRule = WiredSvgFillRule.nonZero,
    this.fillColor,
    this.strokeColor,
    this.strokeWidth = 1.0,
    this.clipPaths = const [],
    this.strokeDashArray = const [],
    this.strokeDashOffset = 0,
    this.strokeCap = StrokeCap.round,
    this.strokeJoin = StrokeJoin.round,
    this.strokeMiterLimit = 4,
  });

  const factory WiredSvgPrimitive.path(
    String data, {
    WiredSvgFillRule fillRule,
    String? fillColor,
    String? strokeColor,
    double? strokeWidth,
    List<String> clipPaths,
    List<double> strokeDashArray,
    double strokeDashOffset,
    StrokeCap strokeCap,
    StrokeJoin strokeJoin,
    double strokeMiterLimit,
  }) = WiredSvgPathPrimitive;

  const factory WiredSvgPrimitive.circle({
    required double cx,
    required double cy,
    required double radius,
    WiredSvgFillRule fillRule,
    String? fillColor,
    String? strokeColor,
    double? strokeWidth,
  }) = WiredSvgCirclePrimitive;

  const factory WiredSvgPrimitive.ellipse({
    required double cx,
    required double cy,
    required double radiusX,
    required double radiusY,
    WiredSvgFillRule fillRule,
    String? fillColor,
    String? strokeColor,
    double? strokeWidth,
  }) = WiredSvgEllipsePrimitive;

  const factory WiredSvgPrimitive.polygon(
    String data, {
    WiredSvgFillRule fillRule,
    String? fillColor,
    String? strokeColor,
    double? strokeWidth,
  }) = WiredSvgPathPrimitive;

  final WiredSvgFillRule fillRule;

  /// Paint colour for the enclosed area as `#RRGGBB`, or null when the
  /// primitive should use the ambient single colour.
  final String? fillColor;

  /// Outline colour as `#RRGGBB`, or null for the ambient single colour.
  final String? strokeColor;

  /// Outline width from the source SVG (`stroke-width`), defaulting to 1.
  final double strokeWidth;

  /// SVG clipping paths in the same coordinate space as this primitive.
  final List<String> clipPaths;

  /// Alternating painted and unpainted lengths in source coordinates.
  final List<double> strokeDashArray;

  /// Distance into the dash pattern at each contour's start.
  final double strokeDashOffset;

  /// Shape of open stroke endpoints.
  final StrokeCap strokeCap;

  /// Shape of stroke corners.
  final StrokeJoin strokeJoin;

  /// Maximum miter length relative to the stroke width.
  final double strokeMiterLimit;

  /// Builds the stroke geometry, preserving SVG dashes on each contour.
  Path buildStrokePath() {
    final path = buildPath();
    if (strokeDashArray.isEmpty) return path;
    if (strokeDashArray.any((value) => !value.isFinite || value < 0) ||
        !strokeDashOffset.isFinite) {
      throw const FormatException(
        'SVG dash lengths must be finite and nonnegative.',
      );
    }
    final pattern = strokeDashArray.length.isOdd
        ? [...strokeDashArray, ...strokeDashArray]
        : strokeDashArray;
    final length = pattern.fold(0.0, (sum, value) => sum + value);
    if (length == 0) return path;
    final dashed = Path();
    for (final metric in path.computeMetrics()) {
      var index = 0;
      var offset = strokeDashOffset % length;
      while (offset >= pattern[index]) {
        offset -= pattern[index];
        index = (index + 1) % pattern.length;
      }
      var position = -offset;
      while (position < metric.length) {
        final end = position + pattern[index];
        if (index.isEven && end > 0 && end > position) {
          dashed.addPath(
            metric.extractPath(
              position.clamp(0, metric.length),
              end.clamp(0, metric.length),
            ),
            Offset.zero,
          );
        }
        position = end;
        index = (index + 1) % pattern.length;
      }
    }
    return dashed;
  }

  Path buildPath();

  Path createPath() {
    return Path()
      ..fillType = switch (fillRule) {
        WiredSvgFillRule.nonZero => PathFillType.nonZero,
        WiredSvgFillRule.evenOdd => PathFillType.evenOdd,
      };
  }
}

final class WiredSvgPathPrimitive extends WiredSvgPrimitive {
  const WiredSvgPathPrimitive(
    this.data, {
    super.clipPaths,
    super.strokeDashArray,
    super.strokeDashOffset,
    super.strokeCap,
    super.strokeJoin,
    super.strokeMiterLimit,
    super.fillRule,
    super.fillColor,
    super.strokeColor,
    double? strokeWidth,
  }) : super(strokeWidth: strokeWidth ?? 1.0);

  final String data;

  @override
  Path buildPath() {
    final path = createPath();
    writeSvgPathDataToPath(data, _FlutterPathProxy(path));
    return path;
  }
}

final class WiredSvgCirclePrimitive extends WiredSvgPrimitive {
  const WiredSvgCirclePrimitive({
    required this.cx,
    required this.cy,
    required this.radius,
    super.fillRule,
    super.fillColor,
    super.strokeColor,
    double? strokeWidth,
  }) : super(strokeWidth: strokeWidth ?? 1.0);

  final double cx;
  final double cy;
  final double radius;

  @override
  Path buildPath() {
    return createPath()..addOval(
      Rect.fromCircle(
        center: Offset(cx, cy),
        radius: radius,
      ),
    );
  }
}

final class WiredSvgEllipsePrimitive extends WiredSvgPrimitive {
  const WiredSvgEllipsePrimitive({
    required this.cx,
    required this.cy,
    required this.radiusX,
    required this.radiusY,
    super.fillRule,
    super.fillColor,
    super.strokeColor,
    double? strokeWidth,
  }) : super(strokeWidth: strokeWidth ?? 1.0);

  final double cx;
  final double cy;
  final double radiusX;
  final double radiusY;

  @override
  Path buildPath() {
    return createPath()..addOval(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: radiusX * 2,
        height: radiusY * 2,
      ),
    );
  }
}

final class _FlutterPathProxy extends PathProxy {
  _FlutterPathProxy(this.path);

  final Path path;

  @override
  void close() => path.close();

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    path.cubicTo(x1, y1, x2, y2, x3, y3);
  }

  @override
  void lineTo(double x, double y) => path.lineTo(x, y);

  @override
  void moveTo(double x, double y) => path.moveTo(x, y);
}
