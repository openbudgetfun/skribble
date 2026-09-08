import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'generated/material_rough_icon_font.g.dart';
import 'generated/material_rough_icons.g.dart';
import 'rough/renderer.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_svg_icon_data.dart';
import 'wired_theme.dart';

/// Fill strategy used by [WiredSvgIcon] and [WiredIcon].
enum WiredIconFillStyle { none, solid, hachure, crossHatch }

/// Renders a hand-drawn version of a precomputed SVG icon.
class WiredSvgIcon extends HookWidget {
  const WiredSvgIcon({
    super.key,
    required this.data,
    this.size,
    this.color,
    this.semanticLabel,
    this.fillStyle = WiredIconFillStyle.solid,
    this.strokeWidth = 1.6,
    this.drawConfig,
    this.flipHorizontally = false,
    this.sampleDistance = 1.2,
    this.hachureGap = 2.25,
    this.hachureAngle = 320,
  });

  final WiredSvgIconData data;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  final WiredIconFillStyle fillStyle;
  final double strokeWidth;
  final DrawConfig? drawConfig;
  final bool flipHorizontally;
  final double sampleDistance;
  final double hachureGap;
  final double hachureAngle;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final wiredTheme = WiredTheme.of(context);
    final effectiveSize = size ?? iconTheme.size ?? 24;
    final effectiveColor = color ?? iconTheme.color ?? wiredTheme.textColor;

    final effectiveDrawConfig =
        drawConfig ??
        DrawConfig.build(
          maxRandomnessOffset: math.max(0.35, effectiveSize / 80),
          roughness: 0.65,
          bowing: 0.8,
          curveFitting: 0.9,
          curveTightness: 0,
          curveStepCount: 8,
          seed: 1,
        );

    final primitives = useMemoized(
      () => _preparePrimitives(
        data: data,
        iconSize: effectiveSize,
        flipHorizontally: flipHorizontally,
      ),
      <Object?>[data, effectiveSize, flipHorizontally],
    );

    Widget child = buildWiredElement(
      child: SizedBox.square(
        dimension: effectiveSize,
        child: CustomPaint(
          painter: _WiredSvgIconPainter(
            primitives: primitives,
            color: effectiveColor,
            fillStyle: fillStyle,
            strokeWidth: strokeWidth,
            drawConfig: effectiveDrawConfig,
            sampleDistance: sampleDistance,
            hachureGap: hachureGap,
            hachureAngle: hachureAngle,
          ),
        ),
      ),
    );

    if (semanticLabel != null && semanticLabel!.isNotEmpty) {
      child = Semantics(label: semanticLabel, image: true, child: child);
    }

    return child;
  }
}

/// Renders a rough Material icon when the icon exists in the generated catalog.
///
/// Falls back to Flutter's regular [Icon] widget for unsupported icon families.
class WiredIcon extends HookWidget {
  const WiredIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
    this.semanticLabel,
    this.fillStyle = WiredIconFillStyle.solid,
    this.strokeWidth = 1.6,
    this.drawConfig,
    this.sampleDistance = 1.2,
    this.hachureGap = 2.25,
    this.hachureAngle = 320,
  });

  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  final WiredIconFillStyle fillStyle;
  final double strokeWidth;
  final DrawConfig? drawConfig;
  final double sampleDistance;
  final double hachureGap;
  final double hachureAngle;

  @override
  Widget build(BuildContext context) {
    final data = lookupMaterialRoughIcon(icon);
    if (data == null) {
      return Icon(icon, size: size, color: color, semanticLabel: semanticLabel);
    }

    final shouldFlip =
        icon.matchTextDirection &&
        Directionality.of(context) == TextDirection.rtl;

    return WiredSvgIcon(
      data: data,
      size: size,
      color: color,
      semanticLabel: semanticLabel,
      fillStyle: fillStyle,
      strokeWidth: strokeWidth,
      drawConfig: drawConfig,
      flipHorizontally: shouldFlip,
      sampleDistance: sampleDistance,
      hachureGap: hachureGap,
      hachureAngle: hachureAngle,
    );
  }
}

WiredSvgIconData? lookupMaterialRoughIcon(IconData icon) {
  if (icon.fontFamily != 'MaterialIcons') {
    return null;
  }
  return kMaterialRoughIcons[icon.codePoint];
}

