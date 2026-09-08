import 'dart:io';

import 'package:skribble_font_roughen/skribble_font_roughen.dart';

/// Rebuilds every bundled roughness level and style from repository root.
/// Pass --check to verify artifacts without changing them.
Future<void> main(List<String> arguments) async {
  final check = arguments.contains('--check');
  final scratch = await Directory.systemTemp.createTemp('skribble-fonts-');
  var stale = false;

  try {
    for (final level in [
      (family: 'SkribbleGentle', strength: 18.0),
      (family: 'SkribblePlayful', strength: 27.0),
      (family: 'Skribble', strength: 36.0),
    ]) {
      for (final variant in FontVariant.values) {
        final suffix = variant.fullNameSuffix.replaceAll(' ', '');
        final name = '${level.family}-$suffix.ttf';
        final result = await FontRoughener(
          inputPath:
              'packages/skribble/tool/font/RecursiveSansCslSt-$suffix.ttf',
          outputPath: '${scratch.path}/$name',
          variant: variant,
          familyName: level.family,
          jitterAmount: level.strength,
        ).roughen();
        final bytes = await File(result.outputPath).readAsBytes();

        for (final directory in [
          'packages/skribble/assets/fonts',
          if (level.family == 'Skribble') ...[
            'packages/skribble/tool/font',
            'apps/skribble_storybook/assets/fonts',
          ],
        ]) {
          final destination = File('$directory/$name');

          if (check) {
            final current = await destination.readAsBytes();
            if (current.length != bytes.length ||
                !List.generate(
                  bytes.length,
                  (i) => i,
                ).every((i) => bytes[i] == current[i])) {
              stderr.writeln('Stale font: ${destination.path}');
              stale = true;
            }
          } else {
            await destination.writeAsBytes(bytes);
          }
        }

        stdout.writeln('$name: ${result.glyphCount} outlined glyphs');
      }
    }
  } finally {
    await scratch.delete(recursive: true);
  }

  if (stale) exitCode = 1;
}
