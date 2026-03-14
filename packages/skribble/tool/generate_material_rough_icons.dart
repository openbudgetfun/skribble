// ignore_for_file: unreachable_from_main

import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:xml/xml.dart';

import 'icon_kit_provider.dart';

const _kDefaultKit = 'flutter-material';
const _kDefaultRoughCliPath = 'tool/deno/svg2roughjs_cli.ts';
const _kDefaultRoughCliRunner = 'deno';
const _kDefaultFontGeneratorExecutable = 'npx';
const _kDefaultFontGeneratorPackage = 'fantasticon';
const _kDefaultFontName = 'material_rough_icons';

Future<void> main(List<String> args) async {
  final options = _ScriptOptions.parse(args);
  if (options.showHelp) {
    _printUsage();
    return;
  }

  if (options.fontOutputDir != null && options.roughOutputDir == null) {
    throw ArgumentError('--font-output-dir requires --rough-output-dir.');
  }

  final provider = await _createProvider(options);
  final declarations = await provider.loadDeclarations();

  final byCodePoint = SplayTreeMap<int, List<_FlutterIconDeclaration>>();
  for (final declaration in declarations) {
    byCodePoint
        .putIfAbsent(declaration.codePoint, () => <_FlutterIconDeclaration>[])
        .add(declaration);
  }

  final icons = <_GeneratedIcon>[];
  final roughTasks = <_RoughTask>[];
  final unresolved = <_UnresolvedIcon>[];

  for (final entry in byCodePoint.entries) {
    _GeneratedIcon? resolvedIcon;
    for (final declaration in entry.value) {
      final resolved = provider.resolveIcon(declaration);
      if (resolved == null) {
        continue;
      }
      resolvedIcon = _GeneratedIcon(
        codePoint: entry.key,
        identifier: declaration.identifier,
        data: resolved.data,
      );
      roughTasks.add(
        _RoughTask(
          identifier: declaration.identifier,
          codePoint: entry.key,
          inputSvgPath: resolved.sourcePath,
        ),
      );
      break;
    }

    if (resolvedIcon != null) {
      icons.add(resolvedIcon);
      continue;
    }

    unresolved.add(
      _UnresolvedIcon(
        codePoint: entry.key,
        identifiers: entry.value
            .map((item) => item.identifier)
            .toList(growable: false),
      ),
    );
  }

  if (options.roughOutputDir != null) {
    await _generateRoughSvgs(options, roughTasks);
  }

  if (options.fontOutputDir case final fontOutputDir?) {
    await _generateIconFont(
      fontOutputDir: fontOutputDir,
      roughOutputDir: options.roughOutputDir!,
      tasks: roughTasks,
      fontName: options.fontName,
      generatorExecutable: options.fontGeneratorExecutable,
      generatorPackage: options.fontGeneratorPackage,
    );
  }

  if (!options.roughOnly) {
    final outputFile = File(
      options.outputPath ?? 'lib/src/generated/material_rough_icons.g.dart',
    );
    outputFile.createSync(recursive: true);
    outputFile.writeAsStringSync(_renderGeneratedFile(icons));
    stdout.writeln(
      'Generated ${icons.length} rough icons to ${outputFile.path}',
    );
  }

  if (unresolved.isEmpty) {
    return;
  }

  stderr.writeln(
    'Warning: ${unresolved.length} Flutter icon codepoints could not be '
    'resolved to SVGs. WiredIcon will fall back to Icon for those values.',
  );
  for (final item in unresolved) {
    stderr.writeln(
      '  0x${item.codePoint.toRadixString(16)}: ${item.identifiers.join(', ')}',
    );
  }
}

void _printUsage() {
  stdout.writeln('''
Generate rough icon artifacts for WiredIcon.

Usage:
  dart run tool/generate_material_rough_icons.dart [options]

Options:
  --kit <flutter-material>         Icon kit provider to use.
  --flutter-icons <path>           Path to Flutter material icons.dart.
  --material-icons-source <path>   Path to extracted @material-design-icons/svg package.
  --material-symbols-source <path> Path to extracted @material-symbols/svg-400 package.
  --output <path>                  Output Dart file.
  --rough-cli <path>               TypeScript script that converts SVG(s) (default: tool/deno/svg2roughjs_cli.ts).
  --rough-cli-runner <exe>         Runner executable for --rough-cli (default: deno).
  --rough-output-dir <path>        Directory where roughened SVG files are written.
  --rough-seed <int>               Base deterministic seed for rough generation.
  --rough-normalize-viewbox <size> Normalize SVGs to this square viewBox before roughing.
  --rough-bulk                     Use one manifest-driven converter invocation.
  --rough-only                     Skip Dart map generation; only emit rough SVG files.
  --font-output-dir <path>         Build an icon font from rough SVGs into this directory.
  --font-name <name>               Name of generated icon font (default: material_rough_icons).
  --font-generator-executable <e>  Font generator executable (default: npx).
  --font-generator-package <name>  Package passed to generator executable (default: fantasticon).
  --help                           Show this help text.

If a source path is omitted, the script downloads the package with npm pack into
a temporary directory.
''');
}

