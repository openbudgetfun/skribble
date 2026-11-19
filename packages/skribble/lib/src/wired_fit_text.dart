import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// The least a [WiredFitText] shrinks its label by default, as a fraction of
/// the label's own size: three quarters.
const double kWiredFitTextMinScale = 0.75;

/// The smallest font size, in logical pixels after text scaling, that a
/// [WiredFitText] shrinks its label to by default.
///
/// A label that already starts at or below this size never shrinks; it is
/// cut short with an ellipsis instead.
const double kWiredFitTextMinFontSize = 9;

/// One line of text that shrinks to fit the width it is given.
///
/// A label that fits is drawn at its full size. A label that is too wide is
/// scaled down, glyphs and line height together, until it fits, but never
/// below [minScale] of its size or below [minFontSize]. A label that still
/// does not fit at that floor is drawn at the floor and cut short with an
/// ellipsis, so it never clips, wraps onto a second line, or overflows.
///
/// ```dart
/// SizedBox(
///   width: 72,
///   child: WiredFitText('Notifications'),
/// )
/// ```
///
/// Use [WiredFitText.wrap] to fit a label you already have, such as the
/// [Text] passed to a button or chip:
///
/// ```dart
/// Expanded(
///   child: WiredFilledButton(
///     onPressed: save,
///     child: WiredFitText('Save and continue'),
///   ),
/// )
/// ```
///
/// Chips and navigation items (bottom nav, navigation bar and rail, and tab
/// bar) fit their labels this way already.
///
/// Shrinking scales the laid-out text, so it works with any font, including
/// the default Noto Sketch, and keeps the reader's text scale: with larger
/// text the label starts larger and its floor is larger too. The floors are
/// measured against the font size of [style] merged over the ambient
/// [DefaultTextStyle]; a wrapped child with its own, different font size
/// shrinks by the same fraction.
class WiredFitText extends HookWidget {
  /// Fits [data] on one line.
  const WiredFitText(
    String this.data, {
    super.key,
    this.style,
    this.semanticsLabel,
    this.minScale = kWiredFitTextMinScale,
    this.minFontSize = kWiredFitTextMinFontSize,
    this.alignment = AlignmentDirectional.centerStart,
  }) : child = null,
       assert(minScale > 0 && minScale <= 1, 'minScale must be in (0, 1]'),
       assert(minFontSize >= 0, 'minFontSize must not be negative');

  /// Fits [child], usually a [Text], on one line.
  ///
  /// The child is laid out on a single line, with an ellipsis if it is still
  /// too wide at the floor; a [Text] that sets its own `maxLines`, `softWrap`
  /// or `overflow` keeps them. [style] is merged into the
  /// [DefaultTextStyle] the child inherits.
  const WiredFitText.wrap({
    super.key,
    required Widget this.child,
    this.style,
    this.minScale = kWiredFitTextMinScale,
    this.minFontSize = kWiredFitTextMinFontSize,
    this.alignment = AlignmentDirectional.centerStart,
  }) : data = null,
       semanticsLabel = null,
       assert(minScale > 0 && minScale <= 1, 'minScale must be in (0, 1]'),
       assert(minFontSize >= 0, 'minFontSize must not be negative');

  /// The text to show, or null when this fits a [child].
  final String? data;

  /// The label to fit, or null when this shows [data].
  final Widget? child;

  /// The text style, merged over the ambient [DefaultTextStyle].
  final TextStyle? style;

  /// An alternative label read by screen readers in place of [data].
  final String? semanticsLabel;

  /// The least fraction of its size the label shrinks to, from just above 0
  /// to 1. A [minScale] of 1 never shrinks and only adds the ellipsis.
  /// Defaults to [kWiredFitTextMinScale].
  final double minScale;

  /// The smallest font size, in logical pixels after text scaling, the label
  /// shrinks to. Whichever of [minScale] and [minFontSize] gives the larger
  /// text wins. Defaults to [kWiredFitTextMinFontSize].
  final double minFontSize;

  /// Where the label sits when it is given more room than it needs, such as
  /// a tight width wider than the text. Defaults to the start of the line,
  /// vertically centred.
  final AlignmentGeometry alignment;

  /// The fraction the label may shrink to in [context]: the larger of
  /// [minScale] and the fraction that keeps [minFontSize].
  double _floor(BuildContext context) {
    final resolved = DefaultTextStyle.of(context).style.merge(style);
    final textScaler = MediaQuery.maybeTextScalerOf(context);
    final fontSize = (textScaler ?? TextScaler.noScaling).scale(
      resolved.fontSize ?? 14,
    );
    final floor = fontSize <= 0 ? 1.0 : minFontSize / fontSize;
    return math.min(1, math.max(minScale, floor));
  }

  @override
  Widget build(BuildContext context) {
    final label = data == null
        ? DefaultTextStyle.merge(
            style: style,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            child: child!,
          )
        : Text(
            data!,
            style: style,
            semanticsLabel: semanticsLabel,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          );

    return _FitLine(
      minScale: _floor(context),
      alignment: alignment,
      textDirection: Directionality.maybeOf(context),
      child: label,
    );
  }
}

/// Lays out its child on one line and scales it down to fit the width.
class _FitLine extends SingleChildRenderObjectWidget {
  const _FitLine({
    required this.minScale,
    required this.alignment,
    required this.textDirection,
    required super.child,
  });

  final double minScale;
  final AlignmentGeometry alignment;
  final TextDirection? textDirection;

