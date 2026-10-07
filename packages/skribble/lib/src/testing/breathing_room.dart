import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../canvas/wired_painter.dart';
import '../rough/skribble_rough.dart';
import '../wired_paint.dart';
import '../wired_painter_bases.dart';

/// Text that sits too close to the hand-drawn line around it, found by
/// [crampedText].
final class CrampedText {
  /// Describes [text] at [gaps] from the [border] that [owner] drew.
  const CrampedText(this.text, this.border, this.gaps, this.owner);

  /// The skribble widget that drew [border].
  final String owner;

  /// The text, shortened.
  final String text;

  /// The hand-drawn border around it, in global coordinates.
  final Rect border;

  /// The space between the text's glyphs and each side of [border].
  final EdgeInsets gaps;

  @override
  String toString() {
    String gap(double value) => value.toStringAsFixed(1);
    return '$owner: "$text" in ${border.width.round()}×${border.height.round()}: '
        'left ${gap(gaps.left)}, top ${gap(gaps.top)}, '
        'right ${gap(gaps.right)}, bottom ${gap(gaps.bottom)}';
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

/// Every hand-drawn border on screen: rough box decorations and the shapes
/// skribble paints its controls in.
List<(Rect, String, Rect)> _borders(RenderObject root) {
  final borders = <(Rect, String, Rect)>[];
  void visit(RenderObject node) {
    final isBorder = switch (node) {
      RenderDecoratedBox(:final decoration) => decoration is RoughBoxDecoration,
      RenderCustomPaint(:final painter, :final foregroundPainter) =>
        _isShape(painter) || _isShape(foregroundPainter),
      _ => false,
    };
    if (isBorder && node is RenderBox && node.hasSize) {
      final whole = MatrixUtils.transformRect(
        node.getTransformTo(null),
        Offset.zero & node.size,
      );
      final rect = _clipped(node, whole);
      if (!rect.isEmpty) borders.add((rect, _owner(node), whole));
    }
    node.visitChildren(visit);
  }

  visit(root);
  return borders;
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
List<CrampedText> crampedText(
  RenderObject root, {
  double? vertical,
  double? horizontal,
}) {
  final minimumVertical = vertical ?? kWiredInkPadding.top;
  final minimumHorizontal = horizontal ?? kWiredInkPadding.left;
  final borders = _borders(root);
  final cramped = <CrampedText>[];
  for (final (text, bounds, uncut, scale) in _texts(root)) {
    Rect? border;
    var whole = Rect.zero;
    var owner = '?';
    for (final (candidate, name, uncut) in borders) {
      // The text lives in a border when most of it is inside; a neighbour
      // straddling the line belongs to something else.
      final inside = candidate.intersect(bounds);
      if (inside.width <= 0 ||
          inside.height <= 0 ||
          inside.width * inside.height < bounds.width * bounds.height / 2) {
        continue;
      }
      // The smallest border around the text is the one it lives in.
      if (border == null ||
          candidate.width * candidate.height < border.width * border.height) {
        border = candidate;
        whole = uncut;
        owner = name;
      }
    }
    // Badges and other micro labels keep their own tight pill; text that
    // lives in one is not measured against the larger shape around it.
    if (border == null || border.shortestSide <= 24) continue;
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
