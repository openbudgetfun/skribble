import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/generate_material_rough_icons.dart' as tool;

void main() {
  test('supportedIconKitsForTest includes built-in providers', () {
    final kits = tool.supportedIconKitsForTest();
    expect(kits, contains('flutter-material'));
    expect(kits, contains('svg-manifest'));
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

  test(
    'renderFontCodePointsDartForTest renders stable helper names and order',
    () {
      final rendered = tool.renderFontCodePointsDartForTest(
        fontName: 'my-rough-icons',
        codePoints: <String, int>{
          'zeta': 0xe200,
          'beta': 0xe100,
          'alpha': 0xe100,
        },
      );

      expect(
        rendered,
        contains('const String kMyRoughIconsFontFamily = "my-rough-icons";'),
      );
      expect(
        rendered,
        contains('IconData? lookupMyRoughIconsIconData(String identifier) {'),
      );

      final alphaIndex = rendered.indexOf('"alpha": 0xe100');
      final betaIndex = rendered.indexOf('"beta": 0xe100');
      final zetaIndex = rendered.indexOf('"zeta": 0xe200');

      expect(alphaIndex, isNonNegative);
      expect(betaIndex, greaterThan(alphaIndex));
      expect(zetaIndex, greaterThan(betaIndex));
    },
  );

  group('parseSvgManifestDeclarationsForTest', () {
    late Directory tempDirectory;

    setUp(() {
      tempDirectory = Directory.systemTemp.createTempSync(
        'rough-icon-manifest-test-',
      );
    });

    tearDown(() {
      tempDirectory.deleteSync(recursive: true);
    });

    test('parses object format and resolves relative svgPath', () {
      final iconsDirectory = Directory('${tempDirectory.path}/icons')
        ..createSync(recursive: true);
      final heartSvgFile = File('${iconsDirectory.path}/heart.svg')
        ..writeAsStringSync(
          '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
        );

      final parsed = tool.parseSvgManifestDeclarationsForTest('''
{
  "icons": [
    {
      "identifier": "heart",
      "codePoint": "0xe001",
      "svgPath": "icons/heart.svg"
    }
  ]
}
''', manifestDirectoryPath: tempDirectory.path);

      expect(parsed, hasLength(1));
      expect(parsed.single.identifier, 'heart');
      expect(parsed.single.codePoint, 0xe001);
      expect(parsed.single.svgPath, heartSvgFile.path);
    });

    test('parses list format and supports svg alias key', () {
      final starSvgFile = File('${tempDirectory.path}/star.svg')
        ..writeAsStringSync(
          '<svg viewBox="0 0 24 24"><path d="M2 2h20v20H2z"/></svg>',
        );

      final parsed = tool.parseSvgManifestDeclarationsForTest('''
[
  {
    "identifier": "star",
    "codePoint": 57346,
    "svg": "star.svg"
  }
]
''', manifestDirectoryPath: tempDirectory.path);

      expect(parsed, hasLength(1));
      expect(parsed.single.identifier, 'star');
      expect(parsed.single.codePoint, 57346);
      expect(parsed.single.svgPath, starSvgFile.path);
    });

    test('throws when identifiers are duplicated', () {
      File('${tempDirectory.path}/one.svg').writeAsStringSync(
        '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
      );
      File('${tempDirectory.path}/two.svg').writeAsStringSync(
        '<svg viewBox="0 0 24 24"><path d="M2 2h20v20H2z"/></svg>',
      );

      expect(
        () => tool.parseSvgManifestDeclarationsForTest('''
[
  {
    "identifier": "dup",
    "codePoint": "0xe001",
    "svgPath": "one.svg"
  },
  {
    "identifier": "dup",
    "codePoint": "0xe002",
    "svgPath": "two.svg"
  }
]
''', manifestDirectoryPath: tempDirectory.path),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('duplicate identifiers'),
          ),
        ),
      );
    });

    test('throws when codePoints are duplicated', () {
      File('${tempDirectory.path}/one.svg').writeAsStringSync(
        '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
      );
      File('${tempDirectory.path}/two.svg').writeAsStringSync(
        '<svg viewBox="0 0 24 24"><path d="M2 2h20v20H2z"/></svg>',
      );

      expect(
        () => tool.parseSvgManifestDeclarationsForTest('''
[
  {
    "identifier": "alpha",
    "codePoint": "0xe001",
    "svgPath": "one.svg"
  },
  {
    "identifier": "beta",
    "codePoint": "0xe001",
    "svgPath": "two.svg"
  }
]
''', manifestDirectoryPath: tempDirectory.path),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('duplicate codePoints'),
          ),
        ),
      );
    });
  });
}
