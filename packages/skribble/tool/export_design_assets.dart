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

  for (final variant in [
    (name: 'light', ink: '#34283F', paper: '#FFFAF0'),
    (name: 'dark', ink: '#FFFAF0', paper: '#292331'),
    (name: 'lilac', ink: '#34283F', paper: '#E5DDF4'),
  ]) {
    final svg = _svg(
      logoGeometry(),
      variant.ink,
      background: variant.paper,
      width: 3.6,
    );
    File('assets/brand/skribble-${variant.name}.svg').writeAsStringSync(svg);
    File(
      'assets/brand/skribble-${variant.name}-transparent.svg',
    ).writeAsStringSync(_svg(logoGeometry(), variant.ink, width: 3.6));
  }

  for (final kind in WiredDoodleKind.values) {
    for (final seed in [1, 8, 21]) {
      File('assets/flourishes/${kind.name}-$seed.svg').writeAsStringSync(
        _svg(doodleGeometry(kind, seed: seed, amplitude: 1.25), '#34283F'),
      );
    }
  }

  File('docs/site/web/favicon.svg').writeAsStringSync(
    _svg(logoGeometry(), '#34283F', background: '#FFFAF0', width: 5),
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
