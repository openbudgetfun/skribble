import 'package:skribble_emoji/src/emoji_palette.dart';

/// The side of the default person an emoji depicts, for art that is drawn
/// once with alternative hair.
enum EmojiVariant {
  /// A person of unspecified gender.
  person,

  /// A man.
  man,

  /// A woman.
  woman,
}

/// One drawn layer of an emoji, in a 36-unit square.
///
/// Shapes paint in order. A shape with a [fill] lays down marker colour, and a
/// shape with a [stroke] is inked with the theme pen at [width] units.
final class EmojiShape {
  /// Creates a shape from SVG path data [d].
  const EmojiShape(
    this.d, {
    this.fill,
    this.stroke,
    this.width = 2,
    this.part,
    this.variant,
    this.clip,
    this.evenOdd = false,
  });

  /// SVG path data in the 36-unit square, using only M, L, C, and Z.
  final String d;

  /// Marker colour for the enclosed area, or null for none.
  final EmojiPaint? fill;

  /// Ink colour for the outline, or null for none.
  final EmojiPaint? stroke;

  /// Pen width in units of the 36-unit square.
  final double width;

  /// The named part this shape belongs to, such as `eyes` or `hand`.
  ///
  /// Animations move, turn, and scale parts as rigid groups.
  final String? part;

  /// When set, this shape is drawn only for that variant.
  final EmojiVariant? variant;

  /// SVG path data the shape is clipped to, or null.
  final String? clip;

  /// Whether [d] fills with the even-odd rule.
  final bool evenOdd;
}

/// A drawing in skribble's emoji style: shapes in a 36-unit square.
final class EmojiArt {
  /// Creates art from its [shapes] in paint order.
  const EmojiArt(this.shapes);

  /// The shapes, in paint order.
  final List<EmojiShape> shapes;

  /// The distinct named parts in this drawing.
  Set<String> get parts => {
    for (final shape in shapes) ?shape.part,
  };
}
