import 'dart:io';
import 'dart:math' as math;

import 'package:skribble_font_roughen/skribble_font_roughen.dart';
import 'package:skribble_font_roughen/src/truetype_font.dart';

/// Builds review-only Casual and Code families, leaving bundled fonts intact.
/// Run from the repository root with FontForge on PATH.
Future<void> main() async {
  const output = '.screenshots/font-exploration';
  const source = 'packages/skribble/tool/font';
  await Directory(output).create(recursive: true);
  await File('$source/RECURSIVE-OFL.txt').copy('$output/OFL.txt');
  await File('$output/README.txt').writeAsString('''
Skribble font exploration

SkribblePetal: experimental Casual lettering with liga text joins,
dlig decorative joins, and optional swsh curls on a e h k m n r t u.
SkribbleCode: hand-drawn Recursive Code Casual with calt operators.
Each family includes Regular, Bold, Italic, and Bold Italic TTF files.

Install the TTFs using your operating system's font manager.
VS Code settings for the Code family:
  "editor.fontFamily": "'SkribbleCode', monospace",
  "editor.fontLigatures": true

The Casual swashes are a first Latin design pass, not flourishes for
every character. These experiments do not replace shipped defaults.
All four styles were checked with HarfBuzz; individual editors still
need installation, cursor and rendering checks.

Derived from Recursive 1.085 by Arrow Type, under SIL OFL 1.1.
Keep OFL.txt with the font files when redistributing them.
Source: https://github.com/arrowtype/recursive
Project: https://github.com/openbudgetfun/skribble
''');

  for (final variant in FontVariant.values) {
    final suffix = variant.fullNameSuffix.replaceAll(' ', '');
    await FontRoughener(
      inputPath: '$source/RecMonoCasual-$suffix.ttf',
      outputPath: '$output/SkribbleCode-$suffix.ttf',
      familyName: 'SkribbleCode',
      jitterAmount: 22,
      variant: variant,
    ).roughen();

    await _casual(source, output, variant);
  }

  stdout.writeln('Built eight experimental faces in $output');
}

