import 'package:flutter/widgets.dart';

import 'wired_palette.dart';

/// Default border color when no theme is provided.
///
/// Internal to the library; exposed through [WiredBase]'s defaults rather than
/// the public barrel. Matches the branded plum ink of [WiredPalette.ink].
const Color kWiredDefaultBorderColor = WiredPalette.ink;

/// Default fill color when no theme is provided.
///
/// Internal to the library; exposed through [WiredBase]'s defaults rather than
/// the public barrel. Matches the warm paper of [WiredPalette.paper].
const Color kWiredDefaultFillColor = WiredPalette.paper;

/// The least height of a skribble button. Buttons grow past it when their
/// label does, such as with a larger font or the platform's text scaling.
const double kWiredButtonHeight = 42.0;

/// The least height of a skribble chip. Chips grow past it with their label.
const double kWiredChipHeight = 36.0;

/// The least space between a hand-drawn line and the content inside it.
///
/// Ink wobbles and has width, so content needs more room from a sketched
/// border than from a straight one: 8 pixels above and below and 12 at the
/// sides. Every skribble control keeps at least this much space around its
/// content and grows to keep it as the content grows.
const EdgeInsets kWiredInkPadding = EdgeInsets.symmetric(
  horizontal: 12,
  vertical: 8,
);

/// The space inside a button or a chip: [kWiredInkPadding], a little wider
/// so a label reads as something to press.
const EdgeInsets kWiredButtonPadding = EdgeInsets.symmetric(
  horizontal: 16,
  vertical: 8,
);

/// Utility class with default Paint objects for wired widgets.
class WiredBase {
  /// Returns the standard fill paint used by hand-drawn shapes.
  ///
  /// The paint is stroked rather than filled: standalone fillers receive it to
  /// draw their hachure, dots, or solid wash inside a shape.
  static Paint fillPainter(Color color) {
    return Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2;
  }

  /// Returns the standard outline paint used by hand-drawn shapes.
  ///
  /// [strokeWidth] is the pen width in logical pixels; [color] defaults to the
  /// built-in border color used when no theme is present.
  static Paint pathPainter(
    double strokeWidth, {
    Color color = kWiredDefaultBorderColor,
  }) {
    return Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth;
  }
}
