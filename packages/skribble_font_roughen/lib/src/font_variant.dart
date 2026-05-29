/// Font variant options for roughened output.
///
/// Each variant specifies the weight and style properties that will be
/// applied to the roughened font output.
enum FontVariant {
  /// Regular weight, upright style.
  regular('Regular', 'Regular', 0),

  /// Bold weight, upright style.
  bold('Bold', 'Bold', 0),

  /// Regular weight, italic style.
  italic('Regular', 'Italic', -12),

  /// Bold weight, italic style.
  boldItalic('Bold', 'Bold Italic', -12);

  /// The weight name (Regular or Bold).
  final String weight;

  /// The full name suffix for the font.
  final String fullNameSuffix;

  /// The italic angle in degrees (0 for upright).
  final int italicAngle;

  const FontVariant(this.weight, this.fullNameSuffix, this.italicAngle);

  /// Returns the font name for this variant.
  String get fontName => 'Skribble-$name';

  /// Returns the full font name for this variant.
  String get fullName => 'Skribble $fullNameSuffix';
}
