import 'package:flutter/widgets.dart';

import 'rough/skribble_rough.dart';
import 'wired_icon.dart';
import 'wired_svg_icon_data.dart';
import 'wired_svg_icon_painter.dart';

/// Renders catalog geometry with the theme's hand-drawn icon treatment.
///
/// A convenience over [WiredSvgIcon] for catalog lookups such as
/// `lookupLucideIconByIdentifier('house')`. Gentle preserves subtle
/// contours; Playful and Expressive add progressively stronger wavering and
/// looser pens without tilting the whole icon.
class SkribbleIcon extends StatelessWidget {
  /// Creates an icon from catalog [data].
  const SkribbleIcon({
    required this.data,
    super.key,
    this.size,
    this.color,
    this.weight,
    this.semanticLabel,
    this.fillStyle = WiredIconFillStyle.solid,
    this.drawConfig,
  });

  /// Pre-computed icon data containing SVG paths.
  final WiredSvgIconData data;

  /// Desired size in logical pixels, falling back to [IconThemeData.size] or 24.
  final double? size;

  /// Icon color, falling back to the inherited icon or Wired theme color.
  final Color? color;

  /// Pen weight from 100 (thin) to 700 (bold), 400 being normal. Falls back
  /// to [IconThemeData.weight].
  final double? weight;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  /// How ambient silhouettes are filled. Stroke artwork ignores it.
  final WiredIconFillStyle fillStyle;

  /// Overrides theme-driven wavering. Use zero roughness for source geometry.
  final DrawConfig? drawConfig;

  @override
  Widget build(BuildContext context) => WiredSvgIcon(
    data: data,
    size: size,
    color: color,
    weight: weight,
    semanticLabel: semanticLabel,
    fillStyle: fillStyle,
    drawConfig: drawConfig,
  );
}
