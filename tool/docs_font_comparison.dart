import 'dart:io';

/// Copies the pinned, unmodified font specimens used in the docs comparison.
/// Roughened families are generated once by `roughen_fonts.dart` in the library.
Future<void> main(List<String> arguments) async {
  final check = arguments.contains('--check');
  final destination = Directory('docs/site/assets/fonts');
  if (!check) await destination.create(recursive: true);

  for (final source in [
    'RecursiveSansCslSt',
    'RecursiveSansLnrSt',
    'RecursiveMonoLnrSt',
  ]) {
    for (final suffix in ['Regular', 'Bold', 'Italic', 'BoldItalic']) {
      final name = '$source-$suffix.ttf';
      final bytes = await File('packages/skribble/tool/font/$name')
          .readAsBytes();
      final file = File('${destination.path}/$name');

      if (!check) {
        await file.writeAsBytes(bytes);
        continue;
      }

      final current = await file.readAsBytes();
      if (current.length != bytes.length ||
          Iterable<int>.generate(bytes.length)
              .any((i) => current[i] != bytes[i])) {
        stderr.writeln('Stale specimen: ${file.path}');
        exitCode = 1;
      }
    }
  }
}
