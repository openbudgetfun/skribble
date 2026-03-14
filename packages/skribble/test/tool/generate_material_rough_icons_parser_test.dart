import 'package:flutter_test/flutter_test.dart';

import '../../tool/generate_material_rough_icons.dart' as tool;

void main() {
  test('supportedIconKitsForTest includes flutter-material', () {
    expect(tool.supportedIconKitsForTest(), contains('flutter-material'));
  });

  group('parseFlutterIconDeclarationsForTest', () {
    test('parses canonical docs metadata', () {
      final declarations = tool.parseFlutterIconDeclarationsForTest('''
class Icons {
  /// The material icon named "abc".
  static const IconData abc = IconData(0xe001, fontFamily: 'MaterialIcons');

  /// The material icon named "alarm" (outlined).
  static const IconData alarm_outlined = IconData(0xe002, fontFamily: 'MaterialIcons');

  /// The material icon named "add alarm" (round).
  static const IconData add_alarm_rounded = IconData(0xe003, fontFamily: 'MaterialIcons');
}
''');

      expect(declarations, hasLength(3));

      expect(declarations[0].identifier, 'abc');
      expect(declarations[0].baseIdentifier, 'abc');
      expect(declarations[0].svgName, 'abc');
      expect(declarations[0].oldPackageFolder, 'filled');
      expect(declarations[0].symbolPackageFolder, 'outlined');
      expect(declarations[0].useSymbolFillVariant, isTrue);

      expect(declarations[1].identifier, 'alarm_outlined');
      expect(declarations[1].baseIdentifier, 'alarm');
      expect(declarations[1].svgName, 'alarm');
      expect(declarations[1].oldPackageFolder, 'outlined');
      expect(declarations[1].symbolPackageFolder, 'outlined');
      expect(declarations[1].useSymbolFillVariant, isFalse);

      expect(declarations[2].identifier, 'add_alarm_rounded');
      expect(declarations[2].baseIdentifier, 'add_alarm');
      expect(declarations[2].svgName, 'add_alarm');
      expect(declarations[2].oldPackageFolder, 'round');
      expect(declarations[2].symbolPackageFolder, 'rounded');
      expect(declarations[2].useSymbolFillVariant, isTrue);
    });

    test('falls back to identifier parsing when docs drift', () {
      final declarations = tool.parseFlutterIconDeclarationsForTest('''
class Icons {
  static const IconData browse_gallery = IconData(
    0xe100,
    fontFamily: 'MaterialIcons',
  );

  /// Some unrelated docs that do not include expected phrase.
  static const IconData image_search_sharp = IconData(0xe101, fontFamily: 'MaterialIcons');
}
''');

      expect(declarations, hasLength(2));

      expect(declarations[0].identifier, 'browse_gallery');
      expect(declarations[0].baseIdentifier, 'browse_gallery');
      expect(declarations[0].svgName, 'browse_gallery');
      expect(declarations[0].oldPackageFolder, 'filled');
      expect(declarations[0].symbolPackageFolder, 'outlined');

      expect(declarations[1].identifier, 'image_search_sharp');
      expect(declarations[1].baseIdentifier, 'image_search');
      expect(declarations[1].svgName, 'image_search');
      expect(declarations[1].oldPackageFolder, 'sharp');
      expect(declarations[1].symbolPackageFolder, 'sharp');
      expect(declarations[1].useSymbolFillVariant, isTrue);
    });
  });
}
