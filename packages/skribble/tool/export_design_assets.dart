import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:skribble/src/doodles/doodle_geometry.dart';
import 'package:skribble/src/rough/config.dart';
import 'package:skribble/src/rough/core.dart';
import 'package:skribble/src/rough/filler.dart';
import 'package:skribble/src/rough/generator.dart';
import 'package:skribble/src/wired_doodle_kind.dart';
import 'package:skribble/src/wired_roughness.dart';

/// Exports the same curves used by Flutter for Figma, GitHub, and browsers.
void main() {
  Directory('assets/brand').createSync(recursive: true);
  Directory('assets/flourishes').createSync(recursive: true);

  // The face takes the theme's marker colour on day and night paper, and
  // paper on lilac, where a lilac face would vanish.
  for (final variant in [
    (name: 'light', ink: '#34283F', face: '#E5DDF4', paper: '#FFFAF0'),
    (name: 'dark', ink: '#FFFAF0', face: '#4A3B5E', paper: '#292331'),
    (name: 'lilac', ink: '#34283F', face: '#FFFAF0', paper: '#E5DDF4'),
  ]) {
    File('assets/brand/skribble-${variant.name}.svg').writeAsStringSync(
      _logoSvg(ink: variant.ink, face: variant.face, background: variant.paper),
    );
    File(
      'assets/brand/skribble-${variant.name}-transparent.svg',
    ).writeAsStringSync(_logoSvg(ink: variant.ink, face: variant.face));
  }

  for (final kind in WiredDoodleKind.values) {
    for (final seed in [1, 8, 21]) {
      File('assets/flourishes/${kind.name}-$seed.svg').writeAsStringSync(
        _svg(doodleGeometry(kind, seed: seed, amplitude: 1.25), '#34283F'),
      );
    }
  }

  // Browsers show favicons tiny, so they get a stronger pen.
  final favicon = _logoSvg(
    ink: '#34283F',
    face: '#E5DDF4',
    background: '#FFFAF0',
    width: 6,
  );
  File('docs/site/web/favicon.svg').writeAsStringSync(favicon);
  File('apps/skribble_storybook/web/favicon.svg').writeAsStringSync(favicon);
  Directory('apps/skribble_storybook/web/icons').createSync(recursive: true);
  File('apps/skribble_storybook/web/icons/skribble.svg').writeAsStringSync(
    favicon,
  );
  // Maskable icons fill the square and keep the mark in the central safe zone.
  File(
    'apps/skribble_storybook/web/icons/skribble-maskable.svg',
  ).writeAsStringSync(
    _logoSvg(
      ink: '#34283F',
      face: '#E5DDF4',
      background: '#FFFAF0',
      width: 6,
      bleed: true,
    ),
  );

  final shapes = <String, Object>{};

  for (final spec in [
    (name: 'button', width: 160.0, height: 42.0, radius: 6.0),
    (name: 'input', width: 320.0, height: 56.0, radius: 8.0),
    (name: 'card', width: 320.0, height: 160.0, radius: 12.0),
    (name: 'checkbox', width: 27.0, height: 27.0, radius: 4.0),
    (name: 'switch', width: 60.0, height: 24.0, radius: 12.0),
    (name: 'chip', width: 112.0, height: 32.0, radius: 16.0),
    (name: 'swatch', width: 94.0, height: 72.0, radius: 12.0),
    (name: 'dialog', width: 400.0, height: 240.0, radius: 0.0),
    (name: 'text-area', width: 320.0, height: 120.0, radius: 0.0),
    (name: 'snack-bar', width: 400.0, height: 56.0, radius: 0.0),
    (name: 'tooltip', width: 160.0, height: 32.0, radius: 0.0),
    (name: 'menu', width: 240.0, height: 160.0, radius: 0.0),
    (name: 'segments', width: 320.0, height: 42.0, radius: 8.0),
    (name: 'search', width: 320.0, height: 48.0, radius: 24.0),
    (name: 'combo', width: 320.0, height: 60.0, radius: 0.0),
  ]) {
    for (final level in WiredRoughness.values) {
      final generator = Generator(
        DrawConfig.build(
          roughness: level.roughness,
          maxRandomnessOffset: level.maxRandomnessOffset,
          lineWobble: level.lineWobble,
        ),
        SolidFiller(FillerConfig.defaultConfig),
      );
      final inset = 2.4 / 2 + 1 + level.maxRandomnessOffset * level.roughness;
      final drawing = spec.radius == 0
          ? generator.rectangle(
              inset,
              inset,
              spec.width - 2 * inset,
              spec.height - 2 * inset,
            )
          : generator.roundedRectangle(
              inset,
              inset,
              spec.width - 2 * inset,
              spec.height - 2 * inset,
              spec.radius,
              spec.radius,
              spec.radius,
              spec.radius,
            );
      final path = drawing.sets!.last.ops!
          .map((op) {
            final points = op.data
                .map(
                  (p) => '${p.x.toStringAsFixed(3)} ${p.y.toStringAsFixed(3)}',
                )
                .join(' ');

            return '${switch (op.op) {
              OpType.move => 'M',
              OpType.lineTo => 'L',
              OpType.curveTo => 'C',
            }} $points';
          })
          .join(' ');
      shapes['${spec.name}/${level.name}'] = {
        'width': spec.width,
        'height': spec.height,
        'path': path,
        'fillPath': _svgOps(drawing.sets!.first.ops!),
      };
    }
  }

  for (final spec in [
    (name: 'thumb', size: 24.0, ratio: 1.0),
    (name: 'radio', size: 48.0, ratio: 0.7),
    (name: 'radio-dot', size: 24.0, ratio: 0.7),
    (name: 'icon-button', size: 48.0, ratio: 0.85),
    (name: 'fab', size: 56.0, ratio: 1.0),
    (name: 'avatar', size: 64.0, ratio: 1.0),
  ]) {
    for (final level in WiredRoughness.values) {
      final roughness = level.roughness * math.min(1.0, spec.size / 48);
      final inset = 2.4 / 2 + 1 + level.maxRandomnessOffset * roughness;
      final generator = Generator(
        DrawConfig.build(
          roughness: roughness,
          maxRandomnessOffset: level.maxRandomnessOffset,
          lineWobble: level.lineWobble,
        ),
        SolidFiller(FillerConfig.defaultConfig),
      );
      final drawing = generator.circle(
        spec.size / 2,
        spec.size / 2,
        (spec.size - 2 * inset) * spec.ratio,
      );
      final path = drawing.sets!.last.ops!
          .map((op) {
            final points = op.data
                .map(
                  (p) => '${p.x.toStringAsFixed(3)} ${p.y.toStringAsFixed(3)}',
                )
                .join(' ');
            return '${switch (op.op) {
              OpType.move => 'M',
              OpType.lineTo => 'L',
              OpType.curveTo => 'C',
            }} $points';
          })
          .join(' ');
      shapes['${spec.name}/${level.name}'] = {
        'width': spec.size,
        'height': spec.size,
        'path': path,
        'fillPath': _svgOps(drawing.sets!.first.ops!),
      };
    }
  }

  Directory('docs/design').createSync(recursive: true);
  File('docs/design/geometry.json').writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(shapes)}\n',
  );
  final assets = <String, String>{
    for (final file in Directory(
      'assets/flourishes',
    ).listSync().whereType<File>())
      file.uri.pathSegments.last: file.readAsStringSync(),
  };
  Directory('.screenshots/design').createSync(recursive: true);
  File('.screenshots/design/flourishes.json')
      .writeAsStringSync(jsonEncode(assets));
}

