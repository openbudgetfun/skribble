import 'dart:convert';
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

  group('runGenerateRoughIcons alias resolution', () {
    late Directory tempDirectory;

    setUp(() {
      tempDirectory = Directory.systemTemp.createTempSync(
        'rough-icon-alias-resolution-test-',
      );
    });

    tearDown(() {
      tempDirectory.deleteSync(recursive: true);
    });

    test(
      'resolves known Flutter alias names to available SVG sources',
      () async {
        final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
          ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "wifi tethering error rounded" (round).
  static const IconData wifi_tethering_error_rounded_rounded = IconData(0xf02c0, fontFamily: 'MaterialIcons');
}
''');

        final materialIconsRoot = Directory(
          '${tempDirectory.path}/material-icons',
        )..createSync(recursive: true);
        final materialSymbolsRoot = Directory(
          '${tempDirectory.path}/material-symbols',
        )..createSync(recursive: true);

        File('${materialIconsRoot.path}/filled/label.svg')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
          );
        File(
            '${materialSymbolsRoot.path}/rounded/wifi_tethering_error-fill.svg',
          )
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<svg viewBox="0 0 24 24"><path d="M2 2h20v20H2z"/></svg>',
          );

        final outputFile = File(
          '${tempDirectory.path}/material_rough_icons.g.dart',
        );

        await tool.runGenerateRoughIcons(<String>[
          '--kit',
          'flutter-material',
          '--flutter-icons',
          flutterIconsFile.path,
          '--material-icons-source',
          materialIconsRoot.path,
          '--material-symbols-source',
          materialSymbolsRoot.path,
          '--output',
          outputFile.path,
        ]);

        final generated = outputFile.readAsStringSync();
        expect(generated, contains('// label_outline'));
        expect(generated, contains('0xe364'));
        expect(generated, contains('// wifi_tethering_error_rounded_rounded'));
        expect(generated, contains('0xf02c0'));
      },
    );
  });

  group('runGenerateRoughIcons brand fallback', () {
    late Directory tempDirectory;

    setUp(() {
      tempDirectory = Directory.systemTemp.createTempSync(
        'rough-icon-brand-fallback-test-',
      );
    });

    tearDown(() {
      tempDirectory.deleteSync(recursive: true);
    });

    test(
      'resolves selected brand icons from simple-icons fallback source',
      () async {
        final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
          ..writeAsStringSync('''
class Icons {
  /// The material icon named "facebook".
  static const IconData facebook = IconData(0xe255, fontFamily: 'MaterialIcons');

  /// The material icon named "woo commerce" (outlined).
  static const IconData woo_commerce_outlined = IconData(0xf069f, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

        final materialIconsRoot = Directory(
          '${tempDirectory.path}/material-icons',
        )..createSync(recursive: true);
        final materialSymbolsRoot = Directory(
          '${tempDirectory.path}/material-symbols',
        )..createSync(recursive: true);
        final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
          ..createSync(recursive: true);

        File('${brandIconsRoot.path}/icons/facebook.svg')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<svg viewBox="0 0 24 24"><path d="M4 4h16v16H4z"/></svg>',
          );
        File('${brandIconsRoot.path}/icons/woocommerce.svg')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<svg viewBox="0 0 24 24"><path d="M6 6h12v12H6z"/></svg>',
          );

        final outputFile = File(
          '${tempDirectory.path}/material_rough_icons.g.dart',
        );

        await tool.runGenerateRoughIcons(<String>[
          '--kit',
          'flutter-material',
          '--flutter-icons',
          flutterIconsFile.path,
          '--material-icons-source',
          materialIconsRoot.path,
          '--material-symbols-source',
          materialSymbolsRoot.path,
          '--brand-icons-source',
          brandIconsRoot.path,
          '--output',
          outputFile.path,
        ]);

        final generated = outputFile.readAsStringSync();
        expect(generated, contains('// facebook'));
        expect(generated, contains('// woo_commerce_outlined'));
        expect(generated, contains('0xe255'));
        expect(generated, contains('0xf069f'));
        expect(generated, isNot(contains('// adobe')));
      },
    );
  });

  group('runGenerateRoughIcons supplemental manifest', () {
    late Directory tempDirectory;

    setUp(() {
      tempDirectory = Directory.systemTemp.createTempSync(
        'rough-icon-supplemental-manifest-test-',
      );
    });

    tearDown(() {
      tempDirectory.deleteSync(recursive: true);
    });

    test(
      'resolves unresolved declarations from supplemental manifest',
      () async {
        final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
          ..writeAsStringSync('''
class Icons {
  /// The material icon named "adobe" (outlined).
  static const IconData adobe_outlined = IconData(0xf05b4, fontFamily: 'MaterialIcons');

  /// The material icon named "face unlock" (sharp).
  static const IconData face_unlock_sharp = IconData(0xe951, fontFamily: 'MaterialIcons');
}
''');

        final materialIconsRoot = Directory(
          '${tempDirectory.path}/material-icons',
        )..createSync(recursive: true);
        final materialSymbolsRoot = Directory(
          '${tempDirectory.path}/material-symbols',
        )..createSync(recursive: true);
        final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
          ..createSync(recursive: true);

        File('${tempDirectory.path}/adobe.svg').writeAsStringSync(
          '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
        );
        File('${tempDirectory.path}/face_unlock.svg').writeAsStringSync(
          '<svg viewBox="0 0 24 24"><path d="M2 2h20v20H2z"/></svg>',
        );
        final supplementalManifestFile =
            File('${tempDirectory.path}/extra.json')..writeAsStringSync('''
{
  "icons": [
    {
      "identifier": "adobe_outlined",
      "codePoint": "0xf05b4",
      "svgPath": "adobe.svg"
    },
    {
      "identifier": "face_unlock_sharp",
      "codePoint": "0xe951",
      "svgPath": "face_unlock.svg"
    }
  ]
}
''');

        final outputFile = File(
          '${tempDirectory.path}/material_rough_icons.g.dart',
        );

        await tool.runGenerateRoughIcons(<String>[
          '--kit',
          'flutter-material',
          '--flutter-icons',
          flutterIconsFile.path,
          '--material-icons-source',
          materialIconsRoot.path,
          '--material-symbols-source',
          materialSymbolsRoot.path,
          '--brand-icons-source',
          brandIconsRoot.path,
          '--supplemental-manifest',
          supplementalManifestFile.path,
          '--output',
          outputFile.path,
        ]);

        final generated = outputFile.readAsStringSync();
        expect(generated, contains('// adobe_outlined'));
        expect(generated, contains('// face_unlock_sharp'));
        expect(generated, contains('0xf05b4'));
        expect(generated, contains('0xe951'));
      },
    );
  });

  group('runGenerateRoughIcons font Dart aliases', () {
    late Directory tempDirectory;

    setUp(() {
      tempDirectory = Directory.systemTemp.createTempSync(
        'rough-icon-font-aliases-test-',
      );
    });

    tearDown(() {
      tempDirectory.deleteSync(recursive: true);
    });

    test(
      'writes codepoint aliases for all declarations sharing a resolved codepoint',
      () async {
        final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
          ..writeAsStringSync('''
class Icons {
  /// The material icon named "radio button on".
  static const IconData radio_button_on = IconData(0xe503, fontFamily: 'MaterialIcons');

  /// The material icon named "radio button checked".
  static const IconData radio_button_checked = IconData(0xe503, fontFamily: 'MaterialIcons');
}
''');

        final materialIconsRoot = Directory(
          '${tempDirectory.path}/material-icons',
        )..createSync(recursive: true);
        final materialSymbolsRoot = Directory(
          '${tempDirectory.path}/material-symbols',
        )..createSync(recursive: true);
        final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
          ..createSync(recursive: true);

        File('${materialIconsRoot.path}/filled/radio_button_checked.svg')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
          );

        final outputFile = File(
          '${tempDirectory.path}/material_rough_icons.g.dart',
        );
        final fontOutputFile = File(
          '${tempDirectory.path}/material_rough_icon_font.g.dart',
        );

        await tool.runGenerateRoughIcons(<String>[
          '--kit',
          'flutter-material',
          '--flutter-icons',
          flutterIconsFile.path,
          '--material-icons-source',
          materialIconsRoot.path,
          '--material-symbols-source',
          materialSymbolsRoot.path,
          '--brand-icons-source',
          brandIconsRoot.path,
          '--font-dart-output',
          fontOutputFile.path,
          '--output',
          outputFile.path,
        ]);

        final generated = outputFile.readAsStringSync();
        final fontDart = fontOutputFile.readAsStringSync();

        expect(generated, contains('// radio_button_on'));
        expect(fontDart, contains("'radio_button_on': 0xe503"));
        expect(fontDart, contains("'radio_button_checked': 0xe503"));
      },
    );
  });

  group('runGenerateRoughIcons unresolved report', () {
    late Directory tempDirectory;

    setUp(() {
      tempDirectory = Directory.systemTemp.createTempSync(
        'rough-icon-unresolved-report-test-',
      );
    });

    tearDown(() {
      tempDirectory.deleteSync(recursive: true);
    });

    test('writes unresolved icon report JSON when requested', () async {
      final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
        ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

      final materialIconsRoot = Directory(
        '${tempDirectory.path}/material-icons',
      )..createSync(recursive: true);
      final materialSymbolsRoot = Directory(
        '${tempDirectory.path}/material-symbols',
      )..createSync(recursive: true);
      final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
        ..createSync(recursive: true);

      File('${materialIconsRoot.path}/filled/label.svg')
        ..createSync(recursive: true)
        ..writeAsStringSync(
          '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
        );

      final outputFile = File(
        '${tempDirectory.path}/material_rough_icons.g.dart',
      );
      final unresolvedReportFile = File(
        '${tempDirectory.path}/unresolved.json',
      );

      await tool.runGenerateRoughIcons(<String>[
        '--kit',
        'flutter-material',
        '--flutter-icons',
        flutterIconsFile.path,
        '--material-icons-source',
        materialIconsRoot.path,
        '--material-symbols-source',
        materialSymbolsRoot.path,
        '--brand-icons-source',
        brandIconsRoot.path,
        '--unresolved-output',
        unresolvedReportFile.path,
        '--output',
        outputFile.path,
      ]);

      expect(unresolvedReportFile.existsSync(), isTrue);

      final decoded =
          jsonDecode(unresolvedReportFile.readAsStringSync())
              as Map<String, dynamic>;
      expect(decoded['kit'], 'flutter-material');
      expect(decoded['resolvedCount'], 1);
      expect(decoded['unresolvedCount'], 1);
      expect(decoded['wouldFail'], isFalse);
      expect(decoded['unresolvedGateFailed'], isFalse);
      expect(decoded['newUnresolvedGateFailed'], isFalse);
      expect(decoded['activeGates'], <String>[]);
      expect(decoded['failedGates'], <String>[]);
      expect(decoded['unresolvedCodePoints'], <String>['0xf04b9']);
      expect(decoded['unresolvedThresholdMode'], 'disabled');
      expect(decoded['newUnresolvedThresholdMode'], 'disabled');
      expect(decoded.containsKey('maxUnresolved'), isFalse);
      expect(decoded.containsKey('maxUnresolvedExceeded'), isFalse);
      expect(decoded.containsKey('maxNewUnresolved'), isFalse);
      expect(decoded.containsKey('maxNewUnresolvedExceeded'), isFalse);

      final unresolved = decoded['unresolved'] as List<dynamic>;
      expect(unresolved, hasLength(1));

      final firstUnresolved = unresolved.first as Map<String, dynamic>;
      expect(firstUnresolved['codePoint'], '0xf04b9');
      expect(firstUnresolved['identifiers'], <String>['adobe']);

      final generated = outputFile.readAsStringSync();
      expect(generated, contains('// label_outline'));
      expect(generated, isNot(contains('// adobe')));
    });
  });

  group('runGenerateRoughIcons unresolved baseline output', () {
    late Directory tempDirectory;

    setUp(() {
      tempDirectory = Directory.systemTemp.createTempSync(
        'rough-icon-unresolved-baseline-output-test-',
      );
    });

    tearDown(() {
      tempDirectory.deleteSync(recursive: true);
    });

    test('writes normalized unresolved baseline JSON when requested', () async {
      final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
        ..writeAsStringSync('''
class Icons {
  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');

  /// The material icon named "face unlock" (sharp).
  static const IconData face_unlock_sharp = IconData(0xe951, fontFamily: 'MaterialIcons');
}
''');

      final materialIconsRoot = Directory(
        '${tempDirectory.path}/material-icons',
      )..createSync(recursive: true);
      final materialSymbolsRoot = Directory(
        '${tempDirectory.path}/material-symbols',
      )..createSync(recursive: true);
      final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
        ..createSync(recursive: true);

      final outputFile = File(
        '${tempDirectory.path}/material_rough_icons.g.dart',
      );
      final unresolvedBaselineFile = File(
        '${tempDirectory.path}/unresolved-baseline.json',
      );

      await tool.runGenerateRoughIcons(<String>[
        '--kit',
        'flutter-material',
        '--flutter-icons',
        flutterIconsFile.path,
        '--material-icons-source',
        materialIconsRoot.path,
        '--material-symbols-source',
        materialSymbolsRoot.path,
        '--brand-icons-source',
        brandIconsRoot.path,
        '--unresolved-baseline-output',
        unresolvedBaselineFile.path,
        '--output',
        outputFile.path,
      ]);

      expect(unresolvedBaselineFile.existsSync(), isTrue);

      final decoded =
          jsonDecode(unresolvedBaselineFile.readAsStringSync())
              as Map<String, dynamic>;
      expect(decoded.containsKey('unresolved'), isTrue);
      expect(decoded.containsKey('kit'), isFalse);
      expect(decoded.containsKey('resolvedCount'), isFalse);
      expect(decoded.containsKey('unresolvedCount'), isFalse);

      final unresolved = decoded['unresolved'] as List<dynamic>;
      expect(unresolved, hasLength(2));

      final firstUnresolved = unresolved.first as Map<String, dynamic>;
      expect(firstUnresolved['codePoint'], '0xe951');
      expect(firstUnresolved['identifiers'], <String>['face_unlock_sharp']);

      final secondUnresolved = unresolved[1] as Map<String, dynamic>;
      expect(secondUnresolved['codePoint'], '0xf04b9');
      expect(secondUnresolved['identifiers'], <String>['adobe']);
    });

    test('writes codePoints baseline JSON when requested', () async {
      final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
        ..writeAsStringSync('''
class Icons {
  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');

  /// The material icon named "face unlock" (sharp).
  static const IconData face_unlock_sharp = IconData(0xe951, fontFamily: 'MaterialIcons');
}
''');

      final materialIconsRoot = Directory(
        '${tempDirectory.path}/material-icons',
      )..createSync(recursive: true);
      final materialSymbolsRoot = Directory(
        '${tempDirectory.path}/material-symbols',
      )..createSync(recursive: true);
      final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
        ..createSync(recursive: true);

      final outputFile = File(
        '${tempDirectory.path}/material_rough_icons.g.dart',
      );
      final unresolvedBaselineFile = File(
        '${tempDirectory.path}/unresolved-baseline-codepoints.json',
      );

      await tool.runGenerateRoughIcons(<String>[
        '--kit',
        'flutter-material',
        '--flutter-icons',
        flutterIconsFile.path,
        '--material-icons-source',
        materialIconsRoot.path,
        '--material-symbols-source',
        materialSymbolsRoot.path,
        '--brand-icons-source',
        brandIconsRoot.path,
        '--unresolved-baseline-output',
        unresolvedBaselineFile.path,
        '--unresolved-baseline-output-format',
        'codepoints',
        '--output',
        outputFile.path,
      ]);

      expect(unresolvedBaselineFile.existsSync(), isTrue);

      final decoded =
          jsonDecode(unresolvedBaselineFile.readAsStringSync())
              as Map<String, dynamic>;
      expect(decoded.containsKey('codePoints'), isTrue);
      expect(decoded.containsKey('unresolved'), isFalse);

      final codePoints = decoded['codePoints'] as List<dynamic>;
      expect(codePoints, <String>['0xe951', '0xf04b9']);
    });

    test(
      'requires baseline output path when output format is customized',
      () async {
        await expectLater(
          tool.runGenerateRoughIcons(<String>[
            '--unresolved-baseline-output-format',
            'codepoints',
          ]),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test('rejects unknown unresolved baseline output format', () async {
      await expectLater(
        tool.runGenerateRoughIcons(<String>[
          '--unresolved-baseline-output',
          '${tempDirectory.path}/unresolved-baseline.json',
          '--unresolved-baseline-output-format',
          'invalid-format',
        ]),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('runGenerateRoughIcons supplemental manifest template output', () {
    late Directory tempDirectory;

    setUp(() {
      tempDirectory = Directory.systemTemp.createTempSync(
        'rough-icon-supplemental-manifest-template-test-',
      );
    });

    tearDown(() {
      tempDirectory.deleteSync(recursive: true);
    });

    test(
      'writes supplemental manifest template JSON for unresolved icons',
      () async {
        final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
          ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

        final materialIconsRoot = Directory(
          '${tempDirectory.path}/material-icons',
        )..createSync(recursive: true);
        final materialSymbolsRoot = Directory(
          '${tempDirectory.path}/material-symbols',
        )..createSync(recursive: true);
        final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
          ..createSync(recursive: true);

        File('${materialIconsRoot.path}/filled/label.svg')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
          );

        final outputFile = File(
          '${tempDirectory.path}/material_rough_icons.g.dart',
        );
        final supplementalTemplateFile = File(
          '${tempDirectory.path}/supplemental_template.json',
        );

        await tool.runGenerateRoughIcons(<String>[
          '--kit',
          'flutter-material',
          '--flutter-icons',
          flutterIconsFile.path,
          '--material-icons-source',
          materialIconsRoot.path,
          '--material-symbols-source',
          materialSymbolsRoot.path,
          '--brand-icons-source',
          brandIconsRoot.path,
          '--supplemental-manifest-output',
          supplementalTemplateFile.path,
          '--output',
          outputFile.path,
        ]);

        expect(supplementalTemplateFile.existsSync(), isTrue);

        final decoded =
            jsonDecode(supplementalTemplateFile.readAsStringSync())
                as Map<String, dynamic>;
        final icons = decoded['icons'] as List<dynamic>;
        expect(icons, hasLength(1));

        final firstIcon = icons.first as Map<String, dynamic>;
        expect(firstIcon['identifier'], 'adobe');
        expect(firstIcon['codePoint'], '0xf04b9');
        expect(firstIcon['svgPath'], 'TODO/adobe.svg');
      },
    );
  });

  group('runGenerateRoughIcons fail on unresolved', () {
    late Directory tempDirectory;

    setUp(() {
      tempDirectory = Directory.systemTemp.createTempSync(
        'rough-icon-fail-on-unresolved-test-',
      );
    });

    tearDown(() {
      tempDirectory.deleteSync(recursive: true);
    });

    test('rejects combining fail-on-unresolved with max-unresolved', () async {
      await expectLater(
        tool.runGenerateRoughIcons(<String>[
          '--fail-on-unresolved',
          '--max-unresolved',
          '1',
        ]),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws StateError when unresolved icons remain', () async {
      final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
        ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

      final materialIconsRoot = Directory(
        '${tempDirectory.path}/material-icons',
      )..createSync(recursive: true);
      final materialSymbolsRoot = Directory(
        '${tempDirectory.path}/material-symbols',
      )..createSync(recursive: true);
      final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
        ..createSync(recursive: true);

      File('${materialIconsRoot.path}/filled/label.svg')
        ..createSync(recursive: true)
        ..writeAsStringSync(
          '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
        );

      final outputFile = File(
        '${tempDirectory.path}/material_rough_icons.g.dart',
      );
      final unresolvedReportFile = File(
        '${tempDirectory.path}/unresolved.json',
      );

      await expectLater(
        tool.runGenerateRoughIcons(<String>[
          '--kit',
          'flutter-material',
          '--flutter-icons',
          flutterIconsFile.path,
          '--material-icons-source',
          materialIconsRoot.path,
          '--material-symbols-source',
          materialSymbolsRoot.path,
          '--brand-icons-source',
          brandIconsRoot.path,
          '--unresolved-output',
          unresolvedReportFile.path,
          '--fail-on-unresolved',
          '--output',
          outputFile.path,
        ]),
        throwsA(isA<StateError>()),
      );

      expect(unresolvedReportFile.existsSync(), isTrue);
      final decoded =
          jsonDecode(unresolvedReportFile.readAsStringSync())
              as Map<String, dynamic>;
      expect(decoded['unresolvedCount'], 1);
      expect(decoded['wouldFail'], isTrue);
      expect(decoded['unresolvedGateFailed'], isTrue);
      expect(decoded['newUnresolvedGateFailed'], isFalse);
      expect(decoded['activeGates'], <String>['unresolved']);
      expect(decoded['failedGates'], <String>['unresolved']);
      expect(decoded['unresolvedThresholdMode'], 'strict');
      expect(decoded['newUnresolvedThresholdMode'], 'disabled');
      expect(decoded['maxUnresolved'], 0);
      expect(decoded['maxUnresolvedExceeded'], isTrue);
    });
  });

  group('runGenerateRoughIcons max unresolved threshold', () {
    late Directory tempDirectory;

    setUp(() {
      tempDirectory = Directory.systemTemp.createTempSync(
        'rough-icon-max-unresolved-test-',
      );
    });

    tearDown(() {
      tempDirectory.deleteSync(recursive: true);
    });

    test('does not throw when unresolved count equals threshold', () async {
      final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
        ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

      final materialIconsRoot = Directory(
        '${tempDirectory.path}/material-icons',
      )..createSync(recursive: true);
      final materialSymbolsRoot = Directory(
        '${tempDirectory.path}/material-symbols',
      )..createSync(recursive: true);
      final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
        ..createSync(recursive: true);

      File('${materialIconsRoot.path}/filled/label.svg')
        ..createSync(recursive: true)
        ..writeAsStringSync(
          '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
        );

      final outputFile = File(
        '${tempDirectory.path}/material_rough_icons.g.dart',
      );
      final unresolvedReportFile = File(
        '${tempDirectory.path}/unresolved_report.json',
      );

      await tool.runGenerateRoughIcons(<String>[
        '--kit',
        'flutter-material',
        '--flutter-icons',
        flutterIconsFile.path,
        '--material-icons-source',
        materialIconsRoot.path,
        '--material-symbols-source',
        materialSymbolsRoot.path,
        '--brand-icons-source',
        brandIconsRoot.path,
        '--max-unresolved',
        '1',
        '--unresolved-output',
        unresolvedReportFile.path,
        '--output',
        outputFile.path,
      ]);

      expect(outputFile.existsSync(), isTrue);
      final decoded =
          jsonDecode(unresolvedReportFile.readAsStringSync())
              as Map<String, dynamic>;
      expect(decoded['maxUnresolved'], 1);
      expect(decoded['maxUnresolvedExceeded'], isFalse);
      expect(decoded['wouldFail'], isFalse);
      expect(decoded['unresolvedGateFailed'], isFalse);
      expect(decoded['newUnresolvedGateFailed'], isFalse);
      expect(decoded['activeGates'], <String>['unresolved']);
      expect(decoded['failedGates'], <String>[]);
      expect(decoded['unresolvedThresholdMode'], 'threshold');
      expect(decoded['newUnresolvedThresholdMode'], 'disabled');
    });

    test('throws when unresolved count exceeds threshold', () async {
      final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
        ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

      final materialIconsRoot = Directory(
        '${tempDirectory.path}/material-icons',
      )..createSync(recursive: true);
      final materialSymbolsRoot = Directory(
        '${tempDirectory.path}/material-symbols',
      )..createSync(recursive: true);
      final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
        ..createSync(recursive: true);

      File('${materialIconsRoot.path}/filled/label.svg')
        ..createSync(recursive: true)
        ..writeAsStringSync(
          '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
        );

      final outputFile = File(
        '${tempDirectory.path}/material_rough_icons.g.dart',
      );

      await expectLater(
        tool.runGenerateRoughIcons(<String>[
          '--kit',
          'flutter-material',
          '--flutter-icons',
          flutterIconsFile.path,
          '--material-icons-source',
          materialIconsRoot.path,
          '--material-symbols-source',
          materialSymbolsRoot.path,
          '--brand-icons-source',
          brandIconsRoot.path,
          '--max-unresolved',
          '0',
          '--output',
          outputFile.path,
        ]),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('runGenerateRoughIcons unresolved baseline regression checks', () {
    late Directory tempDirectory;

    setUp(() {
      tempDirectory = Directory.systemTemp.createTempSync(
        'rough-icon-unresolved-baseline-test-',
      );
    });

    tearDown(() {
      tempDirectory.deleteSync(recursive: true);
    });

    test(
      'requires baseline path when fail-on-new-unresolved is enabled',
      () async {
        await expectLater(
          tool.runGenerateRoughIcons(<String>['--fail-on-new-unresolved']),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test('requires baseline path when max-new-unresolved is enabled', () async {
      await expectLater(
        tool.runGenerateRoughIcons(<String>['--max-new-unresolved', '1']),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
      'rejects combining fail-on-new-unresolved with max-new-unresolved',
      () async {
        await expectLater(
          tool.runGenerateRoughIcons(<String>[
            '--fail-on-new-unresolved',
            '--max-new-unresolved',
            '1',
            '--unresolved-baseline',
            'baseline.json',
          ]),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test(
      'does not throw when unresolved icons are all in baseline (code_point alias)',
      () async {
        final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
          ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

        final materialIconsRoot = Directory(
          '${tempDirectory.path}/material-icons',
        )..createSync(recursive: true);
        final materialSymbolsRoot = Directory(
          '${tempDirectory.path}/material-symbols',
        )..createSync(recursive: true);
        final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
          ..createSync(recursive: true);

        File('${materialIconsRoot.path}/filled/label.svg')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
          );

        final baselineFile = File('${tempDirectory.path}/baseline.json')
          ..writeAsStringSync('''
{
  "unresolved": [
    {
      "code_point": "0xf04b9",
      "identifiers": ["adobe"]
    }
  ]
}
''');
        final unresolvedReportFile = File(
          '${tempDirectory.path}/unresolved_report.json',
        );
        final outputFile = File(
          '${tempDirectory.path}/material_rough_icons.g.dart',
        );

        await tool.runGenerateRoughIcons(<String>[
          '--kit',
          'flutter-material',
          '--flutter-icons',
          flutterIconsFile.path,
          '--material-icons-source',
          materialIconsRoot.path,
          '--material-symbols-source',
          materialSymbolsRoot.path,
          '--brand-icons-source',
          brandIconsRoot.path,
          '--unresolved-baseline',
          baselineFile.path,
          '--fail-on-new-unresolved',
          '--unresolved-output',
          unresolvedReportFile.path,
          '--output',
          outputFile.path,
        ]);

        final decoded =
            jsonDecode(unresolvedReportFile.readAsStringSync())
                as Map<String, dynamic>;
        expect(decoded['baselineUnresolvedCount'], 1);
        expect(decoded['unresolvedCodePoints'], <String>['0xf04b9']);
        expect(decoded['newUnresolvedCount'], 0);
        expect(decoded['newUnresolved'], <dynamic>[]);
        expect(decoded['newUnresolvedCodePoints'], <dynamic>[]);
        expect(decoded['resolvedSinceBaselineCount'], 0);
        expect(decoded['resolvedSinceBaseline'], <dynamic>[]);
      },
    );

    test(
      'does not throw when unresolved icons are all in baseline (code-point alias)',
      () async {
        final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
          ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

        final materialIconsRoot = Directory(
          '${tempDirectory.path}/material-icons',
        )..createSync(recursive: true);
        final materialSymbolsRoot = Directory(
          '${tempDirectory.path}/material-symbols',
        )..createSync(recursive: true);
        final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
          ..createSync(recursive: true);

        File('${materialIconsRoot.path}/filled/label.svg')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
          );

        final baselineFile = File('${tempDirectory.path}/baseline.json')
          ..writeAsStringSync('''
{
  "unresolved": [
    {
      "code-point": "0xf04b9",
      "identifiers": ["adobe"]
    }
  ]
}
''');
        final unresolvedReportFile = File(
          '${tempDirectory.path}/unresolved_report.json',
        );
        final outputFile = File(
          '${tempDirectory.path}/material_rough_icons.g.dart',
        );

        await tool.runGenerateRoughIcons(<String>[
          '--kit',
          'flutter-material',
          '--flutter-icons',
          flutterIconsFile.path,
          '--material-icons-source',
          materialIconsRoot.path,
          '--material-symbols-source',
          materialSymbolsRoot.path,
          '--brand-icons-source',
          brandIconsRoot.path,
          '--unresolved-baseline',
          baselineFile.path,
          '--fail-on-new-unresolved',
          '--unresolved-output',
          unresolvedReportFile.path,
          '--output',
          outputFile.path,
        ]);

        final decoded =
            jsonDecode(unresolvedReportFile.readAsStringSync())
                as Map<String, dynamic>;
        expect(decoded['baselineUnresolvedCount'], 1);
        expect(decoded['unresolvedCodePoints'], <String>['0xf04b9']);
        expect(decoded['newUnresolvedCount'], 0);
        expect(decoded['newUnresolved'], <dynamic>[]);
        expect(decoded['newUnresolvedCodePoints'], <dynamic>[]);
        expect(decoded['resolvedSinceBaselineCount'], 0);
        expect(decoded['resolvedSinceBaseline'], <dynamic>[]);
      },
    );

    test(
      'accepts supplemental manifest icons[] format as unresolved baseline (codepoint alias)',
      () async {
        final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
          ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

        final materialIconsRoot = Directory(
          '${tempDirectory.path}/material-icons',
        )..createSync(recursive: true);
        final materialSymbolsRoot = Directory(
          '${tempDirectory.path}/material-symbols',
        )..createSync(recursive: true);
        final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
          ..createSync(recursive: true);

        File('${materialIconsRoot.path}/filled/label.svg')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
          );

        final baselineFile = File('${tempDirectory.path}/baseline-icons.json')
          ..writeAsStringSync('''
{
  "icons": [
    {
      "identifier": "adobe",
      "codepoint": "0xf04b9",
      "svgPath": "TODO/adobe.svg"
    }
  ]
}
''');
        final unresolvedReportFile = File(
          '${tempDirectory.path}/unresolved_report.json',
        );
        final outputFile = File(
          '${tempDirectory.path}/material_rough_icons.g.dart',
        );

        await tool.runGenerateRoughIcons(<String>[
          '--kit',
          'flutter-material',
          '--flutter-icons',
          flutterIconsFile.path,
          '--material-icons-source',
          materialIconsRoot.path,
          '--material-symbols-source',
          materialSymbolsRoot.path,
          '--brand-icons-source',
          brandIconsRoot.path,
          '--unresolved-baseline',
          baselineFile.path,
          '--fail-on-new-unresolved',
          '--unresolved-output',
          unresolvedReportFile.path,
          '--output',
          outputFile.path,
        ]);

        final decoded =
            jsonDecode(unresolvedReportFile.readAsStringSync())
                as Map<String, dynamic>;
        expect(decoded['baselineUnresolvedCount'], 1);
        expect(decoded['unresolvedCodePoints'], <String>['0xf04b9']);
        expect(decoded['newUnresolvedCount'], 0);
        expect(decoded['newUnresolved'], <dynamic>[]);
        expect(decoded['newUnresolvedCodePoints'], <dynamic>[]);
        expect(decoded['resolvedSinceBaselineCount'], 0);
        expect(decoded['resolvedSinceBaseline'], <dynamic>[]);
      },
    );

    test(
      'throws when unresolved baseline object omits recognized top-level list key',
      () async {
        final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
          ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

        final materialIconsRoot = Directory(
          '${tempDirectory.path}/material-icons',
        )..createSync(recursive: true);
        final materialSymbolsRoot = Directory(
          '${tempDirectory.path}/material-symbols',
        )..createSync(recursive: true);
        final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
          ..createSync(recursive: true);

        File('${materialIconsRoot.path}/filled/label.svg')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
          );

        final baselineFile = File('${tempDirectory.path}/baseline-invalid.json')
          ..writeAsStringSync('''
{
  "items": [
    "f04b9"
  ]
}
''');
        final unresolvedReportFile = File(
          '${tempDirectory.path}/unresolved_report.json',
        );
        final outputFile = File(
          '${tempDirectory.path}/material_rough_icons.g.dart',
        );

        await expectLater(
          tool.runGenerateRoughIcons(<String>[
            '--kit',
            'flutter-material',
            '--flutter-icons',
            flutterIconsFile.path,
            '--material-icons-source',
            materialIconsRoot.path,
            '--material-symbols-source',
            materialSymbolsRoot.path,
            '--brand-icons-source',
            brandIconsRoot.path,
            '--unresolved-baseline',
            baselineFile.path,
            '--fail-on-new-unresolved',
            '--unresolved-output',
            unresolvedReportFile.path,
            '--output',
            outputFile.path,
          ]),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'message',
              allOf(
                contains(
                  'Expected unresolved baseline JSON to contain either an "unresolved" list',
                ),
                contains('Found keys: items'),
              ),
            ),
          ),
        );
      },
    );

    test(
      'throws when unresolved baseline recognized key value is not a list',
      () async {
        final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
          ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

        final materialIconsRoot = Directory(
          '${tempDirectory.path}/material-icons',
        )..createSync(recursive: true);
        final materialSymbolsRoot = Directory(
          '${tempDirectory.path}/material-symbols',
        )..createSync(recursive: true);
        final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
          ..createSync(recursive: true);

        File('${materialIconsRoot.path}/filled/label.svg')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
          );

        final baselineFile = File('${tempDirectory.path}/baseline-invalid.json')
          ..writeAsStringSync('''
{
  "codePoints": "f04b9"
}
''');
        final unresolvedReportFile = File(
          '${tempDirectory.path}/unresolved_report.json',
        );
        final outputFile = File(
          '${tempDirectory.path}/material_rough_icons.g.dart',
        );

        await expectLater(
          tool.runGenerateRoughIcons(<String>[
            '--kit',
            'flutter-material',
            '--flutter-icons',
            flutterIconsFile.path,
            '--material-icons-source',
            materialIconsRoot.path,
            '--material-symbols-source',
            materialSymbolsRoot.path,
            '--brand-icons-source',
            brandIconsRoot.path,
            '--unresolved-baseline',
            baselineFile.path,
            '--fail-on-new-unresolved',
            '--unresolved-output',
            unresolvedReportFile.path,
            '--output',
            outputFile.path,
          ]),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'message',
              allOf(
                contains(
                  'Expected unresolved baseline recognized list keys to map to arrays',
                ),
                contains('Found non-list values: codePoints (String)'),
              ),
            ),
          ),
        );
      },
    );

    test(
      'throws when unresolved baseline object entry omits codepoint key',
      () async {
        final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
          ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

        final materialIconsRoot = Directory(
          '${tempDirectory.path}/material-icons',
        )..createSync(recursive: true);
        final materialSymbolsRoot = Directory(
          '${tempDirectory.path}/material-symbols',
        )..createSync(recursive: true);
        final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
          ..createSync(recursive: true);

        File('${materialIconsRoot.path}/filled/label.svg')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
          );

        final baselineFile = File('${tempDirectory.path}/baseline-icons.json')
          ..writeAsStringSync('''
{
  "icons": [
    {
      "identifier": "adobe",
      "svgPath": "TODO/adobe.svg"
    }
  ]
}
''');
        final unresolvedReportFile = File(
          '${tempDirectory.path}/unresolved_report.json',
        );
        final outputFile = File(
          '${tempDirectory.path}/material_rough_icons.g.dart',
        );

        await expectLater(
          tool.runGenerateRoughIcons(<String>[
            '--kit',
            'flutter-material',
            '--flutter-icons',
            flutterIconsFile.path,
            '--material-icons-source',
            materialIconsRoot.path,
            '--material-symbols-source',
            materialSymbolsRoot.path,
            '--brand-icons-source',
            brandIconsRoot.path,
            '--unresolved-baseline',
            baselineFile.path,
            '--fail-on-new-unresolved',
            '--unresolved-output',
            unresolvedReportFile.path,
            '--output',
            outputFile.path,
          ]),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'message',
              contains(
                'Expected one of "codePoint", "codepoint", "code_point", or "code-point" keys',
              ),
            ),
          ),
        );
      },
    );

    test('accepts codePoint[] format as unresolved baseline', () async {
      final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
        ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

      final materialIconsRoot = Directory(
        '${tempDirectory.path}/material-icons',
      )..createSync(recursive: true);
      final materialSymbolsRoot = Directory(
        '${tempDirectory.path}/material-symbols',
      )..createSync(recursive: true);
      final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
        ..createSync(recursive: true);

      File('${materialIconsRoot.path}/filled/label.svg')
        ..createSync(recursive: true)
        ..writeAsStringSync(
          '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
        );

      final baselineFile =
          File('${tempDirectory.path}/baseline-codePoint-camel-singular.json')
            ..writeAsStringSync('''
{
  "codePoint": [
    "f04b9"
  ]
}
''');
      final unresolvedReportFile = File(
        '${tempDirectory.path}/unresolved_report.json',
      );
      final outputFile = File(
        '${tempDirectory.path}/material_rough_icons.g.dart',
      );

      await tool.runGenerateRoughIcons(<String>[
        '--kit',
        'flutter-material',
        '--flutter-icons',
        flutterIconsFile.path,
        '--material-icons-source',
        materialIconsRoot.path,
        '--material-symbols-source',
        materialSymbolsRoot.path,
        '--brand-icons-source',
        brandIconsRoot.path,
        '--unresolved-baseline',
        baselineFile.path,
        '--fail-on-new-unresolved',
        '--unresolved-output',
        unresolvedReportFile.path,
        '--output',
        outputFile.path,
      ]);

      final decoded =
          jsonDecode(unresolvedReportFile.readAsStringSync())
              as Map<String, dynamic>;
      expect(decoded['baselineUnresolvedCount'], 1);
      expect(decoded['unresolvedCodePoints'], <String>['0xf04b9']);
      expect(decoded['newUnresolvedCount'], 0);
      expect(decoded['newUnresolved'], <dynamic>[]);
      expect(decoded['newUnresolvedCodePoints'], <dynamic>[]);
      expect(decoded['resolvedSinceBaselineCount'], 0);
      expect(decoded['resolvedSinceBaseline'], <dynamic>[]);
    });

    test('accepts codePoints[] format as unresolved baseline', () async {
      final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
        ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

      final materialIconsRoot = Directory(
        '${tempDirectory.path}/material-icons',
      )..createSync(recursive: true);
      final materialSymbolsRoot = Directory(
        '${tempDirectory.path}/material-symbols',
      )..createSync(recursive: true);
      final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
        ..createSync(recursive: true);

      File('${materialIconsRoot.path}/filled/label.svg')
        ..createSync(recursive: true)
        ..writeAsStringSync(
          '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
        );

      final baselineFile =
          File('${tempDirectory.path}/baseline-codepoints.json')
            ..writeAsStringSync('''
{
  "codePoints": [
    "f04b9"
  ]
}
''');
      final unresolvedReportFile = File(
        '${tempDirectory.path}/unresolved_report.json',
      );
      final outputFile = File(
        '${tempDirectory.path}/material_rough_icons.g.dart',
      );

      await tool.runGenerateRoughIcons(<String>[
        '--kit',
        'flutter-material',
        '--flutter-icons',
        flutterIconsFile.path,
        '--material-icons-source',
        materialIconsRoot.path,
        '--material-symbols-source',
        materialSymbolsRoot.path,
        '--brand-icons-source',
        brandIconsRoot.path,
        '--unresolved-baseline',
        baselineFile.path,
        '--fail-on-new-unresolved',
        '--unresolved-output',
        unresolvedReportFile.path,
        '--output',
        outputFile.path,
      ]);

      final decoded =
          jsonDecode(unresolvedReportFile.readAsStringSync())
              as Map<String, dynamic>;
      expect(decoded['baselineUnresolvedCount'], 1);
      expect(decoded['unresolvedCodePoints'], <String>['0xf04b9']);
      expect(decoded['newUnresolvedCount'], 0);
      expect(decoded['newUnresolved'], <dynamic>[]);
      expect(decoded['newUnresolvedCodePoints'], <dynamic>[]);
      expect(decoded['resolvedSinceBaselineCount'], 0);
      expect(decoded['resolvedSinceBaseline'], <dynamic>[]);
    });

    test(
      'accepts unresolvedCodePoints[] format as unresolved baseline',
      () async {
        final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
          ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

        final materialIconsRoot = Directory(
          '${tempDirectory.path}/material-icons',
        )..createSync(recursive: true);
        final materialSymbolsRoot = Directory(
          '${tempDirectory.path}/material-symbols',
        )..createSync(recursive: true);
        final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
          ..createSync(recursive: true);

        File('${materialIconsRoot.path}/filled/label.svg')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
          );

        final baselineFile =
            File('${tempDirectory.path}/baseline-unresolved-codepoints.json')
              ..writeAsStringSync('''
{
  "unresolvedCodePoints": [
    "f04b9"
  ]
}
''');
        final unresolvedReportFile = File(
          '${tempDirectory.path}/unresolved_report.json',
        );
        final outputFile = File(
          '${tempDirectory.path}/material_rough_icons.g.dart',
        );

        await tool.runGenerateRoughIcons(<String>[
          '--kit',
          'flutter-material',
          '--flutter-icons',
          flutterIconsFile.path,
          '--material-icons-source',
          materialIconsRoot.path,
          '--material-symbols-source',
          materialSymbolsRoot.path,
          '--brand-icons-source',
          brandIconsRoot.path,
          '--unresolved-baseline',
          baselineFile.path,
          '--fail-on-new-unresolved',
          '--unresolved-output',
          unresolvedReportFile.path,
          '--output',
          outputFile.path,
        ]);

        final decoded =
            jsonDecode(unresolvedReportFile.readAsStringSync())
                as Map<String, dynamic>;
        expect(decoded['baselineUnresolvedCount'], 1);
        expect(decoded['unresolvedCodePoints'], <String>['0xf04b9']);
        expect(decoded['newUnresolvedCount'], 0);
        expect(decoded['newUnresolved'], <dynamic>[]);
        expect(decoded['newUnresolvedCodePoints'], <dynamic>[]);
        expect(decoded['resolvedSinceBaselineCount'], 0);
        expect(decoded['resolvedSinceBaseline'], <dynamic>[]);
      },
    );

    test(
      'accepts unresolvedCodePoint[] format as unresolved baseline',
      () async {
        final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
          ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

        final materialIconsRoot = Directory(
          '${tempDirectory.path}/material-icons',
        )..createSync(recursive: true);
        final materialSymbolsRoot = Directory(
          '${tempDirectory.path}/material-symbols',
        )..createSync(recursive: true);
        final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
          ..createSync(recursive: true);

        File('${materialIconsRoot.path}/filled/label.svg')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
          );

        final baselineFile =
            File('${tempDirectory.path}/baseline-unresolved-codepoint.json')
              ..writeAsStringSync('''
{
  "unresolvedCodePoint": [
    "f04b9"
  ]
}
''');
        final unresolvedReportFile = File(
          '${tempDirectory.path}/unresolved_report.json',
        );
        final outputFile = File(
          '${tempDirectory.path}/material_rough_icons.g.dart',
        );

        await tool.runGenerateRoughIcons(<String>[
          '--kit',
          'flutter-material',
          '--flutter-icons',
          flutterIconsFile.path,
          '--material-icons-source',
          materialIconsRoot.path,
          '--material-symbols-source',
          materialSymbolsRoot.path,
          '--brand-icons-source',
          brandIconsRoot.path,
          '--unresolved-baseline',
          baselineFile.path,
          '--fail-on-new-unresolved',
          '--unresolved-output',
          unresolvedReportFile.path,
          '--output',
          outputFile.path,
        ]);

        final decoded =
            jsonDecode(unresolvedReportFile.readAsStringSync())
                as Map<String, dynamic>;
        expect(decoded['baselineUnresolvedCount'], 1);
        expect(decoded['unresolvedCodePoints'], <String>['0xf04b9']);
        expect(decoded['newUnresolvedCount'], 0);
        expect(decoded['newUnresolved'], <dynamic>[]);
        expect(decoded['newUnresolvedCodePoints'], <dynamic>[]);
        expect(decoded['resolvedSinceBaselineCount'], 0);
        expect(decoded['resolvedSinceBaseline'], <dynamic>[]);
      },
    );

    test(
      'accepts unresolvedCodepoint[] format as unresolved baseline',
      () async {
        final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
          ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

        final materialIconsRoot = Directory(
          '${tempDirectory.path}/material-icons',
        )..createSync(recursive: true);
        final materialSymbolsRoot = Directory(
          '${tempDirectory.path}/material-symbols',
        )..createSync(recursive: true);
        final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
          ..createSync(recursive: true);

        File('${materialIconsRoot.path}/filled/label.svg')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
          );

        final baselineFile =
            File('${tempDirectory.path}/baseline-unresolved-codepoint.json')
              ..writeAsStringSync('''
{
  "unresolvedCodepoint": [
    "f04b9"
  ]
}
''');
        final unresolvedReportFile = File(
          '${tempDirectory.path}/unresolved_report.json',
        );
        final outputFile = File(
          '${tempDirectory.path}/material_rough_icons.g.dart',
        );

        await tool.runGenerateRoughIcons(<String>[
          '--kit',
          'flutter-material',
          '--flutter-icons',
          flutterIconsFile.path,
          '--material-icons-source',
          materialIconsRoot.path,
          '--material-symbols-source',
          materialSymbolsRoot.path,
          '--brand-icons-source',
          brandIconsRoot.path,
          '--unresolved-baseline',
          baselineFile.path,
          '--fail-on-new-unresolved',
          '--unresolved-output',
          unresolvedReportFile.path,
          '--output',
          outputFile.path,
        ]);

        final decoded =
            jsonDecode(unresolvedReportFile.readAsStringSync())
                as Map<String, dynamic>;
        expect(decoded['baselineUnresolvedCount'], 1);
        expect(decoded['unresolvedCodePoints'], <String>['0xf04b9']);
        expect(decoded['newUnresolvedCount'], 0);
        expect(decoded['newUnresolved'], <dynamic>[]);
        expect(decoded['newUnresolvedCodePoints'], <dynamic>[]);
        expect(decoded['resolvedSinceBaselineCount'], 0);
        expect(decoded['resolvedSinceBaseline'], <dynamic>[]);
      },
    );

    test(
      'accepts unresolvedCodepoints[] format as unresolved baseline',
      () async {
        final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
          ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

        final materialIconsRoot = Directory(
          '${tempDirectory.path}/material-icons',
        )..createSync(recursive: true);
        final materialSymbolsRoot = Directory(
          '${tempDirectory.path}/material-symbols',
        )..createSync(recursive: true);
        final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
          ..createSync(recursive: true);

        File('${materialIconsRoot.path}/filled/label.svg')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
          );

        final baselineFile =
            File(
              '${tempDirectory.path}/baseline-unresolved-codepoints-lowercase.json',
            )..writeAsStringSync('''
{
  "unresolvedCodepoints": [
    "f04b9"
  ]
}
''');
        final unresolvedReportFile = File(
          '${tempDirectory.path}/unresolved_report.json',
        );
        final outputFile = File(
          '${tempDirectory.path}/material_rough_icons.g.dart',
        );

        await tool.runGenerateRoughIcons(<String>[
          '--kit',
          'flutter-material',
          '--flutter-icons',
          flutterIconsFile.path,
          '--material-icons-source',
          materialIconsRoot.path,
          '--material-symbols-source',
          materialSymbolsRoot.path,
          '--brand-icons-source',
          brandIconsRoot.path,
          '--unresolved-baseline',
          baselineFile.path,
          '--fail-on-new-unresolved',
          '--unresolved-output',
          unresolvedReportFile.path,
          '--output',
          outputFile.path,
        ]);

        final decoded =
            jsonDecode(unresolvedReportFile.readAsStringSync())
                as Map<String, dynamic>;
        expect(decoded['baselineUnresolvedCount'], 1);
        expect(decoded['unresolvedCodePoints'], <String>['0xf04b9']);
        expect(decoded['newUnresolvedCount'], 0);
        expect(decoded['newUnresolved'], <dynamic>[]);
        expect(decoded['newUnresolvedCodePoints'], <dynamic>[]);
        expect(decoded['resolvedSinceBaselineCount'], 0);
        expect(decoded['resolvedSinceBaseline'], <dynamic>[]);
      },
    );

    test(
      'accepts unresolved_code_points[] format as unresolved baseline',
      () async {
        final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
          ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

        final materialIconsRoot = Directory(
          '${tempDirectory.path}/material-icons',
        )..createSync(recursive: true);
        final materialSymbolsRoot = Directory(
          '${tempDirectory.path}/material-symbols',
        )..createSync(recursive: true);
        final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
          ..createSync(recursive: true);

        File('${materialIconsRoot.path}/filled/label.svg')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
          );

        final baselineFile =
            File(
              '${tempDirectory.path}/baseline-unresolved-code-points-snake-case.json',
            )..writeAsStringSync('''
{
  "unresolved_code_points": [
    "f04b9"
  ]
}
''');
        final unresolvedReportFile = File(
          '${tempDirectory.path}/unresolved_report.json',
        );
        final outputFile = File(
          '${tempDirectory.path}/material_rough_icons.g.dart',
        );

        await tool.runGenerateRoughIcons(<String>[
          '--kit',
          'flutter-material',
          '--flutter-icons',
          flutterIconsFile.path,
          '--material-icons-source',
          materialIconsRoot.path,
          '--material-symbols-source',
          materialSymbolsRoot.path,
          '--brand-icons-source',
          brandIconsRoot.path,
          '--unresolved-baseline',
          baselineFile.path,
          '--fail-on-new-unresolved',
          '--unresolved-output',
          unresolvedReportFile.path,
          '--output',
          outputFile.path,
        ]);

        final decoded =
            jsonDecode(unresolvedReportFile.readAsStringSync())
                as Map<String, dynamic>;
        expect(decoded['baselineUnresolvedCount'], 1);
        expect(decoded['unresolvedCodePoints'], <String>['0xf04b9']);
        expect(decoded['newUnresolvedCount'], 0);
        expect(decoded['newUnresolved'], <dynamic>[]);
        expect(decoded['newUnresolvedCodePoints'], <dynamic>[]);
        expect(decoded['resolvedSinceBaselineCount'], 0);
        expect(decoded['resolvedSinceBaseline'], <dynamic>[]);
      },
    );

    test(
      'accepts unresolved-code-points[] format as unresolved baseline',
      () async {
        final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
          ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

        final materialIconsRoot = Directory(
          '${tempDirectory.path}/material-icons',
        )..createSync(recursive: true);
        final materialSymbolsRoot = Directory(
          '${tempDirectory.path}/material-symbols',
        )..createSync(recursive: true);
        final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
          ..createSync(recursive: true);

        File('${materialIconsRoot.path}/filled/label.svg')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
          );

        final baselineFile =
            File(
              '${tempDirectory.path}/baseline-unresolved-code-points-kebab-case.json',
            )..writeAsStringSync('''
{
  "unresolved-code-points": [
    "f04b9"
  ]
}
''');
        final unresolvedReportFile = File(
          '${tempDirectory.path}/unresolved_report.json',
        );
        final outputFile = File(
          '${tempDirectory.path}/material_rough_icons.g.dart',
        );

        await tool.runGenerateRoughIcons(<String>[
          '--kit',
          'flutter-material',
          '--flutter-icons',
          flutterIconsFile.path,
          '--material-icons-source',
          materialIconsRoot.path,
          '--material-symbols-source',
          materialSymbolsRoot.path,
          '--brand-icons-source',
          brandIconsRoot.path,
          '--unresolved-baseline',
          baselineFile.path,
          '--fail-on-new-unresolved',
          '--unresolved-output',
          unresolvedReportFile.path,
          '--output',
          outputFile.path,
        ]);

        final decoded =
            jsonDecode(unresolvedReportFile.readAsStringSync())
                as Map<String, dynamic>;
        expect(decoded['baselineUnresolvedCount'], 1);
        expect(decoded['unresolvedCodePoints'], <String>['0xf04b9']);
        expect(decoded['newUnresolvedCount'], 0);
        expect(decoded['newUnresolved'], <dynamic>[]);
        expect(decoded['newUnresolvedCodePoints'], <dynamic>[]);
        expect(decoded['resolvedSinceBaselineCount'], 0);
        expect(decoded['resolvedSinceBaseline'], <dynamic>[]);
      },
    );

    test(
      'accepts unresolved-codepoints[] format as unresolved baseline',
      () async {
        final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
          ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

        final materialIconsRoot = Directory(
          '${tempDirectory.path}/material-icons',
        )..createSync(recursive: true);
        final materialSymbolsRoot = Directory(
          '${tempDirectory.path}/material-symbols',
        )..createSync(recursive: true);
        final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
          ..createSync(recursive: true);

        File('${materialIconsRoot.path}/filled/label.svg')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
          );

        final baselineFile =
            File(
              '${tempDirectory.path}/baseline-unresolved-codepoints-kebab-case.json',
            )..writeAsStringSync('''
{
  "unresolved-codepoints": [
    "f04b9"
  ]
}
''');
        final unresolvedReportFile = File(
          '${tempDirectory.path}/unresolved_report.json',
        );
        final outputFile = File(
          '${tempDirectory.path}/material_rough_icons.g.dart',
        );

        await tool.runGenerateRoughIcons(<String>[
          '--kit',
          'flutter-material',
          '--flutter-icons',
          flutterIconsFile.path,
          '--material-icons-source',
          materialIconsRoot.path,
          '--material-symbols-source',
          materialSymbolsRoot.path,
          '--brand-icons-source',
          brandIconsRoot.path,
          '--unresolved-baseline',
          baselineFile.path,
          '--fail-on-new-unresolved',
          '--unresolved-output',
          unresolvedReportFile.path,
          '--output',
          outputFile.path,
        ]);

        final decoded =
            jsonDecode(unresolvedReportFile.readAsStringSync())
                as Map<String, dynamic>;
        expect(decoded['baselineUnresolvedCount'], 1);
        expect(decoded['unresolvedCodePoints'], <String>['0xf04b9']);
        expect(decoded['newUnresolvedCount'], 0);
        expect(decoded['newUnresolved'], <dynamic>[]);
        expect(decoded['newUnresolvedCodePoints'], <dynamic>[]);
        expect(decoded['resolvedSinceBaselineCount'], 0);
        expect(decoded['resolvedSinceBaseline'], <dynamic>[]);
      },
    );

    test(
      'accepts unresolved_codepoint[] format as unresolved baseline',
      () async {
        final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
          ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

        final materialIconsRoot = Directory(
          '${tempDirectory.path}/material-icons',
        )..createSync(recursive: true);
        final materialSymbolsRoot = Directory(
          '${tempDirectory.path}/material-symbols',
        )..createSync(recursive: true);
        final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
          ..createSync(recursive: true);

        File('${materialIconsRoot.path}/filled/label.svg')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
          );

        final baselineFile =
            File(
              '${tempDirectory.path}/baseline-unresolved-codepoint-snake-case.json',
            )..writeAsStringSync('''
{
  "unresolved_codepoint": [
    "f04b9"
  ]
}
''');
        final unresolvedReportFile = File(
          '${tempDirectory.path}/unresolved_report.json',
        );
        final outputFile = File(
          '${tempDirectory.path}/material_rough_icons.g.dart',
        );

        await tool.runGenerateRoughIcons(<String>[
          '--kit',
          'flutter-material',
          '--flutter-icons',
          flutterIconsFile.path,
          '--material-icons-source',
          materialIconsRoot.path,
          '--material-symbols-source',
          materialSymbolsRoot.path,
          '--brand-icons-source',
          brandIconsRoot.path,
          '--unresolved-baseline',
          baselineFile.path,
          '--fail-on-new-unresolved',
          '--unresolved-output',
          unresolvedReportFile.path,
          '--output',
          outputFile.path,
        ]);

        final decoded =
            jsonDecode(unresolvedReportFile.readAsStringSync())
                as Map<String, dynamic>;
        expect(decoded['baselineUnresolvedCount'], 1);
        expect(decoded['unresolvedCodePoints'], <String>['0xf04b9']);
        expect(decoded['newUnresolvedCount'], 0);
        expect(decoded['newUnresolved'], <dynamic>[]);
        expect(decoded['newUnresolvedCodePoints'], <dynamic>[]);
        expect(decoded['resolvedSinceBaselineCount'], 0);
        expect(decoded['resolvedSinceBaseline'], <dynamic>[]);
      },
    );

    test(
      'accepts unresolved_codepoints[] format as unresolved baseline',
      () async {
        final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
          ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

        final materialIconsRoot = Directory(
          '${tempDirectory.path}/material-icons',
        )..createSync(recursive: true);
        final materialSymbolsRoot = Directory(
          '${tempDirectory.path}/material-symbols',
        )..createSync(recursive: true);
        final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
          ..createSync(recursive: true);

        File('${materialIconsRoot.path}/filled/label.svg')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
          );

        final baselineFile =
            File(
              '${tempDirectory.path}/baseline-unresolved-codepoints-snake-case.json',
            )..writeAsStringSync('''
{
  "unresolved_codepoints": [
    "f04b9"
  ]
}
''');
        final unresolvedReportFile = File(
          '${tempDirectory.path}/unresolved_report.json',
        );
        final outputFile = File(
          '${tempDirectory.path}/material_rough_icons.g.dart',
        );

        await tool.runGenerateRoughIcons(<String>[
          '--kit',
          'flutter-material',
          '--flutter-icons',
          flutterIconsFile.path,
          '--material-icons-source',
          materialIconsRoot.path,
          '--material-symbols-source',
          materialSymbolsRoot.path,
          '--brand-icons-source',
          brandIconsRoot.path,
          '--unresolved-baseline',
          baselineFile.path,
          '--fail-on-new-unresolved',
          '--unresolved-output',
          unresolvedReportFile.path,
          '--output',
          outputFile.path,
        ]);

        final decoded =
            jsonDecode(unresolvedReportFile.readAsStringSync())
                as Map<String, dynamic>;
        expect(decoded['baselineUnresolvedCount'], 1);
        expect(decoded['unresolvedCodePoints'], <String>['0xf04b9']);
        expect(decoded['newUnresolvedCount'], 0);
        expect(decoded['newUnresolved'], <dynamic>[]);
        expect(decoded['newUnresolvedCodePoints'], <dynamic>[]);
        expect(decoded['resolvedSinceBaselineCount'], 0);
        expect(decoded['resolvedSinceBaseline'], <dynamic>[]);
      },
    );

    test('accepts code_points[] format as unresolved baseline', () async {
      final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
        ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

      final materialIconsRoot = Directory(
        '${tempDirectory.path}/material-icons',
      )..createSync(recursive: true);
      final materialSymbolsRoot = Directory(
        '${tempDirectory.path}/material-symbols',
      )..createSync(recursive: true);
      final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
        ..createSync(recursive: true);

      File('${materialIconsRoot.path}/filled/label.svg')
        ..createSync(recursive: true)
        ..writeAsStringSync(
          '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
        );

      final baselineFile =
          File('${tempDirectory.path}/baseline-code-points-snake-case.json')
            ..writeAsStringSync('''
{
  "code_points": [
    "f04b9"
  ]
}
''');
      final unresolvedReportFile = File(
        '${tempDirectory.path}/unresolved_report.json',
      );
      final outputFile = File(
        '${tempDirectory.path}/material_rough_icons.g.dart',
      );

      await tool.runGenerateRoughIcons(<String>[
        '--kit',
        'flutter-material',
        '--flutter-icons',
        flutterIconsFile.path,
        '--material-icons-source',
        materialIconsRoot.path,
        '--material-symbols-source',
        materialSymbolsRoot.path,
        '--brand-icons-source',
        brandIconsRoot.path,
        '--unresolved-baseline',
        baselineFile.path,
        '--fail-on-new-unresolved',
        '--unresolved-output',
        unresolvedReportFile.path,
        '--output',
        outputFile.path,
      ]);

      final decoded =
          jsonDecode(unresolvedReportFile.readAsStringSync())
              as Map<String, dynamic>;
      expect(decoded['baselineUnresolvedCount'], 1);
      expect(decoded['unresolvedCodePoints'], <String>['0xf04b9']);
      expect(decoded['newUnresolvedCount'], 0);
      expect(decoded['newUnresolved'], <dynamic>[]);
      expect(decoded['newUnresolvedCodePoints'], <dynamic>[]);
      expect(decoded['resolvedSinceBaselineCount'], 0);
      expect(decoded['resolvedSinceBaseline'], <dynamic>[]);
    });

    test('accepts code-points[] format as unresolved baseline', () async {
      final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
        ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

      final materialIconsRoot = Directory(
        '${tempDirectory.path}/material-icons',
      )..createSync(recursive: true);
      final materialSymbolsRoot = Directory(
        '${tempDirectory.path}/material-symbols',
      )..createSync(recursive: true);
      final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
        ..createSync(recursive: true);

      File('${materialIconsRoot.path}/filled/label.svg')
        ..createSync(recursive: true)
        ..writeAsStringSync(
          '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
        );

      final baselineFile =
          File('${tempDirectory.path}/baseline-code-points-kebab-case.json')
            ..writeAsStringSync('''
{
  "code-points": [
    "f04b9"
  ]
}
''');
      final unresolvedReportFile = File(
        '${tempDirectory.path}/unresolved_report.json',
      );
      final outputFile = File(
        '${tempDirectory.path}/material_rough_icons.g.dart',
      );

      await tool.runGenerateRoughIcons(<String>[
        '--kit',
        'flutter-material',
        '--flutter-icons',
        flutterIconsFile.path,
        '--material-icons-source',
        materialIconsRoot.path,
        '--material-symbols-source',
        materialSymbolsRoot.path,
        '--brand-icons-source',
        brandIconsRoot.path,
        '--unresolved-baseline',
        baselineFile.path,
        '--fail-on-new-unresolved',
        '--unresolved-output',
        unresolvedReportFile.path,
        '--output',
        outputFile.path,
      ]);

      final decoded =
          jsonDecode(unresolvedReportFile.readAsStringSync())
              as Map<String, dynamic>;
      expect(decoded['baselineUnresolvedCount'], 1);
      expect(decoded['unresolvedCodePoints'], <String>['0xf04b9']);
      expect(decoded['newUnresolvedCount'], 0);
      expect(decoded['newUnresolved'], <dynamic>[]);
      expect(decoded['newUnresolvedCodePoints'], <dynamic>[]);
      expect(decoded['resolvedSinceBaselineCount'], 0);
      expect(decoded['resolvedSinceBaseline'], <dynamic>[]);
    });

    test('accepts codepoint[] format as unresolved baseline', () async {
      final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
        ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

      final materialIconsRoot = Directory(
        '${tempDirectory.path}/material-icons',
      )..createSync(recursive: true);
      final materialSymbolsRoot = Directory(
        '${tempDirectory.path}/material-symbols',
      )..createSync(recursive: true);
      final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
        ..createSync(recursive: true);

      File('${materialIconsRoot.path}/filled/label.svg')
        ..createSync(recursive: true)
        ..writeAsStringSync(
          '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
        );

      final baselineFile =
          File('${tempDirectory.path}/baseline-codepoint-singular.json')
            ..writeAsStringSync('''
{
  "codepoint": [
    "f04b9"
  ]
}
''');
      final unresolvedReportFile = File(
        '${tempDirectory.path}/unresolved_report.json',
      );
      final outputFile = File(
        '${tempDirectory.path}/material_rough_icons.g.dart',
      );

      await tool.runGenerateRoughIcons(<String>[
        '--kit',
        'flutter-material',
        '--flutter-icons',
        flutterIconsFile.path,
        '--material-icons-source',
        materialIconsRoot.path,
        '--material-symbols-source',
        materialSymbolsRoot.path,
        '--brand-icons-source',
        brandIconsRoot.path,
        '--unresolved-baseline',
        baselineFile.path,
        '--fail-on-new-unresolved',
        '--unresolved-output',
        unresolvedReportFile.path,
        '--output',
        outputFile.path,
      ]);

      final decoded =
          jsonDecode(unresolvedReportFile.readAsStringSync())
              as Map<String, dynamic>;
      expect(decoded['baselineUnresolvedCount'], 1);
      expect(decoded['unresolvedCodePoints'], <String>['0xf04b9']);
      expect(decoded['newUnresolvedCount'], 0);
      expect(decoded['newUnresolved'], <dynamic>[]);
      expect(decoded['newUnresolvedCodePoints'], <dynamic>[]);
      expect(decoded['resolvedSinceBaselineCount'], 0);
      expect(decoded['resolvedSinceBaseline'], <dynamic>[]);
    });

    test(
      'accepts lowercase codepoints[] format as unresolved baseline',
      () async {
        final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
          ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

        final materialIconsRoot = Directory(
          '${tempDirectory.path}/material-icons',
        )..createSync(recursive: true);
        final materialSymbolsRoot = Directory(
          '${tempDirectory.path}/material-symbols',
        )..createSync(recursive: true);
        final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
          ..createSync(recursive: true);

        File('${materialIconsRoot.path}/filled/label.svg')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
          );

        final baselineFile =
            File('${tempDirectory.path}/baseline-codepoints-lowercase.json')
              ..writeAsStringSync('''
{
  "codepoints": [
    "f04b9"
  ]
}
''');
        final unresolvedReportFile = File(
          '${tempDirectory.path}/unresolved_report.json',
        );
        final outputFile = File(
          '${tempDirectory.path}/material_rough_icons.g.dart',
        );

        await tool.runGenerateRoughIcons(<String>[
          '--kit',
          'flutter-material',
          '--flutter-icons',
          flutterIconsFile.path,
          '--material-icons-source',
          materialIconsRoot.path,
          '--material-symbols-source',
          materialSymbolsRoot.path,
          '--brand-icons-source',
          brandIconsRoot.path,
          '--unresolved-baseline',
          baselineFile.path,
          '--fail-on-new-unresolved',
          '--unresolved-output',
          unresolvedReportFile.path,
          '--output',
          outputFile.path,
        ]);

        final decoded =
            jsonDecode(unresolvedReportFile.readAsStringSync())
                as Map<String, dynamic>;
        expect(decoded['baselineUnresolvedCount'], 1);
        expect(decoded['unresolvedCodePoints'], <String>['0xf04b9']);
        expect(decoded['newUnresolvedCount'], 0);
        expect(decoded['newUnresolved'], <dynamic>[]);
        expect(decoded['newUnresolvedCodePoints'], <dynamic>[]);
        expect(decoded['resolvedSinceBaselineCount'], 0);
        expect(decoded['resolvedSinceBaseline'], <dynamic>[]);
      },
    );

    test(
      'reports resolvedSinceBaseline when baseline entries are now resolved',
      () async {
        final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
          ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

        final materialIconsRoot = Directory(
          '${tempDirectory.path}/material-icons',
        )..createSync(recursive: true);
        final materialSymbolsRoot = Directory(
          '${tempDirectory.path}/material-symbols',
        )..createSync(recursive: true);
        final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
          ..createSync(recursive: true);

        File('${materialIconsRoot.path}/filled/label.svg')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
          );

        final baselineFile = File('${tempDirectory.path}/baseline-mixed.json')
          ..writeAsStringSync('''
{
  "unresolved": [
    {
      "codePoint": "0xe364",
      "identifiers": ["label_outline"]
    },
    {
      "codePoint": "0xf04b9",
      "identifiers": ["adobe"]
    }
  ]
}
''');
        final unresolvedReportFile = File(
          '${tempDirectory.path}/unresolved_report.json',
        );
        final outputFile = File(
          '${tempDirectory.path}/material_rough_icons.g.dart',
        );

        await tool.runGenerateRoughIcons(<String>[
          '--kit',
          'flutter-material',
          '--flutter-icons',
          flutterIconsFile.path,
          '--material-icons-source',
          materialIconsRoot.path,
          '--material-symbols-source',
          materialSymbolsRoot.path,
          '--brand-icons-source',
          brandIconsRoot.path,
          '--unresolved-baseline',
          baselineFile.path,
          '--fail-on-new-unresolved',
          '--unresolved-output',
          unresolvedReportFile.path,
          '--output',
          outputFile.path,
        ]);

        final decoded =
            jsonDecode(unresolvedReportFile.readAsStringSync())
                as Map<String, dynamic>;
        expect(decoded['baselineUnresolvedCount'], 2);
        expect(decoded['unresolvedCodePoints'], <String>['0xf04b9']);
        expect(decoded['newUnresolvedCount'], 0);
        expect(decoded['newUnresolvedCodePoints'], <dynamic>[]);
        expect(decoded['resolvedSinceBaselineCount'], 1);
        expect(decoded['resolvedSinceBaseline'], <String>['0xe364']);
      },
    );

    test(
      'does not throw when max-new-unresolved threshold is not exceeded',
      () async {
        final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
          ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

        final materialIconsRoot = Directory(
          '${tempDirectory.path}/material-icons',
        )..createSync(recursive: true);
        final materialSymbolsRoot = Directory(
          '${tempDirectory.path}/material-symbols',
        )..createSync(recursive: true);
        final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
          ..createSync(recursive: true);

        File('${materialIconsRoot.path}/filled/label.svg')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
          );

        final baselineFile = File('${tempDirectory.path}/baseline-empty.json')
          ..writeAsStringSync('''
{
  "unresolved": []
}
''');
        final unresolvedReportFile = File(
          '${tempDirectory.path}/unresolved_report.json',
        );
        final outputFile = File(
          '${tempDirectory.path}/material_rough_icons.g.dart',
        );

        await tool.runGenerateRoughIcons(<String>[
          '--kit',
          'flutter-material',
          '--flutter-icons',
          flutterIconsFile.path,
          '--material-icons-source',
          materialIconsRoot.path,
          '--material-symbols-source',
          materialSymbolsRoot.path,
          '--brand-icons-source',
          brandIconsRoot.path,
          '--unresolved-baseline',
          baselineFile.path,
          '--max-new-unresolved',
          '1',
          '--unresolved-output',
          unresolvedReportFile.path,
          '--output',
          outputFile.path,
        ]);

        final decoded =
            jsonDecode(unresolvedReportFile.readAsStringSync())
                as Map<String, dynamic>;
        expect(decoded['baselineUnresolvedCount'], 0);
        expect(decoded['unresolvedCodePoints'], <String>['0xf04b9']);
        expect(decoded['newUnresolvedCount'], 1);
        expect(decoded['newUnresolvedCodePoints'], <String>['0xf04b9']);
        expect(decoded['wouldFail'], isFalse);
        expect(decoded['unresolvedGateFailed'], isFalse);
        expect(decoded['newUnresolvedGateFailed'], isFalse);
        expect(decoded['activeGates'], <String>['newUnresolved']);
        expect(decoded['failedGates'], <String>[]);
        expect(decoded['maxNewUnresolved'], 1);
        expect(decoded['maxNewUnresolvedExceeded'], isFalse);
        expect(decoded['unresolvedThresholdMode'], 'disabled');
        expect(decoded['newUnresolvedThresholdMode'], 'threshold');
      },
    );

    test('throws when max-new-unresolved threshold is exceeded', () async {
      final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
        ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

      final materialIconsRoot = Directory(
        '${tempDirectory.path}/material-icons',
      )..createSync(recursive: true);
      final materialSymbolsRoot = Directory(
        '${tempDirectory.path}/material-symbols',
      )..createSync(recursive: true);
      final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
        ..createSync(recursive: true);

      File('${materialIconsRoot.path}/filled/label.svg')
        ..createSync(recursive: true)
        ..writeAsStringSync(
          '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
        );

      final baselineFile = File('${tempDirectory.path}/baseline-empty.json')
        ..writeAsStringSync('''
{
  "unresolved": []
}
''');
      final unresolvedReportFile = File(
        '${tempDirectory.path}/unresolved_report.json',
      );
      final outputFile = File(
        '${tempDirectory.path}/material_rough_icons.g.dart',
      );

      await expectLater(
        tool.runGenerateRoughIcons(<String>[
          '--kit',
          'flutter-material',
          '--flutter-icons',
          flutterIconsFile.path,
          '--material-icons-source',
          materialIconsRoot.path,
          '--material-symbols-source',
          materialSymbolsRoot.path,
          '--brand-icons-source',
          brandIconsRoot.path,
          '--unresolved-baseline',
          baselineFile.path,
          '--max-new-unresolved',
          '0',
          '--unresolved-output',
          unresolvedReportFile.path,
          '--output',
          outputFile.path,
        ]),
        throwsA(isA<StateError>()),
      );

      final decoded =
          jsonDecode(unresolvedReportFile.readAsStringSync())
              as Map<String, dynamic>;
      expect(decoded['baselineUnresolvedCount'], 0);
      expect(decoded['newUnresolvedCount'], 1);
      expect(decoded['newUnresolvedCodePoints'], <String>['0xf04b9']);
      expect(decoded['wouldFail'], isTrue);
      expect(decoded['unresolvedGateFailed'], isFalse);
      expect(decoded['newUnresolvedGateFailed'], isTrue);
      expect(decoded['activeGates'], <String>['newUnresolved']);
      expect(decoded['failedGates'], <String>['newUnresolved']);
      expect(decoded['maxNewUnresolved'], 0);
      expect(decoded['maxNewUnresolvedExceeded'], isTrue);
      expect(decoded['unresolvedThresholdMode'], 'disabled');
      expect(decoded['newUnresolvedThresholdMode'], 'threshold');
    });

    test(
      'reports both failed gates when both thresholds are exceeded',
      () async {
        final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
          ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

        final materialIconsRoot = Directory(
          '${tempDirectory.path}/material-icons',
        )..createSync(recursive: true);
        final materialSymbolsRoot = Directory(
          '${tempDirectory.path}/material-symbols',
        )..createSync(recursive: true);
        final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
          ..createSync(recursive: true);

        File('${materialIconsRoot.path}/filled/label.svg')
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
          );

        final baselineFile = File('${tempDirectory.path}/baseline-empty.json')
          ..writeAsStringSync('''
{
  "unresolved": []
}
''');
        final unresolvedReportFile = File(
          '${tempDirectory.path}/unresolved_report.json',
        );
        final outputFile = File(
          '${tempDirectory.path}/material_rough_icons.g.dart',
        );

        await expectLater(
          tool.runGenerateRoughIcons(<String>[
            '--kit',
            'flutter-material',
            '--flutter-icons',
            flutterIconsFile.path,
            '--material-icons-source',
            materialIconsRoot.path,
            '--material-symbols-source',
            materialSymbolsRoot.path,
            '--brand-icons-source',
            brandIconsRoot.path,
            '--unresolved-baseline',
            baselineFile.path,
            '--max-unresolved',
            '0',
            '--max-new-unresolved',
            '0',
            '--unresolved-output',
            unresolvedReportFile.path,
            '--output',
            outputFile.path,
          ]),
          throwsA(isA<StateError>()),
        );

        final decoded =
            jsonDecode(unresolvedReportFile.readAsStringSync())
                as Map<String, dynamic>;
        expect(decoded['wouldFail'], isTrue);
        expect(decoded['unresolvedGateFailed'], isTrue);
        expect(decoded['newUnresolvedGateFailed'], isTrue);
        expect(decoded['activeGates'], <String>['unresolved', 'newUnresolved']);
        expect(decoded['failedGates'], <String>['unresolved', 'newUnresolved']);
        expect(decoded['maxUnresolvedExceeded'], isTrue);
        expect(decoded['maxNewUnresolvedExceeded'], isTrue);
        expect(decoded['unresolvedThresholdMode'], 'threshold');
        expect(decoded['newUnresolvedThresholdMode'], 'threshold');
      },
    );

    test('throws when unresolved icons regress against baseline', () async {
      final flutterIconsFile = File('${tempDirectory.path}/icons.dart')
        ..writeAsStringSync('''
class Icons {
  /// The material icon named "label outline".
  static const IconData label_outline = IconData(0xe364, fontFamily: 'MaterialIcons');

  /// The material icon named "adobe".
  static const IconData adobe = IconData(0xf04b9, fontFamily: 'MaterialIcons');
}
''');

      final materialIconsRoot = Directory(
        '${tempDirectory.path}/material-icons',
      )..createSync(recursive: true);
      final materialSymbolsRoot = Directory(
        '${tempDirectory.path}/material-symbols',
      )..createSync(recursive: true);
      final brandIconsRoot = Directory('${tempDirectory.path}/simple-icons')
        ..createSync(recursive: true);

      File('${materialIconsRoot.path}/filled/label.svg')
        ..createSync(recursive: true)
        ..writeAsStringSync(
          '<svg viewBox="0 0 24 24"><path d="M1 1h22v22H1z"/></svg>',
        );

      final baselineFile = File('${tempDirectory.path}/baseline-empty.json')
        ..writeAsStringSync('''
{
  "unresolved": []
}
''');
      final unresolvedReportFile = File(
        '${tempDirectory.path}/unresolved_report.json',
      );
      final outputFile = File(
        '${tempDirectory.path}/material_rough_icons.g.dart',
      );

      await expectLater(
        tool.runGenerateRoughIcons(<String>[
          '--kit',
          'flutter-material',
          '--flutter-icons',
          flutterIconsFile.path,
          '--material-icons-source',
          materialIconsRoot.path,
          '--material-symbols-source',
          materialSymbolsRoot.path,
          '--brand-icons-source',
          brandIconsRoot.path,
          '--unresolved-baseline',
          baselineFile.path,
          '--fail-on-new-unresolved',
          '--unresolved-output',
          unresolvedReportFile.path,
          '--output',
          outputFile.path,
        ]),
        throwsA(isA<StateError>()),
      );

      final decoded =
          jsonDecode(unresolvedReportFile.readAsStringSync())
              as Map<String, dynamic>;
      expect(decoded['baselineUnresolvedCount'], 0);
      expect(decoded['unresolvedCodePoints'], <String>['0xf04b9']);
      expect(decoded['newUnresolvedCount'], 1);
      expect(decoded['newUnresolvedCodePoints'], <String>['0xf04b9']);
      expect(decoded['wouldFail'], isTrue);
      expect(decoded['unresolvedGateFailed'], isFalse);
      expect(decoded['newUnresolvedGateFailed'], isTrue);
      expect(decoded['activeGates'], <String>['newUnresolved']);
      expect(decoded['failedGates'], <String>['newUnresolved']);
      expect(decoded['maxNewUnresolved'], 0);
      expect(decoded['maxNewUnresolvedExceeded'], isTrue);
      expect(decoded['unresolvedThresholdMode'], 'disabled');
      expect(decoded['newUnresolvedThresholdMode'], 'strict');
      expect(decoded['resolvedSinceBaselineCount'], 0);
      expect(decoded['resolvedSinceBaseline'], <dynamic>[]);

      final newUnresolved = decoded['newUnresolved'] as List<dynamic>;
      expect(newUnresolved, hasLength(1));
      final first = newUnresolved.first as Map<String, dynamic>;
      expect(first['codePoint'], '0xf04b9');
      expect(first['identifiers'], <String>['adobe']);
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
        contains("const String kMyRoughIconsFontFamily = 'my-rough-icons';"),
      );
      expect(
        rendered,
        contains('IconData? lookupMyRoughIconsIconData(String identifier) {'),
      );

      final alphaIndex = rendered.indexOf("'alpha': 0xe100");
      final betaIndex = rendered.indexOf("'beta': 0xe100");
      final zetaIndex = rendered.indexOf("'zeta': 0xe200");

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

    test('parses bare-hex and U+ codePoint string formats', () {
      final alphaSvgFile = File('${tempDirectory.path}/alpha.svg')
        ..writeAsStringSync(
          '<svg viewBox="0 0 24 24"><path d="M2 2h20v20H2z"/></svg>',
        );
      final betaSvgFile = File('${tempDirectory.path}/beta.svg')
        ..writeAsStringSync(
          '<svg viewBox="0 0 24 24"><path d="M3 3h18v18H3z"/></svg>',
        );

      final parsed = tool.parseSvgManifestDeclarationsForTest('''
{
  "icons": [
    {
      "identifier": "alpha",
      "codePoint": "e001",
      "svgPath": "alpha.svg"
    },
    {
      "identifier": "beta",
      "codePoint": "U+E002",
      "svgPath": "beta.svg"
    }
  ]
}
''', manifestDirectoryPath: tempDirectory.path);

      expect(parsed, hasLength(2));
      expect(parsed[0].identifier, 'alpha');
      expect(parsed[0].codePoint, 0xe001);
      expect(parsed[0].svgPath, alphaSvgFile.path);
      expect(parsed[1].identifier, 'beta');
      expect(parsed[1].codePoint, 0xe002);
      expect(parsed[1].svgPath, betaSvgFile.path);
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
