import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'rough/skribble_rough.dart';
import 'wired_icon.dart';
import 'wired_svg_icon_data.dart';

/// Renders catalog geometry with the theme's hand-drawn icon treatment.
///
/// Uses the same cached painter as [WiredSvgIcon], including authored SVG
/// strokes and colors. Gentle preserves subtle contours; Playful and Expressive
/// add progressively stronger wavering without tilting the whole icon.
class SkribbleIcon extends HookWidget {
  const SkribbleIcon({
    required this.data,
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.drawConfig,
  });

  /// Pre-computed icon data containing SVG paths.
  final WiredSvgIconData data;

  /// Desired size in logical pixels, falling back to [IconThemeData.size] or 24.
  final double? size;

  /// Icon color, falling back to the inherited icon or Wired theme color.
  final Color? color;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  /// Overrides theme-driven wavering. Use zero roughness for source geometry.
  final DrawConfig? drawConfig;

  @override
  Widget build(BuildContext context) => WiredSvgIcon(
    data: data,
    size: size,
    color: color,
    semanticLabel: semanticLabel,
    drawConfig: drawConfig,
  );
}
