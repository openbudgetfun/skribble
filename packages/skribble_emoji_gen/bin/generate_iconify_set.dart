import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:skribble_emoji_gen/svg_shapes.dart';

/// Filename of the pinned Iconify payload inside the cache directory.
const _iconsJsonName = 'icons.json';

/// Generates a Skribble icon catalog from an Iconify icon set.
///
/// Reads `icons.json`, resolves Iconify aliases, warps every outline with the
/// shared deterministic rough pass, and writes a Dart map plus its
/// identifier-to-codepoint lookup. Everything runs in pure Dart across
/// isolates, so a full set takes seconds rather than the minutes a headless
/// browser round trip costs.
Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('prefix', mandatory: true, help: 'Iconify set prefix.')
    ..addOption(
      'icons-json',
      help: 'Local icons.json. Defaults to the pinned download cache.',
    )
    ..addOption(
      'cache-dir',
      defaultsTo: '.audit/iconify',
      help: 'Directory holding downloaded icon sets.',
    )
    ..addOption('version', help: 'npm version to pin when downloading.')
    ..addOption(
      'sha256',
      help: 'Expected SHA-256 of icons.json when downloading.',
    )
    ..addOption(
      'package',
      help: 'Dart package name. Defaults to skribble_icons_<prefix>.',
    )
    ..addOption(
      'stem',
      help: 'Identifier stem, PascalCase. Defaults to the prefix PascalCased.',
    )
    ..addOption('output', mandatory: true, help: 'Output Dart file.')
    ..addOption(
      'base-code-point',
      mandatory: true,
      help: 'First codepoint of this set\'s private-use band.',
    )
    ..addOption(
      'license',
      mandatory: true,
      help: 'SPDX identifier recorded in the generated header.',
    )
    ..addOption(
      'attribution',
      mandatory: true,
      help: 'Upstream project name recorded in the generated header.',
    )
    ..addOption(
      'attribution-url',
      mandatory: true,
      help: 'Upstream project URL recorded in the generated header.',
    )
    ..addFlag(
      'check',
      negatable: false,
      help: 'Verify the committed file is current without writing it.',
    );

  final args = parser.parse(arguments);
  final prefix = args['prefix'] as String;
  final output = File(args['output'] as String);
  final baseCodePoint = _parseCodePoint(args['base-code-point'] as String);
  final license = args['license'] as String;
  final attribution = args['attribution'] as String;
  final attributionUrl = args['attribution-url'] as String;
  final package = (args['package'] as String?) ?? 'skribble_icons_$prefix';
  final stem = (args['stem'] as String?) ?? _pascal(prefix);

  final raw = await _loadIconsJson(args, prefix);
  final decoded = jsonDecode(raw) as Map<String, Object?>;

  final icons = <String, Map<String, Object?>>{
    for (final entry in (decoded['icons']! as Map<String, Object?>).entries)
      entry.key: entry.value! as Map<String, Object?>,
  };
  final aliases = <String, Map<String, Object?>>{
    for (final entry
        in ((decoded['aliases'] as Map<String, Object?>?) ?? const {}).entries)
      entry.key: entry.value! as Map<String, Object?>,
  };
  final defaultWidth = (decoded['width'] as num?)?.toDouble() ?? 16;
  final defaultHeight = (decoded['height'] as num?)?.toDouble() ?? 16;

  var next = baseCodePoint;
  final names = [...icons.keys, ...aliases.keys]..sort();
  final codePoints = <String, int>{};
  final dataByCodePoint = <int, String>{};

  for (final name in names) {
    final icon = icons[name];
    // Hidden entries only survive so that already-published names keep
    // resolving, and Iconify excludes them from its own totals. Skip them so
    // the catalog matches the published count, but they remain valid alias
    // parents because [_bodyFor] reads the raw tables.
    if (icon != null && icon['hidden'] == true) {
      continue;
    }
    if (icon == null && aliases[name] == null) {
      continue;
    }
    codePoints[name] = next;
    dataByCodePoint[next] = await _resolve(
      prefix,
      name,
      icons,
      aliases,
      defaultWidth,
      defaultHeight,
    );
    next += 1;
  }

  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// ignore_for_file: lines_longer_than_80_chars')
    ..writeln('//')
    ..writeln(
      '// Source: $prefix (${icons.length} icons, '
      '${aliases.length} aliases) from $attribution',
    )
    ..writeln('// $attributionUrl')
    ..writeln('// License: $license')
    ..writeln('// Package: $package')
    ..writeln()
    ..writeln("import '../wired_svg_icon_data.dart';")
    ..writeln();

  final mapName = 'k${stem}Icons';
  buffer.writeln('const Map<int, WiredSvgIconData> $mapName = {');
  final sortedCodePoints = dataByCodePoint.keys.toList()..sort();
  for (final codePoint in sortedCodePoints) {
    buffer
      ..writeln('  0x${codePoint.toRadixString(16)}:')
      ..writeln(dataByCodePoint[codePoint]);
  }
  buffer.writeln('};');
  buffer.writeln();

  final codePointMapName = 'k${stem}IconCodePoints';
  buffer.writeln('const Map<String, int> $codePointMapName = {');
  for (final name in codePoints.keys.toList()..sort()) {
    buffer.writeln(
      "  '${_escape(name)}': 0x${codePoints[name]!.toRadixString(16)},",
    );
  }
  buffer.writeln('};');

  final rendered = buffer.toString();
  if (args['check'] as bool) {
    if (await _isStale(output.path, rendered)) {
      stderr.writeln('Stale icon catalog: ${output.path}');
      exitCode = 1;
    } else {
      stdout.writeln('$prefix up to date (${codePoints.length} names).');
    }
    return;
  }

  await output.parent.create(recursive: true);
  await output.writeAsString(rendered);
  await _format(output.path);
  stdout.writeln(
    'Generated ${codePoints.length} names '
    '(${dataByCodePoint.length} codepoints) into ${output.path}.',
  );
}

