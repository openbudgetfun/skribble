import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:xml/xml.dart';

import '../../tool/design_kit.dart';

void main() {
  test(
    'export copies every font, notices and portable reduced-motion links',
    () async {
      final repository = Directory('../..');
      final destination = await Directory.systemTemp.createTemp(
        'skribble-kit-',
      );
      addTearDown(() => destination.delete(recursive: true));
      await exportDesignKit(repository, destination);
      final manifestFile = File('${destination.path}/manifest.json');
      final firstManifest = await manifestFile.readAsString();
      final manifest = jsonDecode(firstManifest) as Map<String, dynamic>;
      final fonts = manifest['fonts'] as List<dynamic>;
      expect(fonts, hasLength(36));

      for (final entry in fonts.cast<Map<String, dynamic>>()) {
        final name = (entry['file'] as String).split('/').last;
        expect(
          await File('${destination.path}/${entry['file']}').readAsBytes(),
          await File('${repository.path}/packages/skribble/assets/fonts/$name')
              .readAsBytes(),
        );
      }

      final notice = await File(
        '${repository.path}/packages/skribble/tool/font/RECURSIVE-OFL.txt',
      ).readAsString();
      expect(
        await File('${destination.path}/fonts/OFL.txt').readAsString(),
        notice,
      );
      expect(
        await File(
          '${repository.path}/apps/skribble_storybook/assets/fonts/OFL.txt',
        ).readAsString(),
        notice,
      );
      expect(
        await File('${destination.path}/LICENSE').readAsString(),
        await File('${repository.path}/LICENSE').readAsString(),
      );

      final specimens = manifest['specimens'] as List<dynamic>;
      expect(specimens, hasLength(18));

      for (final entry in specimens.cast<Map<String, dynamic>>()) {
        final reduced = File(
          '${destination.path}/${entry['reducedMotionFile']}',
        );
        final svg = XmlDocument.parse(await reduced.readAsString());
        expect(svg.findAllElements('animate'), isEmpty);
        expect(svg.findAllElements('image'), isEmpty);
        expect(svg.findAllElements('text'), isEmpty);
        expect(
          svg.rootElement.getAttribute('width'),
          '${entry['layoutWidth']}',
        );
        expect(
          svg.rootElement.getAttribute('height'),
          '${entry['layoutHeight']}',
        );
        expect(
          svg.findAllElements('g').map((g) => g.getAttribute('id')),
          containsAll(['ink', 'layout-bounds']),
        );
        expect(svg.findAllElements('path'), isNotEmpty);
      }

      await exportDesignKit(repository, destination);
      expect(await manifestFile.readAsString(), firstManifest);
    },
  );

  test('SVG paths match the runtime button geometry and pressure changes only width', () {
    for (final level in WiredRoughness.values) {
      final theme = WiredThemeData(roughnessLevel: level);
      final bleed = theme.inkExtent / 2;
      final expected = Generator(theme.drawConfig, NoFiller()).roundedRectangle(
        bleed,
        3 + bleed,
        160 - 2 * bleed,
        42 - 2 * bleed,
        6,
        6,
        6,
        6,
      );
      final rest = XmlDocument.parse(designSpecimens[0].svg(level));
      final pressed = XmlDocument.parse(designSpecimens[1].svg(level));
      final paths = rest.findAllElements('path').toList();
      expect(
        paths.map((p) => p.getAttribute('d')),
        pressed.findAllElements('path').map((p) => p.getAttribute('d')),
      );
      expect(paths.single.getAttribute('stroke-width'), '2.4');
      expect(
        pressed.findAllElements('path').single.getAttribute('stroke-width'),
        '3.0',
      );
      final coordinates = RegExp(r'-?\d+(?:\.\d+)?(?:e[+-]?\d+)?')
          .allMatches(paths.single.getAttribute('d')!)
          .map((m) => double.parse(m.group(0)!));
      expect(
        coordinates,
        expected.sets!.last.ops!.expand(
          (op) => op.data.expand((p) => [p.x, p.y]),
        ),
      );
      expect(designSpecimens[0].svg(level), designSpecimens[0].svg(level));
    }
  });

  test(
    'all specimen control points reserve room for the pen inside the frame',
    () {
      for (final level in WiredRoughness.values) {
        for (final specimen in designSpecimens) {
          final svg = XmlDocument.parse(specimen.svg(level));

          for (final path in svg.findAllElements('path')) {
            final halfPen =
                double.parse(path.getAttribute('stroke-width')!) / 2;
            final points = RegExp(r'-?\d+(?:\.\d+)?(?:e[+-]?\d+)?')
                .allMatches(path.getAttribute('d')!)
                .map((m) => double.parse(m.group(0)!))
                .toList();

            for (var i = 0; i < points.length; i += 2) {
              expect(
                points[i],
                inInclusiveRange(halfPen, specimen.width - halfPen),
                reason: '${level.name}/${specimen.name} x',
              );
              expect(
                points[i + 1],
                inInclusiveRange(halfPen, specimen.height - halfPen),
                reason: '${level.name}/${specimen.name} y',
              );
            }
          }
        }
      }
    },
  );
}
