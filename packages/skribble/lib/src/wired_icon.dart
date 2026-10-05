import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'generated/skribble_glyphs.g.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_icon_registry.dart';
import 'wired_svg_icon_data.dart';
import 'wired_svg_icon_painter.dart';
import 'wired_theme.dart';

/// The theme stroke width icons are designed against. A theme with a wider
/// pen draws proportionally bolder icons.
const double _referenceInkWidth = 2.4;

/// Renders hand-drawn icon geometry with the theme's pen.
///
/// Strokes in the source artwork (Lucide and the curated set) are inked by
/// the theme's `RoughPen`, so they taper and swell like the rest of the
/// interface. Silhouettes in the ambient colour (Material, Boxicons, brand
/// sets) are filled according to [fillStyle].
///
/// [weight] follows Flutter's icon weight scale from 100 to 700 and defaults
/// to [IconThemeData.weight], or 400 when no theme sets one. It applies to
/// every set: strokes are inked thinner or bolder, and silhouettes grow or
/// shrink evenly along their edges. A theme whose `strokeWidth` is wider than
/// 2.4 scales icon ink in proportion, so one setting controls the weight of
/// borders and icons together.
class WiredSvgIcon extends HookWidget {
  /// Creates an icon from precomputed geometry.
  const WiredSvgIcon({
    super.key,
    required this.data,
    this.size,
    this.color,
    this.weight,
    this.semanticLabel,
    this.fillStyle = WiredIconFillStyle.solid,
    this.drawConfig,
    this.flipHorizontally = false,
    this.hachureGap = 2.25,
    this.hachureAngle = 320,
  });

  /// The icon geometry.
  final WiredSvgIconData data;

  /// Size in logical pixels, falling back to [IconThemeData.size] or 24.
  final double? size;

  /// Ambient colour, falling back to [IconThemeData.color] or the theme's
  /// text colour. Artwork with its own colours keeps them.
  final Color? color;

  /// Pen weight from 100 (thin) to 700 (bold), 400 being normal.
  ///
  /// Falls back to [IconThemeData.weight], then 400.
  final double? weight;

  /// Accessible description. Icons without one add nothing to semantics.
  final String? semanticLabel;

  /// How ambient silhouettes are filled. Stroke artwork ignores it.
  final WiredIconFillStyle fillStyle;

  /// Overrides theme-driven wavering and pen. Zero roughness paints the
  /// source geometry with only the pen's taper.
  final DrawConfig? drawConfig;

  /// Mirrors the icon, for directional icons in right-to-left layouts.
  final bool flipHorizontally;

  /// Distance between hachure strokes, in logical pixels.
  final double hachureGap;

  /// Angle of hachure strokes, in degrees.
  final double hachureAngle;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final wiredTheme = WiredTheme.of(context);
    final effectiveSize = size ?? iconTheme.size ?? 24;
    final effectiveColor = color ?? iconTheme.color ?? wiredTheme.textColor;
    final effectiveWeight =
        wiredIconWeightFactor(weight ?? iconTheme.weight ?? 400) *
        wiredTheme.strokeWidth /
        _referenceInkWidth;
    final effectiveDrawConfig =
        drawConfig ?? _iconDrawConfig(wiredTheme, effectiveSize);

    final primitives = useMemoized(
      () => prepareIconPrimitives(
        data,
        effectiveSize,
        flip: flipHorizontally,
      ),
      [data, effectiveSize, flipHorizontally],
    );
    // The painter caches its wavered contours and pen outlines, so keep the
    // same instance until something it draws with changes.
    final painter = useMemoized(
      () => WiredSvgIconPainter(
        primitives: primitives,
        color: effectiveColor,
        fillStyle: fillStyle,
        weight: effectiveWeight,
        drawConfig: effectiveDrawConfig,
        hachureGap: hachureGap,
        hachureAngle: hachureAngle,
      ),
      [
        primitives,
        effectiveColor,
        fillStyle,
        effectiveWeight,
        effectiveDrawConfig,
        hachureGap,
        hachureAngle,
      ],
    );

    Widget child = buildWiredElement(
      child: SizedBox.square(
        dimension: effectiveSize,
        child: CustomPaint(painter: painter),
      ),
    );

    if (semanticLabel case final label? when label.isNotEmpty) {
      child = Semantics(label: label, image: true, child: child);
    }

    return child;
  }

  // Small silhouettes need more separation between the theme levels than
  // borders do. Gentle keeps the original amplitude; local wobble increases
  // it for Playful and Expressive. An explicit icon config bypasses this.
  static DrawConfig _iconDrawConfig(WiredThemeData theme, double size) {
    final config = theme.drawConfig;
    return DrawConfig.build(
      maxRandomnessOffset:
          config.maxRandomnessOffset *
          (1 + 1.5 * config.lineWobble) *
          math.min(2.0, size / 24),
      roughness: config.roughness,
      lineWobble: config.lineWobble,
      bowing: 0.8,
      curveFitting: 0.9,
      curveTightness: 0,
      curveStepCount: 8,
      seed: config.seed,
      pen: config.pen,
    );
  }
}

/// Renders a hand-drawn version of a Flutter [IconData].
///
/// Resolves the icon through the registered icon catalog (see
/// `registerSkribbleIcons`). Without a catalog, about sixty common Material
/// icons (home, search, check, close, the arrows and chevrons, and so on) are
/// drawn with the matching `SkribbleGlyphs`. Anything else falls back to
/// Flutter's [Icon] so the interface stays usable.
///
/// See [WiredSvgIcon] for [weight] and [fillStyle].
class WiredIcon extends StatelessWidget {
  /// Creates a hand-drawn icon for [icon].
  const WiredIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
    this.weight,
    this.semanticLabel,
    this.fillStyle = WiredIconFillStyle.solid,
    this.drawConfig,
    this.hachureGap = 2.25,
    this.hachureAngle = 320,
  });

  /// The icon to draw.
  final IconData icon;

  /// Size in logical pixels, falling back to [IconThemeData.size] or 24.
  final double? size;

  /// Ambient colour, falling back to [IconThemeData.color] or the theme's
  /// text colour.
  final Color? color;

  /// Pen weight from 100 (thin) to 700 (bold), 400 being normal.
  final double? weight;

  /// Accessible description. Icons without one add nothing to semantics.
  final String? semanticLabel;

  /// How ambient silhouettes are filled. Stroke artwork ignores it.
  final WiredIconFillStyle fillStyle;

  /// Overrides theme-driven wavering and pen.
  final DrawConfig? drawConfig;

  /// Distance between hachure strokes, in logical pixels.
  final double hachureGap;

  /// Angle of hachure strokes, in degrees.
  final double hachureAngle;

  @override
  Widget build(BuildContext context) {
    final data =
        lookupMaterialRoughIcon(icon) ??
        (icon.fontFamily == 'MaterialIcons'
            ? kSkribbleGlyphMaterialFallbacks[icon.codePoint]
            : null);
    if (data == null) {
      return Icon(
        icon,
        size: size,
        color: color,
        weight: weight,
        semanticLabel: semanticLabel,
      );
    }

    return WiredSvgIcon(
      data: data,
      size: size,
      color: color,
      weight: weight,
      semanticLabel: semanticLabel,
      fillStyle: fillStyle,
      drawConfig: drawConfig,
      flipHorizontally:
          icon.matchTextDirection &&
          Directionality.of(context) == TextDirection.rtl,
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