final class _ScriptOptions {
  const _ScriptOptions({
    this.kit = _kDefaultKit,
    this.flutterIconsPath,
    this.materialIconsSourcePath,
    this.materialSymbolsSourcePath,
    this.outputPath,
    this.roughCliPath,
    this.roughCliRunner = _kDefaultRoughCliRunner,
    this.roughOutputDir,
    this.roughSeed,
    this.roughNormalizeViewBox = 128,
    this.roughBulk = false,
    this.roughOnly = false,
    this.fontOutputDir,
    this.fontName = _kDefaultFontName,
    this.fontGeneratorExecutable = _kDefaultFontGeneratorExecutable,
    this.fontGeneratorPackage = _kDefaultFontGeneratorPackage,
    this.showHelp = false,
  });

  final String kit;
  final String? flutterIconsPath;
  final String? materialIconsSourcePath;
  final String? materialSymbolsSourcePath;
  final String? outputPath;
  final String? roughCliPath;
  final String roughCliRunner;
  final String? roughOutputDir;
  final int? roughSeed;
  final double roughNormalizeViewBox;
  final bool roughBulk;
  final bool roughOnly;
  final String? fontOutputDir;
  final String fontName;
  final String fontGeneratorExecutable;
  final String fontGeneratorPackage;
  final bool showHelp;

  static _ScriptOptions parse(List<String> args) {
    var kit = _kDefaultKit;
    String? flutterIconsPath;
    String? materialIconsSourcePath;
    String? materialSymbolsSourcePath;
    String? outputPath;
    String? roughCliPath;
    var roughCliRunner = _kDefaultRoughCliRunner;
    String? roughOutputDir;
    int? roughSeed;
    var roughNormalizeViewBox = 128.0;
    var roughBulk = false;
    var roughOnly = false;
    String? fontOutputDir;
    var fontName = _kDefaultFontName;
    var fontGeneratorExecutable = _kDefaultFontGeneratorExecutable;
    var fontGeneratorPackage = _kDefaultFontGeneratorPackage;
    var showHelp = false;

    for (var index = 0; index < args.length; index++) {
      final argument = args[index];
      if (argument == '--help' || argument == '-h') {
        showHelp = true;
        continue;
      }
      if (argument == '--rough-bulk') {
        roughBulk = true;
        continue;
      }
      if (argument == '--rough-only') {
        roughOnly = true;
        continue;
      }

      String option;
      String value;
      final split = argument.split('=');
      if (split.length == 2) {
        option = split.first;
        value = split.last;
      } else {
        option = argument;
        if (!option.startsWith('--')) {
          throw ArgumentError('Unexpected argument: $argument');
        }
        if (index + 1 >= args.length) {
          throw ArgumentError('Missing value for $option');
        }
        value = args[++index];
      }

      switch (option) {
        case '--kit':
          kit = value;
        case '--flutter-icons':
          flutterIconsPath = value;
        case '--material-icons-source':
          materialIconsSourcePath = value;
        case '--material-symbols-source':
          materialSymbolsSourcePath = value;
        case '--output':
          outputPath = value;
        case '--rough-cli':
          roughCliPath = value;
        case '--rough-cli-runner':
          roughCliRunner = value;
        case '--rough-output-dir':
          roughOutputDir = value;
        case '--rough-seed':
          roughSeed = int.parse(value);
        case '--rough-normalize-viewbox':
          roughNormalizeViewBox = double.parse(value);
        case '--font-output-dir':
          fontOutputDir = value;
        case '--font-name':
          fontName = value;
        case '--font-generator-executable':
          fontGeneratorExecutable = value;
        case '--font-generator-package':
          fontGeneratorPackage = value;
        default:
          throw ArgumentError('Unknown option: $option');
      }
    }

    return _ScriptOptions(
      kit: kit,
      flutterIconsPath: flutterIconsPath,
      materialIconsSourcePath: materialIconsSourcePath,
      materialSymbolsSourcePath: materialSymbolsSourcePath,
      outputPath: outputPath,
      roughCliPath: roughCliPath,
      roughCliRunner: roughCliRunner,
      roughOutputDir: roughOutputDir,
      roughSeed: roughSeed,
      roughNormalizeViewBox: roughNormalizeViewBox,
      roughBulk: roughBulk,
      roughOnly: roughOnly,
      fontOutputDir: fontOutputDir,
      fontName: fontName,
      fontGeneratorExecutable: fontGeneratorExecutable,
      fontGeneratorPackage: fontGeneratorPackage,
      showHelp: showHelp,
    );
  }
}

Future<String> _discoverFlutterIconsPath() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null && flutterRoot.isNotEmpty) {
    return '$flutterRoot/packages/flutter/lib/src/material/icons.dart';
  }

  final result = await Process.run('flutter', const <String>[
    '--version',
    '--machine',
  ]);
  if (result.exitCode != 0) {
    throw StateError(
      'Unable to resolve FLUTTER_ROOT. flutter --version --machine failed:\n'
      '${result.stderr}',
    );
  }

  final decoded = jsonDecode(result.stdout as String) as Map<String, dynamic>;
  final root = decoded['flutterRoot'] as String?;
  if (root == null || root.isEmpty) {
    throw StateError('flutter --version --machine did not return flutterRoot');
  }
  return '$root/packages/flutter/lib/src/material/icons.dart';
}

