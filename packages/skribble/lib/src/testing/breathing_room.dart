import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../canvas/wired_painter.dart';
import '../rough/skribble_rough.dart';
import '../wired_paint.dart';
import '../wired_painter_bases.dart';
import '../wired_svg_icon_painter.dart';

/// Which hand-drawn ink a [CrampedText] crowds.
enum CrampedInk {
  /// Text too close to the shape it sits in.
  border,

  /// A hand-drawn line, such as a divider, an underline, or a tab
  /// indicator, crossing a text's glyphs. Reported when
  /// [crampedText]'s `lines` is set.
  line,

  /// An icon too close to the shape it sits in, such as the circle of an
  /// icon button. Reported when [crampedText]'s `icons` is set.
  icon,
}

/// Text or an icon that sits too close to hand-drawn ink, found by
/// [crampedText].
final class CrampedText {
  /// Describes [text] at [gaps] from the [border] that [owner] drew.
  ///
  /// [ink] says what kind of ink is crowded; see [CrampedInk].
  const CrampedText(
    this.text,
    this.border,
    this.gaps,
    this.owner, {
    this.ink = CrampedInk.border,
  });

  /// What the text or icon crowds.
  final CrampedInk ink;

  /// The skribble widget that drew [border].
  final String owner;

  /// The text, shortened, or `icon` for an icon.
  final String text;

  /// The hand-drawn border around it, in global coordinates. For a line,
  /// the bounds of the line's ink.
  final Rect border;

  /// The space between the text's glyphs, or the icon's ink, and each side
  /// of [border]. A circle reports the same gap on every side: the least
  /// distance from the ink to the circle. A line reports, on every side,
  /// the distance from its ideal centreline to the glyph box: zero when it
  /// runs through the glyphs, and less than the pen's reach when its ink
  /// touches them.
  final EdgeInsets gaps;

  @override
  String toString() {
    String gap(double value) => value.toStringAsFixed(1);
    final size = '${border.width.round()}×${border.height.round()}';
    return switch (ink) {
      CrampedInk.line =>
        gaps.top == 0
            ? '$owner: a line crosses "$text" at $size'
            : '$owner: a line touches "$text" at $size, '
                  '${gap(gaps.top)} from its glyph box',
      CrampedInk.border || CrampedInk.icon =>
        '$owner: ${ink == CrampedInk.icon ? text : '"$text"'} in $size: '
            'left ${gap(gaps.left)}, top ${gap(gaps.top)}, '
            'right ${gap(gaps.right)}, bottom ${gap(gaps.bottom)}',
    };
  }
}

/// The nearest skribble widget that built [node], for reports.
String _owner(RenderObject node) {
  var name = '?';
  final creator = node.debugCreator;
  if (creator is DebugCreator) {
    creator.element.visitAncestorElements((element) {
      final type = element.widget.runtimeType.toString();
      if (type.startsWith('Wired') && type != 'WiredCanvas') {
        name = type;
        return false;
      }
      return true;
    });
  }
  return name;
}

/// Whether [painter] draws a hand-drawn shape that content sits inside:
/// a rectangle, a rounded rectangle, or a circle. Lines, doodles, markers,
/// and icons are drawn beside or under content, not around it.
bool _isShape(CustomPainter? painter) =>
    painter is WiredPainter &&
    (painter.painter is WiredRectangleBase ||
        painter.painter is WiredRoundedRectangleBase ||
        painter.painter is WiredCircleBase);

/// The fraction of its box's shortest side a circular border spans, or null
/// for a border that is not a circle.
double? _circleRatio(Object? shape) => switch (shape) {
  WiredPainter(painter: final WiredCircleBase circle) => circle.diameterRatio,
  RoughBoxDecoration(shape: RoughBoxShape.circle) => 1,
  _ => null,
};

/// A hand-drawn border on screen: its visible bounds, the widget that drew
/// it, its whole bounds, and, for a circle, the share of the box it spans.
typedef _Border = (Rect, String, Rect, double?);

