import 'dart:io';

import 'package:path/path.dart' as path;

/// Script to pre-roughen popular fonts for the Skribble design system.
///
/// This script downloads and roughens popular fonts, creating
/// hand-drawn variants for use in Skribble apps.
///
/// Usage:
///   dart run bin/roughen_fonts.dart [output_dir]
void main(List<String> arguments) async {
  final outputDir = arguments.isNotEmpty
      ? arguments[0]
      : 'packages/skribble/assets/fonts/roughened';

  print('Skribble Font Roughener - Pre-roughen Popular Fonts');
  print('===================================================');
  print('');
  print('Output directory: $outputDir');
  print('');

  // Create output directory
  final dir = Directory(outputDir);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  // Popular fonts to roughen
  final fonts = [
    _FontConfig(
      name: 'Inter',
      variants: ['Regular', 'Bold', 'Italic', 'BoldItalic'],
      sourceUrl: 'https://github.com/rsms/inter/releases/download/v4.0/Inter-4.0.zip',
    ),
    _FontConfig(
      name: 'Roboto',
      variants: ['Regular', 'Bold', 'Italic', 'BoldItalic'],
      sourceUrl: 'https://fonts.google.com/download?family=Roboto',
    ),
    _FontConfig(
      name: 'Open Sans',
      variants: ['Regular', 'Bold', 'Italic', 'BoldItalic'],
      sourceUrl: 'https://fonts.google.com/download?family=Open+Sans',
    ),
    _FontConfig(
      name: 'Lato',
      variants: ['Regular', 'Bold', 'Italic', 'BoldItalic'],
      sourceUrl: 'https://fonts.google.com/download?family=Lato',
    ),
    _FontConfig(
      name: 'Poppins',
      variants: ['Regular', 'Bold', 'Italic', 'BoldItalic'],
      sourceUrl: 'https://fonts.google.com/download?family=Poppins',
    ),
    _FontConfig(
      name: 'Source Sans Pro',
      variants: ['Regular', 'Bold', 'Italic', 'BoldItalic'],
      sourceUrl: 'https://fonts.google.com/download?family=Source+Sans+Pro',
    ),
  ];

  // Process each font
  for (final font in fonts) {
    print('Processing ${font.name}...');
    await _processFont(font, outputDir);
    print('');
  }

  print('Done! Roughened fonts saved to: $outputDir');
}

Future<void> _processFont(_FontConfig font, String outputDir) async {
  // TODO: Implement actual font downloading and processing
  // For now, create placeholder files

  for (final variant in font.variants) {
    final outputName = 'Skribble-${font.name.replaceAll(' ', '')}-$variant.ttf';
    final outputPath = path.join(outputDir, outputName);

    print('  - $variant -> $outputName');

    // Create placeholder file
    final file = File(outputPath);
    await file.writeAsString('Placeholder for ${font.name} $variant');

    // In a real implementation, we would:
    // 1. Download the font from font.sourceUrl
    // 2. Extract the TTF/OTF file
    // 3. Run FontRoughener on it
    // 4. Save the roughened version
  }
}

/// Configuration for a font to roughen.
class _FontConfig {
  final String name;
  final List<String> variants;
  final String sourceUrl;

  const _FontConfig({
    required this.name,
    required this.variants,
    required this.sourceUrl,
  });
}
