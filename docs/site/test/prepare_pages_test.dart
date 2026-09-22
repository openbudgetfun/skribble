import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/prepare_pages.dart' as pages;

void main() {
  test('release manifest keeps reading faces and defers comparison faces', () {
    final output = Directory.systemTemp.createTempSync('skribble-docs-fonts-');
    addTearDown(() => output.deleteSync(recursive: true));
    final assets = Directory('${output.path}/assets')..createSync();
    final manifest = File('${assets.path}/FontManifest.json');
    final deferred = File('${assets.path}/DeferredFontManifest.json');

    Map<String, Object> family(String name, {bool variable = false}) => {
      'family': name,
      'fonts': variable
          ? [
              {'asset': 'fonts/$name.ttf'},
            ]
          : [
              for (final weight in [300, 400, 500, 600, 700, 800, 900])
                for (final style in ['normal', 'italic'])
                  {
                    'weight': weight,
                    if (style == 'italic') 'style': style,
                    'asset': 'fonts/$name-$weight-$style.ttf',
                  },
            ],
    };

    manifest.writeAsStringSync(
      jsonEncode([
        family('MaterialIcons', variable: true),
        family('packages/skribble_font_recursive/SkribblePlayful'),
        family('packages/skribble_font_recursive/SkribbleMonoPlayful'),
        family('packages/skribble_font_recursive/SkribbleLinearPlayful'),
        family('packages/skribble_font_recursive/SkribbleVariablePlayful',
            variable: true),
        family('RecursiveCasualOriginal'),
      ]),
    );

    pages.deferComparisonFonts(output);

    final startup = (jsonDecode(manifest.readAsStringSync()) as List)
        .cast<Map<String, dynamic>>();
    final comparison = (jsonDecode(deferred.readAsStringSync()) as List)
        .cast<Map<String, dynamic>>();
    expect(startup.map((family) => family['family']), [
      'MaterialIcons',
      'packages/skribble_font_recursive/SkribblePlayful',
      'packages/skribble_font_recursive/SkribbleMonoPlayful',
    ]);
    expect(
      startup.skip(1).map((family) => (family['fonts'] as List).length),
      [7, 4],
    );
    expect(comparison.map((family) => family['family']), [
      'packages/skribble_font_recursive/SkribblePlayful',
      'packages/skribble_font_recursive/SkribbleMonoPlayful',
      'packages/skribble_font_recursive/SkribbleLinearPlayful',
      'packages/skribble_font_recursive/SkribbleVariablePlayful',
      'RecursiveCasualOriginal',
    ]);
    expect(
      comparison.map((family) => (family['fonts'] as List).length),
      [7, 10, 14, 1, 14],
    );

    final before = deferred.readAsStringSync();
    pages.deferComparisonFonts(output);
    expect(deferred.readAsStringSync(), before);
  });
}