Future<Directory> _resolvePackageRoot({
  required String packageName,
  required String? suppliedPath,
}) async {
  if (suppliedPath != null) {
    final directory = Directory(suppliedPath);
    if (!directory.existsSync()) {
      throw StateError('Package source does not exist: $suppliedPath');
    }
    return directory;
  }

  final tempDirectory = await Directory.systemTemp.createTemp(
    packageName.replaceAll(RegExp('[^a-zA-Z0-9]+'), '_'),
  );

  final packResult = await Process.run('npm', <String>[
    'pack',
    packageName,
  ], workingDirectory: tempDirectory.path);
  if (packResult.exitCode != 0) {
    throw StateError('npm pack $packageName failed:\n${packResult.stderr}');
  }

  final archiveName = (packResult.stdout as String).trim().split('\n').last;
  final archivePath = '${tempDirectory.path}/$archiveName';
  final extractResult = await Process.run('tar', <String>[
    '-xzf',
    archivePath,
  ], workingDirectory: tempDirectory.path);
  if (extractResult.exitCode != 0) {
    throw StateError(
      'tar extraction for $packageName failed:\n${extractResult.stderr}',
    );
  }

  return Directory('${tempDirectory.path}/package');
}

Future<
  IconKitProvider<
    _FlutterIconDeclaration,
    ResolvedSvgCandidate<_GeneratedIconData>
  >
>
_createProvider(_ScriptOptions options) async {
  switch (options.kit) {
    case _kDefaultKit:
      final flutterIconsFile = File(
        options.flutterIconsPath ?? await _discoverFlutterIconsPath(),
      );
      if (!flutterIconsFile.existsSync()) {
        throw StateError(
          'Flutter icons file not found: ${flutterIconsFile.path}',
        );
      }
      final materialIconsRoot = await _resolvePackageRoot(
        packageName: '@material-design-icons/svg',
        suppliedPath: options.materialIconsSourcePath,
      );
      final materialSymbolsRoot = await _resolvePackageRoot(
        packageName: '@material-symbols/svg-400',
        suppliedPath: options.materialSymbolsSourcePath,
      );

      return _MaterialIconKitProvider(
        flutterIconsFile: flutterIconsFile,
        materialIconsRoot: materialIconsRoot,
        materialSymbolsRoot: materialSymbolsRoot,
      );
    default:
      throw ArgumentError(
        'Unknown --kit value: ${options.kit}. Supported: $_kDefaultKit',
      );
  }
}

final class _MaterialIconKitProvider
    implements
        IconKitProvider<
          _FlutterIconDeclaration,
          ResolvedSvgCandidate<_GeneratedIconData>
        > {
  const _MaterialIconKitProvider({
    required this.flutterIconsFile,
    required this.materialIconsRoot,
    required this.materialSymbolsRoot,
  });

  final File flutterIconsFile;
  final Directory materialIconsRoot;
  final Directory materialSymbolsRoot;

  @override
  Future<List<_FlutterIconDeclaration>> loadDeclarations() async {
    return _parseFlutterIconDeclarations(flutterIconsFile);
  }

  @override
  ResolvedSvgCandidate<_GeneratedIconData>? resolveIcon(
    _FlutterIconDeclaration declaration,
  ) {
    return _resolveIconData(
      declaration,
      materialIconsRoot: materialIconsRoot,
      materialSymbolsRoot: materialSymbolsRoot,
    );
  }
}

List<_FlutterIconDeclaration> _parseFlutterIconDeclarations(File file) {
  return _parseFlutterIconDeclarationsFromSource(file.readAsStringSync());
}

List<ParsedFlutterIconDeclaration> parseFlutterIconDeclarationsForTest(
  String source,
) {
  return _parseFlutterIconDeclarationsFromSource(source)
      .map(
        (declaration) => ParsedFlutterIconDeclaration(
          identifier: declaration.identifier,
          baseIdentifier: declaration.baseIdentifier,
          codePoint: declaration.codePoint,
          svgName: declaration.svgName,
          oldPackageFolder: declaration.oldPackageFolder,
          symbolPackageFolder: declaration.symbolPackageFolder,
          useSymbolFillVariant: declaration.useSymbolFillVariant,
        ),
      )
      .toList(growable: false);
}

