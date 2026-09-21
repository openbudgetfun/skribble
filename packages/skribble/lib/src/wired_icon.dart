import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show PathMetric;

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_icon_registry.dart';
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

  /// Base pen width. Solid fills use a 45% contour to keep small counters open.
  final double strokeWidth;

  /// Overrides theme-driven icon wavering. Zero roughness paints source paths.
  final DrawConfig? drawConfig;
  final bool flipHorizontally;
  final double sampleDistance;
  final double hachureGap;
  final double hachureAngle;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final wiredTheme = WiredTheme.of(context);
    final themeDrawConfig = wiredTheme.drawConfig;
    final effectiveSize = size ?? iconTheme.size ?? 24;
    final effectiveColor = color ?? iconTheme.color ?? wiredTheme.textColor;

    // Small silhouettes need more separation between the theme levels than
    // borders do. Gentle keeps the original amplitude; local wobble increases
    // it for Playful and Expressive. An explicit icon config bypasses this.
    final effectiveDrawConfig =
        drawConfig ??
        DrawConfig.build(
          maxRandomnessOffset:
              themeDrawConfig.maxRandomnessOffset! *
              (1 + 1.5 * (themeDrawConfig.lineWobble ?? 0)) *
              math.min(2.0, effectiveSize / 24),
          roughness: themeDrawConfig.roughness,
          lineWobble: themeDrawConfig.lineWobble,
          bowing: 0.8,
          curveFitting: 0.9,
          curveTightness: 0,
          curveStepCount: 8,
          seed: themeDrawConfig.seed,
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

  /// Base pen width. Solid fills use a 45% contour to keep small counters open.
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

/// Returns precomputed hand-drawn geometry for [icon], or `null` when no
/// icon-set package has registered a catalog covering it.
///
/// Importing an icon-set package (for example `package:skribble_icons_material`)
/// and calling its registration function installs the catalog. Without one,
/// [WiredIcon] falls back to Flutter's regular [Icon] widget, which renders the
/// font glyph. Identifier lookups live with each catalog instead, because only
/// the owning package knows its own names.
WiredSvgIconData? lookupMaterialRoughIcon(IconData icon) {
  return wiredIconCatalog?.resolve(icon);
}

/// Returns the font-backed [IconData] for a catalog [identifier], or `null`
/// when no catalog is registered or none ships the name.
///
/// The bundled catalogs generate an icon font whose codepoints match their
/// geometry map, so this is the glyph-rendering counterpart to
/// [lookupMaterialRoughIconByIdentifier]. The name is kept for compatibility
/// with earlier releases, when only the Material catalog existed.
IconData? lookupMaterialRoughFontIcon(String identifier) =>
    wiredIconCatalog?.resolveFontIcon(identifier);

/// Returns precomputed hand-drawn geometry for a catalog [identifier] such as
/// `'search'`, or `null` when no catalog is registered or none ships the name.
///
/// This searches whichever catalog was registered, so it stays useful to code
/// that should not care which icon set is loaded.
WiredSvgIconData? lookupMaterialRoughIconByIdentifier(String identifier) {
  return wiredIconCatalog?.resolveByIdentifier(identifier);
}

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
          fillColor: _parseSvgColor(primitive.fillColor),
          strokeColor: _parseSvgColor(primitive.strokeColor),
          fillIsAmbient: primitive.fillColor == 'currentColor',
          strokeIsAmbient: primitive.strokeColor == 'currentColor',
          strokeWidth: primitive.strokeWidth * scale,
        ),
      )
      .toList(growable: false);
}