/// Every hand-drawn border on screen: rough box decorations and the shapes
/// skribble paints its controls in.
List<_Border> _borders(RenderObject root) {
  final borders = <_Border>[];
  void visit(RenderObject node) {
    final (isBorder, circle) = switch (node) {
      RenderDecoratedBox(:final decoration) => (
        decoration is RoughBoxDecoration,
        _circleRatio(decoration),
      ),
      RenderCustomPaint(:final painter, :final foregroundPainter) => (
        _isShape(painter) || _isShape(foregroundPainter),
        _circleRatio(_isShape(foregroundPainter) ? foregroundPainter : painter),
      ),
      _ => (false, null),
    };
    if (isBorder && node is RenderBox && node.hasSize) {
      final whole = MatrixUtils.transformRect(
        node.getTransformTo(null),
        Offset.zero & node.size,
      );
      final rect = _clipped(node, whole);
      if (!rect.isEmpty) borders.add((rect, _owner(node), whole, circle));
    }
    node.visitChildren(visit);
  }

  visit(root);
  return borders;
}

/// The smallest of [borders] that holds most of [bounds], or null.
_Border? _enclosing(List<_Border> borders, Rect bounds) {
  _Border? found;
  for (final border in borders) {
    final candidate = border.$1;
    // The content lives in a border when most of it is inside; a neighbour
    // straddling the line belongs to something else.
    final inside = candidate.intersect(bounds);
    if (inside.width <= 0 ||
        inside.height <= 0 ||
        inside.width * inside.height < bounds.width * bounds.height / 2) {
      continue;
    }
    // The smallest border around the content is the one it lives in. Of
    // two the same size, the later one paints over the earlier, the way an
    // elevated button's face covers its offset shadow.
    if (found == null ||
        candidate.width * candidate.height <=
            found.$1.width * found.$1.height) {
      found = border;
    }
  }
  return found;
}

/// A hand-drawn line on screen, from `start` to `end` in global
/// coordinates, inked `reach` pixels to either side, drawn by `owner`.
typedef _Line = ({Offset start, Offset end, double reach, String owner});

/// Every hand-drawn line on screen: dividers, underlines, and indicators
/// drawn with [WiredLineBase].
List<_Line> _lines(RenderObject root) {
  final lines = <_Line>[];
  void visit(RenderObject node) {
    if (node is RenderCustomPaint && node.hasSize) {
      for (final candidate in [node.painter, node.foregroundPainter]) {
        if (candidate case WiredPainter(
          painter: final WiredLineBase line,
          :final drawConfig,
        )) {
          final size = node.size;
          final transform = node.getTransformTo(null);
          Offset place(double x, double y) => MatrixUtils.transformPoint(
            transform,
            Offset(
              x.clamp(0, size.width).toDouble(),
              y.clamp(0, size.height).toDouble(),
            ),
          );
          final start = place(line.x1, line.y1);
          final end = place(line.x2, line.y2);
          // Only a line that shows can cross anything.
          final bounds = Rect.fromPoints(start, end).inflate(.5);
          if (_clipped(node, bounds).isEmpty) continue;
          lines.add((
            start: start,
            end: end,
            reach:
                line.strokeWidth / 2 +
                drawConfig.maxRandomnessOffset * drawConfig.roughness,
            owner: _owner(node),
          ));
        }
      }
    }
    node.visitChildren(visit);
  }

  visit(root);
  return lines;
}