List<_FlutterIconDeclaration> _parseFlutterIconDeclarationsFromSource(
  String text,
) {
  final declarationPattern = RegExp(
    r'((?:^\s*///.*\n)*)\s*static const IconData (\w+) = IconData\(\s*(0x[0-9a-fA-F]+)\s*,',
    multiLine: true,
  );
  final materialNamePattern = RegExp(
    r'material icon named "([^"]+)"(?: \((outlined|round|sharp)\))?',
  );

  return declarationPattern
      .allMatches(text)
      .map((match) {
        final docs = match.group(1) ?? '';
        final identifier = match.group(2)!;
        final codePointText = match.group(3)!;
        final infoMatch = materialNamePattern.firstMatch(docs);
        final baseIdentifier = _stripStyleSuffix(identifier);
        final styleTag =
            infoMatch?.group(2) ?? _styleTagFromIdentifier(identifier);

        return _FlutterIconDeclaration(
          identifier: identifier,
          baseIdentifier: baseIdentifier,
          codePoint: int.parse(codePointText.substring(2), radix: 16),
          svgName: infoMatch?.group(1)?.replaceAll(' ', '_') ?? baseIdentifier,
          oldPackageFolder: switch (styleTag) {
            'outlined' => 'outlined',
            'round' => 'round',
            'sharp' => 'sharp',
            _ => 'filled',
          },
          symbolPackageFolder: switch (styleTag) {
            'outlined' => 'outlined',
            'round' => 'rounded',
            'sharp' => 'sharp',
            _ => 'outlined',
          },
          useSymbolFillVariant: styleTag != 'outlined',
        );
      })
      .toList(growable: false);
}

String? _styleTagFromIdentifier(String identifier) {
  if (identifier.endsWith('_outlined')) {
    return 'outlined';
  }
  if (identifier.endsWith('_rounded')) {
    return 'round';
  }
  if (identifier.endsWith('_sharp')) {
    return 'sharp';
  }
  return null;
}

String _stripStyleSuffix(String identifier) {
  for (final suffix in const <String>['_outlined', '_rounded', '_sharp']) {
    if (identifier.endsWith(suffix)) {
      return identifier.substring(0, identifier.length - suffix.length);
    }
  }
  return identifier;
}

ResolvedSvgCandidate<_GeneratedIconData>? _resolveIconData(
  _FlutterIconDeclaration declaration, {
  required Directory materialIconsRoot,
  required Directory materialSymbolsRoot,
}) {
  final candidates = <String>{
    declaration.svgName,
    declaration.baseIdentifier,
    ...?_svgAliases[declaration.baseIdentifier],
  };

  for (final candidate in candidates) {
    final materialIconsFile = File(
      '${materialIconsRoot.path}/${declaration.oldPackageFolder}/$candidate.svg',
    );
    if (materialIconsFile.existsSync()) {
      return ResolvedSvgCandidate<_GeneratedIconData>(
        data: _parseSvgIcon(materialIconsFile),
        sourcePath: materialIconsFile.path,
      );
    }

    final symbolBase =
        '${materialSymbolsRoot.path}/${declaration.symbolPackageFolder}/$candidate';
    final symbolCandidates = declaration.useSymbolFillVariant
        ? <String>['$symbolBase-fill.svg', '$symbolBase.svg']
        : <String>['$symbolBase.svg'];

    for (final path in symbolCandidates) {
      final file = File(path);
      if (file.existsSync()) {
        return ResolvedSvgCandidate<_GeneratedIconData>(
          data: _parseSvgIcon(file),
          sourcePath: file.path,
        );
      }
    }
  }

  return null;
}

const Map<String, List<String>> _svgAliases = <String, List<String>>{
  'airplanemode_off': <String>['airplanemode_inactive'],
  'airplanemode_on': <String>['airplanemode_active'],
  'block_flipped': <String>['block'],
  'bookmark_outline': <String>['bookmark_border'],
  'cloudy_snowing': <String>['weather_snowy'],
  'confirmation_num': <String>['confirmation_number'],
  'copy': <String>['content_copy'],
  'cut': <String>['content_cut'],
  'directions_ferry': <String>['directions_boat'],
  'directions_train': <String>['directions_railway'],
  'dnd_forwardslash': <String>['do_not_disturb_on_total_silence'],
  'drive_file_move_outline': <String>['drive_file_move'],
  'emoji_flags': <String>['flag'],
  'exposure_minus_1': <String>['exposure_neg_1'],
  'exposure_minus_2': <String>['exposure_neg_2'],
  'favorite_outline': <String>['favorite_border'],
  'filter_list_alt': <String>['filter_alt'],
  'flourescent': <String>['fluorescent'],
  'format_underline': <String>['format_underlined'],
  'highlight_remove': <String>['highlight_off'],
  'home_filled': <String>['home'],
  'info_outline': <String>['info'],
  'invert_colors_on': <String>['invert_colors'],
  'keyboard_control': <String>['keyboard_control_key'],
  'label_important_outline': <String>['label_important'],
  'leave_bags_at_home': <String>['no_luggage'],
  'lightbulb_outline': <String>['lightbulb'],
  'local_attraction': <String>['local_activity'],
  'local_print_shop': <String>['local_printshop'],
  'local_restaurant': <String>['local_dining'],
  'location_pin': <String>['location_on'],
  'lock_outline': <String>['lock'],
  'multitrack_audio': <String>['library_music'],
  'my_library_add': <String>['library_add'],
  'my_library_books': <String>['library_books'],
  'my_library_music': <String>['library_music'],
  'no_meals_ouline': <String>['no_meals'],
  'notifications_on': <String>['notifications_active'],
  'now_wallpaper': <String>['wallpaper'],
  'now_widgets': <String>['widgets'],
  'outbond': <String>['outbound'],
  'panorama_fisheye': <String>['panorama_fish_eye'],
  'paste': <String>['content_paste'],
  'perm_contact_cal': <String>['perm_contact_calendar'],
  'perm_device_info': <String>['perm_device_information'],
  'play_circle_fill': <String>['play_circle_filled'],
  'quick_contacts_dialer': <String>['contact_phone'],
  'quick_contacts_mail': <String>['contact_mail'],
  'radio_button_off': <String>['radio_button_unchecked'],
  'radio_button_on': <String>['radio_button_checked'],
  'settings_display': <String>['display_settings'],
  'share_arrival_time': <String>['share_eta'],
  'swap_vert_circle': <String>['swap_vertical_circle'],
  'system_update_tv': <String>['system_update'],
  'trending_neutral': <String>['trending_flat'],
  'video_collection': <String>['video_library'],
  'view_comfortable': <String>['view_comfy'],
  'volume_down_alt': <String>['volume_down'],
  'wallet_giftcard': <String>['card_giftcard'],
  'wallet_membership': <String>['card_membership'],
  'wallet_travel': <String>['card_travel'],
  'wb_twighlight': <String>['wb_twilight'],
  'workspaces_filled': <String>['workspaces'],
  'workspaces_outline': <String>['workspaces'],
};

