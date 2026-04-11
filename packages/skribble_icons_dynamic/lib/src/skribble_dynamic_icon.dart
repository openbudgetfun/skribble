import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

/// Renders a hand-drawn icon by applying the rough engine at runtime.
///
/// This widget wraps [WiredSvgIcon] from the core skribble package, providing
/// maximum flexibility over the roughness, fill style, and draw configuration.
///
/// Use this when you need:
/// - Dynamic fill styles (solid, hachure, crossHatch)
/// - Custom [DrawConfig] for fine-tuned roughness
/// - Runtime variation of the hand-drawn appearance
///
/// For better performance with a fixed rough look, prefer the
/// `skribble_icons` package with its pre-computed rough paths instead.
///
/// ```dart
/// SkribbleDynamicIcon(
///   data: kSkribbleDynamicIcons[0xf001]!,
///   fillStyle: WiredIconFillStyle.hachure,
/// )
/// ```
class SkribbleDynamicIcon extends HookWidget {
  const SkribbleDynamicIcon({
    required this.data,
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.fillStyle = WiredIconFillStyle.solid,
    this.drawConfig,
  });

  /// Clean SVG icon data that will be roughened at runtime.
  final WiredSvgIconData data;

  /// Desired icon size in logical pixels.
  final double? size;

  /// Icon color.
  final Color? color;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  /// Fill style applied by the rough engine.
  final WiredIconFillStyle fillStyle;

  /// Custom draw configuration for fine-tuned roughness. When `null`, the
  /// default rough parameters from [WiredSvgIcon] are used.
  final DrawConfig? drawConfig;

  @override
  Widget build(BuildContext context) {
    return WiredSvgIcon(
      data: data,
      size: size,
      color: color,
      semanticLabel: semanticLabel,
      fillStyle: fillStyle,
      drawConfig: drawConfig,
    );
  }
}
