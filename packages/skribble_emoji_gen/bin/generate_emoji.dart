import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:skribble_emoji_gen/emoji_art_compiler.dart';
import 'package:skribble_emoji_gen/unicode_emoji.dart';

/// The pinned Unicode emoji list.
const _unicodeVersion = '18.0';
const _unicodeUrl =
    'https://www.unicode.org/Public/18.0.0/emoji/emoji-test.txt';
const _unicodeSha256 =
    '8f3735cda1f92a779d78af67cf86066bb1f07143dc22f2ac29394d9bc57ab21a';

const _defaultArt = 'packages/skribble_emoji/art';
const _defaultOutput = 'packages/skribble_emoji/lib/src/generated';
const _defaultCache = '.audit/unicode/emoji-test-$_unicodeVersion.txt';

const _groups = {
  'Smileys & Emotion': 'smileysAndEmotion',
  'People & Body': 'peopleAndBody',
  'Component': 'component',
  'Animals & Nature': 'animalsAndNature',
  'Food & Drink': 'foodAndDrink',
  'Travel & Places': 'travelAndPlaces',
  'Activities': 'activities',
  'Objects': 'objects',
  'Symbols': 'symbols',
  'Flags': 'flags',
};

const _tones = ['none', 'light', 'mediumLight', 'medium', 'mediumDark', 'dark'];

/// Generates skribble's emoji catalog from Unicode's emoji list and the art
/// in `packages/skribble_emoji/art`.
///
/// Every fully-qualified emoji is planned onto a drawing (see `planEmoji`),
/// each drawing is compiled from its SVG source, and the result is written
/// as Dart: the catalog, the uniform skin-tone map, and the compiled art. The
/// run fails when any emoji has no drawing unless `--allow-missing` is set,
/// in which case missing emoji are left out and listed.
Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('art', defaultsTo: _defaultArt)
    ..addOption('output', defaultsTo: _defaultOutput)
    ..addOption(
      'unicode',
      help: 'A local emoji-test.txt; otherwise the pinned file is downloaded.',
    )
    ..addOption('report', help: 'Write a JSON coverage report to this path.')
    ..addFlag(
      'allow-missing',
      negatable: false,
      help: 'Leave out emoji without art instead of failing.',
    )
    ..addFlag(
      'check',
      negatable: false,
      help: 'Verify the committed output is current without writing it.',
    );
  final args = parser.parse(arguments);

  final unicode = await _loadUnicode(args['unicode'] as String?);
  final plans = planEmoji(parseEmojiTest(unicode));

  final artDirectory = Directory(args['art'] as String);
  final sources = <String, String>{};
  final locations = <String, String>{};
  for (final file in artDirectory.listSync(recursive: true).whereType<File>()) {
    if (!file.path.endsWith('.svg')) continue;
    final key = p.basenameWithoutExtension(file.path);
    if (locations[key] case final existing?) {
      throw StateError('Art "$key" exists twice: $existing and ${file.path}');
    }
    sources[key] = file.readAsStringSync();
    locations[key] = file.path;
  }
  final compiler = EmojiArtCompiler(sources);

  final missing = <String, List<String>>{};
  final drawn = <EmojiPlan>[];
  final art = <String, List<CompiledShape>>{};
  for (final plan in plans) {
    if (!sources.containsKey(plan.art)) {
      (missing[plan.art] ??= []).add(plan.emoji.name);
      continue;
    }
    art[plan.art] ??= compiler.compile(plan.art);
    drawn.add(plan);
  }

  final arts = {for (final plan in plans) plan.art};
  stdout.writeln(
    'Unicode $_unicodeVersion: ${plans.length} emoji, ${arts.length} drawings; '
    '${art.length} drawn, ${missing.length} missing '
    '(${plans.length - drawn.length} emoji).',
  );
  if (args['report'] case final String path) {
    File(path)
      ..createSync(recursive: true)
      ..writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert({
          'emoji': plans.length,
          'drawings': arts.length,
          'drawn': art.length,
          'missing': {
            for (final entry in missing.entries)
              entry.key: {
                'group': plans
                    .firstWhere((plan) => plan.art == entry.key)
                    .emoji
                    .group,
                'names': entry.value,
              },
          },
        }),
      );
  }
  if (missing.isNotEmpty && !(args['allow-missing'] as bool)) {
    stderr.writeln('Emoji without art (pass --allow-missing to skip them):');
    for (final key in missing.keys.take(40)) {
      stderr.writeln('  $key');
    }
    if (missing.length > 40) stderr.writeln('  … ${missing.length - 40} more');
    exitCode = 1;
    return;
  }

  final outputs = {
    'emoji_catalog.g.dart': _catalog(drawn),
    'emoji_art.g.dart': _art(art),
  };
  final output = Directory(args['output'] as String);
  if (args['check'] as bool) {
    var stale = false;
    for (final MapEntry(key: name, value: content) in outputs.entries) {
      final file = File(p.join(output.path, name));
      if (!file.existsSync() ||
          await _formatted(content) != file.readAsStringSync()) {
        stderr.writeln('Stale emoji output: ${file.path}');
        stale = true;
      }
    }
    if (stale) {
      stderr.writeln(
        'Run dart run packages/skribble_emoji_gen/bin/generate_emoji.dart.',
      );
      exitCode = 1;
    } else {
      stdout.writeln('Emoji output is current.');
    }
    return;
  }
  output.createSync(recursive: true);
  for (final MapEntry(key: name, value: content) in outputs.entries) {
    File(p.join(output.path, name))
        .writeAsStringSync(await _formatted(content));
  }
  stdout.writeln('Wrote ${outputs.length} files to ${output.path}.');
}

