import 'package:flutter/widgets.dart';

import 'canvas/wired_canvas.dart';
import 'motion/wired_curves.dart';
import 'motion/wired_draw.dart';
import 'motion/wired_motion.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';

/// How long a navigation indicator takes to pop in and draw its ink.
const Duration kWiredNavigationIndicatorDuration = Duration(milliseconds: 420);

/// The hand-drawn wash behind a selected navigation destination.
///
/// Internal to the library. When [visible] turns on, the wash pops in on a
/// spring and its outline draws itself on, unless motion is off. [child]
/// (the icon, or the icon and label of an extended rail) sits on top and
/// stays put while the wash animates.
class WiredNavigationIndicator extends StatelessWidget {
  /// Creates an indicator around [child].
  const WiredNavigationIndicator({
    super.key,
    required this.visible,
    required this.color,
    required this.radius,
    required this.child,
    this.width,
    this.height,
    this.padding = EdgeInsets.zero,
    this.duration = kWiredNavigationIndicatorDuration,
    this.seed,
  });

  /// Whether the wash is drawn.
  final bool visible;

  /// The wash colour.
  final Color color;

  /// The corner radius of the wash.
  final double radius;

  /// The content drawn on the wash.
  final Widget child;

  /// A fixed width for the wash. Null sizes it to [child] plus [padding].
  final double? width;

  /// A minimum height for the wash. Null sizes it to [child] plus [padding].
  final double? height;

  /// Space between [child] and the edge of the wash.
  final EdgeInsetsGeometry padding;

  /// How long the wash takes to pop in and draw.
  final Duration duration;

  /// Varies the hand behind the wash.
  final int? seed;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final animate = WiredMotion.enabledOf(context) && duration > Duration.zero;
    final wash = WiredCanvas(
      painter: WiredRoundedRectangleBase(
        strokeWidth: theme.strokeWidth,
        borderRadius: BorderRadius.circular(radius),
        fillColor: color,
        borderColor: theme.borderColor,
      ),
      seed: seed,
      fillerType: RoughFilter.solidFiller,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: width ?? 0,
        maxWidth: width ?? double.infinity,
        minHeight: height ?? 0,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (visible)
            Positioned.fill(
              child: animate
                  ? WiredDraw(
                      duration: duration,
                      curve: WiredCurves.pen,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.6, end: 1),
                        duration: duration,
                        curve: WiredCurves.springy,
                        builder: (context, scale, child) =>
                            Transform.scale(scale: scale, child: child),
                        child: wash,
                      ),
                    )
                  : wash,
            ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

/// A destination's icon, with an optional badge over its top corner.
///
/// Internal to the library. A [badge] of `''` draws a dot; any other text
/// draws a pill around it. Like Material's navigation badges, the badge
/// starts near the icon's end edge and grows away from it, so a long count
/// never covers the glyph.
class WiredNavigationIcon extends StatelessWidget {
  /// Creates a destination icon.
  const WiredNavigationIcon({
    super.key,
    required this.icon,
    required this.color,
    this.badge,
    this.size = 24,
  });

  /// The glyph.
  final IconData icon;

  /// The glyph colour.
  final Color color;

  /// The badge text, `''` for a dot, or null for no badge.
  final String? badge;

  /// The glyph size.
  final double size;

  @override
  Widget build(BuildContext context) {
    final glyph = WiredIcon(icon: icon, color: color, size: size);
    final badge = this.badge;
    if (badge == null) return glyph;
    final dot = badge.isEmpty;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        glyph,
        PositionedDirectional(
          // A dot overlaps the corner; a pill starts two thirds across.
          start: dot ? size - 10 : size * 2 / 3,
          top: dot ? -4 : -8,
          child: _NavigationBadge(label: dot ? null : badge),
        ),
      ],
    );
  }
}

/// The hand-drawn dot or pill of a destination badge, washed with the
/// theme's `accentColor` like `WiredBadge`.
class _NavigationBadge extends StatelessWidget {
  const _NavigationBadge({required this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final fill = theme.accentColor;
    final label = this.label;
    if (label == null) {
      return SizedBox.square(
        dimension: 14,
        child: WiredCanvas(
          painter: WiredCircleBase(
            strokeWidth: theme.strokeWidth,
            fillColor: fill,
            diameterRatio: 0.9,
            borderColor: theme.borderColor,
          ),
          fillerType: RoughFilter.solidFiller,
        ),
      );
    }
    return Stack(
      children: [
        Positioned.fill(
          child: WiredCanvas(
            painter: WiredRoundedRectangleBase(
              strokeWidth: theme.strokeWidth,
              fillColor: fill,
              borderColor: theme.borderColor,
              borderRadius: const BorderRadius.all(Radius.circular(9)),
            ),
            fillerType: RoughFilter.solidFiller,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color: theme.onColor(fill),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
