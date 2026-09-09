import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

/// A hand-drawn map pin with a stable, seedable outline.
class WiredMapPin extends HookWidget {
  /// Creates a map pin.
  const WiredMapPin({
    super.key,
    this.child,
    this.onTap,
    this.semanticLabel,
    this.width = 44,
    this.height = 54,
    this.fillColor,
    this.inkColor,
    this.strokeWidth,
    this.seed = 37,
  }) : assert(width > 0, 'width must be positive'),
       assert(height > 0, 'height must be positive');

  /// Content drawn inside the rounded head of the pin.
  final Widget? child;

  /// Called when the pin is activated.
  final VoidCallback? onTap;

  /// An accessibility label for the pin.
  final String? semanticLabel;

  /// The pin width.
  final double width;

  /// The pin height.
  final double height;

  /// The pin body color, or the active Wired theme fill color.
  final Color? fillColor;

  /// The pin outline color, or the active Wired theme border color.
  final Color? inkColor;

  /// The pin outline width, or the active Wired theme stroke width.
  final double? strokeWidth;

  /// The deterministic rough-drawing seed.
  final int seed;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final pressed = useState(false);
    final enabled = onTap != null;
    final resolvedInk = inkColor ?? theme.borderColor;
    final resolvedFill = fillColor ?? theme.fillColor;
    final duration = theme.motionEnabled
        ? const Duration(milliseconds: 90)
        : Duration.zero;

    return buildWiredElement(
      child: Semantics(
        label: semanticLabel,
        button: enabled,
        excludeSemantics: semanticLabel != null,
        child: MouseRegion(
          cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            onTapDown: enabled ? (_) => pressed.value = true : null,
            onTapUp: enabled ? (_) => pressed.value = false : null,
            onTapCancel: enabled ? () => pressed.value = false : null,
            child: AnimatedScale(
              duration: duration,
              curve: Curves.easeOut,
              scale: pressed.value ? 0.92 : 1,
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: width,
                height: height,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned.fill(
                      child: WiredCanvas(
                        drawConfig: theme.drawConfig.copyWith(seed: seed),
                        fillerType: RoughFilter.solidFiller,
                        painter: _WiredMapPinPainter(
                          fillColor: resolvedFill,
                          inkColor: resolvedInk,
                          strokeWidth: strokeWidth ?? theme.strokeWidth,
                        ),
                      ),
                    ),
                    if (child != null)
                      Positioned(
                        top: height * 0.12,
                        width: width * 0.55,
                        height: height * 0.42,
                        child: Center(child: child),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WiredMapPinPainter extends WiredPainterBase {
  _WiredMapPinPainter({
    required this.fillColor,
    required this.inkColor,
    required this.strokeWidth,
  });

  final Color fillColor;
  final Color inkColor;
  final double strokeWidth;

  @override
  RoughDrawing prepare(Size size, DrawConfig drawConfig, Filler filler) {
    final inset = strokeWidth + (drawConfig.maxRandomnessOffset ?? 2);
    final left = inset.clamp(0, size.width / 3).toDouble();
    final right = size.width - left;
    final top = inset.clamp(0, size.height / 4).toDouble();
    final tip = size.height - inset;
    final points = <PointD>[
      PointD(size.width * 0.5, tip),
      PointD(size.width * 0.18, size.height * 0.5),
      PointD(left, size.height * 0.31),
      PointD(size.width * 0.22, size.height * 0.14),
      PointD(size.width * 0.39, top),
      PointD(size.width * 0.61, top),
      PointD(size.width * 0.78, size.height * 0.14),
      PointD(right, size.height * 0.31),
      PointD(size.width * 0.82, size.height * 0.5),
    ];
    final drawable = Generator(drawConfig, filler).polygon(points);
    return RoughDrawing(
      drawable,
      WiredBase.pathPainter(strokeWidth, color: inkColor),
      WiredBase.fillPainter(fillColor),
    );
  }

  @override
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  ) {
    prepare(size, drawConfig, filler).paint(canvas);
  }
}