/// Resolves [name] to warped Dart geometry, following Iconify alias links.
///
/// Per the Iconify spec an alias inherits its parent's body and geometry, then
/// applies its own overrides on top. Parent chains never exceed one level, but
/// the loop guards against a malformed source that points an alias at itself.
Future<String> _resolve(
  String prefix,
  String name,
  Map<String, Map<String, Object?>> icons,
  Map<String, Map<String, Object?>> aliases,
  double defaultWidth,
  double defaultHeight,
) async {
  final overrides = <Map<String, Object?>>[];
  var current = name;
  final visited = <String>{};
  Map<String, Object?>? source;

  while (true) {
    if (!visited.add(current)) {
      throw StateError('Alias cycle detected at $prefix:$current.');
    }
    final icon = icons[current];
    if (icon != null) {
      source = icon;
      break;
    }
    final alias = aliases[current];
    if (alias == null) {
      throw StateError('Icon "$prefix:$name" has no definition.');
    }
    overrides.add(alias);
    current = alias['parent']! as String;
  }

  // Nearest override wins, so apply them from the outermost alias inwards.
  Object? valueOf(String key) {
    for (final override in overrides) {
      if (override.containsKey(key)) return override[key];
    }
    return source![key];
  }

  final width = (valueOf('width') as num?)?.toDouble() ?? defaultWidth;
  final height = (valueOf('height') as num?)?.toDouble() ?? defaultHeight;
  final left = (valueOf('left') as num?)?.toDouble() ?? 0;
  final top = (valueOf('top') as num?)?.toDouble() ?? 0;
  final rotate = (valueOf('rotate') as num?)?.toInt() ?? 0;
  final hFlip = valueOf('hFlip') == true;
  final vFlip = valueOf('vFlip') == true;
  final body = source['body']! as String;

  final markup =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $width $height">'
      '<g${_viewBoxTransform(width: width, height: height, left: left, top: top, rotate: rotate, hFlip: hFlip, vFlip: vFlip)}>$body</g></svg>';

  final shapes = extractShapesFromMarkup(markup);
  if (shapes.isEmpty) {
    throw StateError('Icon "$prefix:$name" produced no drawable shapes.');
  }

  final buffer = StringBuffer()
    ..writeln('  WiredSvgIconData(')
    ..writeln('    width: ${_num(width)},')
    ..writeln('    height: ${_num(height)},')
    ..writeln('    primitives: <WiredSvgPrimitive>[');
  for (final shape in shapes) {
    buffer
      ..write('      WiredSvgPrimitive.path(')
      ..write("'${_escape(shape.data)}'")
      ..write(', fillRule: WiredSvgFillRule.')
      ..write(shape.evenOdd ? 'evenOdd' : 'nonZero');
    if (shape.fillColor != null) {
      buffer.write(", fillColor: '${_escape(shape.fillColor!)}'");
    }
    if (shape.strokeColor != null) {
      buffer.write(", strokeColor: '${_escape(shape.strokeColor!)}'");
    }
    if (shape.strokeWidth != 1) {
      buffer.write(', strokeWidth: ${_num(shape.strokeWidth)}');
    }
    buffer.writeln('),');
  }
  buffer
    ..writeln('    ],')
    ..writeln('  ),');
  return buffer.toString();
}

