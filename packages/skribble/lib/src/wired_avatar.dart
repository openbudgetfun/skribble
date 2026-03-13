import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'const.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';

/// A hand-drawn avatar corresponding to Flutter's [CircleAvatar].
///
/// Displays an image, icon, or initials inside a sketchy hand-drawn circle.
class WiredAvatar extends HookWidget {
  /// The background image to display.
  final ImageProvider? backgroundImage;

  /// A foreground image to display on top.
  final ImageProvider? foregroundImage;

  /// Background color when no image is provided.
  final Color? backgroundColor;

  /// Foreground color for text/icon.
  final Color? foregroundColor;

  /// The radius of the avatar. Defaults to 20.
  final double radius;

  /// The child widget, typically a [Text] with initials or an [Icon].
  final Widget? child;

  /// Minimum radius constraint.
  final double? minRadius;

  /// Maximum radius constraint.
  final double? maxRadius;

  const WiredAvatar({
    super.key,
    this.backgroundImage,
    this.foregroundImage,
    this.backgroundColor,
    this.foregroundColor,
    this.radius = 20,
    this.child,
    this.minRadius,
    this.maxRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = radius;
    final size = effectiveRadius * 2;
    final bgColor = backgroundColor ?? borderColor.withValues(alpha: 0.15);
    final fgColor = foregroundColor ?? textColor;

    return buildWiredElement(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Hand-drawn circle border
            Positioned.fill(
              child: WiredCanvas(
                painter: WiredCircleBase(fillColor: bgColor),
                fillerType: backgroundImage != null
                    ? RoughFilter.noFiller
                    : RoughFilter.hachureFiller,
                fillerConfig: FillerConfig.build(hachureGap: 2.5),
              ),
            ),
            // Background image
            if (backgroundImage != null)
              ClipOval(
                child: SizedBox(
                  width: size - 4,
                  height: size - 4,
                  child: Image(
                    image: backgroundImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _buildFallback(fgColor),
                  ),
                ),
              ),
            // Foreground image
            if (foregroundImage != null)
              ClipOval(
                child: SizedBox(
                  width: size - 4,
                  height: size - 4,
                  child: Image(image: foregroundImage!, fit: BoxFit.cover),
                ),
              ),
            // Child (initials or icon)
            if (backgroundImage == null && child != null)
              DefaultTextStyle(
                style: TextStyle(
                  color: fgColor,
                  fontSize: effectiveRadius * 0.7,
                  fontWeight: FontWeight.w600,
                ),
                child: IconTheme(
                  data: IconThemeData(color: fgColor, size: effectiveRadius),
                  child: child!,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallback(Color fgColor) {
    return Center(
      child: child ?? Icon(Icons.person, color: fgColor, size: radius),
    );
  }
}