/// Draws new outlines and OpenType text ligatures with FontForge as compiler.
Future<void> _casual(String source, String output, FontVariant variant) async {
  final suffix = variant.fullNameSuffix.replaceAll(' ', '');
  final sfdPath = '$output/casual-$suffix.sfd';
  final italic =
      variant == FontVariant.italic || variant == FontVariant.boldItalic;
  final bold = variant == FontVariant.bold || variant == FontVariant.boldItalic;
  const prepare = r'''
Open($1);
Select("a.italic"); Copy(); Select("a"); Paste();
Select("g.italic"); Copy(); Select("g"); Paste();
SelectAll(); UnlinkReference(); ClearInstrs(); ClearHints();
SetFontOrder(3); Save($2);
''';
  await _fontforge([
    '-lang=ff',
    '-c',
    prepare,
    '$source/RecursiveSansCslSt-$suffix.ttf',
    sfdPath,
  ]);
  var sfd = await File(sfdPath).readAsString();
  // Source italic fi/ffi must not consume input before our new liga lookup.
  final removeOldLigatures = sfd
      .split('\n')
      .where(
        (line) =>
            line.startsWith('Lookup:') &&
            (line.contains("['liga'") || line.contains("['rvrn'")),
      )
      .map((line) => RegExp('"([^"]+)"').firstMatch(line)![1]!)
      .map((lookup) => 'RemoveLookup("$lookup");')
      .join('\n');
  final glyphPattern = RegExp(r'StartChar: ([^\n]+)\n.*?EndChar', dotAll: true);
  final glyphs = <String, String>{
    for (final match in glyphPattern.allMatches(sfd)) match[1]!: match[0]!,
  };
  final splines = RegExp(r'SplineSet\n(.*?)EndSplineSet', dotAll: true);

  // The variable-source instances retain required substitutions (e.g. l.sans).
  // Bake their selected outlines before drawing new ligatures and swashes, so
  // rvrn cannot redirect letters away from the prototype's authored glyphs.
  final selectedOutlines = Map<String, String>.of(glyphs);
  final variation = RegExp(r'''Substitution2: "[^"\n]*'rvrn'[^"\n]*" (\S+)''');
  final advance = RegExp(r'Width: \d+');
  for (final entry in selectedOutlines.entries) {
    final target = variation.firstMatch(entry.value)?[1];
    if (target == null) continue;
    final selected = selectedOutlines[target]!;
    glyphs[entry.key] = entry.value
        .replaceFirst(splines, splines.firstMatch(selected)![0]!)
        .replaceFirst(advance, advance.firstMatch(selected)![0]!);
  }

  for (final entry in glyphs.entries.toList()) {
    final phase = entry.key.codeUnits.fold(0, (a, b) => a + b) * 1.618;
    glyphs[entry.key] = entry.value.replaceAllMapped(splines, (match) {
      return 'SplineSet\n${_transform(match[1]!, phase)}EndSplineSet';
    });
  }

  // A looped ascender gives the family a distinct, drawn pen gesture.
  final lStroke = _stroke(
    [
      const math.Point(123, 120),
      const math.Point(202, 374),
      const math.Point(260, 646),
      const math.Point(229, 735),
      const math.Point(153, 674),
      const math.Point(127, 451),
      const math.Point(125, 179),
      const math.Point(175, 42),
      const math.Point(291, 76),
    ],
    bold ? 55 : 35,
    slant: italic ? 0.15 : 0,
  );
  glyphs['l'] = glyphs['l']!.replaceFirst(
    splines,
    'SplineSet\n${lStroke}EndSplineSet',
  );

  final counts = RegExp(r'BeginChars: (\d+) (\d+)').firstMatch(sfd)!;
  var encoding = int.parse(counts[1]!);
  var glyphId = int.parse(counts[2]!);
  final added = StringBuffer();
  final addedNames = <String>['l'];
  final features = StringBuffer(
    'languagesystem DFLT dflt;\nlanguagesystem latn dflt;\n',
  );

  void addGlyph(String name, String outline, int width) {
    addedNames.add(name);
    added.writeln(
      'StartChar: $name\nEncoding: ${encoding++} -1 ${glyphId++}\n'
      'Width: $width\nFlags: W\nLayerCount: 2\nFore\nSplineSet\n'
      '${outline}EndSplineSet\nEndChar',
    );
  }

  String outline(String name) => splines.firstMatch(glyphs[name]!)![1]!;
  int width(String name) =>
      int.parse(RegExp(r'Width: (\d+)').firstMatch(glyphs[name]!)![1]!);

  features.writeln('feature liga {');

  // Longest matches precede pairs so ffi/ffl do not become ff + i/l.
  for (final letters in ['ffi', 'ffl', 'ff', 'fi', 'fl']) {
    final name = '${letters.split('').join('_')}.petal';
    final shape = StringBuffer();
    var advance = 0;

    for (final letter in letters.split('')) {
      shape.write(_translate(outline(letter), advance.toDouble()));
      advance += width(letter) - 44;
    }

    // A shared crossbar physically joins the letters, beyond substitution alone.
    shape.write(
      _stroke([
        const math.Point(130, 491),
        math.Point(advance * 0.48, 496),
        math.Point(advance - 75.0, 490),
      ], bold ? 38 : 26),
    );
    addGlyph(name, shape.toString(), advance + 44);
    features.writeln('sub ${letters.split('').join(' ')} by $name;');
  }

  features.writeln('} liga;\nfeature dlig {');

  for (final letters in ['ct', 'st', 'tt']) {
    final firstWidth = width(letters[0]);
    final name = '${letters.split('').join('_')}.petal';
    final bridge = _stroke([
      math.Point(firstWidth - 170.0, 475),
      math.Point(firstWidth - 60.0, 655),
      math.Point(firstWidth + 100.0, 741),
      math.Point(firstWidth + 180.0, 664),
    ], bold ? 31 : 20);
    addGlyph(
      name,
      outline(letters[0]) +
          _translate(outline(letters[1]), firstWidth - 30.0) +
          bridge,
      firstWidth + width(letters[1]) - 30,
    );
    features.writeln('sub ${letters.split('').join(' ')} by $name;');
  }

  features.writeln('} dlig;\nfeature swsh {');

  // These are explicit display alternates, not claimed as every Unicode glyph.
  for (final letter in 'aehkmnrtu'.split('')) {
    final advance = width(letter);
    final curl = _stroke([
      math.Point(advance - 110.0, 42),
      math.Point(advance - 30.0, -15),
      math.Point(advance + 45.0, 18),
      math.Point(advance + 62.0, 103),
      math.Point(advance + 6.0, 116),
    ], bold ? 27 : 18);
    addGlyph('$letter.petalSwash', outline(letter) + curl, advance + 70);
    features.writeln('sub $letter by $letter.petalSwash;');
  }

  features.writeln('} swsh;');
  sfd = sfd.replaceAllMapped(glyphPattern, (match) => glyphs[match[1]!]!);
  sfd = sfd.replaceFirst(counts[0]!, 'BeginChars: $encoding $glyphId');
  sfd = sfd.replaceFirst('EndChars', '${added}EndChars');
  await File(sfdPath).writeAsString(sfd);
  final featurePath = '$output/casual-$suffix.fea';
  await File(featurePath).writeAsString(features.toString());
  final compile =
      '''
Open(\$1);
$removeOldLigatures
MergeFeature(\$2);
Select(${addedNames.map((name) => '"$name"').join(',')});
RemoveOverlap();
SetFontNames("SkribblePetal-$suffix", "SkribblePetal", "SkribblePetal ${variant.fullNameSuffix}");
SelectAll(); CorrectDirection(); RoundToInt(); Generate(\$3);
''';
  await Directory('$output/compiled').create(recursive: true);
  final compiled = '$output/compiled/SkribblePetal-$suffix.ttf';
  await _fontforge([
    '-lang=ff',
    '-c',
    compile,
    sfdPath,
    featurePath,
    compiled,
  ]);
  // FontForge retains source typographic names. The existing writer updates
  // every platform's family/style records without deforming the new outlines.
  final font = TrueTypeFont(await File(compiled).readAsBytes());
  await File('$output/SkribblePetal-$suffix.ttf').writeAsBytes(
    font.encode(
      family: 'SkribblePetal',
      style: variant.fullNameSuffix,
      weight: bold ? 700 : 400,
      italic: italic,
    ),
  );
}

