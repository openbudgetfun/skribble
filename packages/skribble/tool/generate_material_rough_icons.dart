// ignore_for_file: unreachable_from_main

import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:xml/xml.dart';

import 'icon_kit_provider.dart';

const _kDefaultKit = 'flutter-material';
const _kManifestKit = 'svg-manifest';
const _kDefaultRoughCliPath = 'tool/deno/svg2roughjs_cli.ts';
const _kDefaultRoughCliRunner = 'deno';
const _kDefaultFontGeneratorExecutable = 'npx';
const _kDefaultFontGeneratorPackage = 'fantasticon';
const _kDefaultBrandIconsPackage = 'simple-icons';
const _kDefaultFontName = 'material_rough_icons';
const _kUnresolvedBaselineOutputFormatUnresolved = 'unresolved';
const _kUnresolvedBaselineOutputFormatCodePoints = 'codepoints';
const _kUnresolvedBaselineOutputFormats = <String>{
  _kUnresolvedBaselineOutputFormatUnresolved,
  _kUnresolvedBaselineOutputFormatCodePoints,
};
const _kSupportedKitDescriptions = <String, String>{
  _kDefaultKit:
      'Flutter Material Icons (from Flutter icons.dart + Material SVG packages)',
  _kManifestKit: 'Custom SVG manifest file for non-Material icon kits',
};

Future<void> main(List<String> args) => runGenerateRoughIcons(args);

