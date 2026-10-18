// COMPATIBILITY LAYER -- transitional, sanctioned Material/Cupertino import.
//
// See `wired_theme_interop.dart` and docs/site/content/core/material-bridge.md
// for why this directory is the one place allowed to import Material.

import 'dart:math';

import 'package:flutter/material.dart';

import '../rough/skribble_rough.dart';

/// The hand-drawn outline around a Material text field.
///
/// Use it as the `border`, `enabledBorder`, or `focusedBorder` of an
/// [InputDecoration] or [InputDecorationTheme] so `TextField`s and
/// `DropdownMenu`s in an app that still uses Material draw the same rough
/// edge as Wired widgets.
///
/// A rough line cannot leave a clean gap for a floating label, so this border
/// reports itself as not an outline ([isOutline] is false). Material then
/// floats the label inside the field, as it does for a filled field, and the
/// pen draws the whole box.
///
/// Like [RoughOutlinedBorder], the [seed] is fixed, so the outline keeps its
/// wobble while the field gains focus or its text changes, and prepared
/// outlines are shared between fields of the same size.
class RoughInputBorder extends InputBorder {
  /// Creates a rough outline for a text field.
  const RoughInputBorder({
    super.borderSide,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.seed = 1,
    this.drawConfig,
  });

  /// Corner radii of the outline.
  final BorderRadius borderRadius;

  /// Seed for the outline's wobble. Ignored when [drawConfig] is set.
  final int seed;

  /// Draw configuration for the outline, compared by identity. Defaults to
  /// `DrawConfig.build(seed: seed)`.
  final DrawConfig? drawConfig;

  @override
  bool get isOutline => false;

  double get _inset =>
      borderSide.style == BorderStyle.none || borderSide.width == 0
      ? 0
      : roughInkInset(borderSide.width, drawConfig);

  RRect _shape(Rect rect) =>
      borderRadius.toRRect(rect.deflate(min(_inset, rect.shortestSide / 2)));

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(borderSide.strokeInset);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_shape(rect).deflate(borderSide.strokeInset));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_shape(rect));

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0,
    double gapPercentage = 0,
    TextDirection? textDirection,
  }) => paintRoughOutline(
    canvas,
    rect,
    side: borderSide,
    borderRadius: borderRadius,
    seed: seed,
    drawConfig: drawConfig,
  );

  @override
  RoughInputBorder copyWith({
    BorderSide? borderSide,
    BorderRadius? borderRadius,
    int? seed,
  }) => RoughInputBorder(
    borderSide: borderSide ?? this.borderSide,
    borderRadius: borderRadius ?? this.borderRadius,
    seed: seed ?? this.seed,
    drawConfig: drawConfig,
  );

  @override
  ShapeBorder scale(double t) => RoughInputBorder(
    borderSide: borderSide.scale(t),
    borderRadius: borderRadius * t,
    seed: seed,
    drawConfig: drawConfig,
  );

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is RoughInputBorder) {
      return RoughInputBorder(
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
        borderRadius: BorderRadius.lerp(a.borderRadius, borderRadius, t)!,
        seed: t < 0.5 ? a.seed : seed,
        drawConfig: t < 0.5 ? a.drawConfig : drawConfig,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is RoughInputBorder) {
      return RoughInputBorder(
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
        borderRadius: BorderRadius.lerp(borderRadius, b.borderRadius, t)!,
        seed: t < 0.5 ? seed : b.seed,
        drawConfig: t < 0.5 ? drawConfig : b.drawConfig,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  bool operator ==(Object other) =>
      other is RoughInputBorder &&
      other.borderSide == borderSide &&
      other.borderRadius == borderRadius &&
      other.seed == seed &&
      identical(other.drawConfig, drawConfig);

  @override
  int get hashCode => Object.hash(borderSide, borderRadius, seed, drawConfig);
}
