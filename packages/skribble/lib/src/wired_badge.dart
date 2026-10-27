import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A badge overlay: a hand-drawn dot, or a pill around a short [label].
///
/// The badge is washed with the theme's `markerColor` and inked like the
/// rest of the interface, with the label in the theme's text colour.
class WiredBadge extends HookWidget {
  /// The widget the badge sits on.
  final Widget child;

  /// Short text in the badge, such as a count or "new". Null draws a dot.
  final String? label;

  /// Whether the badge is shown.
  final bool isVisible;

  /// Wash behind the badge. Defaults to the theme's `markerColor`; pick a
  /// colour that keeps the theme's text colour legible on it.
  final Color? backgroundColor;

  const WiredBadge({
    super.key,
    required this.child,
    this.label,
    this.isVisible = true,
    this.backgroundColor,
    this.seed,
  });

  /// Varies the hand behind this widget's ink. The same seed always draws
  /// the same wobble, so neighbouring shapes of the same size need different
  /// seeds to stop them reading as copies of each other. Null keeps the
  /// theme's seed.
  final int? seed;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final fill = backgroundColor ?? theme.markerColor;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (isVisible)
          Positioned(
            right: -6,
            top: -6,
            child: label == null
                ? SizedBox.square(
                    dimension: 16,
                    child: WiredCanvas(
                      painter: WiredCircleBase(
                        strokeWidth: theme.strokeWidth,
                        fillColor: fill,
                        diameterRatio: 0.9,
                        borderColor: theme.borderColor,
                      ),
                      seed: seed,
                      fillerType: RoughFilter.solidFiller,
                    ),
                  )
                // A label sits in a pill that grows with it, so the text
                // never spills past the ink.
                : Stack(
                    children: [
                      Positioned.fill(
                        child: WiredCanvas(
                          painter: WiredRoundedRectangleBase(
                            strokeWidth: theme.strokeWidth,
                            fillColor: fill,
                            borderColor: theme.borderColor,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(9),
                            ),
                          ),
                          seed: seed,
                          fillerType: RoughFilter.solidFiller,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        child: Text(
                          label!,
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
      ],
    );
  }
}