Future<String> _loadIconsJson(ArgResults args, String prefix) async {
  final explicit = args['icons-json'] as String?;
  final cacheDir = args['cache-dir'] as String;
  final file = File(explicit ?? '$cacheDir/$prefix/$_iconsJsonName');
  if (file.existsSync()) return file.readAsString();

  final version = args['version'] as String?;
  final sha256 = args['sha256'] as String?;
  if (version == null || sha256 == null) {
    throw ArgumentError(
      'Missing ${file.path}. Pass --icons-json, or supply --version and '
      '--sha256 to download it.',
    );
  }

  final url = Uri.parse(
    'https://unpkg.com/@iconify-json/$prefix@$version/$_iconsJsonName',
  );
  stdout.writeln('Downloading $url');
  final client = HttpClient();
  try {
    final request = await client.getUrl(url);
    final response = await request.close();
    if (response.statusCode != 200) {
      throw HttpException('Download failed: ${response.statusCode}', uri: url);
    }
    final bytes = await response.fold<List<int>>(
      <int>[],
      (all, chunk) => all..addAll(chunk),
    );
    final actual = _sha256(bytes);
    if (actual != sha256.toLowerCase()) {
      throw StateError(
        'Checksum mismatch for $prefix:\\n  expected $sha256\\n  actual   '
        '$actual',
      );
    }
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes);
    return utf8.decode(bytes);
  } finally {
    client.close();
  }
}

/// Builds the SVG transform attribute implementing Iconify's per-icon overrides.
String _viewBoxTransform({
  required double width,
  required double height,
  required double left,
  required double top,
  required int rotate,
  required bool hFlip,
  required bool vFlip,
}) {
  final operations = <String>[
    if (left != 0 || top != 0) 'translate(${_num(left)} ${_num(top)})',
    if (hFlip || vFlip)
      'translate(${_num(hFlip ? width : 0)} ${_num(vFlip ? height : 0)}) '
          'scale(${hFlip ? -1 : 1} ${vFlip ? -1 : 1})',
    if (rotate % 4 != 0)
      'rotate(${rotate % 4 * 90} ${_num(width / 2)} ${_num(height / 2)})',
  ];
  return operations.isEmpty ? '' : ' transform="${operations.join(' ')}"';
}

/// Renders a double without a trailing `.0` so the output stays compact.
String _num(double value) {
  if (value == value.roundToDouble() && value.abs() < 1e15) {
    return value.toInt().toString();
  }
  return value.toString();
}

String _escape(String value) =>
    value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");

String _pascal(String value) => value
    .split(RegExp('[^a-zA-Z0-9]+'))
    .where((part) => part.isNotEmpty)
    .map((part) => part[0].toUpperCase() + part.substring(1))
    .join();

int _parseCodePoint(String value) {
  final normalized = value
      .toLowerCase()
      .replaceFirst('u+', '')
      .replaceFirst('0x', '');
  final parsed = int.tryParse(normalized, radix: 16);
  if (parsed == null) {
    throw ArgumentError('Invalid codepoint: $value');
  }
  return parsed;
}

