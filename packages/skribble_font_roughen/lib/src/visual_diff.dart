import 'dart:convert';
import 'dart:io';

import 'package:skribble_font_roughen/src/truetype_font.dart';

/// Creates a self-contained HTML specimen and measures changed outline points.
/// Open the specimen in a browser to inspect real font rasterization at the
/// requested size. The statistics compare outlines, not screenshot pixels.
class VisualDiff {
  /// Creates a comparison. [outputPath] must end in `.html`.
  const VisualDiff({
    required this.originalPath,
    required this.roughenedPath,
    required this.outputPath,
    this.sampleText = 'Hello, World! AaBbCc 123',
    this.fontSize = 24,
  });

  /// Original static TrueType font.
  final String originalPath;

  /// Roughened static TrueType font with matching glyph order.
  final String roughenedPath;

  /// Self-contained HTML output file.
  final String outputPath;

  /// Text used to compare the fonts.
  final String sampleText;

  /// Default specimen size in CSS pixels.
  final double fontSize;

  /// Writes the specimen and counts changed points across every glyph.
  Future<DiffResult> compare() async {
    if (!outputPath.endsWith('.html')) {
      throw ArgumentError('VisualDiff output must be .html.');
    }
    final before = await File(originalPath).readAsBytes();
    final after = await File(roughenedPath).readAsBytes();
    final original = TrueTypeFont(before);
    final rough = TrueTypeFont(after);
    if (original.glyphCount != rough.glyphCount) {
      throw ArgumentError('Glyph counts differ.');
    }
    var changed = 0;
    var total = 0;
    for (var id = 0; id < original.glyphCount; id++) {
      final a = original.glyphPoints(id);
      final b = rough.glyphPoints(id);
      if (a.length != b.length) {
        throw ArgumentError('Point counts differ in glyph $id.');
      }
      total += a.length;
      for (var point = 0; point < a.length; point++) {
        if (a[point] != b[point]) changed++;
      }
    }
    final sample = const HtmlEscape().convert(sampleText);
    final html =
        '''
<!doctype html><html lang="en"><meta charset="utf-8">
<title>Recursive Casual and Skribble</title><style>
@font-face{font-family:Source;src:url(data:font/ttf;base64,${base64Encode(before)})}
@font-face{font-family:Sketch;src:url(data:font/ttf;base64,${base64Encode(after)})}
body{margin:40px;background:#fffbef;color:#382d40;font:16px system-ui;max-width:1100px}
section{margin:32px 0;padding:24px;border:1px solid #c7b9c9}p{line-height:1.5;overflow-wrap:anywhere}
.source{font-family:Source}.sketch{font-family:Sketch}.sample{font-size:${fontSize}px}
</style><h1>Recursive Casual → Skribble</h1><p>$changed of $total outline points changed. Glyph order and advance widths are preserved.</p>
<section><h2>Original Recursive Casual</h2><p class="source sample">$sample</p></section>
<section><h2>Skribble, a gently uneven pen</h2><p class="sketch sample">$sample</p></section>
${[12, 16, 24, 36, 48].map((size) => '<p class="sketch" style="font-size:${size}px">${size}px · Café sketch, £12.50. Make something lovely!</p>').join()}
</html>''';
    await File(outputPath).parent.create(recursive: true);
    await File(outputPath).writeAsString(html);
    return DiffResult(
      originalPath: originalPath,
      roughenedPath: roughenedPath,
      outputPath: outputPath,
      differenceCount: changed,
      similarityScore: total == 0 ? 1 : 1 - changed / total,
    );
  }
}

/// Outline-change statistics accompanying a browser-renderable specimen.
class DiffResult {
  /// Creates comparison statistics.
  const DiffResult({
    required this.originalPath,
    required this.roughenedPath,
    required this.outputPath,
    required this.differenceCount,
    required this.similarityScore,
  });

  /// Original font path.
  final String originalPath;

  /// Roughened font path.
  final String roughenedPath;

  /// Generated HTML specimen path.
  final String outputPath;

  /// Number of changed outline points.
  final int differenceCount;

  /// Fraction of unchanged points, from zero to one. Not a perceptual score.
  final double similarityScore;
}
