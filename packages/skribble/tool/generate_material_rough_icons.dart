import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:xml/xml.dart';

Future<void> main(List<String> args) async {
  final options = _ScriptOptions.parse(args);
  if (options.showHelp) {
    _printUsage();
    return;
  }

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
  final outputFile = File(
    options.outputPath ?? 'lib/src/generated/material_rough_icons.g.dart',
  );

  final declarations = _parseFlutterIconDeclarations(flutterIconsFile);
  final byCodePoint = SplayTreeMap<int, List<_FlutterIconDeclaration>>();
  for (final declaration in declarations) {
    final declarationsForCodePoint = byCodePoint.putIfAbsent(
      declaration.codePoint,
      () => <_FlutterIconDeclaration>[],
    );
    declarationsForCodePoint.add(declaration);
  }

  final icons = <_GeneratedIcon>[];
  final unresolved = <_UnresolvedIcon>[];

  for (final entry in byCodePoint.entries) {
    _GeneratedIcon? resolvedIcon;
    for (final declaration in entry.value) {
      final data = _resolveIconData(
        declaration,
        materialIconsRoot: materialIconsRoot,
        materialSymbolsRoot: materialSymbolsRoot,
      );
      if (data != null) {
        resolvedIcon = _GeneratedIcon(
          codePoint: entry.key,
          identifier: declaration.identifier,
          data: data,
        );
        break;
      }
    }

    if (resolvedIcon != null) {
      icons.add(resolvedIcon);
    } else {
      unresolved.add(
        _UnresolvedIcon(
          codePoint: entry.key,
          identifiers: entry.value
              .map((item) => item.identifier)
              .toList(growable: false),
        ),
      );
    }
  }

  outputFile.createSync(recursive: true);
  outputFile.writeAsStringSync(_renderGeneratedFile(icons));

  stdout.writeln('Generated ${icons.length} rough icons to ${outputFile.path}');

  if (unresolved.isNotEmpty) {
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
}

void _printUsage() {
  stdout.writeln('''
Generate the Material rough icon catalog used by WiredIcon.

Usage:
  dart run tool/generate_material_rough_icons.dart [options]

Options:
  --flutter-icons <path>           Path to Flutter material icons.dart.
  --material-icons-source <path>   Path to extracted @material-design-icons/svg package.
  --material-symbols-source <path> Path to extracted @material-symbols/svg-400 package.
  --output <path>                  Output Dart file.
  --help                           Show this help text.

If a source path is omitted, the script downloads the package with npm pack into
a temporary directory.
''');
}

final class _ScriptOptions {
  const _ScriptOptions({
    this.flutterIconsPath,
    this.materialIconsSourcePath,
    this.materialSymbolsSourcePath,
    this.outputPath,
    this.showHelp = false,
  });

  final String? flutterIconsPath;
  final String? materialIconsSourcePath;
  final String? materialSymbolsSourcePath;
  final String? outputPath;
  final bool showHelp;

  static _ScriptOptions parse(List<String> args) {
    String? flutterIconsPath;
    String? materialIconsSourcePath;
    String? materialSymbolsSourcePath;
    String? outputPath;
    var showHelp = false;

    for (var index = 0; index < args.length; index++) {
      final argument = args[index];
      if (argument == '--help' || argument == '-h') {
        showHelp = true;
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
        case '--flutter-icons':
          flutterIconsPath = value;
        case '--material-icons-source':
          materialIconsSourcePath = value;
        case '--material-symbols-source':
          materialSymbolsSourcePath = value;
        case '--output':
          outputPath = value;
        default:
          throw ArgumentError('Unknown option: $option');
      }
    }

    return _ScriptOptions(
      flutterIconsPath: flutterIconsPath,
      materialIconsSourcePath: materialIconsSourcePath,
      materialSymbolsSourcePath: materialSymbolsSourcePath,
      outputPath: outputPath,
      showHelp: showHelp,
    );
  }
}

Future<String> _discoverFlutterIconsPath() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null && flutterRoot.isNotEmpty) {
    return '$flutterRoot/packages/flutter/lib/src/material/icons.dart';
  }

  final result = await Process.run(
    'flutter',
    const <String>['--version', '--machine'],
  );
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

  final packResult = await Process.run(
    'npm',
    <String>['pack', packageName],
    workingDirectory: tempDirectory.path,
  );
  if (packResult.exitCode != 0) {
    throw StateError('npm pack $packageName failed:\n${packResult.stderr}');
  }

  final archiveName = (packResult.stdout as String).trim().split('\n').last;
  final archivePath = '${tempDirectory.path}/$archiveName';
  final extractResult = await Process.run(
    'tar',
    <String>['-xzf', archivePath],
    workingDirectory: tempDirectory.path,
  );
  if (extractResult.exitCode != 0) {
    throw StateError(
      'tar extraction for $packageName failed:\n${extractResult.stderr}',
    );
  }

  return Directory('${tempDirectory.path}/package');
}

List<_FlutterIconDeclaration> _parseFlutterIconDeclarations(File file) {
  final text = file.readAsStringSync();
  final declarationPattern = RegExp(
    r'((?:^\s*///.*\n)+)\s*static const IconData (\w+) = IconData\((0x[0-9a-fA-F]+),',
    multiLine: true,
  );
  final materialNamePattern = RegExp(
    r'material icon named "([^"]+)"(?: \((outlined|round|sharp)\))?',
  );

  return declarationPattern
      .allMatches(text)
      .map((match) {
        final docs = match.group(1)!;
        final identifier = match.group(2)!;
        final codePointText = match.group(3)!;
        final infoMatch = materialNamePattern.firstMatch(docs);
        if (infoMatch == null) {
          throw StateError(
            'Unable to parse material icon metadata for $identifier',
          );
        }

        final styleTag = infoMatch.group(2);
        final baseIdentifier = _stripStyleSuffix(identifier);

        return _FlutterIconDeclaration(
          identifier: identifier,
          baseIdentifier: baseIdentifier,
          codePoint: int.parse(codePointText.substring(2), radix: 16),
          svgName: infoMatch.group(1)!.replaceAll(' ', '_'),
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

String _stripStyleSuffix(String identifier) {
  for (final suffix in const <String>['_outlined', '_rounded', '_sharp']) {
    if (identifier.endsWith(suffix)) {
      return identifier.substring(0, identifier.length - suffix.length);
    }
  }
  return identifier;
}

_GeneratedIconData? _resolveIconData(
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
      return _parseSvgIcon(materialIconsFile);
    }

    final symbolBase =
        '${materialSymbolsRoot.path}/${declaration.symbolPackageFolder}/$candidate';
    final symbolCandidates = declaration.useSymbolFillVariant
        ? <String>['$symbolBase-fill.svg', '$symbolBase.svg']
        : <String>['$symbolBase.svg'];

    for (final path in symbolCandidates) {
      final file = File(path);
      if (file.existsSync()) {
        return _parseSvgIcon(file);
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
          _collectPrimitives(
            child,
            inheritedFillRule: effectiveFillRule,
          ),
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