_GeneratedIconData _parseSvgIcon(File file) {
  final document = XmlDocument.parse(file.readAsStringSync());
  final root = document.rootElement;
  final viewBox = root.getAttribute('viewBox');

  var width = _parseDouble(root.getAttribute('width')) ?? 24;
  var height = _parseDouble(root.getAttribute('height')) ?? 24;

  if (viewBox != null) {
    final parts = viewBox
        .split(RegExp(r'[\s,]+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.length == 4) {
      width = double.parse(parts[2]);
      height = double.parse(parts[3]);
    }
  }

  final primitives = _collectPrimitives(
    root,
    inheritedFillRule: _SvgFillRule.nonZero,
  );

  return _GeneratedIconData(
    width: width,
    height: height,
    primitives: primitives,
  );
}

List<_PrimitiveData> _collectPrimitives(
  XmlElement element, {
  required _SvgFillRule inheritedFillRule,
}) {
  final localName = element.name.local;
  final effectiveFillRule =
      _parseFillRule(
        element.getAttribute('fill-rule') ?? element.getAttribute('clip-rule'),
      ) ??
      inheritedFillRule;

  switch (localName) {
    case 'svg':
    case 'g':
      final primitives = <_PrimitiveData>[];
      for (final child in element.children.whereType<XmlElement>()) {
        primitives.addAll(
          _collectPrimitives(child, inheritedFillRule: effectiveFillRule),
        );
      }
      return primitives;
    case 'path':
      if (element.getAttribute('fill') == 'none') {
        return const <_PrimitiveData>[];
      }
      final data = element.getAttribute('d');
      if (data == null || data.isEmpty) {
        return const <_PrimitiveData>[];
      }
      return <_PrimitiveData>[
        _PathPrimitiveData(data: data, fillRule: effectiveFillRule),
      ];
    case 'circle':
      if (element.getAttribute('fill') == 'none') {
        return const <_PrimitiveData>[];
      }
      return <_PrimitiveData>[
        _CirclePrimitiveData(
          cx: _requireDouble(element, 'cx'),
          cy: _requireDouble(element, 'cy'),
          radius: _requireDouble(element, 'r'),
          fillRule: effectiveFillRule,
        ),
      ];
    case 'ellipse':
      if (element.getAttribute('fill') == 'none') {
        return const <_PrimitiveData>[];
      }
      return <_PrimitiveData>[
        _EllipsePrimitiveData(
          cx: _requireDouble(element, 'cx'),
          cy: _requireDouble(element, 'cy'),
          radiusX: _requireDouble(element, 'rx'),
          radiusY: _requireDouble(element, 'ry'),
          fillRule: effectiveFillRule,
        ),
      ];
    default:
      return const <_PrimitiveData>[];
  }
}

double _requireDouble(XmlElement element, String attributeName) {
  final value = _parseDouble(element.getAttribute(attributeName));
  if (value == null) {
    throw StateError(
      'Missing $attributeName on <${element.name.local}> in '
      '${element.toXmlString()}',
    );
  }
  return value;
}

double? _parseDouble(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  final match = RegExp(r'-?\d+(?:\.\d+)?').firstMatch(value);
  if (match == null) {
    return null;
  }
  return double.parse(match.group(0)!);
}

_SvgFillRule? _parseFillRule(String? value) {
  return switch (value) {
    'evenodd' => _SvgFillRule.evenOdd,
    'nonzero' => _SvgFillRule.nonZero,
    _ => null,
  };
}

String _renderGeneratedFile(List<_GeneratedIcon> icons) {
  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// ignore_for_file: lines_longer_than_80_chars')
    ..writeln()
    ..writeln("import '../wired_svg_icon_data.dart';")
    ..writeln()
    ..writeln(
      'const Map<int, WiredSvgIconData> kMaterialRoughIcons = '
      '<int, WiredSvgIconData>{',
    );

  for (final icon in icons) {
    buffer
      ..writeln('  // ${icon.identifier}')
      ..writeln('  0x${icon.codePoint.toRadixString(16)}: WiredSvgIconData(')
      ..writeln('    width: ${_formatDouble(icon.data.width)},')
      ..writeln('    height: ${_formatDouble(icon.data.height)},')
      ..writeln('    primitives: <WiredSvgPrimitive>[');

    for (final primitive in icon.data.primitives) {
      buffer.writeln('      ${primitive.render()},');
    }

    buffer
      ..writeln('    ],')
      ..writeln('  ),');
  }

  buffer
    ..writeln('};')
    ..writeln();

  return buffer.toString();
}

String _formatDouble(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(1)
      : value.toString();
}

String _resolveRoughCliScriptPath(String? providedPath) {
  final candidates = <String>[
    ?providedPath,
    _kDefaultRoughCliPath,
    'packages/skribble/$_kDefaultRoughCliPath',
  ];

  for (final candidate in candidates) {
    if (File(candidate).existsSync()) {
      return candidate;
    }
  }

  throw StateError(
    'Rough CLI script not found. Tried: ${candidates.join(', ')}\n'
    'Use the Deno script at packages/skribble/tool/deno and/or pass '
    '--rough-cli explicitly.',
  );
}

List<String> _buildRoughCliArguments({
  required String runnerExecutable,
  required String scriptPath,
  required List<String> scriptArguments,
}) {
  if (runnerExecutable == 'deno') {
    return <String>['run', '-A', scriptPath, ...scriptArguments];
  }

  return <String>[scriptPath, ...scriptArguments];
}

Future<void> _generateRoughSvgs(
  _ScriptOptions options,
  List<_RoughTask> tasks,
) async {
  if (tasks.isEmpty) {
    return;
  }

  final outputDir = Directory(options.roughOutputDir!);
  outputDir.createSync(recursive: true);

  final normalizedInputDir = await Directory.systemTemp.createTemp(
    'material_rough_normalized_',
  );
  final normalizedOutputDir = await Directory.systemTemp.createTemp(
    'material_rough_normalized_output_',
  );

  try {
    final normalizedTasks = <_RoughTask>[];
    for (final task in tasks) {
      normalizedTasks.add(
        _RoughTask(
          identifier: task.identifier,
          codePoint: task.codePoint,
          inputSvgPath: _normalizeSvgForRough(
            inputPath: task.inputSvgPath,
            outputDirectory: normalizedInputDir,
            normalizeViewBoxSize: options.roughNormalizeViewBox,
          ),
        ),
      );
    }

    final cliScriptPath = _resolveRoughCliScriptPath(options.roughCliPath);

    final cliRunner = options.roughCliRunner;
    final seedBase = options.roughSeed ?? 1337;
    final useManifestMode = options.roughBulk || cliRunner == 'deno';

    if (useManifestMode) {
      final manifestFile = File(
        '${normalizedOutputDir.path}/rough_manifest.json',
      );
      final manifestTasks = normalizedTasks
          .map(
            (task) => <String, Object>{
              'input': task.inputSvgPath,
              'output': '${normalizedOutputDir.path}/${task.outputFileName}',
              'seed': seedBase + task.codePoint,
            },
          )
          .toList(growable: false);
      manifestFile.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(manifestTasks),
      );

      final runnerArguments = _buildRoughCliArguments(
        runnerExecutable: cliRunner,
        scriptPath: cliScriptPath,
        scriptArguments: <String>['--manifest', manifestFile.path],
      );
      await _runRoughCli(
        executable: cliRunner,
        arguments: runnerArguments,
        context: 'rough generation for ${normalizedTasks.length} icon(s)',
      );
    } else {
      for (final task in normalizedTasks) {
        final outputPath = '${normalizedOutputDir.path}/${task.outputFileName}';
        final seed = seedBase + task.codePoint;
        final runnerArguments = _buildRoughCliArguments(
          runnerExecutable: cliRunner,
          scriptPath: cliScriptPath,
          scriptArguments: <String>[
            '--input',
            task.inputSvgPath,
            '--output',
            outputPath,
            '--seed',
            '$seed',
          ],
        );
        await _runRoughCli(
          executable: cliRunner,
          arguments: runnerArguments,
          context: 'rough generation for ${task.identifier}',
        );
      }
    }

    for (var index = 0; index < tasks.length; index++) {
      final originalTask = tasks[index];
      final normalizedTask = normalizedTasks[index];
      final roughOutputPath =
          '${normalizedOutputDir.path}/${normalizedTask.outputFileName}';
      final finalOutputPath =
          '${outputDir.path}/${originalTask.outputFileName}';
      _scaleRoughSvgBackToTarget(
        originalInputPath: originalTask.inputSvgPath,
        roughInputPath: roughOutputPath,
        outputPath: finalOutputPath,
        normalizeViewBoxSize: options.roughNormalizeViewBox,
      );
    }

    stdout.writeln('Generated ${tasks.length} rough SVGs in ${outputDir.path}');
  } finally {
    if (normalizedInputDir.existsSync()) {
      normalizedInputDir.deleteSync(recursive: true);
    }
    if (normalizedOutputDir.existsSync()) {
      normalizedOutputDir.deleteSync(recursive: true);
    }
  }
}

