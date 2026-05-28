import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'wired_theme.dart';

/// A hand-drawn fade transition with organic motion.
///
/// Provides a smooth fade animation that fits the Skribble aesthetic
/// with slight overshoot and organic timing.
///
/// ## Example
///
/// ```dart
/// WiredFadeTransition(
///   animation: animation,
///   child: MyWidget(),
/// )
/// ```
class WiredFadeTransition extends HookWidget {
  /// The animation that drives the transition.
  final Animation<double> animation;

  /// The child widget to animate.
  final Widget child;

  /// Whether to fade in (true) or fade out (false).
  final bool fadeIn;

  /// Creates a hand-drawn fade transition.
  const WiredFadeTransition({
    super.key,
    required this.animation,
    required this.child,
    this.fadeIn = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final opacity = fadeIn ? animation.value : 1.0 - animation.value;
        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: child,
        );
      },
      child: child,
    );
  }
}

/// A hand-drawn slide transition with organic motion.
///
/// Provides a smooth slide animation that fits the Skribble aesthetic
/// with slight overshoot and organic timing.
///
/// ## Example
///
/// ```dart
/// WiredSlideTransition(
///   animation: animation,
///   begin: Offset(1.0, 0.0),
///   child: MyWidget(),
/// )
/// ```
class WiredSlideTransition extends HookWidget {
  /// The animation that drives the transition.
  final Animation<double> animation;

  /// The starting offset of the slide.
  final Offset begin;

  /// The ending offset of the slide.
  final Offset end;

  /// The child widget to animate.
  final Widget child;

  /// Creates a hand-drawn slide transition.
  const WiredSlideTransition({
    super.key,
    required this.animation,
    this.begin = const Offset(1.0, 0.0),
    this.end = Offset.zero,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final offset = Offset.lerp(begin, end, animation.value)!;
        return FractionalTranslation(
          translation: offset,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// A hand-drawn scale transition with organic motion.
///
/// Provides a smooth scale animation that fits the Skribble aesthetic
/// with slight overshoot and organic timing.
///
/// ## Example
///
/// ```dart
/// WiredScaleTransition(
///   animation: animation,
///   child: MyWidget(),
/// )
/// ```
class WiredScaleTransition extends HookWidget {
  /// The animation that drives the transition.
  final Animation<double> animation;

  /// The starting scale.
  final double begin;

  /// The ending scale.
  final double end;

  /// The child widget to animate.
  final Widget child;

  /// Creates a hand-drawn scale transition.
  const WiredScaleTransition({
    super.key,
    required this.animation,
    this.begin = 0.0,
    this.end = 1.0,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale = begin + (end - begin) * animation.value;
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// A hand-drawn combined transition with fade, slide, and scale.
///
/// Provides a rich animation that combines multiple effects for
/// a polished, organic feel.
///
/// ## Example
///
/// ```dart
/// WiredCombinedTransition(
///   animation: animation,
///   child: MyWidget(),
/// )
/// ```
class WiredCombinedTransition extends HookWidget {
  /// The animation that drives the transition.
  final Animation<double> animation;

  /// The child widget to animate.
  final Widget child;

  /// Whether to fade in.
  final bool fadeIn;

  /// The slide direction.
  final Offset slideBegin;

  /// The initial scale.
  final double scaleBegin;

  /// Creates a hand-drawn combined transition.
  const WiredCombinedTransition({
    super.key,
    required this.animation,
    required this.child,
    this.fadeIn = true,
    this.slideBegin = const Offset(0.0, 0.3),
    this.scaleBegin = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = animation.value;

        // Fade
        final opacity = fadeIn ? progress : 1.0 - progress;

        // Slide
        final offset = Offset.lerp(slideBegin, Offset.zero, progress)!;

        // Scale
        final scale = scaleBegin + (1.0 - scaleBegin) * progress;

        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: FractionalTranslation(
            translation: offset,
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

/// A hand-drawn page route transition builder.
///
/// Provides organic page transitions that fit the Skribble aesthetic.
///
/// ## Example
///
/// ```dart
/// PageRouteBuilder(
///   pageBuilder: (context, animation, secondaryAnimation) => NextPage(),
///   transitionsBuilder: (context, animation, secondaryAnimation, child) {
///     return WiredPageTransition(
///       animation: animation,
///       child: child,
///     );
///   },
/// )
/// ```
class WiredPageTransition extends HookWidget {
  /// The animation that drives the transition.
  final Animation<double> animation;

  /// The secondary animation for back navigation.
  final Animation<double>? secondaryAnimation;

  /// The child widget to animate.
  final Widget child;

  /// Creates a hand-drawn page transition.
  const WiredPageTransition({
    super.key,
    required this.animation,
    this.secondaryAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Use easeOutCubic for organic feel
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    return WiredCombinedTransition(
      animation: curvedAnimation,
      slideBegin: const Offset(0.2, 0.0),
      scaleBegin: 0.95,
      child: child,
    );
  }
}