/// The least distance from the segment [a] to [b] to [rect]; zero when
/// they touch.
double _segmentToRect(Offset a, Offset b, Rect rect) {
  bool inside(Offset p) =>
      p.dx >= rect.left &&
      p.dx <= rect.right &&
      p.dy >= rect.top &&
      p.dy <= rect.bottom;
  if (inside(a) || inside(b)) return 0;
  final corners = [
    rect.topLeft,
    rect.topRight,
    rect.bottomRight,
    rect.bottomLeft,
  ];
  double cross(Offset o, Offset p, Offset q) =>
      (p.dx - o.dx) * (q.dy - o.dy) - (p.dy - o.dy) * (q.dx - o.dx);
  // The segment crosses an edge of the rectangle.
  for (var i = 0; i < 4; i++) {
    final c = corners[i];
    final d = corners[(i + 1) % 4];
    if (cross(a, b, c) * cross(a, b, d) <= 0 &&
        cross(c, d, a) * cross(c, d, b) <= 0) {
      return 0;
    }
  }
  double pointToSegment(Offset p, Offset s, Offset e) {
    final along = e - s;
    final length = along.distanceSquared;
    final t = length == 0
        ? 0.0
        : (((p - s).dx * along.dx + (p - s).dy * along.dy) / length).clamp(
            0.0,
            1.0,
          );
    return (p - (s + along * t)).distance;
  }

  double pointToRect(Offset p) {
    final dx = math.max(math.max(rect.left - p.dx, 0.0), p.dx - rect.right);
    final dy = math.max(math.max(rect.top - p.dy, 0.0), p.dy - rect.bottom);
    return math.sqrt(dx * dx + dy * dy);
  }

  return [
    pointToRect(a),
    pointToRect(b),
    for (final corner in corners) pointToSegment(corner, a, b),
  ].reduce(math.min);
}

/// An icon on screen: points along its ink in global coordinates, how far
/// the pen reaches past them, and how much it is scaled.
typedef _Icon = ({List<Offset> ink, double reach, double scale});

/// Every hand-drawn icon on screen, sampled along its source geometry.
List<_Icon> _icons(RenderObject root) {
  final icons = <_Icon>[];
  void visit(RenderObject node) {
    if (node is RenderCustomPaint &&
        node.hasSize &&
        node.painter is WiredSvgIconPainter) {
      final painter = node.painter! as WiredSvgIconPainter;
      final transform = node.getTransformTo(null);
      final ink = <Offset>[];
      var reach = 0.0;
      for (final primitive in painter.primitives) {
        final strokes = primitive.strokes;
        if (strokes) {
          reach = math.max(reach, primitive.strokeWidth * painter.weight / 2);
        }
        final path = strokes ? primitive.strokePath : primitive.path;
        for (final metric in path.computeMetrics()) {
          final steps = math.max(1, metric.length.ceil());
          for (var i = 0; i <= steps; i++) {
            final tangent = metric.getTangentForOffset(
              metric.length * i / steps,
            );
            if (tangent != null) {
              ink.add(MatrixUtils.transformPoint(transform, tangent.position));
            }
          }
        }
      }
      if (ink.isNotEmpty) {
        icons.add((
          ink: ink,
          reach: reach,
          scale: math.sqrt(
            transform.storage[0] * transform.storage[0] +
                transform.storage[1] * transform.storage[1],
          ),
        ));
      }
    }
    node.visitChildren(visit);
  }

  visit(root);
  return icons;
}

/// The part of [bounds] that shows on screen: inside every scrolling
/// viewport and clip above [node]. Lists lay out a little more than they
/// show, and zoomed content spills past its frame; the clips hide both.
Rect _clipped(RenderObject node, Rect bounds) {
  var visible = bounds;
  for (var parent = node.parent; parent != null;) {
    final clips =
        parent is RenderAbstractViewport ||
        (parent is RenderClipRect && parent.clipBehavior != Clip.none) ||
        (parent is RenderClipRRect && parent.clipBehavior != Clip.none);
    if (clips && parent is RenderBox && parent.hasSize) {
      visible = visible.intersect(
        MatrixUtils.transformRect(
          parent.getTransformTo(null),
          Offset.zero & parent.size,
        ),
      );
      if (visible.width <= 0 || visible.height <= 0) return Rect.zero;
    }
    parent = parent.parent;
  }
  return visible;
}

