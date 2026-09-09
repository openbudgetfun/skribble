import 'dart:io';

import 'package:skribble_font_roughen/skribble_font_roughen.dart';

/// Generates docs-only Linear specimens from the pinned Recursive 1.085 source.
Future<void> main(List<String> arguments) async {
  final check = arguments.contains('--check');
  final destination = Directory('docs/site/assets/fonts');
  final scratch = await Directory.systemTemp.createTemp('skribble-comparison-');
  if (!check) await destination.create(recursive: true);

  try {
    for (final variant in FontVariant.values) {
      final suffix = variant.fullNameSuffix.replaceAll(' ', '');
      for (final source in ['Csl', 'Lnr']) {
        final name = 'RecursiveSans${source}St-$suffix.ttf';
        await _write(
          File('${destination.path}/$name'),
          await File('packages/skribble/tool/font/$name').readAsBytes(),
          check: check,
        );
      }

      for (final level in [
        (name: 'Gentle', strength: 18.0),
        (name: 'Playful', strength: 27.0),
        (name: 'Expressive', strength: 36.0),
      ]) {
        final family = 'SkribbleLinear${level.name}';
        final name = '$family-$suffix.ttf';
        await FontRoughener(
          inputPath:
              'packages/skribble/tool/font/RecursiveSansLnrSt-$suffix.ttf',
          outputPath: '${scratch.path}/$name',
          variant: variant,
          familyName: family,
          jitterAmount: level.strength,
        ).roughen();
        await _write(
          File('${destination.path}/$name'),
          await File('${scratch.path}/$name').readAsBytes(),
          check: check,
        );
        stdout.writeln(name);
      }
    }
  } finally {
    await scratch.delete(recursive: true);
  }
}

Future<void> _write(File file, List<int> bytes, {required bool check}) async {
  if (!check) {
    await file.writeAsBytes(bytes);
    return;
  }

  final current = await file.readAsBytes();
  if (current.length != bytes.length ||
      Iterable<int>.generate(bytes.length).any((i) => current[i] != bytes[i])) {
    stderr.writeln('Stale specimen: ${file.path}');
    exitCode = 1;
  }
}