Future<void> runGenerateRoughIcons(List<String> args) async {
  final options = _ScriptOptions.parse(args);
  if (options.showHelp) {
    _printUsage();
    return;
  }

  if (options.listKits) {
    _printSupportedKits();
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
  final fontGlyphs = <_FontGlyph>[];
  final unresolved = <_UnresolvedIcon>[];

  for (final entry in byCodePoint.entries) {
    final declarationsForCodePoint = entry.value;
    _FlutterIconDeclaration? resolvedDeclaration;
    ResolvedSvgCandidate<_GeneratedIconData>? resolvedCandidate;

    for (final declaration in declarationsForCodePoint) {
      final resolved = provider.resolveIcon(declaration);
      if (resolved == null) {
        continue;
      }
      resolvedDeclaration = declaration;
      resolvedCandidate = resolved;
      break;
    }

    if (resolvedDeclaration != null && resolvedCandidate != null) {
      icons.add(
        _GeneratedIcon(
          codePoint: entry.key,
          identifier: resolvedDeclaration.identifier,
          data: resolvedCandidate.data,
        ),
      );
      roughTasks.add(
        _RoughTask(
          identifier: resolvedDeclaration.identifier,
          codePoint: entry.key,
          inputSvgPath: resolvedCandidate.sourcePath,
        ),
      );
      for (final declaration in declarationsForCodePoint) {
        fontGlyphs.add(
          _FontGlyph(identifier: declaration.identifier, codePoint: entry.key),
        );
      }
      continue;
    }

    unresolved.add(
      _UnresolvedIcon(
        codePoint: entry.key,
        identifiers: declarationsForCodePoint
            .map((item) => item.identifier)
            .toList(growable: false),
      ),
    );
  }

  final baselineUnresolvedCodePoints = _loadUnresolvedBaselineCodePoints(
    options.unresolvedBaselinePath,
  );
  final unresolvedCodePoints = unresolved.map((item) => item.codePoint).toSet();
  final newUnresolved = baselineUnresolvedCodePoints == null
      ? null
      : unresolved
            .where(
              (item) => !baselineUnresolvedCodePoints.contains(item.codePoint),
            )
            .toList(growable: false);
  final resolvedSinceBaseline = baselineUnresolvedCodePoints == null
      ? null
      : (() {
          final resolved = baselineUnresolvedCodePoints
              .where((codePoint) => !unresolvedCodePoints.contains(codePoint))
              .toList(growable: false);
          resolved.sort();
          return resolved;
        })();
  final unresolvedThreshold = options.failOnUnresolved
      ? 0
      : options.maxUnresolved;
  final newUnresolvedThreshold = options.failOnNewUnresolved
      ? 0
      : options.maxNewUnresolved;
  final unresolvedThresholdMode = _resolveThresholdMode(
    strictModeEnabled: options.failOnUnresolved,
    thresholdOption: options.maxUnresolved,
  );
  final newUnresolvedThresholdMode = _resolveThresholdMode(
    strictModeEnabled: options.failOnNewUnresolved,
    thresholdOption: options.maxNewUnresolved,
  );
  final thresholdFailure =
      unresolvedThreshold != null && unresolved.length > unresolvedThreshold;
  final newUnresolvedCount = newUnresolved?.length ?? 0;
  final newUnresolvedThresholdFailure =
      newUnresolvedThreshold != null &&
      newUnresolvedCount > newUnresolvedThreshold;
  final shouldFail = thresholdFailure || newUnresolvedThresholdFailure;

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

  if (options.fontDartOutputPath case final outputPath?) {
    final outputFile = File(outputPath)..createSync(recursive: true);
    outputFile.writeAsStringSync(
      _renderFontCodePointsDart(fontName: options.fontName, glyphs: fontGlyphs),
    );
    stdout.writeln('Generated icon font Dart helpers to ${outputFile.path}');
  }

  if (!options.roughOnly) {
    final outputFile = File(
      options.outputPath ?? _defaultOutputPathForKit(options.kit),
    );
    outputFile.createSync(recursive: true);
    outputFile.writeAsStringSync(_renderGeneratedFile(icons));
    stdout.writeln(
      'Generated ${icons.length} rough icons to ${outputFile.path}',
    );
  }

  if (options.unresolvedOutputPath case final unresolvedOutputPath?) {
    final unresolvedOutputFile = File(unresolvedOutputPath)
      ..createSync(recursive: true);
    unresolvedOutputFile.writeAsStringSync(
      _renderUnresolvedReportJson(
        kit: options.kit,
        resolvedCount: icons.length,
        unresolved: unresolved,
        baselineUnresolvedCount: baselineUnresolvedCodePoints?.length,
        newUnresolved: newUnresolved,
        resolvedSinceBaseline: resolvedSinceBaseline,
        unresolvedThreshold: unresolvedThreshold,
        newUnresolvedThreshold: newUnresolvedThreshold,
        unresolvedThresholdMode: unresolvedThresholdMode,
        newUnresolvedThresholdMode: newUnresolvedThresholdMode,
        unresolvedGateFailed: thresholdFailure,
        newUnresolvedGateFailed: newUnresolvedThresholdFailure,
        wouldFail: shouldFail,
      ),
    );
    stdout.writeln(
      'Generated unresolved icon report to ${unresolvedOutputFile.path}',
    );
  }

  if (options.unresolvedBaselineOutputPath
      case final unresolvedBaselineOutputPath?) {
    final unresolvedBaselineOutputFile = File(unresolvedBaselineOutputPath)
      ..createSync(recursive: true);
    final unresolvedBaselineJson =
        switch (options.unresolvedBaselineOutputFormat) {
          _kUnresolvedBaselineOutputFormatUnresolved =>
            _renderUnresolvedBaselineJson(unresolved: unresolved),
          _kUnresolvedBaselineOutputFormatCodePoints =>
            _renderUnresolvedBaselineCodePointsJson(unresolved: unresolved),
          _ => throw StateError(
            'Unsupported unresolved baseline output format: '
            '${options.unresolvedBaselineOutputFormat}',
          ),
        };
    unresolvedBaselineOutputFile.writeAsStringSync(unresolvedBaselineJson);
    stdout.writeln(
      'Generated unresolved baseline JSON to '
      '${unresolvedBaselineOutputFile.path}',
    );
  }

  if (options.supplementalManifestOutputPath
      case final supplementalManifestOutputPath?) {
    final supplementalManifestOutputFile = File(supplementalManifestOutputPath)
      ..createSync(recursive: true);
    supplementalManifestOutputFile.writeAsStringSync(
      _renderSupplementalManifestTemplateJson(unresolved: unresolved),
    );
    stdout.writeln(
      'Generated supplemental manifest template to '
      '${supplementalManifestOutputFile.path}',
    );
  }

  if (unresolved.isEmpty) {
    return;
  }

  final severityLabel = shouldFail ? 'Error' : 'Warning';
  stderr.writeln(
    '$severityLabel: ${unresolved.length} icon codepoints for kit '
    '"${options.kit}" could not be resolved to SVGs. WiredIcon will '
    'fall back to Icon for those values.',
  );
  for (final item in unresolved) {
    stderr.writeln(
      '  0x${item.codePoint.toRadixString(16)}: ${item.identifiers.join(', ')}',
    );
  }

  if (newUnresolved case final baselineDiff?) {
    final baselineSeverity = newUnresolvedThresholdFailure
        ? 'Error'
        : (shouldFail ? 'Warning' : 'Info');
    stderr.writeln(
      '$baselineSeverity: ${baselineDiff.length} newly unresolved '
      'codepoints compared to baseline.',
    );
    for (final item in baselineDiff) {
      stderr.writeln(
        '  + 0x${item.codePoint.toRadixString(16)}: '
        '${item.identifiers.join(', ')}',
      );
    }
  }

  if (resolvedSinceBaseline case final resolvedDiff?) {
    if (resolvedDiff.isNotEmpty) {
      final baselineSeverity = shouldFail ? 'Warning' : 'Info';
      stderr.writeln(
        '$baselineSeverity: ${resolvedDiff.length} baseline unresolved '
        'codepoints are now resolved.',
      );
      for (final codePoint in resolvedDiff) {
        stderr.writeln('  - 0x${codePoint.toRadixString(16)}');
      }
    }
  }

  if (shouldFail) {
    final details = <String>[
      if (thresholdFailure)
        'found ${unresolved.length}, allowed $unresolvedThreshold',
      if (newUnresolvedThresholdFailure)
        'new unresolved regression detected ($newUnresolvedCount, allowed $newUnresolvedThreshold)',
    ].join('; ');
    throw StateError(
      'Unresolved icon codepoints remain for kit "${options.kit}" ($details).',
    );
  }
}

void _printUsage() {
  stdout.writeln('''
Generate rough icon artifacts for WiredIcon.

Usage:
  dart run tool/generate_rough_icons.dart [options]

Compatibility alias:
  dart run tool/generate_material_rough_icons.dart [options]

Options:
  --kit <flutter-material|svg-manifest> Icon kit provider to use.
  --list-kits                      Print supported --kit values and exit.
  --manifest <path>                JSON manifest for --kit svg-manifest.
  --flutter-icons <path>           Path to Flutter material icons.dart.
  --material-icons-source <path>   Path to extracted @material-design-icons/svg package.
  --material-symbols-source <path> Path to extracted @material-symbols/svg-400 package.
  --brand-icons-source <path>      Path to extracted simple-icons package (brand fallback).
  --supplemental-manifest <path>   JSON manifest for unresolved flutter-material icons.
  --unresolved-output <path>       Emit unresolved icon codepoint report as JSON.
  --unresolved-baseline-output <path>
                                   Emit normalized unresolved baseline JSON.
  --unresolved-baseline-output-format <unresolved|codepoints>
                                   Baseline JSON shape for --unresolved-baseline-output (default: unresolved).
  --supplemental-manifest-output <path>
                                   Emit supplemental manifest template JSON.
  --unresolved-baseline <path>     Baseline unresolved report/manifest/codePoints JSON for diffing.
                                   Accepts unresolvedCodePoints/unresolvedCodepoints/codePoints/codepoints keys for minimal baseline objects.
  --max-unresolved <int>           Max unresolved icons allowed before failing.
  --fail-on-unresolved             Exit with error when unresolved icons remain (cannot be combined with --max-unresolved).
  --max-new-unresolved <int>       Max newly unresolved icons allowed before failing (requires --unresolved-baseline).
  --fail-on-new-unresolved         Exit with error on unresolved baseline regressions (cannot be combined with --max-new-unresolved).
  --output <path>                  Output Dart file.
  --rough-cli <path>               TypeScript script that converts SVG(s) (default: tool/deno/svg2roughjs_cli.ts).
  --rough-cli-runner <exe>         Runner executable for --rough-cli (default: deno).
  --rough-output-dir <path>        Directory where roughened SVG files are written.
  --rough-seed <int>               Base deterministic seed for rough generation.
  --rough-normalize-viewbox <size> Normalize SVGs to this square viewBox before roughing.
  --rough-bulk                     Use one manifest-driven converter invocation.
  --rough-only                     Skip Dart map generation; only emit rough SVG files.
  --font-output-dir <path>         Build an icon font from rough SVGs into this directory.
  --font-dart-output <path>        Emit Dart helpers (font family + codepoint lookup map).
  --font-name <name>               Name of generated icon font (default: material_rough_icons).
  --font-generator-executable <e>  Font generator executable (default: npx).
  --font-generator-package <name>  Package passed to generator executable (default: fantasticon).
  --help                           Show this help text.

If a source path is omitted, the script downloads the package with npm pack into
a temporary directory.
''');
}

void _printSupportedKits() {
  stdout.writeln('Supported icon kits:');
  for (final entry in _kSupportedKitDescriptions.entries) {
    stdout.writeln('  - ${entry.key}: ${entry.value}');
  }
}

String _defaultOutputPathForKit(String kit) {
  if (kit == _kDefaultKit) {
    return 'lib/src/generated/material_rough_icons.g.dart';
  }
  final normalized = kit.toLowerCase().replaceAll(RegExp('[^a-z0-9_]+'), '_');
  return 'lib/src/generated/${normalized}_rough_icons.g.dart';
}

List<String> supportedIconKitsForTest() =>
    _kSupportedKitDescriptions.keys.toList(growable: false);

final class _ScriptOptions {
  const _ScriptOptions({
    this.kit = _kDefaultKit,
    this.manifestPath,
    this.flutterIconsPath,
    this.materialIconsSourcePath,
    this.materialSymbolsSourcePath,
    this.brandIconsSourcePath,
    this.supplementalManifestPath,
    this.unresolvedOutputPath,
    this.unresolvedBaselineOutputPath,
    this.unresolvedBaselineOutputFormat =
        _kUnresolvedBaselineOutputFormatUnresolved,
    this.supplementalManifestOutputPath,
    this.unresolvedBaselinePath,
    this.maxUnresolved,
    this.maxNewUnresolved,
    this.outputPath,
    this.roughCliPath,
    this.roughCliRunner = _kDefaultRoughCliRunner,
    this.roughOutputDir,
    this.roughSeed,
    this.roughNormalizeViewBox = 128,
    this.roughBulk = false,
    this.roughOnly = false,
    this.failOnUnresolved = false,
    this.failOnNewUnresolved = false,
    this.fontOutputDir,
    this.fontDartOutputPath,
    this.fontName = _kDefaultFontName,
    this.fontGeneratorExecutable = _kDefaultFontGeneratorExecutable,
    this.fontGeneratorPackage = _kDefaultFontGeneratorPackage,
    this.showHelp = false,
    this.listKits = false,
  });

  final String kit;
  final String? manifestPath;
  final String? flutterIconsPath;
  final String? materialIconsSourcePath;
  final String? materialSymbolsSourcePath;
  final String? brandIconsSourcePath;
  final String? supplementalManifestPath;
  final String? unresolvedOutputPath;
  final String? unresolvedBaselineOutputPath;
  final String unresolvedBaselineOutputFormat;
  final String? supplementalManifestOutputPath;
  final String? unresolvedBaselinePath;
  final int? maxUnresolved;
  final int? maxNewUnresolved;
  final String? outputPath;
  final String? roughCliPath;
  final String roughCliRunner;
  final String? roughOutputDir;
  final int? roughSeed;
  final double roughNormalizeViewBox;
  final bool roughBulk;
  final bool roughOnly;
  final bool failOnUnresolved;
  final bool failOnNewUnresolved;
  final String? fontOutputDir;
  final String? fontDartOutputPath;
  final String fontName;
  final String fontGeneratorExecutable;
  final String fontGeneratorPackage;
  final bool showHelp;
  final bool listKits;

  static _ScriptOptions parse(List<String> args) {
    var kit = _kDefaultKit;
    String? manifestPath;
    String? flutterIconsPath;
    String? materialIconsSourcePath;
    String? materialSymbolsSourcePath;
    String? brandIconsSourcePath;
    String? supplementalManifestPath;
    String? unresolvedOutputPath;
    String? unresolvedBaselineOutputPath;
    var unresolvedBaselineOutputFormat =
        _kUnresolvedBaselineOutputFormatUnresolved;
    String? supplementalManifestOutputPath;
    String? unresolvedBaselinePath;
    int? maxUnresolved;
    int? maxNewUnresolved;
    String? outputPath;
    String? roughCliPath;
    var roughCliRunner = _kDefaultRoughCliRunner;
    String? roughOutputDir;
    int? roughSeed;
    var roughNormalizeViewBox = 128.0;
    var roughBulk = false;
    var roughOnly = false;
    var failOnUnresolved = false;
    var failOnNewUnresolved = false;
    String? fontOutputDir;
    String? fontDartOutputPath;
    var fontName = _kDefaultFontName;
    var fontGeneratorExecutable = _kDefaultFontGeneratorExecutable;
    var fontGeneratorPackage = _kDefaultFontGeneratorPackage;
    var showHelp = false;
    var listKits = false;

    for (var index = 0; index < args.length; index++) {
      final argument = args[index];
      if (argument == '--help' || argument == '-h') {
        showHelp = true;
        continue;
      }
      if (argument == '--list-kits') {
        listKits = true;
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
      if (argument == '--fail-on-unresolved') {
        failOnUnresolved = true;
        continue;
      }
      if (argument == '--fail-on-new-unresolved') {
        failOnNewUnresolved = true;
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
        case '--manifest':
          manifestPath = value;
        case '--flutter-icons':
          flutterIconsPath = value;
        case '--material-icons-source':
          materialIconsSourcePath = value;
        case '--material-symbols-source':
          materialSymbolsSourcePath = value;
        case '--brand-icons-source':
          brandIconsSourcePath = value;
        case '--supplemental-manifest':
          supplementalManifestPath = value;
        case '--unresolved-output':
          unresolvedOutputPath = value;
        case '--unresolved-baseline-output':
          unresolvedBaselineOutputPath = value;
        case '--unresolved-baseline-output-format':
          unresolvedBaselineOutputFormat = value.toLowerCase();
        case '--supplemental-manifest-output':
          supplementalManifestOutputPath = value;
        case '--unresolved-baseline':
          unresolvedBaselinePath = value;
        case '--max-unresolved':
          maxUnresolved = int.parse(value);
        case '--max-new-unresolved':
          maxNewUnresolved = int.parse(value);
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
        case '--font-dart-output':
          fontDartOutputPath = value;
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

    if (maxUnresolved != null && maxUnresolved < 0) {
      throw ArgumentError('--max-unresolved must be >= 0.');
    }
    if (maxNewUnresolved != null && maxNewUnresolved < 0) {
      throw ArgumentError('--max-new-unresolved must be >= 0.');
    }
    if (failOnUnresolved && maxUnresolved != null) {
      throw ArgumentError(
        '--fail-on-unresolved cannot be combined with --max-unresolved.',
      );
    }
    if (failOnNewUnresolved && maxNewUnresolved != null) {
      throw ArgumentError(
        '--fail-on-new-unresolved cannot be combined with '
        '--max-new-unresolved.',
      );
    }
    if (!_kUnresolvedBaselineOutputFormats.contains(
      unresolvedBaselineOutputFormat,
    )) {
      throw ArgumentError(
        '--unresolved-baseline-output-format must be one of: '
        '${_kUnresolvedBaselineOutputFormats.join(', ')}.',
      );
    }
    if (unresolvedBaselineOutputPath == null &&
        unresolvedBaselineOutputFormat !=
            _kUnresolvedBaselineOutputFormatUnresolved) {
      throw ArgumentError(
        '--unresolved-baseline-output-format requires '
        '--unresolved-baseline-output.',
      );
    }
    if ((failOnNewUnresolved || maxNewUnresolved != null) &&
        unresolvedBaselinePath == null) {
      throw ArgumentError(
        '--fail-on-new-unresolved and --max-new-unresolved require '
        '--unresolved-baseline.',
      );
    }

    return _ScriptOptions(
      kit: kit,
      manifestPath: manifestPath,
      flutterIconsPath: flutterIconsPath,
      materialIconsSourcePath: materialIconsSourcePath,
      materialSymbolsSourcePath: materialSymbolsSourcePath,
      brandIconsSourcePath: brandIconsSourcePath,
      supplementalManifestPath: supplementalManifestPath,
      unresolvedOutputPath: unresolvedOutputPath,
      unresolvedBaselineOutputPath: unresolvedBaselineOutputPath,
      unresolvedBaselineOutputFormat: unresolvedBaselineOutputFormat,
      supplementalManifestOutputPath: supplementalManifestOutputPath,
      unresolvedBaselinePath: unresolvedBaselinePath,
      maxUnresolved: maxUnresolved,
      maxNewUnresolved: maxNewUnresolved,
      outputPath: outputPath,
      roughCliPath: roughCliPath,
      roughCliRunner: roughCliRunner,
      roughOutputDir: roughOutputDir,
      roughSeed: roughSeed,
      roughNormalizeViewBox: roughNormalizeViewBox,
      roughBulk: roughBulk,
      roughOnly: roughOnly,
      failOnUnresolved: failOnUnresolved,
      failOnNewUnresolved: failOnNewUnresolved,
      fontOutputDir: fontOutputDir,
      fontDartOutputPath: fontDartOutputPath,
      fontName: fontName,
      fontGeneratorExecutable: fontGeneratorExecutable,
      fontGeneratorPackage: fontGeneratorPackage,
      showHelp: showHelp,
      listKits: listKits,
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

Future<Directory?> _resolveOptionalPackageRoot({
  required String packageName,
  required String? suppliedPath,
}) async {
  if (suppliedPath != null) {
    return _resolvePackageRoot(
      packageName: packageName,
      suppliedPath: suppliedPath,
    );
  }

  try {
    return await _resolvePackageRoot(
      packageName: packageName,
      suppliedPath: suppliedPath,
    );
  } on Object catch (error) {
    stderr.writeln(
      'Warning: Optional package "$packageName" could not be resolved. '
      'Continuing without this fallback source.\n$error',
    );
    return null;
  }
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
      final brandIconsRoot = await _resolveOptionalPackageRoot(
        packageName: _kDefaultBrandIconsPackage,
        suppliedPath: options.brandIconsSourcePath,
      );

      var supplementalEntriesByDeclarationKey = <String, _ManifestIconEntry>{};
      if (options.supplementalManifestPath
          case final supplementalManifestPath?) {
        final supplementalManifestFile = File(supplementalManifestPath);
        if (!supplementalManifestFile.existsSync()) {
          throw StateError(
            'Supplemental manifest file not found: '
            '${supplementalManifestFile.path}',
          );
        }

        final supplementalEntries = _parseSvgManifest(
          supplementalManifestFile.readAsStringSync(),
          manifestDirectory: supplementalManifestFile.parent,
        );
        supplementalEntriesByDeclarationKey = <String, _ManifestIconEntry>{
          for (final entry in supplementalEntries)
            _manifestDeclarationKey(entry.identifier, entry.codePoint): entry,
        };
      }

      return _MaterialIconKitProvider(
        flutterIconsFile: flutterIconsFile,
        materialIconsRoot: materialIconsRoot,
        materialSymbolsRoot: materialSymbolsRoot,
        brandIconsRoot: brandIconsRoot,
        supplementalEntriesByDeclarationKey:
            supplementalEntriesByDeclarationKey,
      );
    case _kManifestKit:
      final manifestPath = options.manifestPath;
      if (manifestPath == null) {
        throw ArgumentError('--manifest is required when --kit=$_kManifestKit');
      }
      final manifestFile = File(manifestPath);
      if (!manifestFile.existsSync()) {
        throw StateError('Manifest file not found: ${manifestFile.path}');
      }
      return _SvgManifestIconKitProvider.fromManifest(manifestFile);
    default:
      throw ArgumentError(
        'Unknown --kit value: ${options.kit}. Supported: '
        '${_kSupportedKitDescriptions.keys.join(', ')}',
      );
  }
}

final class _SvgManifestIconKitProvider
    implements
        IconKitProvider<
          _FlutterIconDeclaration,
          ResolvedSvgCandidate<_GeneratedIconData>
        > {
  _SvgManifestIconKitProvider._({
    required this.entriesByDeclarationKey,
    required this.declarations,
  });

  factory _SvgManifestIconKitProvider.fromManifest(File manifestFile) {
    final entries = _parseSvgManifest(
      manifestFile.readAsStringSync(),
      manifestDirectory: manifestFile.parent,
    );
    final entriesByDeclarationKey = <String, _ManifestIconEntry>{
      for (final entry in entries)
        _manifestDeclarationKey(entry.identifier, entry.codePoint): entry,
    };
    final declarations = entries
        .map(
          (entry) => _FlutterIconDeclaration(
            identifier: entry.identifier,
            baseIdentifier: entry.identifier,
            codePoint: entry.codePoint,
            svgName: entry.identifier,
            oldPackageFolder: 'filled',
            symbolPackageFolder: 'outlined',
            useSymbolFillVariant: false,
          ),
        )
        .toList(growable: false);

    return _SvgManifestIconKitProvider._(
      entriesByDeclarationKey: entriesByDeclarationKey,
      declarations: declarations,
    );
  }

  final Map<String, _ManifestIconEntry> entriesByDeclarationKey;
  final List<_FlutterIconDeclaration> declarations;

  @override
  Future<List<_FlutterIconDeclaration>> loadDeclarations() async =>
      declarations;

  @override
  ResolvedSvgCandidate<_GeneratedIconData>? resolveIcon(
    _FlutterIconDeclaration declaration,
  ) {
    final entry =
        entriesByDeclarationKey[_manifestDeclarationKey(
          declaration.identifier,
          declaration.codePoint,
        )];
    if (entry == null) {
      return null;
    }

    return ResolvedSvgCandidate<_GeneratedIconData>(
      data: _parseSvgIcon(entry.svgFile),
      sourcePath: entry.svgFile.path,
    );
  }
}

String _manifestDeclarationKey(String identifier, int codePoint) =>
    '$identifier|$codePoint';

List<_ManifestIconEntry> _parseSvgManifest(
  String source, {
  required Directory manifestDirectory,
}) {
  final decoded = jsonDecode(source);

  List<Object?> entries;
  if (decoded is List<Object?>) {
    entries = decoded;
  } else if (decoded is Map<String, Object?>) {
    final icons = decoded['icons'];
    if (icons is! List<Object?>) {
      throw FormatException(
        'Expected top-level "icons" list in manifest JSON object.',
      );
    }
    entries = icons;
  } else {
    throw FormatException(
      'Expected manifest JSON to be either a list or an object with "icons".',
    );
  }

  final parsedEntries = entries
      .map((item) => _parseManifestIconEntry(item, manifestDirectory))
      .toList(growable: false);

  _validateManifestEntries(parsedEntries);
  return parsedEntries;
}

void _validateManifestEntries(List<_ManifestIconEntry> entries) {
  final seenIdentifiers = <String>{};
  final duplicateIdentifiers = <String>{};

  final seenCodePoints = <int>{};
  final duplicateCodePoints = <int>{};

  for (final entry in entries) {
    if (!seenIdentifiers.add(entry.identifier)) {
      duplicateIdentifiers.add(entry.identifier);
    }
    if (!seenCodePoints.add(entry.codePoint)) {
      duplicateCodePoints.add(entry.codePoint);
    }
  }

  if (duplicateIdentifiers.isEmpty && duplicateCodePoints.isEmpty) {
    return;
  }

  final details = <String>[
    if (duplicateIdentifiers.isNotEmpty)
      'duplicate identifiers: ${duplicateIdentifiers.join(', ')}',
    if (duplicateCodePoints.isNotEmpty)
      'duplicate codePoints: ${duplicateCodePoints.map((codePoint) => '0x${codePoint.toRadixString(16)}').join(', ')}',
  ];

  throw FormatException('Invalid manifest entries: ${details.join('; ')}');
}

_ManifestIconEntry _parseManifestIconEntry(
  Object? item,
  Directory manifestDirectory,
) {
  if (item is! Map<Object?, Object?>) {
    throw FormatException('Manifest icon entry must be an object.');
  }

  final identifier = item['identifier'];
  if (identifier is! String || identifier.isEmpty) {
    throw FormatException('Manifest entry is missing string "identifier".');
  }

  final codePoint = _parseManifestCodePoint(item['codePoint'], identifier);

  final svgPathValue = item['svgPath'] ?? item['svg'] ?? item['path'];
  if (svgPathValue is! String || svgPathValue.isEmpty) {
    throw FormatException(
      'Manifest entry "$identifier" is missing "svgPath" (or "svg").',
    );
  }

  final svgFile = _resolveManifestSvgFile(
    svgPathValue,
    manifestDirectory: manifestDirectory,
  );
  if (!svgFile.existsSync()) {
    throw StateError(
      'Manifest entry "$identifier" points to missing SVG: ${svgFile.path}',
    );
  }

  return _ManifestIconEntry(
    identifier: identifier,
    codePoint: codePoint,
    svgFile: svgFile,
  );
}

int _parseManifestCodePoint(Object? value, String identifier) {
  return _parseCodePointValue(value, context: 'manifest entry "$identifier"');
}

File _resolveManifestSvgFile(
  String svgPath, {
  required Directory manifestDirectory,
}) {
  final directFile = File(svgPath);
  if (_isAbsolutePath(svgPath)) {
    return directFile;
  }
  return File('${manifestDirectory.path}/$svgPath');
}

bool _isAbsolutePath(String path) {
  return path.startsWith('/') ||
      path.startsWith(r'\\') ||
      RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(path);
}

List<ParsedManifestIconDeclaration> parseSvgManifestDeclarationsForTest(
  String source, {
  required String manifestDirectoryPath,
}) {
  return _parseSvgManifest(
        source,
        manifestDirectory: Directory(manifestDirectoryPath),
      )
      .map(
        (entry) => ParsedManifestIconDeclaration(
          identifier: entry.identifier,
          codePoint: entry.codePoint,
          svgPath: entry.svgFile.path,
        ),
      )
      .toList(growable: false);
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
    this.brandIconsRoot,
    this.supplementalEntriesByDeclarationKey =
        const <String, _ManifestIconEntry>{},
  });

  final File flutterIconsFile;
  final Directory materialIconsRoot;
  final Directory materialSymbolsRoot;
  final Directory? brandIconsRoot;
  final Map<String, _ManifestIconEntry> supplementalEntriesByDeclarationKey;

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
      brandIconsRoot: brandIconsRoot,
      supplementalEntriesByDeclarationKey: supplementalEntriesByDeclarationKey,
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
  required Directory? brandIconsRoot,
  required Map<String, _ManifestIconEntry> supplementalEntriesByDeclarationKey,
}) {
  final candidates = <String>{
    declaration.identifier,
    declaration.svgName,
    declaration.baseIdentifier,
    ...?_svgAliases[declaration.identifier],
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

    if (brandIconsRoot case final root?) {
      final brandFile = _resolveBrandIconSvgFile(root, candidate);
      if (brandFile != null && brandFile.existsSync()) {
        return ResolvedSvgCandidate<_GeneratedIconData>(
          data: _parseSvgIcon(brandFile),
          sourcePath: brandFile.path,
        );
      }
    }
  }

  for (final candidate in candidates) {
    final supplementalEntry =
        supplementalEntriesByDeclarationKey[_manifestDeclarationKey(
          candidate,
          declaration.codePoint,
        )];
    if (supplementalEntry == null) {
      continue;
    }

    return ResolvedSvgCandidate<_GeneratedIconData>(
      data: _parseSvgIcon(supplementalEntry.svgFile),
      sourcePath: supplementalEntry.svgFile.path,
    );
  }

  return null;
}

File? _resolveBrandIconSvgFile(Directory brandIconsRoot, String identifier) {
  final slug = _brandIconAliases[identifier] ?? identifier;
  final iconDirectoryCandidate = File('${brandIconsRoot.path}/icons/$slug.svg');
  if (iconDirectoryCandidate.existsSync()) {
    return iconDirectoryCandidate;
  }

  final rootCandidate = File('${brandIconsRoot.path}/$slug.svg');
  if (rootCandidate.existsSync()) {
    return rootCandidate;
  }

  return null;
}

const Map<String, String> _brandIconAliases = <String, String>{
  'woo_commerce': 'woocommerce',
};

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
  'label_outline': <String>['label'],
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
  'wifi_tethering_error_rounded': <String>['wifi_tethering_error'],
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

Set<int>? _loadUnresolvedBaselineCodePoints(String? baselinePath) {
  if (baselinePath == null) {
    return null;
  }

  final baselineFile = File(baselinePath);
  if (!baselineFile.existsSync()) {
    throw StateError(
      'Unresolved baseline file not found: ${baselineFile.path}',
    );
  }

  final decoded = jsonDecode(baselineFile.readAsStringSync());

  List<Object?> entries;
  if (decoded is List<Object?>) {
    entries = decoded;
  } else if (decoded is Map<String, Object?>) {
    final unresolvedValue = decoded['unresolved'];
    final iconsValue = decoded['icons'];
    final unresolvedCodePointsValue = decoded['unresolvedCodePoints'];
    final unresolvedCodepointsValue = decoded['unresolvedCodepoints'];
    final codePointsValue = decoded['codePoints'];
    final codepointsValue = decoded['codepoints'];

    if (unresolvedValue is List<Object?>) {
      entries = unresolvedValue;
    } else if (iconsValue is List<Object?>) {
      entries = iconsValue;
    } else if (unresolvedCodePointsValue is List<Object?>) {
      entries = unresolvedCodePointsValue;
    } else if (unresolvedCodepointsValue is List<Object?>) {
      entries = unresolvedCodepointsValue;
    } else if (codePointsValue is List<Object?>) {
      entries = codePointsValue;
    } else if (codepointsValue is List<Object?>) {
      entries = codepointsValue;
    } else {
      throw FormatException(
        'Expected unresolved baseline JSON to contain either an "unresolved" '
        'list (report format), "icons" list (manifest format), or '
        '"unresolvedCodePoints"/"unresolvedCodepoints"/"codePoints"/'
        '"codepoints" list (minimal baseline format) '
        'at ${baselineFile.path}.',
      );
    }
  } else {
    throw FormatException(
      'Expected unresolved baseline JSON to be a list or object at '
      '${baselineFile.path}.',
    );
  }

  final codePoints = <int>{};
  for (final entry in entries) {
    if (entry is Map<Object?, Object?>) {
      codePoints.add(
        _parseCodePointValue(
          entry['codePoint'],
          context: 'unresolved baseline entry',
        ),
      );
      continue;
    }

    codePoints.add(
      _parseCodePointValue(entry, context: 'unresolved baseline entry'),
    );
  }

  return codePoints;
}

int _parseCodePointValue(Object? value, {required String context}) {
  if (value is int) {
    return value;
  }

  if (value is String) {
    return _parseCodePointString(value, context: context);
  }

  throw FormatException(
    'Invalid codePoint in $context. Expected int or string, got $value.',
  );
}

int _parseCodePointString(String value, {required String context}) {
  final normalized = value.trim().toLowerCase();
  if (normalized.isEmpty) {
    throw FormatException(
      'Invalid codePoint in $context. Expected decimal, 0x-prefixed hex, '
      'U+-prefixed hex, or bare hex string, got "$value".',
    );
  }

  final decimalPattern = RegExp(r'^\d+$');
  final bareHexPattern = RegExp(r'^[0-9a-f]+$');

  String digits;
  var radix = 10;
  if (normalized.startsWith('0x')) {
    digits = normalized.substring(2);
    radix = 16;
  } else if (normalized.startsWith('u+')) {
    digits = normalized.substring(2);
    radix = 16;
  } else if (normalized.startsWith(r'\u')) {
    digits = normalized.substring(2);
    radix = 16;
  } else if (decimalPattern.hasMatch(normalized)) {
    digits = normalized;
  } else if (bareHexPattern.hasMatch(normalized)) {
    digits = normalized;
    radix = 16;
  } else {
    throw FormatException(
      'Invalid codePoint in $context. Expected decimal, 0x-prefixed hex, '
      'U+-prefixed hex, or bare hex string, got "$value".',
    );
  }

  if (digits.isEmpty) {
    throw FormatException(
      'Invalid codePoint in $context. Expected decimal, 0x-prefixed hex, '
      'U+-prefixed hex, or bare hex string, got "$value".',
    );
  }

  try {
    return int.parse(digits, radix: radix);
  } on FormatException {
    throw FormatException(
      'Invalid codePoint in $context. Expected decimal, 0x-prefixed hex, '
      'U+-prefixed hex, or bare hex string, got "$value".',
    );
  }
}

String _resolveThresholdMode({
  required bool strictModeEnabled,
  required int? thresholdOption,
}) {
  if (strictModeEnabled) {
    return 'strict';
  }
  if (thresholdOption != null) {
    return 'threshold';
  }
  return 'disabled';
}

String _renderUnresolvedReportJson({
  required String kit,
  required int resolvedCount,
  required List<_UnresolvedIcon> unresolved,
  required int? baselineUnresolvedCount,
  required List<_UnresolvedIcon>? newUnresolved,
  required List<int>? resolvedSinceBaseline,
  required int? unresolvedThreshold,
  required int? newUnresolvedThreshold,
  required String unresolvedThresholdMode,
  required String newUnresolvedThresholdMode,
  required bool unresolvedGateFailed,
  required bool newUnresolvedGateFailed,
  required bool wouldFail,
}) {
  final activeGates = <String>[
    if (unresolvedThreshold != null) 'unresolved',
    if (newUnresolvedThreshold != null) 'newUnresolved',
  ];
  final failedGates = <String>[
    if (unresolvedGateFailed) 'unresolved',
    if (newUnresolvedGateFailed) 'newUnresolved',
  ];

  final report = <String, Object>{
    'kit': kit,
    'resolvedCount': resolvedCount,
    'unresolvedCount': unresolved.length,
    'wouldFail': wouldFail,
    'unresolvedGateFailed': unresolvedGateFailed,
    'newUnresolvedGateFailed': newUnresolvedGateFailed,
    'activeGates': activeGates,
    'failedGates': failedGates,
    'unresolved': unresolved.map(_unresolvedIconJson).toList(growable: false),
    'unresolvedCodePoints': _unresolvedCodePointsJson(unresolved),
    'unresolvedThresholdMode': unresolvedThresholdMode,
    'newUnresolvedThresholdMode': newUnresolvedThresholdMode,
    if (unresolvedThreshold != null) ...<String, Object>{
      'maxUnresolved': unresolvedThreshold,
      'maxUnresolvedExceeded': unresolved.length > unresolvedThreshold,
    },
    if (baselineUnresolvedCount != null) ...<String, Object>{
      'baselineUnresolvedCount': baselineUnresolvedCount,
    },
    if (newUnresolved != null) ...<String, Object>{
      'newUnresolvedCount': newUnresolved.length,
      'newUnresolved': newUnresolved
          .map(_unresolvedIconJson)
          .toList(growable: false),
      'newUnresolvedCodePoints': _unresolvedCodePointsJson(newUnresolved),
    },
    if (newUnresolvedThreshold != null) ...<String, Object>{
      'maxNewUnresolved': newUnresolvedThreshold,
      'maxNewUnresolvedExceeded':
          (newUnresolved?.length ?? 0) > newUnresolvedThreshold,
    },
    if (resolvedSinceBaseline != null) ...<String, Object>{
      'resolvedSinceBaselineCount': resolvedSinceBaseline.length,
      'resolvedSinceBaseline': resolvedSinceBaseline
          .map((codePoint) => '0x${codePoint.toRadixString(16)}')
          .toList(growable: false),
    },
  };

  return const JsonEncoder.withIndent('  ').convert(report);
}

Map<String, Object> _unresolvedIconJson(_UnresolvedIcon item) {
  return <String, Object>{
    'codePoint': '0x${item.codePoint.toRadixString(16)}',
    'identifiers': item.identifiers,
  };
}

List<String> _unresolvedCodePointsJson(List<_UnresolvedIcon> unresolved) {
  return unresolved
      .map((item) => '0x${item.codePoint.toRadixString(16)}')
      .toList(growable: false);
}

String _renderUnresolvedBaselineJson({
  required List<_UnresolvedIcon> unresolved,
}) {
  final sortedUnresolved = [...unresolved]
    ..sort((a, b) {
      final byCodePoint = a.codePoint.compareTo(b.codePoint);
      if (byCodePoint != 0) {
        return byCodePoint;
      }
      final aIdentifier = a.identifiers.isEmpty ? '' : a.identifiers.first;
      final bIdentifier = b.identifiers.isEmpty ? '' : b.identifiers.first;
      return aIdentifier.compareTo(bIdentifier);
    });

  final baseline = <String, Object>{
    'unresolved': sortedUnresolved
        .map(_unresolvedIconJson)
        .toList(growable: false),
  };

  return const JsonEncoder.withIndent('  ').convert(baseline);
}

String _renderUnresolvedBaselineCodePointsJson({
  required List<_UnresolvedIcon> unresolved,
}) {
  final sortedCodePoints =
      unresolved.map((item) => item.codePoint).toSet().toList(growable: false)
        ..sort();

  final baseline = <String, Object>{
    'codePoints': sortedCodePoints
        .map((codePoint) => '0x${codePoint.toRadixString(16)}')
        .toList(growable: false),
  };

  return const JsonEncoder.withIndent('  ').convert(baseline);
}

String _renderSupplementalManifestTemplateJson({
  required List<_UnresolvedIcon> unresolved,
}) {
  final icons = unresolved
      .map((item) {
        final identifier = item.identifiers.isNotEmpty
            ? item.identifiers.first
            : 'icon_0x${item.codePoint.toRadixString(16)}';
        return <String, Object>{
          'identifier': identifier,
          'codePoint': '0x${item.codePoint.toRadixString(16)}',
          'svgPath': 'TODO/$identifier.svg',
        };
      })
      .toList(growable: false);

  final manifest = <String, Object>{'icons': icons};
  return const JsonEncoder.withIndent('  ').convert(manifest);
}

String renderFontCodePointsDartForTest({
  required String fontName,
  required Map<String, int> codePoints,
}) {
  final glyphs = codePoints.entries
      .map((entry) => _FontGlyph(identifier: entry.key, codePoint: entry.value))
      .toList(growable: false);
  return _renderFontCodePointsDart(fontName: fontName, glyphs: glyphs);
}

String _renderFontCodePointsDart({
  required String fontName,
  required List<_FontGlyph> glyphs,
}) {
  final sortedGlyphs = [...glyphs]
    ..sort((a, b) {
      final byCodePoint = a.codePoint.compareTo(b.codePoint);
      if (byCodePoint != 0) {
        return byCodePoint;
      }
      return a.identifier.compareTo(b.identifier);
    });

  final upperCamelName = _toUpperCamelIdentifier(fontName);
  final familyConstName = 'k${upperCamelName}FontFamily';
  final codePointsConstName = 'k${upperCamelName}CodePoints';
  final lookupFunctionName = 'lookup${upperCamelName}IconData';

  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln()
    ..writeln('''import 'package:flutter/widgets.dart';''')
    ..writeln()
    ..writeln(
      'const String $familyConstName = ${_singleQuotedDartString(fontName)};',
    )
    ..writeln()
    ..writeln('const Map<String, int> $codePointsConstName = <String, int>{');

  for (final glyph in sortedGlyphs) {
    buffer.writeln(
      '  ${_singleQuotedDartString(glyph.identifier)}: '
      '0x${glyph.codePoint.toRadixString(16)},',
    );
  }

  buffer
    ..writeln('};')
    ..writeln()
    ..writeln('IconData? $lookupFunctionName(String identifier) {')
    ..writeln('  final codePoint = $codePointsConstName[identifier];')
    ..writeln('  if (codePoint == null) {')
    ..writeln('    return null;')
    ..writeln('  }')
    ..writeln('  return IconData(codePoint, fontFamily: $familyConstName);')
    ..writeln('}');

  return buffer.toString();
}

String _singleQuotedDartString(String value) {
  final buffer = StringBuffer("'");
  for (final codeUnit in value.codeUnits) {
    switch (codeUnit) {
      case 0x27: // '
        buffer.write(r"\'");
      case 0x5c: // \
        buffer.write(r'\\');
      case 0x24: // $
        buffer.write(r'\$');
      case 0x0a:
        buffer.write(r'\n');
      case 0x0d:
        buffer.write(r'\r');
      case 0x09:
        buffer.write(r'\t');
      default:
        if (codeUnit < 0x20) {
          buffer.write('\\x${codeUnit.toRadixString(16).padLeft(2, '0')}');
        } else {
          buffer.writeCharCode(codeUnit);
        }
    }
  }
  buffer.write("'");
  return buffer.toString();
}

String _toUpperCamelIdentifier(String value) {
  final words = value
      .split(RegExp('[^a-zA-Z0-9]+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);
  if (words.isEmpty) {
    return 'GeneratedRoughIcons';
  }

  final transformed = words
      .map(
        (word) =>
            '${word.substring(0, 1).toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join();

  if (RegExp('^[0-9]').hasMatch(transformed)) {
    return 'Font$transformed';
  }
  return transformed;
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

final class _ManifestIconEntry {
  const _ManifestIconEntry({
    required this.identifier,
    required this.codePoint,
    required this.svgFile,
  });

  final String identifier;
  final int codePoint;
  final File svgFile;
}

final class _FontGlyph {
  const _FontGlyph({required this.identifier, required this.codePoint});

  final String identifier;
  final int codePoint;
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

final class ParsedManifestIconDeclaration {
  const ParsedManifestIconDeclaration({
    required this.identifier,
    required this.codePoint,
    required this.svgPath,
  });

  final String identifier;
  final int codePoint;
  final String svgPath;
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