/// Minimal SHA-256 so the tool has no crypto dependency.
String _sha256(List<int> bytes) {
  const k = <int>[
    0x428a2f98,
    0x71374491,
    0xb5c0fbcf,
    0xe9b5dba5,
    0x3956c25b,
    0x59f111f1,
    0x923f82a4,
    0xab1c5ed5,
    0xd807aa98,
    0x12835b01,
    0x243185be,
    0x550c7dc3,
    0x72be5d74,
    0x80deb1fe,
    0x9bdc06a7,
    0xc19bf174,
    0xe49b69c1,
    0xefbe4786,
    0x0fc19dc6,
    0x240ca1cc,
    0x2de92c6f,
    0x4a7484aa,
    0x5cb0a9dc,
    0x76f988da,
    0x983e5152,
    0xa831c66d,
    0xb00327c8,
    0xbf597fc7,
    0xc6e00bf3,
    0xd5a79147,
    0x06ca6351,
    0x14292967,
    0x27b70a85,
    0x2e1b2138,
    0x4d2c6dfc,
    0x53380d13,
    0x650a7354,
    0x766a0abb,
    0x81c2c92e,
    0x92722c85,
    0xa2bfe8a1,
    0xa81a664b,
    0xc24b8b70,
    0xc76c51a3,
    0xd192e819,
    0xd6990624,
    0xf40e3585,
    0x106aa070,
    0x19a4c116,
    0x1e376c08,
    0x2748774c,
    0x34b0bcb5,
    0x391c0cb3,
    0x4ed8aa4a,
    0x5b9cca4f,
    0x682e6ff3,
    0x748f82ee,
    0x78a5636f,
    0x84c87814,
    0x8cc70208,
    0x90befffa,
    0xa4506ceb,
    0xbef9a3f7,
    0xc67178f2,
  ];
  var h = <int>[
    0x6a09e667,
    0xbb67ae85,
    0x3c6ef372,
    0xa54ff53a,
    0x510e527f,
    0x9b05688c,
    0x1f83d9ab,
    0x5be0cd19,
  ];
  final message = List<int>.of(bytes)..add(0x80);
  while (message.length % 64 != 56) {
    message.add(0);
  }
  final bitLength = bytes.length * 8;
  for (var i = 7; i >= 0; i--) {
    message.add((bitLength >> (i * 8)) & 0xff);
  }
  final w = List<int>.filled(64, 0);
  for (var chunk = 0; chunk < message.length; chunk += 64) {
    for (var i = 0; i < 16; i++) {
      w[i] =
          (message[chunk + i * 4] << 24) |
          (message[chunk + i * 4 + 1] << 16) |
          (message[chunk + i * 4 + 2] << 8) |
          message[chunk + i * 4 + 3];
    }
    for (var i = 16; i < 64; i++) {
      final s0 = _rotr(w[i - 15], 7) ^ _rotr(w[i - 15], 18) ^ (w[i - 15] >> 3);
      final s1 = _rotr(w[i - 2], 17) ^ _rotr(w[i - 2], 19) ^ (w[i - 2] >> 10);
      w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & 0xffffffff;
    }
    var a = h[0], b = h[1], c = h[2], d = h[3];
    var e = h[4], f = h[5], g = h[6], hh = h[7];
    for (var i = 0; i < 64; i++) {
      final s1 = _rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25);
      final ch = (e & f) ^ (~e & g);
      final t1 = (hh + s1 + ch + k[i] + w[i]) & 0xffffffff;
      final s0 = _rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22);
      final maj = (a & b) ^ (a & c) ^ (b & c);
      final t2 = (s0 + maj) & 0xffffffff;
      hh = g;
      g = f;
      f = e;
      e = (d + t1) & 0xffffffff;
      d = c;
      c = b;
      b = a;
      a = (t1 + t2) & 0xffffffff;
    }
    h = [
      (h[0] + a) & 0xffffffff,
      (h[1] + b) & 0xffffffff,
      (h[2] + c) & 0xffffffff,
      (h[3] + d) & 0xffffffff,
      (h[4] + e) & 0xffffffff,
      (h[5] + f) & 0xffffffff,
      (h[6] + g) & 0xffffffff,
      (h[7] + hh) & 0xffffffff,
    ];
  }
  return h.map((value) => value.toRadixString(16).padLeft(8, '0')).join();
}

int _rotr(int value, int count) =>
    ((value >> count) | (value << (32 - count))) & 0xffffffff;

/// Formats [path] with the same `dart format` the repo enforces, so a
/// regenerated catalog is byte-identical to the committed file. Without this,
/// running `dart format .` would desync the catalog from its generator.
Future<void> _format(String path) async {
  final result = await Process.run(Platform.resolvedExecutable, [
    'format',
    path,
  ]);
  if (result.exitCode != 0) {
    stderr.write(result.stderr);
    throw ProcessException(
      Platform.resolvedExecutable,
      ['format', path],
      'Formatting the generated catalog failed',
      result.exitCode,
    );
  }
}

/// Reports whether [path] differs from [rendered] once formatted.
///
/// The comparison runs through a scratch file so the committed catalog and the
/// generator's output pass through the same formatter.
Future<bool> _isStale(String path, String rendered) async {
  final scratch = File('$path.check');
  try {
    await scratch.writeAsString(rendered);
    await _format(scratch.path);
    final formatted = await scratch.readAsString();
    final committed = File(path);
    final current = committed.existsSync() ? committed.readAsStringSync() : '';
    return formatted != current;
  } finally {
    if (scratch.existsSync()) scratch.deleteSync();
  }
}
