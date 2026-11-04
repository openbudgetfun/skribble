import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_icons/skribble_icons.dart';
import 'package:skribble_storybook/app.dart';

import 'support/skribble_fonts.dart';

/// Where the review captures live, relative to this file:
/// `.screenshots/review/` at the repository root, which Git ignores.
const _reviewDirectory = '../../../.screenshots/review';

/// The pages to review, in the order the captures are numbered.
const List<({String route, String capture})> _pages = [
  (route: '/', capture: '01-home.png'),
  (route: '/buttons', capture: '02-buttons.png'),
  (route: '/inputs', capture: '03-inputs.png'),
  (route: '/navigation', capture: '04-navigation.png'),
  (route: '/selection', capture: '05-selection.png'),
  (route: '/feedback', capture: '06-feedback.png'),
  (route: '/layout', capture: '07-layout.png'),
  (route: '/data-display', capture: '08-data-display.png'),
  (route: '/rough-icons', capture: '09-rough-icons.png'),
];

/// Renders storybook pages, with the real fonts and hand-drawn icons, into
/// `.screenshots/review/` for a visual pass. The images stay out of Git.
///
/// Capture them, from `apps/skribble_storybook`:
///
/// ```bash
/// flutter test --update-goldens test/visual_review_test.dart
/// ```
///
/// Later runs without `--update-goldens` compare against those captures. A
/// page is skipped until its capture exists, and every page is skipped on CI,
/// so the regular suite never depends on local images.
void main() {
  final runningInCi = Platform.environment['CI'] == 'true';

  setUpAll(() async {
    registerSkribbleIcons();
    await loadSkribbleFonts();
  });

  group('Visual review', () {
    for (final page in _pages) {
      final golden = '$_reviewDirectory/${page.capture}';
      // `flutter test` runs from the package root; goldens resolve from
      // this file's directory.
      final captured = File('test/$golden').existsSync();

      testWidgets(
        '${page.route} matches its review capture',
        (tester) async {
          await tester.pumpWidget(const SkribbleStorybookApp());
          await tester.pumpAndSettle();
          if (page.route != '/') {
            tester
                .state<NavigatorState>(find.byType(Navigator).first)
                .pushNamedAndRemoveUntil(page.route, (_) => false);
            await tester.pumpAndSettle();
          }

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile(golden),
          );
        },
        skip: runningInCi || !(captured || autoUpdateGoldenFiles),
      );
    }
  });
}
