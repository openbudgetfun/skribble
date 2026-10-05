import 'dart:io';

/// Rebuilds every generated visual asset: skribble's emoji catalog, the
/// built-in glyphs, the Iconify icon catalogs, and all bundled text fonts.
///
/// Run from the repository root. Each generator verifies its own pinned
/// sources (the emoji generator checks the Unicode `emoji-test.txt` hash), so
/// an upstream update always needs an explicit version and hash edit.
Future<void> main(List<String> arguments) async {
  await _run(Platform.resolvedExecutable, [
    'run',
    'packages/skribble_emoji_gen/bin/generate_emoji.dart',
  ]);
  await _run(Platform.resolvedExecutable, [
    'run',
    'packages/skribble_emoji_gen/bin/generate_glyphs.dart',
  ]);
  await _run(Platform.resolvedExecutable, [
    'run',
    'packages/skribble_font_roughen/bin/roughen_fonts.dart',
  ]);
  // The Iconify sets live in their own packages but are rebuilt here too, so
  // one command refreshes every visual asset from its pinned source.
  await _run('bash', ['scripts/generate_iconify_sets.sh']);
}

Future<void> _run(String executable, List<String> arguments) async {
  final process = await Process.start(
    executable,
    arguments,
    mode: ProcessStartMode.inheritStdio,
  );
  final result = await process.exitCode;
  if (result != 0) {
    throw ProcessException(
      executable,
      arguments,
      'Asset generation failed',
      result,
    );
  }
}