Future<String> _loadUnicode(String? local) async {
  if (local != null) return _verified(File(local).readAsBytesSync(), local);
  final cache = File(_defaultCache);
  if (cache.existsSync()) {
    return _verified(cache.readAsBytesSync(), cache.path);
  }
  final response = await http.get(Uri.parse(_unicodeUrl));
  if (response.statusCode != 200) {
    throw HttpException('GET $_unicodeUrl returned ${response.statusCode}');
  }
  final text = _verified(response.bodyBytes, _unicodeUrl);
  cache
    ..createSync(recursive: true)
    ..writeAsBytesSync(response.bodyBytes);
  return text;
}

String _verified(List<int> bytes, String source) {
  final digest = sha256.convert(bytes).toString();
  if (digest != _unicodeSha256) {
    throw StateError(
      '$source has SHA-256 $digest; expected $_unicodeSha256 '
      '(Unicode $_unicodeVersion emoji-test.txt).',
    );
  }
  return utf8.decode(bytes);
}

String _string(String value) {
  final buffer = StringBuffer("'");
  for (final rune in value.runes) {
    if (rune < 0x20 ||
        rune > 0x7E ||
        rune == 0x27 ||
        rune == 0x5C ||
        rune == 0x24) {
      buffer.write('\\u{${rune.toRadixString(16).toUpperCase()}}');
    } else {
      buffer.writeCharCode(rune);
    }
  }
  buffer.write("'");
  return buffer.toString();
}

String _catalog(List<EmojiPlan> plans) {
  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// ignore_for_file: lines_longer_than_80_chars')
    ..writeln('//')
    ..writeln(
      '// Source: Unicode $_unicodeVersion emoji-test.txt and packages/skribble_emoji/art.',
    )
    ..writeln(
      '// Regenerate with: dart run packages/skribble_emoji_gen/bin/generate_emoji.dart',
    )
    ..writeln()
    ..writeln("import 'package:skribble_emoji/src/emoji_art.dart';")
    ..writeln("import 'package:skribble_emoji/src/emoji_catalog.dart';")
    ..writeln("import 'package:skribble_emoji/src/emoji_palette.dart';")
    ..writeln()
    ..writeln('/// Every drawn, fully-qualified emoji in Unicode order.')
    ..writeln('const List<EmojiEntry> kSkribbleEmojiEntries = [');

  final toned = <String, Map<int, String>>{};
  final hasTones = <String>{};
  for (final plan in plans) {
    if (plan.tone != 0) {
      hasTones.add(plan.baseName);
      if (plan.tone == plan.tone2) {
        (toned[plan.baseName] ??= {})[plan.tone] = plan.emoji.emoji;
      }
    }
  }
  final baseEmoji = <String, String>{};
  for (final plan in plans) {
    final named = <String>[
      if (plan.tone != 0) 'tone: EmojiSkinTone.${_tones[plan.tone]}',
      if (plan.tone2 != 0) 'tone2: EmojiSkinTone.${_tones[plan.tone2]}',
      if (plan.variant != null) 'variant: EmojiVariant.${plan.variant}',
      if (plan.mirrored) 'mirrored: true',
      if (plan.tone == 0 && hasTones.contains(plan.baseName)) 'hasTones: true',
    ];
    if (plan.tone == 0) baseEmoji[plan.baseName] = plan.emoji.emoji;
    buffer.writeln(
      '  EmojiEntry(${_string(plan.emoji.emoji)}, ${_string(plan.emoji.name)}, '
      'EmojiGroup.${_groups[plan.emoji.group]}, ${_string(plan.emoji.subgroup)}, '
      '${_string(plan.art)}${named.isEmpty ? '' : ', ${named.join(', ')}'}),',
    );
  }
  buffer
    ..writeln('];')
    ..writeln()
    ..writeln(
      '/// Each untoned emoji (without variation selectors) mapped to its five',
    )
    ..writeln('/// uniformly toned variants, light to dark.')
    ..writeln('const Map<String, List<String>> kSkribbleEmojiTones = {');
  for (final MapEntry(key: base, value: tones) in toned.entries) {
    final emoji = baseEmoji[base];
    if (emoji == null || tones.length != 5) continue;
    buffer.writeln(
      '  ${_string(emoji.replaceAll('️', ''))}: '
      '[${[for (var tone = 1; tone <= 5; tone++) _string(tones[tone]!)].join(', ')}],',
    );
  }
  buffer.writeln('};');
  return buffer.toString();
}

