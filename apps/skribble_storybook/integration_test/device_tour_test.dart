import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:skribble/testing.dart';
import 'package:skribble_storybook/app.dart';
import 'package:skribble_storybook/widgets/roughness_picker.dart';

/// A tour of every storybook page on a real device, simulator, emulator, or
/// desktop window: the platform's own engine, fonts, and screen size.
///
/// Each page is scrolled a screen at a time, in the paper and the night
/// theme and at 1× and 2× text. Every screen is checked for overflow and
/// with [crampedText] (lines and icons included) and [squeezedText], and
/// is captured as a PNG for review.
///
/// Run it with the driver, which saves the captures on the host in
/// `SKRIBBLE_TOUR_DIR` (default `.screenshots/devices` at the repo root):
///
/// ```sh
/// SKRIBBLE_TOUR_DIR=/tmp/skribble-tour/iphone flutter drive -d <device> \
///   --driver=test_driver/device_tour_test.dart \
///   --target=integration_test/device_tour_test.dart
/// ```
///
/// Pass `--dart-define=SKRIBBLE_TOUR_THEMES=paper` or
/// `--dart-define=SKRIBBLE_TOUR_SCALES=1,1.3,2` to choose the passes.
///
/// Findings go to `<dir>/findings.txt`; the test fails when there are any.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const routes = [
    '/',
    '/buttons',
    '/inputs',
    '/navigation',
    '/selection',
    '/feedback',
    '/layout',
    '/data-display',
    '/loading',
    '/skribble-icons',
    '/emoji',
    '/charts',
    '/font-specimen',
  ];
  const screensPerPage = 3;
  final shots = <String, String>{};
  final findings = <String>[];

  testWidgets('every storybook page on this device', (tester) async {
    final boundary = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(key: boundary, child: const SkribbleStorybookApp()),
    );
    await tester.pump(const Duration(seconds: 1));

    Future<void> capture(String name) async {
      final render =
          boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      // Twice the logical size is sharp enough to review text and keeps
      // the captures small on 3x phones.
      final image = await render.toImage(
        pixelRatio: math.min(tester.view.devicePixelRatio, 2),
      );
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      shots[name] = base64Encode(bytes!.buffer.asUint8List());
    }

    void check(String name) {
      final error = tester.takeException();
      if (error != null) findings.add('$name: ${'$error'.split('\n').first}');
      final root = tester.binding.renderViews.first;
      for (final cramped in crampedText(root, lines: true, icons: true)) {
        findings.add('$name: $cramped');
      }
      for (final squeezed in squeezedText(root)) {
        findings.add('$name: squeezed $squeezed');
      }
    }

    const themes = String.fromEnvironment(
      'SKRIBBLE_TOUR_THEMES',
      defaultValue: 'paper,night',
    );
    const scales = String.fromEnvironment(
      'SKRIBBLE_TOUR_SCALES',
      defaultValue: '1,2',
    );
    for (final night in themes.split(',').map((theme) => theme == 'night')) {
      tester
          .widget<WiredRoughnessPicker>(find.byType(WiredRoughnessPicker))
          .onNightChanged
          ?.call(night);
      for (final scale in scales.split(',').map(double.parse)) {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        for (final route in routes) {
          tester
              .state<NavigatorState>(find.byType(Navigator).first)
              .pushNamedAndRemoveUntil(route, (_) => false);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 900));
          final page = route == '/' ? 'home' : route.substring(1);
          final label = '${night ? 'night' : 'paper'}-${scale}x-$page';
          for (var screen = 0; screen < screensPerPage; screen++) {
            final name = '$label-$screen';
            check(name);
            await capture(name);
            final scrollables = find.byType(Scrollable);
            if (scrollables.evaluate().isEmpty) break;
            final position = tester
                .state<ScrollableState>(scrollables.first)
                .position;
            if (position.pixels >= position.maxScrollExtent) break;
            position.jumpTo(
              (position.pixels + position.viewportDimension * .9).clamp(
                0,
                position.maxScrollExtent,
              ),
            );
            await tester.pump(const Duration(milliseconds: 300));
          }
        }
      }
    }
    tester.platformDispatcher.clearTextScaleFactorTestValue();

    binding.reportData = {'shots': shots, 'findings': findings};
    expect(findings, isEmpty, reason: findings.join('\n'));
  });
}