Future<void> _generateIconFont({
  required String fontOutputDir,
  required String roughOutputDir,
  required List<_RoughTask> tasks,
  required String fontName,
  required String generatorExecutable,
  required String generatorPackage,
}) async {
  if (tasks.isEmpty) {
    stdout.writeln('No rough icons to convert into a font.');
    return;
  }

  final roughDir = Directory(roughOutputDir);
  if (!roughDir.existsSync()) {
    throw StateError('Rough SVG directory does not exist: $roughOutputDir');
  }

  final outputDir = Directory(fontOutputDir)..createSync(recursive: true);
  final configFile = File('${outputDir.path}/fantasticon.config.json');
  final config = <String, Object>{
    'inputDir': roughDir.path,
    'outputDir': outputDir.path,
    'name': fontName,
    'fontTypes': <String>['ttf'],
    'assetTypes': <String>['json'],
    'pathOptions': <String, Object>{'json': './${fontName}_codepoints.json'},
    'formatOptions': <String, Object>{
      'json': <String, Object>{'indent': 2},
    },
    'codepoints': <String, int>{
      for (final task in tasks) task.glyphId: task.codePoint,
    },
  };
  configFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(config),
  );

  final arguments = generatorExecutable == 'npx'
      ? <String>['--yes', generatorPackage, '--config', configFile.path]
      : <String>[generatorPackage, '--config', configFile.path];

  final result = await Process.run(generatorExecutable, arguments);
  if (result.exitCode != 0) {
    final output = [
      if ((result.stdout as String?)?.trim().isNotEmpty ?? false)
        (result.stdout as String).trim(),
      if ((result.stderr as String?)?.trim().isNotEmpty ?? false)
        (result.stderr as String).trim(),
    ].join('\n');
    throw StateError(
      'Icon font generation failed (exit ${result.exitCode}).\n$output',
    );
  }

  stdout.writeln('Generated icon font "$fontName" in ${outputDir.path}');
}