/// The paragraphs on screen, the global bounds of their glyphs, and how much
/// they are scaled (a FittedBox or a zoom scales padding with everything
/// else, so gaps are compared in the content's own size).
List<(String, Rect, Rect, double)> _texts(RenderObject root) {
  final texts = <(String, Rect, Rect, double)>[];
  void visit(RenderObject node) {
    if (node is RenderParagraph && node.hasSize) {
      final text = node.text.toPlainText();
      if (text.trim().isNotEmpty) {
        final boxes = node.getBoxesForSelection(
          TextSelection(baseOffset: 0, extentOffset: text.length),
        );
        if (boxes.isNotEmpty) {
          final local = boxes
              .map((box) => box.toRect())
              .reduce((a, b) => a.expandToInclude(b));
          final transform = node.getTransformTo(null);
          final whole = MatrixUtils.transformRect(transform, local);
          // Long lines that scroll sideways run past their frame on
          // purpose: measure only the part that shows.
          final bounds = _clipped(node, whole);
          if (!bounds.isEmpty) {
            texts.add((
              text.length > 32 ? '${text.substring(0, 31)}…' : text,
              bounds,
              whole,
              // The x axis's scale; a 2D scale leaves z at 1.
              math.sqrt(
                transform.storage[0] * transform.storage[0] +
                    transform.storage[1] * transform.storage[1],
              ),
            ));
          }
        }
      }
    }
    node.visitChildren(visit);
  }

  visit(root);
  return texts;
}

