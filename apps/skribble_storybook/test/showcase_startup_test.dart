import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_storybook/main.dart' as storybook;

void main() {
  testWidgets(
    'startup paints rough icons and bundles every requested font family',
    (tester) async {
      clearWiredIconCatalog();
      addTearDown(clearWiredIconCatalog);
      storybook.main();
      await tester.pumpAndSettle();
      final icons = find.byType(WiredIcon);
      expect(icons, findsWidgets);
      for (final icon in icons.evaluate()) {
        expect(
          find.descendant(
            of: find.byElementPredicate((element) => element == icon),
            matching: find.byType(WiredSvgIcon),
          ),
          findsOneWidget,
        );
      }
      final manifest = (jsonDecode(
        await rootBundle.loadString('FontManifest.json'),
      ) as List<Object?>).cast<Map<String, Object?>>();
      final families = manifest.map((entry) => entry['family']).toSet();
      for (final roughness in WiredRoughness.values) {
        for (final font in WiredFont.values) {
          expect(
            families,
            contains(
              'packages/skribble_font_recursive/${font.familyFor(roughness)}',
            ),
          );
        }
        expect(
          families,
          contains(
            'packages/skribble_font_recursive/${WiredFont.variableFamilyFor(roughness)}',
          ),
        );
      }
      await tester.tap(find.text('Mono'));
      await tester.pumpAndSettle();
      expect(
        DefaultTextStyle.of(tester.element(find.text('Ink style')))
            .style
            .fontFamily,
        'packages/skribble_font_recursive/SkribbleMonoPlayful',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