String _paint(String value) {
  if (value.startsWith('#')) {
    return 'EmojiPaint(0xFF${value.substring(1).toUpperCase()})';
  }
  final camel = value.replaceAllMapped(
    RegExp('-([a-z0-9])'),
    (match) => match.group(1)!.toUpperCase(),
  );
  return 'EmojiPaint.$camel';
}

String _art(Map<String, List<CompiledShape>> art) {
  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// ignore_for_file: lines_longer_than_80_chars')
    ..writeln('//')
    ..writeln('// Source: packages/skribble_emoji/art.')
    ..writeln(
      '// Regenerate with: dart run packages/skribble_emoji_gen/bin/generate_emoji.dart',
    )
    ..writeln()
    ..writeln("import 'package:skribble_emoji/src/emoji_art.dart';")
    ..writeln("import 'package:skribble_emoji/src/emoji_palette.dart';")
    ..writeln()
    ..writeln('/// Every compiled drawing, by art key.')
    ..writeln('const Map<String, EmojiArt> kSkribbleEmojiArt = {');
  final keys = art.keys.toList()..sort();
  for (final key in keys) {
    buffer.writeln("  '$key': EmojiArt([");
    for (final shape in art[key]!) {
      final named = <String>[
        if (shape.fill != null) 'fill: ${_paint(shape.fill!)}',
        if (shape.stroke != null) 'stroke: ${_paint(shape.stroke!)}',
        if (shape.stroke != null && shape.width != 2)
          'width: ${_number(shape.width)}',
        if (shape.part != null) "part: '${shape.part}'",
        if (shape.variant != null) 'variant: EmojiVariant.${shape.variant}',
        if (shape.clip != null) "clip: '${shape.clip}'",
        if (shape.evenOdd) 'evenOdd: true',
      ];
      buffer.writeln("    EmojiShape('${shape.d}', ${named.join(', ')}),");
    }
    buffer.writeln('  ]),');
  }
  buffer.writeln('};');
  return buffer.toString();
}

String _number(double value) {
  final rounded = (value * 100).round() / 100;
  return rounded == rounded.roundToDouble()
      ? rounded.toInt().toString()
      : rounded.toString();
}

/// Formats [source] with `dart format`, so output matches committed files.
Future<String> _formatted(String source) async {
  final scratch = await Directory.systemTemp.createTemp('skribble-emoji-');
  try {
    final file = File(p.join(scratch.path, 'output.dart'))
      ..writeAsStringSync(source);
    final result = await Process.run(Platform.resolvedExecutable, [
      'format',
      file.path,
    ]);
    if (result.exitCode != 0) {
      throw ProcessException(
        Platform.resolvedExecutable,
        ['format', file.path],
        '${result.stderr}',
        result.exitCode,
      );
    }
    return file.readAsStringSync();
  } finally {
    scratch.deleteSync(recursive: true);
  }
}
