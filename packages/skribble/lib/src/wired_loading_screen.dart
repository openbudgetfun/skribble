import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'wired_loader.dart';
import 'wired_theme.dart';

/// A full-screen hand-drawn loading surface for startup and long waits.
///
/// Paints the theme's paper, centers a [WiredLoader], and optionally shows a
/// short status line. The default [WiredLoaderStyle.mark] sketches the brand
/// mark, so a splash screen can hand over to the static `WiredLogo` without
/// the mark jumping.
///
/// The screen is a single live region: screen readers announce [message] once
/// when it appears, and the drawing itself stays decorative. Motion follows
/// [WiredLoader]: reduced motion, a muted [TickerMode], or `animating: false`
/// settles the mark into a visible pose. Replace the screen when work
/// finishes; a settled drawing never means the work completed.
class WiredLoadingScreen extends HookWidget {
  /// Creates a loading screen. [duration] is one complete loop and must be
  /// positive.
  const WiredLoadingScreen({
    super.key,
    this.message,
    this.style = WiredLoaderStyle.mark,
    this.size = 96,
    this.strokeWidth = 2,
    this.seed = 1,
    this.duration = const Duration(milliseconds: 2600),
    this.animating = true,
    this.progress,
    this.color,
    this.backgroundColor,
    this.semanticLabel,
  }) : assert(size >= 0 && size < double.infinity),
       assert(strokeWidth > 0 && strokeWidth < double.infinity);

  /// Status line under the drawing, such as `Getting the pens ready…`.
  /// Null leaves the screen to the drawing alone.
  final String? message;

  /// The ink rhythm to display.
  final WiredLoaderStyle style;

  /// Preferred square size of the drawing. Smaller constraints scale it.
  final double size;

  /// Stroke width at the requested [size], scaled with the drawing.
  final double strokeWidth;

  /// Stable shape variation for the doodle styles; [WiredLoaderStyle.mark]
  /// ignores it.
  final int seed;

  /// Time for one complete loop when using the built-in clock.
  final Duration duration;

  /// Whether motion is allowed. False keeps a quiet, visible drawing.
  final bool animating;

  /// Optional caller-owned phase from zero to one. This widget never starts,
  /// stops, or disposes it. Motion preferences still take precedence.
  final Animation<double>? progress;

  /// Ink color, defaulting to the theme's text color.
  final Color? color;

  /// Paper color, defaulting to the theme's page background.
  final Color? backgroundColor;

  /// Announced status. Defaults to [message], then to `Loading`.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final status = semanticLabel ?? message ?? 'Loading';
    final ink = color ?? theme.textColor;

    return ColoredBox(
      color: backgroundColor ?? theme.paperBackgroundColor,
      child: Semantics(
        container: true,
        liveRegion: true,
        label: status,
        child: ExcludeSemantics(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WiredLoader(
                    style: style,
                    size: size,
                    color: ink,
                    strokeWidth: strokeWidth,
                    seed: seed,
                    duration: duration,
                    animating: animating,
                    progress: progress,
                    semanticLabel: null,
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        // Startup may precede the page's default text style.
                        inherit: false,
                        fontFamily: theme.fontFamily,
                        package: theme.fontPackage,
                        color: ink.withValues(alpha: .72),
                        fontSize: 17,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
