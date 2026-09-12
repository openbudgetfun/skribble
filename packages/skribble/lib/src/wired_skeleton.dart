import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'motion/loading_cycle.dart';
import 'wired_theme.dart';

/// A faint placeholder with bowed pencil hatching and a slow ink pulse.
///
/// Use finite [width] and [height] for text lines or avatars. Null dimensions
/// follow parent constraints; inside a positioned overlay they fill its bounds.
/// Individual placeholders are decorative. Label their containing loading state.
class WiredSkeleton extends HookWidget {
  /// Creates a skeleton block. A circular border radius makes an avatar.
  const WiredSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
    this.color,
    this.animating = true,
  }) : assert(width == null || (width >= 0 && width < double.infinity)),
       assert(height == null || (height >= 0 && height < double.infinity));

  /// Preferred width, or the width allowed by the parent.
  final double? width;

  /// Preferred height, or the height allowed by the parent.
  final double? height;

  /// Shape of the wash and clipped pencil hatching.
  final BorderRadius borderRadius;

  /// Ink color, defaulting to the theme's text color at low opacity.
  final Color? color;

  /// Whether to pulse. Reduced-motion and ticker policies take precedence.
  final bool animating;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: IgnorePointer(
      child: RepaintBoundary(
        child: WiredLoadingCycle(
          duration: const Duration(milliseconds: 2200),
          animating: animating,
          builder: (context, phase) => SizedBox(
            width: width,
            height: height,
            child: CustomPaint(
              painter: _SkeletonPainter(
                phase: phase,
                color: color ?? WiredTheme.of(context).textColor,
                borderRadius: borderRadius,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Replaces a component visually while retaining its layout and mounted state.
///
/// While [loading], the child is invisible and excluded from pointer input,
/// focus, semantics, and tickers. The overlay fills the child's measured bounds.
/// Use a matching arrangement of [WiredSkeleton] blocks for structured content.
/// The skeleton is decorative; [semanticLabel] announces the containing state.
class WiredSkeletonOverlay extends HookWidget {
  /// Creates a layout-preserving loading overlay.
  const WiredSkeletonOverlay({
    super.key,
    required this.loading,
    required this.child,
    this.skeleton = const WiredSkeleton(height: null),
    this.semanticLabel = 'Loading',
  });

  /// Whether the placeholder covers the component.
  final bool loading;

  /// The real component. Its state remains mounted through loading changes.
  final Widget child;

  /// Placeholder constrained to exactly the child's size.
  final Widget skeleton;

  /// Localizable announcement while loading. Null makes the overlay silent.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      ExcludeFocus(
        excluding: loading,
        child: ExcludeSemantics(
          excluding: loading,
          child: IgnorePointer(
            ignoring: loading,
            child: TickerMode(
              enabled: !loading && TickerMode.of(context),
              child: Opacity(opacity: loading ? 0 : 1, child: child),
            ),
          ),
        ),
      ),
      if (loading)
        Positioned.fill(
          child: Semantics(
            container: true,
            liveRegion: true,
            label: semanticLabel,
            child: ExcludeSemantics(child: IgnorePointer(child: skeleton)),
          ),
        ),
    ],
  );
}

class _SkeletonPainter extends CustomPainter {
  _SkeletonPainter({
    required this.phase,
    required this.color,
    required this.borderRadius,
  }) : super(repaint: phase);

  final Animation<double> phase;
  final Color color;
  final BorderRadius borderRadius;
  Size? _cachedSize;
  Path _hatching = Path();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    // Geometry depends on layout, not time. Keep pencil marks stationary.
    if (size != _cachedSize) {
      _cachedSize = size;
      _hatching = Path();

      for (var x = -size.height; x < size.width; x += 9) {
        _hatching.moveTo(x, size.height);
        _hatching.quadraticBezierTo(
          x + size.height * .5 + 2,
          size.height * .45,
          x + size.height,
          0,
        );
      }
    }
    final pulse = .5 - .5 * math.cos(phase.value * math.pi * 2);
    final shape = borderRadius.toRRect(Offset.zero & size);
    canvas.save();
    canvas.clipRRect(shape);
    canvas.drawRRect(
      shape,
      Paint()..color = color.withValues(alpha: color.a * .055),
    );
    canvas.drawPath(
      _hatching,
      Paint()
        ..color = color.withValues(alpha: color.a * (.09 + .07 * pulse))
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SkeletonPainter oldDelegate) =>
      phase != oldDelegate.phase ||
      color != oldDelegate.color ||
      borderRadius != oldDelegate.borderRadius;
}