/// Parses an SVG paint colour (`#RGB`, `#RRGGBB`) into a [Color].
///
/// Returns `null` for anything that is not a plain colour, including `none`,
/// `currentColor`, and `url(...)` references. Callers check the ambient flags
/// separately for `currentColor`.
Color? _parseSvgColor(String? value) {
  if (value == null) return null;
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
    this.fillIsAmbient = false,
    this.strokeIsAmbient = false,
    this.strokeWidth = 1,
  });

  final Path path;
  final Path strokePath;
  final StrokeCap strokeCap;
  final StrokeJoin strokeJoin;
  final double strokeMiterLimit;
  final List<Path> clips;

  /// Resolved fill colour, or null when the source specified no plain colour.
  final Color? fillColor;

  /// Resolved stroke colour, or null when the source specified no plain colour.
  final Color? strokeColor;

  /// Whether the source asked for `currentColor` on this channel.
  final bool fillIsAmbient;

  /// Whether the source asked for `currentColor` on this channel.
  final bool strokeIsAmbient;

  final double strokeWidth;

  /// Whether this primitive paints its own colours instead of inheriting the
  /// single ambient icon colour.
  bool get hasOwnColors =>
      fillColor != null ||
      strokeColor != null ||
      fillIsAmbient ||
      strokeIsAmbient;
}