String _normalizeSvgForRough({
  required String inputPath,
  required Directory outputDirectory,
  required double normalizeViewBoxSize,
}) {
  final inputFile = File(inputPath);
  final document = XmlDocument.parse(inputFile.readAsStringSync());
  final root = document.rootElement;

  final size = _resolveSvgSize(root);
  final scaleX = normalizeViewBoxSize / size.width;
  final scaleY = normalizeViewBoxSize / size.height;

  root.setAttribute('width', _formatDouble(normalizeViewBoxSize));
  root.setAttribute('height', _formatDouble(normalizeViewBoxSize));
  root.setAttribute(
    'viewBox',
    '0 0 ${_formatDouble(normalizeViewBoxSize)} ${_formatDouble(normalizeViewBoxSize)}',
  );

  final wrappedChildren = root.children.toList(growable: false);
  root.children.clear();
  final group = XmlElement(XmlName('g'), <XmlAttribute>[
    XmlAttribute(
      XmlName('transform'),
      'scale(${_formatDouble(scaleX)} ${_formatDouble(scaleY)})',
    ),
  ], wrappedChildren);
  root.children.add(group);

  final outputPath =
      '${outputDirectory.path}/${inputFile.uri.pathSegments.last}';
  File(outputPath)
    ..createSync(recursive: true)
    ..writeAsStringSync(document.toXmlString(pretty: false));
  return outputPath;
}

void _scaleRoughSvgBackToTarget({
  required String originalInputPath,
  required String roughInputPath,
  required String outputPath,
  required double normalizeViewBoxSize,
}) {
  final originalDocument = XmlDocument.parse(
    File(originalInputPath).readAsStringSync(),
  );
  final originalRoot = originalDocument.rootElement;
  final targetSize = _resolveSvgSize(originalRoot);

  final roughDocument = XmlDocument.parse(
    File(roughInputPath).readAsStringSync(),
  );
  final roughRoot = roughDocument.rootElement;

  final scaleX = targetSize.width / normalizeViewBoxSize;
  final scaleY = targetSize.height / normalizeViewBoxSize;

  roughRoot.setAttribute('width', _formatDouble(targetSize.width));
  roughRoot.setAttribute('height', _formatDouble(targetSize.height));
  roughRoot.setAttribute(
    'viewBox',
    '0 0 ${_formatDouble(targetSize.width)} ${_formatDouble(targetSize.height)}',
  );

  final wrappedChildren = roughRoot.children.toList(growable: false);
  roughRoot.children.clear();
  final group = XmlElement(XmlName('g'), <XmlAttribute>[
    XmlAttribute(
      XmlName('transform'),
      'scale(${_formatDouble(scaleX)} ${_formatDouble(scaleY)})',
    ),
  ], wrappedChildren);
  roughRoot.children.add(group);

  File(outputPath)
    ..createSync(recursive: true)
    ..writeAsStringSync(roughDocument.toXmlString(pretty: false));
}