String _svgOps(List<Op> ops) => ops
    .map((op) {
      final points = op.data
          .map(
            (p) => '${p.x.toStringAsFixed(3)} ${p.y.toStringAsFixed(3)}',
          )
          .join(' ');
      return '${switch (op.op) {
        OpType.move => 'M',
        OpType.lineTo => 'L',
        OpType.curveTo => 'C',
      }} $points';
    })
    .join(' ');

/// The logo: a marker-filled face with rosy cheeks, inked in brackets.
///
/// Mirrors `WiredLogo`: the face sits a little off its outline, the way
/// every skribble marker fill does. [bleed] fills the whole square and
/// shrinks the mark into the safe zone of a maskable app icon.
String _logoSvg({
  required String ink,
  required String face,
  String? background,
  double width = 5.2,
  bool bleed = false,
}) {
  final rect = background == null
      ? ''
      : bleed
      ? '<rect width="100" height="100" fill="$background"/>'
      : '<rect width="100" height="100" rx="20" fill="$background"/>';
  final cheeks = logoCheekGeometry()
      .map((cheek) => '<path d="${cheek.svgPath}"/>')
      .join('\n');
  final strokes = logoGeometry()
      .map((stroke) => '<path d="${stroke.svgPath}"/>')
      .join('\n');
  return '''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 100 100" fill="none">
$rect
<g${bleed ? ' transform="translate(15 15) scale(.7)"' : ''}>
<path d="${logoFaceGeometry().svgPath}" fill="$face" transform="translate(1.4 1.2)"/>
<g fill="#F59C9C">
$cheeks
</g>
<g stroke="$ink" stroke-width="$width" stroke-linecap="round" stroke-linejoin="round">
$strokes
</g>
</g>
</svg>
''';
}

String _svg(
  List<DoodleStroke> strokes,
  String ink, {
  String? background,
  double width = 3.125,
}) =>
    '''
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 100 100" fill="none">
${background == null ? '' : '<rect width="100" height="100" rx="20" fill="$background"/>'}
<g stroke="$ink" stroke-width="$width" stroke-linecap="round" stroke-linejoin="round">
${strokes.map((stroke) => '<path d="${stroke.svgPath}"/>').join('\n')}
</g>
</svg>
''';