WiredSvgIconData? lookupMaterialRoughIconByIdentifier(String identifier) {
  final codePoint = kMaterialRoughIconsCodePoints[identifier];
  if (codePoint == null) {
    return null;
  }
  return kMaterialRoughIcons[codePoint];
}

IconData? lookupMaterialRoughFontIcon(String identifier) =>
    lookupMaterialRoughIconsIconData(identifier);

String get materialRoughFontFamily => kMaterialRoughIconsFontFamily;

Map<String, int> get materialRoughFontCodePoints =>
    kMaterialRoughIconsCodePoints;

List<String> get materialRoughIconIdentifiers =>
    kMaterialRoughIconsCodePoints.keys.toList(growable: false);

List<int> get materialRoughIconCodePoints =>
    kMaterialRoughIcons.keys.toList(growable: false);

List<_PreparedPrimitive> _preparePrimitives({
  required WiredSvgIconData data,
  required double iconSize,
  required bool flipHorizontally,
}) {
  final scale = math.min(iconSize / data.width, iconSize / data.height);
  final translatedWidth = data.width * scale;
  final translatedHeight = data.height * scale;
  final dx = (iconSize - translatedWidth) / 2;
  final dy = (iconSize - translatedHeight) / 2;

  final transform = _buildTransform(
    scale: scale,
    dx: dx,
    dy: dy,
    translatedWidth: translatedWidth,
    flipHorizontally: flipHorizontally,
  );

  return data.primitives
      .map(
        (primitive) => _PreparedPrimitive(
          path: primitive.buildPath().transform(transform),
          strokePath: primitive.buildStrokePath().transform(transform),
          strokeCap: primitive.strokeCap,
          strokeJoin: primitive.strokeJoin,
          strokeMiterLimit: primitive.strokeMiterLimit,
          clips: primitive.clipPaths
              .map(
                (data) =>
                    WiredSvgPrimitive.path(data)
                        .buildPath()
                        .transform(transform),
              )
              .toList(growable: false),
          fillColor: primitive.fillColor == null
              ? null
              : _parseSvgColor(primitive.fillColor!),
          strokeColor: primitive.strokeColor == null
              ? null
              : _parseSvgColor(primitive.strokeColor!),
          strokeWidth: primitive.strokeWidth * scale,
        ),
      )
      .toList(growable: false);
}

/// Parses an SVG paint colour (`#RGB`, `#RRGGBB`) into a [Color], or null
/// when the value is not a plain colour (e.g. `none`, a URL reference).
Color? _parseSvgColor(String value) {
  var hex = value.trim();
  if (!hex.startsWith('#')) return null;
  hex = hex.substring(1);
  if (hex.length == 3) {
    hex = hex.split('').map((c) => c + c).join();
  }
  if (hex.length == 8) {
    final rgba = int.tryParse(hex, radix: 16);
    return rgba == null ? null : Color(((rgba & 255) << 24) | (rgba >> 8));
  }
  if (hex.length != 6) return null;
  final rgb = int.tryParse(hex, radix: 16);
  if (rgb == null) return null;
  return Color(0xFF000000 | rgb);
}

Float64List _buildTransform({
  required double scale,
  required double dx,
  required double dy,
  required double translatedWidth,
  required bool flipHorizontally,
}) {
  if (!flipHorizontally) {
    return Float64List.fromList(<double>[
      scale,
      0,
      0,
      0,
      0,
      scale,
      0,
      0,
      0,
      0,
      1,
      0,
      dx,
      dy,
      0,
      1,
    ]);
  }

  return Float64List.fromList(<double>[
    -scale,
    0,
    0,
    0,
    0,
    scale,
    0,
    0,
    0,
    0,
    1,
    0,
    dx + translatedWidth,
    dy,
    0,
    1,
  ]);
}

final class _PreparedPrimitive {
  const _PreparedPrimitive({
    required this.path,
    required this.strokePath,
    required this.strokeCap,
    required this.strokeJoin,
    required this.strokeMiterLimit,
    required this.clips,
    this.fillColor,
    this.strokeColor,
    this.strokeWidth = 1,
  });