_ResolvedSvgSize _resolveSvgSize(XmlElement root) {
  var width = _parseDouble(root.getAttribute('width')) ?? 24;
  var height = _parseDouble(root.getAttribute('height')) ?? 24;

  final viewBox = root.getAttribute('viewBox');
  if (viewBox != null) {
    final parts = viewBox
        .split(RegExp(r'[\s,]+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.length == 4) {
      width = double.parse(parts[2]);
      height = double.parse(parts[3]);
    }
  }

  return _ResolvedSvgSize(width: width, height: height);
}

Future<void> _runRoughCli({
  required String executable,
  required List<String> arguments,
  required String context,
}) async {
  ProcessResult result;
  try {
    result = await Process.run(executable, arguments);
  } on ProcessException catch (error) {
    throw StateError('Failed to execute $executable for $context: $error');
  }

  if (result.exitCode == 0) {
    return;
  }

  final stderrOutput = (result.stderr as String?)?.trim() ?? '';
  final stdoutOutput = (result.stdout as String?)?.trim() ?? '';
  final output = [
    if (stdoutOutput.isNotEmpty) stdoutOutput,
    if (stderrOutput.isNotEmpty) stderrOutput,
  ].join('\n');
  throw StateError(
    'svg2roughjs failed during $context (exit ${result.exitCode}).\n$output',
  );
}

enum _SvgFillRule { nonZero, evenOdd }

final class _FlutterIconDeclaration {
  const _FlutterIconDeclaration({
    required this.identifier,
    required this.baseIdentifier,
    required this.codePoint,
    required this.svgName,
    required this.oldPackageFolder,
    required this.symbolPackageFolder,
    required this.useSymbolFillVariant,
  });

  final String identifier;
  final String baseIdentifier;
  final int codePoint;
  final String svgName;
  final String oldPackageFolder;
  final String symbolPackageFolder;
  final bool useSymbolFillVariant;
}

final class _GeneratedIcon {
  const _GeneratedIcon({
    required this.codePoint,
    required this.identifier,
    required this.data,
  });

  final int codePoint;
  final String identifier;
  final _GeneratedIconData data;
}

final class _UnresolvedIcon {
  const _UnresolvedIcon({required this.codePoint, required this.identifiers});

  final int codePoint;
  final List<String> identifiers;
}

final class _GeneratedIconData {
  const _GeneratedIconData({
    required this.width,
    required this.height,
    required this.primitives,
  });

  final double width;
  final double height;
  final List<_PrimitiveData> primitives;
}

final class ParsedFlutterIconDeclaration {
  const ParsedFlutterIconDeclaration({
    required this.identifier,
    required this.baseIdentifier,
    required this.codePoint,
    required this.svgName,
    required this.oldPackageFolder,
    required this.symbolPackageFolder,
    required this.useSymbolFillVariant,
  });

  final String identifier;
  final String baseIdentifier;
  final int codePoint;
  final String svgName;
  final String oldPackageFolder;
  final String symbolPackageFolder;
  final bool useSymbolFillVariant;
}

final class _ResolvedSvgSize {
  const _ResolvedSvgSize({required this.width, required this.height});

  final double width;
  final double height;
}

final class _RoughTask {
  const _RoughTask({
    required this.identifier,
    required this.codePoint,
    required this.inputSvgPath,
  });

  final String identifier;
  final int codePoint;
  final String inputSvgPath;

  String get glyphId => '${identifier}_0x${codePoint.toRadixString(16)}';

  String get outputFileName => '$glyphId.rough.svg';
}

sealed class _PrimitiveData {
  const _PrimitiveData(this.fillRule);

  final _SvgFillRule fillRule;

  String render();

  String renderFillRule() {
    if (fillRule == _SvgFillRule.nonZero) {
      return '';
    }
    return ', fillRule: WiredSvgFillRule.evenOdd';
  }
}

final class _PathPrimitiveData extends _PrimitiveData {
  const _PathPrimitiveData({required this.data, required _SvgFillRule fillRule})
    : super(fillRule);

  final String data;

  @override
  String render() {
    final escaped = data.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
    return "WiredSvgPrimitive.path('$escaped'${renderFillRule()})";
  }
}

final class _CirclePrimitiveData extends _PrimitiveData {
  const _CirclePrimitiveData({
    required this.cx,
    required this.cy,
    required this.radius,
    required _SvgFillRule fillRule,
  }) : super(fillRule);

  final double cx;
  final double cy;
  final double radius;

  @override
  String render() {
    return 'WiredSvgPrimitive.circle('
        'cx: ${_formatDouble(cx)}, '
        'cy: ${_formatDouble(cy)}, '
        'radius: ${_formatDouble(radius)}'
        '${renderFillRule()})';
  }
}

final class _EllipsePrimitiveData extends _PrimitiveData {
  const _EllipsePrimitiveData({
    required this.cx,
    required this.cy,
    required this.radiusX,
    required this.radiusY,
    required _SvgFillRule fillRule,
  }) : super(fillRule);

  final double cx;
  final double cy;
  final double radiusX;
  final double radiusY;

  @override
  String render() {
    return 'WiredSvgPrimitive.ellipse('
        'cx: ${_formatDouble(cx)}, '
        'cy: ${_formatDouble(cy)}, '
        'radiusX: ${_formatDouble(radiusX)}, '
        'radiusY: ${_formatDouble(radiusY)}'
        '${renderFillRule()})';
  }
}