/// Text under [root] whose glyphs come within [vertical] pixels of the top
/// or bottom, or [horizontal] pixels of the sides, of the smallest
/// hand-drawn border around it, or spill past it. The defaults are
/// [kWiredInkPadding], the space every skribble control keeps.
///
/// Gaps are measured in the content's own size, so a scaled-down preview
/// is judged by its proportions; text and ink hidden by scrolling or clips
/// are ignored.
///
/// Ink wobbles and has width, so a gap that is fine for a straight CSS
/// border looks cramped here: these minimums are measured from the ideal
/// edge, before the pen.
///
/// Two further checks are off by default:
///
/// * [lines] also reports a hand-drawn line (a [WiredLineBase] divider,
///   underline, or tab indicator) whose ink crosses a text's glyph box, as
///   [CrampedInk.line].
/// * [icons] also reports a hand-drawn icon whose ink comes within
///   [iconGap] pixels of the shape around it, such as an icon button's
///   circle, as [CrampedInk.icon]. A circle is measured along its curve,
///   not its bounding box.
List<CrampedText> crampedText(
  RenderObject root, {
  double? vertical,
  double? horizontal,
  bool lines = false,
  bool icons = false,
  double iconGap = 4,
}) {
  final minimumVertical = vertical ?? kWiredInkPadding.top;
  final minimumHorizontal = horizontal ?? kWiredInkPadding.left;
  final borders = _borders(root);
  final texts = _texts(root);
  final cramped = <CrampedText>[];
  for (final (text, bounds, uncut, scale) in texts) {
    final enclosing = _enclosing(borders, bounds);
    // Badges and other micro labels keep their own tight pill; text that
    // lives in one is not measured against the larger shape around it.
    if (enclosing == null || enclosing.$1.shortestSide <= 24) continue;
    final (border, owner, whole, _) = enclosing;
    // A side a clip has cut off, of the ink or of the text, shows nothing
    // to crowd.
    double gap(double value, {required bool cut}) =>
        cut ? double.infinity : value / scale;
    final gaps = EdgeInsets.fromLTRB(
      gap(
        bounds.left - border.left,
        cut: border.left > whole.left + .5 || bounds.left > uncut.left + .5,
      ),
      gap(
        bounds.top - border.top,
        cut: border.top > whole.top + .5 || bounds.top > uncut.top + .5,
      ),
      gap(
        border.right - bounds.right,
        cut: border.right < whole.right - .5 || bounds.right < uncut.right - .5,
      ),
      gap(
        border.bottom - bounds.bottom,
        cut:
            border.bottom < whole.bottom - .5 ||
            bounds.bottom < uncut.bottom - .5,
      ),
    );
    // Half a pixel of slack absorbs glyph side bearings and rounding.
    if (math.min(gaps.top, gaps.bottom) < minimumVertical - .5 ||
        math.min(gaps.left, gaps.right) < minimumHorizontal - .5) {
      cramped.add(CrampedText(text, border, gaps, owner));
    }
  }

  if (lines) {
    final drawn = _lines(root);
    for (final (text, bounds, _, _) in texts) {
      for (final line in drawn) {
        final distance = _segmentToRect(line.start, line.end, bounds);
        if (distance < line.reach) {
          cramped.add(
            CrampedText(
              text,
              Rect.fromPoints(line.start, line.end).inflate(line.reach),
              EdgeInsets.all(distance),
              line.owner,
              ink: CrampedInk.line,
            ),
          );
        }
      }
    }
  }

  if (icons) {
    for (final icon in _icons(root)) {
      final ink = icon.ink;
      var bounds = Rect.fromPoints(ink.first, ink.first);
      for (final point in ink) {
        bounds = bounds.expandToInclude(Rect.fromPoints(point, point));
      }
      bounds = bounds.inflate(icon.reach * icon.scale);
      final enclosing = _enclosing(borders, bounds);
      if (enclosing == null) continue;
      final (border, owner, whole, circle) = enclosing;
      final EdgeInsets gaps;
      if (circle != null) {
        // Measured along the curve: a round icon's bounding box would poke
        // into a circle the ink itself clears.
        final radius = whole.shortestSide * circle / 2;
        final farthest = ink
            .map((point) => (point - whole.center).distance)
            .reduce(math.max);
        gaps = EdgeInsets.all(
          (radius - farthest - icon.reach * icon.scale) / icon.scale,
        );
      } else {
        // As for text, a side of the shape that a clip has cut off, such as
        // a chip scrolled half under an app bar, shows nothing to crowd.
        double gap(double value, {required bool cut}) =>
            cut ? double.infinity : value / icon.scale;
        gaps = EdgeInsets.fromLTRB(
          gap(bounds.left - border.left, cut: border.left > whole.left + .5),
          gap(bounds.top - border.top, cut: border.top > whole.top + .5),
          gap(
            border.right - bounds.right,
            cut: border.right < whole.right - .5,
          ),
          gap(
            border.bottom - bounds.bottom,
            cut: border.bottom < whole.bottom - .5,
          ),
        );
      }
      final least = [
        gaps.left,
        gaps.top,
        gaps.right,
        gaps.bottom,
      ].reduce(math.min);
      if (least < iconGap - .5) {
        cramped.add(
          CrampedText('icon', border, gaps, owner, ink: CrampedInk.icon),
        );
      }
    }
  }
  return cramped;
}

/// Paragraphs squeezed into a narrow column, [lines] lines or more in less
/// than [width] pixels: the sign of a layout that should reflow, such as
/// actions that ought to move below their message on a phone.
List<String> squeezedText(
  RenderObject root, {
  double width = 140,
  int lines = 4,
}) {
  final squeezed = <String>[];
  void visit(RenderObject node) {
    if (node is RenderParagraph && node.hasSize && node.size.width < width) {
      final text = node.text.toPlainText();
      final boxes = node.getBoxesForSelection(
        TextSelection(baseOffset: 0, extentOffset: text.length),
      );
      final rows = {for (final box in boxes) box.top.round()};
      if (rows.length >= lines) {
        squeezed.add(
          '"${text.length > 32 ? '${text.substring(0, 31)}…' : text}" '
          'in ${node.size.width.round()} px over ${rows.length} lines',
        );
      }
    }
    node.visitChildren(visit);
  }

  visit(root);
  return squeezed;
}
