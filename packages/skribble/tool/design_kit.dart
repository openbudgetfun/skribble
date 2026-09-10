import 'dart:convert';
import 'dart:io';

import 'package:skribble/src/rough/config.dart';
import 'package:skribble/src/rough/core.dart';
import 'package:skribble/src/rough/filler.dart';
import 'package:skribble/src/rough/generator.dart';
import 'package:skribble/src/wired_font.dart';
import 'package:skribble/src/wired_roughness.dart';

/// Exports the bundled fonts and editable pen specimens from repository root.
Future<void> main(List<String> arguments) async {
  if (arguments.isNotEmpty) {
    stderr.writeln('Usage: dart run packages/skribble/tool/design_kit.dart');
    exitCode = 64;
    return;
  }

  await exportDesignKit(Directory.current, Directory('build/design-kit'));
  stdout.writeln('Design kit: build/design-kit/index.html');
}

/// Copies assets from [repository] into [destination], with a portable preview.
/// Existing kit files are replaced; unrelated files are left untouched.
Future<void> exportDesignKit(
  Directory repository,
  Directory destination,
) async {
  final fonts = Directory('${destination.path}/fonts');
  final specimens = Directory('${destination.path}/specimens');
  final fontRecords = <Map<String, Object>>[];
  final specimenRecords = <Map<String, Object>>[];
  final css = StringBuffer();
  final preview = StringBuffer();
  await fonts.create(recursive: true);
  await specimens.create(recursive: true);

  for (final font in WiredFont.values) {
    for (final level in WiredRoughness.values) {
      final family = font.familyFor(level);

      for (final style in ['Regular', 'Bold', 'Italic', 'BoldItalic']) {
        final filename = '$family-$style.ttf';
        final weight = style.startsWith('Bold') ? 700 : 400;
        final italic = style.endsWith('Italic');
        await File(
          '${repository.path}/packages/skribble/assets/fonts/$filename',
        ).copy('${fonts.path}/$filename');
        fontRecords.add({
          'file': 'fonts/$filename',
          'family': family,
          'style': style == 'BoldItalic' ? 'Bold Italic' : style,
          'postScriptName': '$family-$style',
          'weight': weight,
          'italic': italic,
        });
        css.writeln('''
@font-face { font-family: '$family'; src: url('fonts/$filename');
  font-weight: $weight; font-style: ${italic ? 'italic' : 'normal'}; }
''');
      }

      preview.writeln('''
<section style="font-family: '$family'"><h2>$family</h2>
<p>Little plans, big days. Café, piñata, £12.50, €42.</p>
<p><b>Bold 700</b> · <i>Italic 400</i> · <b><i>Bold Italic 700</i></b></p></section>
''');
    }
  }

  await File('${repository.path}/packages/skribble/assets/fonts/OFL.txt')
      .copy('${fonts.path}/OFL.txt');
  await File('${repository.path}/LICENSE').copy('${destination.path}/LICENSE');
  await File('${repository.path}/docs/site/content/reference/design-kit.md')
      .copy('${destination.path}/README.md');

  for (final level in WiredRoughness.values) {
    preview.writeln(
      '<h2>${level.name} pen specimens</h2><div class="specimens">',
    );

    for (final specimen in designSpecimens) {
      final file = '${level.name}-${specimen.name}.svg';
      await File('${specimens.path}/$file').writeAsString(specimen.svg(level));
      specimenRecords.add({
        'file': 'specimens/$file',
        'name': specimen.name,
        'roughness': level.name,
        'layoutWidth': specimen.width,
        'layoutHeight': specimen.height,
        'inkBox': [
          specimen.x,
          specimen.y,
          specimen.inkWidth,
          specimen.inkHeight,
        ],
        'pressed': specimen.pressed,
        'reducedMotionFile':
            'specimens/${level.name}-${specimen.pressed ? 'button' : specimen.name}.svg',
      });
      preview.writeln('''
<figure><img src="specimens/$file" alt="${specimen.name}">
<figcaption>${specimen.name} · ${specimen.width} × ${specimen.height}</figcaption></figure>
''');
    }

    preview.writeln('</div>');
  }

  await File('${destination.path}/manifest.json').writeAsString(
    '${const JsonEncoder.withIndent('  ').convert({
      'fonts': fontRecords,
      'specimens': specimenRecords,
      'motion': {'pressMs': 120, 'entryRevealMs': 650, 'revealOnce': true},
    })}\n',
  );
  await File('${destination.path}/index.html').writeAsString('''
<!doctype html><html lang="en"><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Skribble design kit</title><link rel="icon" href="data:,"><style>
$css
body { margin: 32px auto; padding: 0 24px; max-width: 1000px;
  background: #faf7ef; color: #1a2b3c; font-family: sans-serif; font-synthesis: none; }
h1 { font-size: 36px; } p { font-size: 20px; }
section { padding: 12px 0; border-bottom: 1px solid #d8d2c5; }
.specimens { display: flex; flex-wrap: wrap; align-items: center; gap: 24px; }
figure { margin: 12px 0; } figcaption { margin-top: 8px; font-size: 14px; }
img { max-width: 100%; } h2 { margin-top: 32px; }
</style><h1>Skribble design kit</h1>
<p>Editable ink, real lettering, steady layout.</p>
<p>Read <a href="README.md">README.md</a> for Figma setup, dimensions, motion and font notices.
All specimens show completed ink. Reduced motion uses the resting specimen.</p>
$preview
</html>
''');
}

