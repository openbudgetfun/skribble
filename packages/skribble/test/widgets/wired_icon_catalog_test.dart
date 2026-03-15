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

    test('resolves committed supplemental fallback icons', () {
      final adobeByIdentifier = lookupMaterialRoughIconByIdentifier('adobe');
      final adobeByIconData = lookupMaterialRoughIcon(Icons.adobe);
      final faceUnlockByIdentifier = lookupMaterialRoughIconByIdentifier(
        'face_unlock_sharp',
      );
      final faceUnlockByIconData = lookupMaterialRoughIcon(
        Icons.face_unlock_sharp,
      );

      expect(adobeByIdentifier, isNotNull);
      expect(adobeByIdentifier, same(adobeByIconData));
      expect(faceUnlockByIdentifier, isNotNull);
      expect(faceUnlockByIdentifier, same(faceUnlockByIconData));

      final adobeFontIcon = lookupMaterialRoughFontIcon('adobe');
      final faceUnlockFontIcon = lookupMaterialRoughFontIcon(
        'face_unlock_sharp',
      );
      expect(adobeFontIcon, isNotNull);
      expect(faceUnlockFontIcon, isNotNull);
      expect(adobeFontIcon!.codePoint, Icons.adobe.codePoint);
      expect(faceUnlockFontIcon!.codePoint, Icons.face_unlock_sharp.codePoint);
    });

    test('returns null for unknown identifiers', () {
      expect(lookupMaterialRoughIconByIdentifier('does_not_exist'), isNull);
      expect(lookupMaterialRoughFontIcon('does_not_exist'), isNull);
    });
  });
}