  final Path path;
  final Path strokePath;
  final StrokeCap strokeCap;
  final StrokeJoin strokeJoin;
  final double strokeMiterLimit;
  final List<Path> clips;

  /// Resolved paint colours, or null to use the ambient single colour.
  final Color? fillColor;
  final Color? strokeColor;
  final double strokeWidth;
}

final class _WiredSvgIconPainter extends CustomPainter {
  const _WiredSvgIconPainter({
    required this.primitives,
    required this.color,
    required this.fillStyle,
    required this.strokeWidth,
    required this.drawConfig,
    required this.sampleDistance,
    required this.hachureGap,
    required this.hachureAngle,
  });

  final List<_PreparedPrimitive> primitives;
  final Color color;
  final WiredIconFillStyle fillStyle;
  final double strokeWidth;
  final DrawConfig drawConfig;
  final double sampleDistance;
  final double hachureGap;
  final double hachureAngle;

  @override
  void paint(Canvas canvas, Size size) {
    drawConfig.randomizer?.reset();

    final outlinePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final sketchPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, strokeWidth * 0.8)
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    for (final primitive in primitives) {
      canvas.save();
      primitive.clips.forEach(canvas.clipPath);
      // Per-primitive colours (from source SVG artwork) override the
      // ambient single colour. Precomputed Material icons ship without
      // colours and use the theme colour; emoji carry their OpenMoji
      // palette through.
      final hasOwnColors =
          primitive.fillColor != null || primitive.strokeColor != null;

      if (hasOwnColors) {
        if (primitive.fillColor != null) {
          _paintRoughSolidFill(
            canvas,
            primitive.path,
            paint: Paint()
              ..color = primitive.fillColor!
              ..style = PaintingStyle.fill
              ..isAntiAlias = true,
            step: math.max(0.6, sampleDistance),
          );
        }
        if (primitive.strokeColor != null) {
          canvas.drawPath(
            primitive.strokePath,
            Paint()
              ..style = PaintingStyle.stroke
              ..isAntiAlias = true
              ..color = primitive.strokeColor!
              ..strokeWidth = primitive.strokeWidth
              ..strokeCap = primitive.strokeCap
              ..strokeJoin = primitive.strokeJoin
              ..strokeMiterLimit = primitive.strokeMiterLimit,
          );
        }
        canvas.restore();
        continue;
      }

      final fillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

      switch (fillStyle) {
        case WiredIconFillStyle.none:
          break;
        case WiredIconFillStyle.solid:
          _paintRoughSolidFill(
            canvas,
            primitive.path,
            paint: fillPaint,
            step: math.max(0.6, sampleDistance),
          );
        case WiredIconFillStyle.hachure:
          _paintHachureFill(
            canvas,
            primitive.path,
            sketchPaint,
            angleDegrees: hachureAngle,
            gap: hachureGap,
          );
        case WiredIconFillStyle.crossHatch:
          _paintHachureFill(
            canvas,
            primitive.path,
            sketchPaint,
            angleDegrees: hachureAngle,
            gap: hachureGap,
          );
          _paintHachureFill(
            canvas,
            primitive.path,
            sketchPaint,
            angleDegrees: hachureAngle + 90,
            gap: hachureGap,
          );
      }

      _paintOutline(canvas, primitive.path, outlinePaint);
      canvas.restore();
    }
  }

  /// Fills [path] with a solid colour using a hand-wobbled silhouette.
  ///
  /// the contour is sampled, each point is displaced with smooth seeded
  /// noise, and the closed polygon is filled — a "scribble" fill that is
  /// completely solid but visibly hand-drawn.
  void _paintRoughSolidFill(
    Canvas canvas,
    Path path, {
    required Paint paint,
    required double step,
  }) {
    if (drawConfig.roughness == 0) {
      canvas.drawPath(path, paint);
      return;
    }
    final wobbled = Path()..fillType = path.fillType;
    final amplitude = (drawConfig.roughness ?? 1) * 0.35;
    // Each contour stays separate: joining contours paints over counters in
    // letters, rings, search icons, and other shapes with holes.
    for (final metric in path.computeMetrics()) {
      final points = _sampleMetric(metric, distance: step);
      for (var i = 0; i < points.length; i++) {
        final point = points[i];
        final x = point.dx + amplitude * math.sin(point.dy / 3.5);
        final y = point.dy + amplitude * math.sin(point.dx / 4.5);
        if (i == 0) {
          wobbled.moveTo(x, y);
        } else {
          wobbled.lineTo(x, y);
        }
      }
      if (metric.isClosed) wobbled.close();
    }
    canvas.drawPath(wobbled, paint);
  }

  void _paintHachureFill(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double angleDegrees,
    required double gap,
  }) {
    final bounds = path.getBounds();
    if (bounds.isEmpty) {
      return;
    }

    final radians = angleDegrees * (math.pi / 180);
    final direction = Offset(math.cos(radians), math.sin(radians));
    final normal = Offset(-direction.dy, direction.dx);
    final center = bounds.center;
    final diagonal =
        math.sqrt(bounds.width * bounds.width + bounds.height * bounds.height) +
        gap * 4;
    final span =
        bounds.width * normal.dx.abs() + bounds.height * normal.dy.abs();
    final lineCount = (span / gap).ceil() + 2;
    final generator = Generator(drawConfig, NoFiller());

    canvas
      ..save()
      ..clipPath(path);

    for (var index = -lineCount; index <= lineCount; index++) {
      final offset = gap * index;
      final base = center.translate(normal.dx * offset, normal.dy * offset);
      final start = base.translate(
        -direction.dx * diagonal,
        -direction.dy * diagonal,
      );
      final end = base.translate(
        direction.dx * diagonal,
        direction.dy * diagonal,
      );
      final drawable = generator.line(start.dx, start.dy, end.dx, end.dy);
      canvas.drawRough(drawable, paint, paint);
    }

    canvas.restore();
  }

  void _paintOutline(
    Canvas canvas,
    Path path,
    Paint paint, {
    bool doublePass = false,
  }) {
    for (var passIdx = (doublePass ? 2 : 1); passIdx > 0; passIdx--) {
      // Second pass draws with a tiny offset for the layered pen-stroke feel.
      final px = passIdx == 2 ? 1.2 : 0.0;
      final py = passIdx == 2 ? -0.8 : 0.0;
      canvas.save();
      if (px != 0 || py != 0) {
        canvas.translate(px, py);
      }
      for (final metric in path.computeMetrics()) {
        final pts = _sampleMetric(metric);
        if (pts.length < 2) continue;
        final contour = pts
            .map((o) => PointD(o.dx, o.dy))
            .toList(growable: false);
        final opSet = OpSetBuilder.linearPath(
          contour,
          metric.isClosed,
          drawConfig,
        );
        if (opSet.ops?.isEmpty ?? true) continue;
        canvas.drawRough(
          Drawable(options: drawConfig, sets: <OpSet>[opSet]),
          paint,
          paint,
        );
      }
      canvas.restore();
    }
  }

  List<Offset> _sampleMetric(PathMetric metric, {double? distance}) {
    final length = metric.length;
    if (length == 0) {
      return const <Offset>[];
    }

    final step = math.max(0.6, distance ?? sampleDistance);
    final sampleCount = math.max(2, (length / step).ceil());
    final points = <Offset>[];

    for (var index = 0; index <= sampleCount; index++) {
      final offset = math.min(length, length * (index / sampleCount));
      final tangent = metric.getTangentForOffset(offset);
      if (tangent == null) {
        continue;
      }

      final position = tangent.position;
      if (points.isEmpty || (points.last - position).distance > 0.15) {
        points.add(position);
      }
    }

    if (metric.isClosed && points.isNotEmpty) {
      final first = points.first;
      final last = points.last;
      if ((first - last).distance > 0.15) {
        points.add(first);
      }
    }

    return points;
  }

  @override
  bool shouldRepaint(_WiredSvgIconPainter oldDelegate) {
    return oldDelegate.primitives != primitives ||
        oldDelegate.color != color ||
        oldDelegate.fillStyle != fillStyle ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.drawConfig != drawConfig ||
        oldDelegate.sampleDistance != sampleDistance ||
        oldDelegate.hachureGap != hachureGap ||
        oldDelegate.hachureAngle != hachureAngle;
  }
}
