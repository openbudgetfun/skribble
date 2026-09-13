import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The pre-boot shell is plain HTML, so it needs its own guard: nothing else
/// in the docs suite would notice if the mark, the status line, or the
/// handover were dropped.
void main() {
  final shell = File('web/index.html').readAsStringSync();

  test('sketches the brand mark on paper', () {
    expect(RegExp('<path d="M ').allMatches(shell).length, 6);
    expect(shell, contains('<title>skribble — make something delightful</title>'));
    expect(shell, contains('Getting the pens ready…'));
    expect(
      shell,
      contains(
        'assets/packages/skribble/assets/fonts/SkribblePlayful-Regular.ttf',
      ),
    );
  });

  test('fades out on the first Flutter frame', () {
    expect(shell, contains("addEventListener('flutter-first-frame'"));
    expect(shell, contains('is-done'));
  });

  test('keeps a reduced-motion pose and a late-wait hint', () {
    expect(shell, contains('prefers-reduced-motion'));
    expect(shell, contains('Still fetching the ink…'));
  });
}