/// Gives every contour a restrained wave and a consistent per-glyph bounce.
String _transform(String outline, double phase) => _mapPoints(outline, (x, y) {
  final dx = 10 * math.sin(y / 170 + phase) + y * 0.015 * math.sin(phase);
  final dy = 9 * math.sin(x / 145 + phase) + 10 * math.sin(phase * 1.3);

  return math.Point(x + dx, y + dy);
});

/// Translates outline copies when building a single ligature glyph.
String _translate(String outline, double dx) =>
    _mapPoints(outline, (x, y) => math.Point(x + dx, y));

/// Maps only SFD path coordinates, leaving path flags untouched.
String _mapPoints(
  String outline,
  math.Point<double> Function(double, double) map,
) {
  final path = RegExp(
    r'^\s*((?:-?\d+(?:\.\d+)?\s+)+)([mlc]) (.*)$',
    multiLine: true,
  );

  return outline.replaceAllMapped(path, (match) {
    final numbers = match[1]!
        .trim()
        .split(RegExp(r'\s+'))
        .map(double.parse)
        .toList();
    final result = <String>[];

    for (var i = 0; i < numbers.length; i += 2) {
      final point = map(numbers[i], numbers[i + 1]);
      result.addAll([point.x.toStringAsFixed(2), point.y.toStringAsFixed(2)]);
    }

    return '${result.join(' ')} ${match[2]} ${match[3]}';
  });
}

/// Makes a closed, variable-width pen stroke along a Catmull-Rom centerline.
String _stroke(
  List<math.Point<double>> knots,
  double radius, {
  double slant = 0,
}) {
  final points = <math.Point<double>>[];

  for (var i = 0; i < knots.length - 1; i++) {
    final a = knots[math.max(0, i - 1)];
    final b = knots[i];
    final c = knots[i + 1];
    final d = knots[math.min(knots.length - 1, i + 2)];

    for (var step = 0; step <= 16; step++) {
      final t = step / 16;

      double interpolate(double a, double b, double c, double d) =>
          0.5 *
          (2 * b +
              (-a + c) * t +
              (2 * a - 5 * b + 4 * c - d) * t * t +
              (-a + 3 * b - 3 * c + d) * t * t * t);

      points.add(
        math.Point(
          interpolate(a.x, b.x, c.x, d.x),
          interpolate(a.y, b.y, c.y, d.y),
        ),
      );
    }
  }

  final left = <math.Point<double>>[];
  final right = <math.Point<double>>[];

  for (var i = 0; i < points.length; i++) {
    final tangent =
        points[math.min(i + 1, points.length - 1)] - points[math.max(0, i - 1)];
    final length = math.sqrt(tangent.x * tangent.x + tangent.y * tangent.y);
    final pressure =
        radius * (0.85 + 0.15 * math.sin(i / points.length * math.pi));
    final normal = math.Point(
      -tangent.y / length * pressure,
      tangent.x / length * pressure,
    );
    left.add(points[i] + normal);
    right.add(points[i] - normal);
  }

  final contour = [...left, ...right.reversed, left.first];

  return '${contour.indexed.map((entry) {
    final (i, p) = entry;
    return '${(p.x + slant * p.y).toStringAsFixed(2)} ${p.y.toStringAsFixed(2)} ${i == 0 ? 'm' : 'l'} 1';
  }).join('\n')}\n';
}

/// Runs FontForge without a shell and reports compiler failures verbatim.
Future<void> _fontforge(List<String> arguments) async {
  final result = await Process.run('fontforge', arguments);

  if (result.exitCode != 0) {
    throw ProcessException(
      'fontforge',
      arguments,
      '${result.stdout}\n${result.stderr}',
      result.exitCode,
    );
  }

  stdout.writeln('${arguments.last}: compiled');
}
