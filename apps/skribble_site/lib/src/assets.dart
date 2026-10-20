/// Artwork and fonts the landing page borrows from the rest of the
/// repository: the logo, emoji art, rough Lucide icons, and the bundled
/// font faces.
///
/// The page components only see these plain values, so tests can render the
/// page with small fixtures. `loadSiteAssets` in `build.dart` reads the real
/// files from the workspace.
library;

/// A hand-drawn emoji served as its own SVG file.
final class EmojiArt {
  /// Creates an emoji entry.
  const EmojiArt({required this.name, required this.svg});

  /// The art file's name, such as `grinning-face`.
  final String name;

  /// The self-contained SVG, with palette tokens resolved to colours.
  final String svg;

  /// Where the build writes [svg], relative to the site root.
  String get path => 'emoji/$name.svg';

  /// A readable label, such as `grinning face`.
  String get label => name.replaceAll('-', ' ');
}

/// A rough icon drawn with stroked paths on a square grid.
final class IconArt {
  /// Creates an icon entry.
  const IconArt({required this.name, required this.paths, this.size = 24});

  /// The icon's catalog name, such as `pencil`.
  final String name;

  /// Path data for each stroke.
  final List<String> paths;

  /// The width and height of the icon's grid.
  final double size;
}

/// One family of the bundled lettering.
final class LetteringFamily {
  /// Creates a family entry.
  const LetteringFamily({
    required this.label,
    required this.family,
    required this.package,
    required this.faces,
  });

  /// The name shown on the page, such as `Playful`.
  final String label;

  /// The CSS and Flutter family name, such as `SkribblePlayful`.
  final String family;

  /// The workspace package that bundles the family, such as
  /// `skribble_font_recursive`. Its `assets/fonts` folder holds the faces
  /// and the licence.
  final String package;

  /// The faces served for this family.
  final List<LetteringFace> faces;
}

/// A single font file and the CSS descriptors it is served under.
final class LetteringFace {
  /// Creates a face entry.
  const LetteringFace({
    required this.file,
    required this.weight,
    this.italic = false,
  });

  /// The TrueType file name in the package, such as
  /// `SkribblePlayful-Bold.ttf`.
  final String file;

  /// The web font the site serves for this face, such as
  /// `SkribblePlayful-Bold.woff`.
  String get webFile => '${file.substring(0, file.lastIndexOf('.'))}.woff';

  /// The CSS `font-weight`.
  final int weight;

  /// Whether this is an italic face.
  final bool italic;
}

/// The weights bundled for every family, by their file-name suffix.
const fontWeights = {
  'Light': 300,
  'Regular': 400,
  'Medium': 500,
  'SemiBold': 600,
  'Bold': 700,
  'ExtraBold': 800,
  'Black': 900,
};

/// Builds the faces the site serves for [family]: every upright weight and
/// the regular italic.
List<LetteringFace> facesFor(String family) => [
  for (final MapEntry(key: suffix, value: weight) in fontWeights.entries)
    LetteringFace(file: '$family-$suffix.ttf', weight: weight),
  LetteringFace(file: '$family-Italic.ttf', weight: 400, italic: true),
];

/// The package that bundles the Recursive-based families.
const recursivePackage = 'skribble_font_recursive';

/// The lettering families the page uses and shows off, the default first:
/// Skribble Noto Sketch, then the other Noto levels and the Recursive
/// families.
final List<LetteringFamily> fontFamilies = [
  for (final (label, family, package) in const [
    ('Noto Sketch', 'SkribbleNotoSketch', 'skribble_font_noto_sketch'),
    ('Noto', 'SkribbleNoto', 'skribble_font_noto'),
    ('Noto Lively', 'SkribbleNotoLively', 'skribble_font_noto_lively'),
  ])
    LetteringFamily(
      label: label,
      family: family,
      package: package,
      faces: [LetteringFace(file: '$family-Regular.ttf', weight: 400)],
    ),
  for (final (label, family) in const [
    ('Playful', 'SkribblePlayful'),
    ('Gentle', 'SkribbleGentle'),
    ('Expressive', 'Skribble'),
    ('Mono', 'SkribbleMonoPlayful'),
  ])
    LetteringFamily(
      label: label,
      family: family,
      package: recursivePackage,
      faces: facesFor(family),
    ),
];

/// The faces every page needs before it shows: Noto Sketch for the text,
/// headings, and labels (bold is synthesised from its one face), and Mono
/// for code. The page preloads them and waits for them, so the
/// first paint is already in skribble's hand.
const criticalFaces = [
  ('SkribbleNotoSketch', 'SkribbleNotoSketch-Regular.woff', 400),
  ('SkribbleMonoPlayful', 'SkribbleMonoPlayful-Regular.woff', 400),
];

/// The published licence for fonts from [package], under `fonts/`.
String licenceFile(String package) =>
    package == recursivePackage ? 'OFL.txt' : '$package-OFL.txt';

/// `@font-face` rules for [families], served from `fonts/`.
String fontFaceCss(List<LetteringFamily> families) {
  final css = StringBuffer();

  for (final family in families) {
    for (final face in family.faces) {
      css
        ..write('@font-face{font-family:"${family.family}";')
        ..write('src:url("fonts/${face.webFile}") format("woff");')
        ..write('font-weight:${face.weight};')
        ..write('font-style:${face.italic ? 'italic' : 'normal'};')
        ..write('font-display:swap}\n');
    }
  }

  return css.toString();
}

/// Everything the page needs from outside its own source.
final class SiteAssets {
  /// Creates the asset bundle.
  const SiteAssets({
    required this.logoSvg,
    required this.emoji,
    required this.emojiCount,
    required this.icons,
    required this.iconCount,
    required this.fonts,
  });

  /// The bracketed-smile logo, recoloured to `currentColor`.
  final String logoSvg;

  /// Emoji shown in the emoji wall.
  final List<EmojiArt> emoji;

  /// How many emoji skribble ships, for the headline number.
  final int emojiCount;

  /// Icons shown in the icon wall.
  final List<IconArt> icons;

  /// How many Lucide icons skribble ships, for the headline number.
  final int iconCount;

  /// The lettering families.
  final List<LetteringFamily> fonts;
}