  @override
  _RenderFitLine createRenderObject(BuildContext context) =>
      _RenderFitLine(minScale, alignment, textDirection);

  @override
  void updateRenderObject(BuildContext context, _RenderFitLine renderObject) {
    renderObject
      ..minScale = minScale
      ..alignment = alignment
      ..textDirection = textDirection;
  }
}

/// How [_RenderFitLine] lays out its child for one set of constraints.
typedef _Fit = ({double scale, BoxConstraints childConstraints});

class _RenderFitLine extends RenderProxyBox {
  _RenderFitLine(this._minScale, this._alignment, this._textDirection);

  double get minScale => _minScale;
  double _minScale;
  set minScale(double value) {
    if (value == _minScale) return;
    _minScale = value;
    markNeedsLayout();
  }

  AlignmentGeometry get alignment => _alignment;
  AlignmentGeometry _alignment;
  set alignment(AlignmentGeometry value) {
    if (value == _alignment) return;
    _alignment = value;
    markNeedsLayout();
  }

  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;
  set textDirection(TextDirection? value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsLayout();
  }

  /// The scale the child is painted at, from the last layout.
  double _scale = 1;

  /// Where the scaled child sits inside this box, from the last layout.
  Offset _offset = Offset.zero;

  final LayerHandle<TransformLayer> _transformLayer =
      LayerHandle<TransformLayer>();

  Matrix4 get _transform =>
      Matrix4.diagonal3Values(_scale, _scale, 1)
        ..setTranslationRaw(_offset.dx, _offset.dy, 0);

  /// The width the child needs on one line at full size.
  double get _naturalWidth => child!.getMaxIntrinsicWidth(double.infinity);

  /// Chooses the scale for [maxWidth], and the constraints the child is laid
  /// out with at that scale.
  _Fit _fit(double maxWidth) {
    final natural = _naturalWidth;
    if (natural <= maxWidth) {
      return (scale: 1.0, childConstraints: BoxConstraints(maxWidth: maxWidth));
    }
    final scale = maxWidth / natural;
    if (scale >= _minScale) {
      // At this scale the whole line fits, so the child keeps its natural
      // width rather than one a rounding error short of it.
      return (
        scale: scale,
        childConstraints: BoxConstraints(maxWidth: natural),
      );
    }
    // Too wide even at the floor: draw at the floor and let the child's
    // ellipsis cut it to the width that remains.
    return (
      scale: _minScale,
      childConstraints: BoxConstraints(maxWidth: maxWidth / _minScale),
    );
  }

  Size _scaled(Size childSize, double scale, BoxConstraints constraints) =>
      constraints.constrain(childSize * scale);

  @override
  double computeMinIntrinsicWidth(double height) =>
      child == null ? 0 : _naturalWidth * _minScale;

  @override
  double computeMaxIntrinsicWidth(double height) =>
      child == null ? 0 : _naturalWidth;

  double _intrinsicHeight(double width) {
    if (child == null) return 0;
    final fit = _fit(width);
    return child!.getMaxIntrinsicHeight(fit.childConstraints.maxWidth) *
        fit.scale;
  }

  @override
  double computeMinIntrinsicHeight(double width) => _intrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) => _intrinsicHeight(width);

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    if (child == null) return constraints.smallest;
    final fit = _fit(constraints.maxWidth);
    final childSize = child!.getDryLayout(fit.childConstraints);
    return _scaled(childSize, fit.scale, constraints);
  }

  @override
  double? computeDryBaseline(
    covariant BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    if (child == null) return null;
    final fit = _fit(constraints.maxWidth);
    final childBaseline = child!.getDryBaseline(fit.childConstraints, baseline);
    if (childBaseline == null) return null;
    final childSize = child!.getDryLayout(fit.childConstraints) * fit.scale;
    final size = constraints.constrain(childSize);
    final offset = _alignment
        .resolve(_textDirection)
        .alongOffset((size - childSize) as Offset);
    return childBaseline * fit.scale + offset.dy;
  }

  @override
  void performLayout() {
    if (child == null) {
      _scale = 1;
      _offset = Offset.zero;
      size = constraints.smallest;
      return;
    }
    final fit = _fit(constraints.maxWidth);
    child!.layout(fit.childConstraints, parentUsesSize: true);
    _scale = fit.scale;
    final childSize = child!.size * _scale;
    size = constraints.constrain(childSize);
    _offset = _alignment
        .resolve(_textDirection)
        .alongOffset((size - childSize) as Offset);
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    final childBaseline = child?.getDistanceToActualBaseline(baseline);
    if (childBaseline == null) return null;
    return childBaseline * _scale + _offset.dy;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null) return;
    if (_scale == 1) {
      _transformLayer.layer = null;
      context.paintChild(child, offset + _offset);
      return;
    }
    _transformLayer.layer = context.pushTransform(
      needsCompositing,
      offset,
      _transform,
      (context, offset) => context.paintChild(child, offset),
      oldLayer: _transformLayer.layer,
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final child = this.child;
    if (child == null) return false;
    return result.addWithPaintTransform(
      transform: _transform,
      position: position,
      hitTest: (result, position) => child.hitTest(result, position: position),
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.multiply(_transform);
  }

  @override
  void dispose() {
    _transformLayer.layer = null;
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('minScale', _minScale))
      ..add(DoubleProperty('scale', _scale))
      ..add(DiagnosticsProperty<AlignmentGeometry>('alignment', _alignment));
  }
}
