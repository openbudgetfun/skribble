import 'dart:ui';

import 'package:flutter/foundation.dart';
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

  /// Structural equality: the icon painter cache keys on its data, so
  /// equal-valued data built at runtime (rather than shared const glyphs)
  /// still hits the cache instead of re-wavering every contour on each
  /// rebuild.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WiredSvgIconData &&
          width == other.width &&
          height == other.height &&
          listEquals(primitives, other.primitives);

  @override
  int get hashCode => Object.hash(width, height, Object.hashAll(primitives));
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

  /// Field equality shared by every primitive kind, for [operator ==].
  bool matchesBase(WiredSvgPrimitive other) =>
      fillRule == other.fillRule &&
      fillColor == other.fillColor &&
      strokeColor == other.strokeColor &&
      strokeWidth == other.strokeWidth &&
      listEquals(clipPaths, other.clipPaths) &&
      listEquals(strokeDashArray, other.strokeDashArray) &&
      strokeDashOffset == other.strokeDashOffset &&
      strokeCap == other.strokeCap &&
      strokeJoin == other.strokeJoin &&
      strokeMiterLimit == other.strokeMiterLimit;

  /// Field hash shared by every primitive kind, for [hashCode].
  int get baseHash => Object.hash(
    fillRule,
    fillColor,
    strokeColor,
    strokeWidth,
    Object.hashAll(clipPaths),
    Object.hashAll(strokeDashArray),
    strokeDashOffset,
    strokeCap,
    strokeJoin,
    strokeMiterLimit,
  );

  Path buildPath();

  Path createPath() {
    return Path()
      ..fillType = switch (fillRule) {
        WiredSvgFillRule.nonZero => PathFillType.nonZero,
        WiredSvgFillRule.evenOdd => PathFillType.evenOdd,
      };
  }
}

/// Parses each path primitive's SVG data once, however often the primitive is
/// prepared.
///
/// Primitives are canonical const instances shared by every widget drawing the
/// same icon, so keying on the instance lets a revisit (an icon at a new size
/// or colour, or beyond the painter cache's horizon) skip re-parsing the same
/// string. The returned paths are shared: treat them as read-only.
final Expando<Path> _parsedPathData = Expando<Path>('svg path data');

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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WiredSvgPathPrimitive &&
          data == other.data &&
          matchesBase(other);

  @override
  int get hashCode => Object.hash(data, baseHash);

  @override
  Path buildPath() {
    return _parsedPathData[this] ??= _parse();
  }

  Path _parse() {
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WiredSvgCirclePrimitive &&
          cx == other.cx &&
          cy == other.cy &&
          radius == other.radius &&
          matchesBase(other);

  @override
  int get hashCode => Object.hash(cx, cy, radius, baseHash);

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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WiredSvgEllipsePrimitive &&
          cx == other.cx &&
          cy == other.cy &&
          radiusX == other.radiusX &&
          radiusY == other.radiusY &&
          matchesBase(other);

  @override
  int get hashCode => Object.hash(cx, cy, radiusX, radiusY, baseHash);

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
