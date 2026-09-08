import 'dart:io';

import 'package:http/http.dart' as http;

const _version = '17.0.0';
const _zipHash =
    '59b0cd9f6fe033818fc02585cea42bea9fba5d68a4d3a3639bfe5d5cc3805689';
const _csvHash =
    '28375217b92fafacc59d7dfea631c720abedc883518dbf12a73d25d4032cbe7e';

/// Rebuilds the pinned emoji, curated icons, and all four bundled text fonts.
/// Run from the repository root. The downloaded source hashes are verified
/// before generation; upstream updates require an explicit version/hash edit.
Future<void> main(List<String> arguments) async {
  final cache = Directory('.audit/visual-sources')..createSync(recursive: true);
  final client = http.Client();
  try {
    for (final source in [
      (
        name: 'color.zip',
        hash: _zipHash,
        url:
            'https://github.com/hfg-gmuend/openmoji/releases/download/$_version/openmoji-svg-color.zip',
      ),
      (
        name: 'openmoji.csv',
        hash: _csvHash,
        url:
            'https://raw.githubusercontent.com/hfg-gmuend/openmoji/$_version/data/openmoji.csv',
      ),
    ]) {
      final file = File('${cache.path}/${source.name}');
      if (!file.existsSync()) {
        final response = await client.get(Uri.parse(source.url));
        if (response.statusCode != 200)
          throw HttpException(
            'Download failed: ${response.statusCode}',
            uri: Uri.parse(source.url),
          );
        await file.writeAsBytes(response.bodyBytes);
      }
      final checksum = await Process.run('shasum', ['-a', '256', file.path]);
      if (checksum.exitCode != 0 ||
          !(checksum.stdout as String).startsWith(source.hash)) {
        throw StateError('Source checksum mismatch: ${file.path}');
      }
    }
    final extracted = Directory('${cache.path}/svg');
    if (extracted.existsSync()) extracted.deleteSync(recursive: true);
    await _run('unzip', [
      '-q',
      '-o',
      '${cache.path}/color.zip',
      '-d',
      '${cache.path}/svg',
    ]);
    await _run(Platform.resolvedExecutable, [
      'run',
      'packages/skribble_emoji_gen/bin/generate_emoji.dart',
      '--svg-dir',
      '${cache.path}/svg',
      '--csv-file',
      '${cache.path}/openmoji.csv',
      '--output-dir',
      'packages/skribble_emoji/lib/src/generated',
    ]);
    await _run(Platform.resolvedExecutable, [
      'run',
      'packages/skribble_emoji_gen/bin/generate_icons.dart',
    ]);
    await _run(Platform.resolvedExecutable, [
      'run',
      'packages/skribble_font_roughen/bin/roughen_fonts.dart',
    ]);
    await _run(Platform.resolvedExecutable, [
      'format',
      'packages/skribble_emoji/lib/src/generated',
      'packages/skribble_icons/lib/src/generated/skribble_icons_rough.g.dart',
    ]);
  } finally {
    client.close();
  }
}

Future<void> _run(String executable, List<String> arguments) async {
  final process = await Process.start(
    executable,
    arguments,
    mode: ProcessStartMode.inheritStdio,
  );
  final result = await process.exitCode;
  if (result != 0)
    throw ProcessException(
      executable,
      arguments,
      'Asset generation failed',
      result,
    );
}