final class _WiredSvgIconPainter extends CustomPainter {
  _WiredSvgIconPainter({
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

  /// Displaced contours, built once per painter.
  ///
  /// Sampling a contour costs a tangent evaluation every [sampleDistance], so
  /// rebuilding it on each repaint dominates the cost of drawing a large icon.
  /// The displacement is a pure function of the source path and this painter's
  /// configuration, and a rebuild produces a new painter and a fresh list.
  List<Path>? _roughPaths;
  List<Path>? _roughStrokePaths;

  List<Path> _resolveRoughPaths() => _roughPaths ??= [
    for (final primitive in primitives) _roughPath(primitive.path),
  ];

  List<Path> _resolveRoughStrokePaths() => _roughStrokePaths ??= [
    for (final primitive in primitives)
      if (primitive.strokeColor != null || primitive.strokeIsAmbient)
        _roughPath(primitive.strokePath, bounds: primitive.path.getBounds())
      else
        primitive.strokePath,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    drawConfig.randomizer?.reset();

    final outlinePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = fillStyle == WiredIconFillStyle.solid
          ? strokeWidth * 0.45
          : strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final sketchPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, strokeWidth * 0.8)
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final roughPaths = _resolveRoughPaths();
    final roughStrokePaths = _resolveRoughStrokePaths();
    for (var index = 0; index < primitives.length; index++) {
      final primitive = primitives[index];
      final roughPath = roughPaths[index];
      canvas.save();
      primitive.clips.forEach(canvas.clipPath);
      // Per-primitive colours (from source SVG artwork) override the ambient
      // single colour. `currentColor` means "use whatever colour the caller
      // asked for", which is how outline sets like Lucide stay themeable.
      // Emoji carry their OpenMoji palette through the same channel.
      if (primitive.hasOwnColors) {
        if (primitive.fillColor != null || primitive.fillIsAmbient) {
          canvas.drawPath(
            roughPath,
            Paint()
              ..color = primitive.fillColor ?? color
              ..style = PaintingStyle.fill
              ..isAntiAlias = true,
          );
        }
        if (primitive.strokeColor != null || primitive.strokeIsAmbient) {
          // Authored strokes share the icon's wavering treatment while keeping
          // their source pen width, caps, joins, and separated dash contours.
          canvas.drawPath(
            roughStrokePaths[index],
            Paint()
              ..style = PaintingStyle.stroke
              ..isAntiAlias = true
              ..color = primitive.strokeColor ?? color
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
          canvas.drawPath(roughPath, fillPaint);
        case WiredIconFillStyle.hachure:
          _paintHachureFill(
            canvas,
            roughPath,
            sketchPaint,
            angleDegrees: hachureAngle,
            gap: hachureGap,
          );
        case WiredIconFillStyle.crossHatch:
          _paintHachureFill(
            canvas,
            roughPath,
            sketchPaint,
            angleDegrees: hachureAngle,
            gap: hachureGap,
          );
          _paintHachureFill(
            canvas,
            roughPath,
            sketchPaint,
            angleDegrees: hachureAngle + 90,
            gap: hachureGap,
          );
      }

      canvas.drawPath(roughPath, outlinePaint);
      canvas.restore();
    }
  }

  // One smooth displacement field moves both sides of a stroke together.
  // Independent jitter on tiny outline segments looks like raster fuzz and
  // closes narrow counters. Fill and outline must share the same geometry.
  Path _roughPath(Path path, {Rect? bounds}) {
    if (drawConfig.roughness == 0) return path;
    final rough = Path()..fillType = path.fillType;
    final amplitude =
        (drawConfig.roughness ?? 1) *
        (drawConfig.maxRandomnessOffset ?? 1) *
        0.12;
    final phase = (drawConfig.seed ?? 0) * 0.61803398875;
    final pathBounds = bounds ?? path.getBounds();

    // Keep enlarged icons from accumulating extra ripples along every edge.
    final wavelengthScale = math.max(1.0, pathBounds.longestSide / 24);

    // Remove the field's linear trend across the icon. Endpoints on opposite
    // sides receive no relative shift, keeping upright strokes upright.
    double wavering(
      double position,
      double start,
      double extent,
      double wavelength,
      double phase,
    ) {
      if (extent == 0) return 0;
      final t = (position - start) / extent;
      final first = math.sin(start / wavelength + phase);
      final last = math.sin((start + extent) / wavelength + phase);
      return math.sin(position / wavelength + phase) -
          (first + (last - first) * t);
    }

    Offset displacement(Offset point) => Offset(
      amplitude *
          wavering(
            point.dy,
            pathBounds.top,
            pathBounds.height,
            5.5 * wavelengthScale,
            phase,
          ),
      amplitude *
          wavering(
            point.dx,
            pathBounds.left,
            pathBounds.width,
            7 * wavelengthScale,
            phase + 1.7,
          ),
    );

    for (final metric in path.computeMetrics()) {
      final points = _sampleMetric(metric);
      if (points.isEmpty) continue;
      final offsets = points.map(displacement).toList(growable: false);
      // Anchor corners as well as the ends of open strokes. Removing only the
      // whole icon's trend can still lean interior stems, such as a house door.
      // Samples are equally spaced along the contour, so index interpolation
      // removes the local trend between successive corners.
      final anchors = [
        0,
        for (var i = 1; i < points.length - 1; i++)
          if (_isCorner(points[i - 1], points[i], points[i + 1])) i,
        points.length - 1,
      ];
      final anchorCorners = !metric.isClosed || anchors.length > 2;
      var segment = 0;
      for (var i = 0; i < points.length; i++) {
        var offset = offsets[i];
        if (anchorCorners && points.length > 1) {
          while (segment < anchors.length - 2 && i > anchors[segment + 1]) {
            segment++;
          }
          final first = anchors[segment];
          final last = anchors[segment + 1];
          final t = (i - first) / (last - first);
          offset -= Offset.lerp(
            offsets[first],
            offsets[last],
            t,
          )!;
          final chord = points[last] - points[first];
          final length = chord.distance;
          if (length > 0) {
            // Opposing bends keep short straight edges visibly hand-drawn
            // without moving their corners or choosing a consistent lean.
            final bend =
                amplitude *
                0.2 *
                math.min(1, length / 8) *
                math.sin(t * math.pi * 2);
            offset += Offset(-chord.dy, chord.dx) * (bend / length);
          }
        }
        final point = points[i] + offset;
        if (i == 0) {
          rough.moveTo(point.dx, point.dy);
        } else {
          rough.lineTo(point.dx, point.dy);
        }
      }
      if (metric.isClosed) rough.close();
    }
    return rough;
  }

  bool _isCorner(Offset before, Offset point, Offset after) {
    final incoming = point - before;
    final outgoing = after - point;
    final length = incoming.distance * outgoing.distance;
    return length > 0 &&
        (incoming.dx * outgoing.dx + incoming.dy * outgoing.dy) / length < 0.9;
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

  List<Offset> _sampleMetric(PathMetric metric) {
    final length = metric.length;
    if (length == 0) {
      return const <Offset>[];
    }

    final step = math.max(0.6, sampleDistance);
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