/// Fixed design examples. Layout sizes are handoff choices, not widget minima.
const designSpecimens = [
  DesignSpecimen('button', 160, 48, y: 3, inkHeight: 42, radius: 6),
  DesignSpecimen(
    'button-pressed',
    160,
    48,
    y: 3,
    inkHeight: 42,
    radius: 6,
    pressed: true,
  ),
  DesignSpecimen('field', 280, 56),
  DesignSpecimen('card', 280, 130),
  DesignSpecimen('focus-ring', 168, 56, radius: 8),
  DesignSpecimen(
    'navigation-selected',
    72,
    80,
    x: 8,
    y: 17,
    inkWidth: 56,
    inkHeight: 28,
    radius: 14,
    hachure: true,
  ),
];

/// An editable pen specimen with independent layout and ink rectangles.
class DesignSpecimen {
  /// Defines [name], layout [width]/[height], and an optional inner ink box.
  /// [x] and [y] locate it; [inkWidth]/[inkHeight] default to the layout size.
  /// [radius] rounds corners; [pressed] reinforces the pen; [hachure] fills it.
  const DesignSpecimen(
    this.name,
    this.width,
    this.height, {
    this.x = 0,
    this.y = 0,
    double? inkWidth,
    double? inkHeight,
    this.radius = 0,
    this.pressed = false,
    this.hachure = false,
  }) : inkWidth = inkWidth ?? width,
       inkHeight = inkHeight ?? height;

  /// File and layer identifier.
  final String name;

  /// Layout frame width in logical pixels.
  final double width;

  /// Layout frame height in logical pixels.
  final double height;

  /// Ink box horizontal origin.
  final double x;

  /// Ink box vertical origin.
  final double y;

  /// Ink box width before reserving pen bleed.
  final double inkWidth;

  /// Ink box height before reserving pen bleed.
  final double inkHeight;

  /// Radius before the generator clamps it to fit the inset rectangle.
  final double radius;

  /// Whether this shows the fully pressed pen at 125 percent width.
  final bool pressed;

  /// Whether to include selected-navigation hatching.
  final bool hachure;

  /// Generates stable editable paths using the runtime engine for [level].
  String svg(WiredRoughness level) {
    final config = DrawConfig.build(
      roughness: level.roughness,
      maxRandomnessOffset: level.maxRandomnessOffset,
      lineWobble: level.lineWobble,
      seed: 1,
    );
    final filler = hachure
        ? HachureFiller(FillerConfig.build(drawConfig: config, hachureGap: 2))
        : NoFiller();
    final generator = Generator(config, filler);
    // Matches WiredBase's reserved bleed; pressure changes only pen width.
    final bleed = 2.4 / 2 + 1 + level.maxRandomnessOffset * level.roughness;
    final figure = generator.roundedRectangle(
      x + bleed,
      y + bleed,
      inkWidth - 2 * bleed,
      inkHeight - 2 * bleed,
      radius,
      radius,
      radius,
      radius,
    );
    final ink = StringBuffer();

    for (final set in figure.sets!) {
      if (set.ops!.isEmpty) continue;
      final path = StringBuffer();

      for (final op in set.ops!) {
        final command = switch (op.op) {
          OpType.move => 'M',
          OpType.lineTo => 'L',
          OpType.curveTo => 'C',
        };
        path.write('$command${op.data.map((p) => '${p.x} ${p.y}').join(' ')} ');
      }

      final stroke = set.type == OpSetType.fillSketch
          ? 2.0
          : (pressed ? 3.0 : 2.4);
      ink.writeln('<path d="$path" stroke-width="$stroke"/>');
    }

    return '''
<svg xmlns="http://www.w3.org/2000/svg" width="$width" height="$height" viewBox="0 0 $width $height">
<title>$name, ${level.name}</title>
<desc>Static completed ink. Layout frame is separate from painted geometry.</desc>
<g id="layout-bounds" fill="none" stroke="none"><rect width="$width" height="$height"/></g>
<g id="ink" fill="none" stroke="#1a2b3c" stroke-linecap="round" stroke-linejoin="round">
$ink</g>
</svg>
''';
  }
}
