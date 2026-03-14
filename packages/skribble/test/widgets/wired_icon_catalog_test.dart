import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('materialRoughIconCodePoints', () {
    test('exposes generated rough icon codepoints', () {
      expect(materialRoughIconCodePoints, isNotEmpty);
      expect(materialRoughIconCodePoints, contains(Icons.search.codePoint));
    });
  });

  group('material rough icon identifier catalog', () {
    test('exposes identifiers and codepoint map', () {
      expect(materialRoughIconIdentifiers, isNotEmpty);
      expect(materialRoughIconIdentifiers, contains('search'));

      expect(materialRoughFontCodePoints, isNotEmpty);
      expect(materialRoughFontCodePoints['search'], Icons.search.codePoint);
    });

    test('looks up rough SVG icon data by identifier', () {
      final byIdentifier = lookupMaterialRoughIconByIdentifier('search');
      final byIconData = lookupMaterialRoughIcon(Icons.search);

      expect(byIdentifier, isNotNull);
      expect(byIdentifier, same(byIconData));
    });

    test('looks up generated font IconData by identifier', () {
      final icon = lookupMaterialRoughFontIcon('search');

      expect(icon, isNotNull);
      expect(icon!.codePoint, Icons.search.codePoint);
      expect(icon.fontFamily, materialRoughFontFamily);
      expect(materialRoughFontFamily, 'material_rough_icons');
    });

    test('returns null for unknown identifiers', () {
      expect(lookupMaterialRoughIconByIdentifier('does_not_exist'), isNull);
      expect(lookupMaterialRoughFontIcon('does_not_exist'), isNull);
    });
  });
}
