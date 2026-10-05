import 'dart:ui';

/// Warm paper, plum ink, and quiet accent washes shared with the Figma kit.
abstract final class WiredPalette {
  /// The light background.
  static const paper = Color(0xFFFFFAF0);

  /// The dark background.
  static const night = Color(0xFF292331);

  /// The light foreground and outline.
  static const ink = Color(0xFF34283F);

  /// A pale purple accent wash.
  static const lilac = Color(0xFFE5DDF4);

  /// A warm pink accent wash.
  static const peach = Color(0xFFF6DFD5);

  /// A pale green accent wash.
  static const sage = Color(0xFFDDEAD9);

  /// A soft yellow accent wash.
  static const butter = Color(0xFFF6E8AF);

  /// Secondary text on light paper.
  static const mutedInk = Color(0xFF736678);

  /// Secondary text on dark paper.
  static const mutedPaper = Color(0xFFB9ACBF);

  /// A deep plum wash: the evening marker under selections on [night].
  static const dusk = Color(0xFF4A3B5E);

  /// A bold warm coral accent (stamp ink), used for primary actions.
  static const coral = Color(0xFFE87960);

  /// Rosy cheeks: the blush on the logo's face and on happy emoji.
  static const blush = Color(0xFFF59C9C);
}
