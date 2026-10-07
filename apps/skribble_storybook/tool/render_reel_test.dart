// Renders one of skribble's intro reels to PNG frames on the test clock, so
// every run produces identical frames. Run through `scripts/render_reel.sh`,
// which also encodes the video, or directly:
//
//   flutter test tool/render_reel_test.dart \
//     --dart-define=REEL=fun-again --dart-define=ASPECT=portrait \
//     --dart-define=REEL_OUT=<dir>
//
// Portrait frames are 1080x1920 and landscape frames 1920x1080, at 30 frames
// a second. REEL_STILLS renders only the given comma-separated seconds.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_storybook/promo/intro_reels.dart';

import '../test/support/skribble_fonts.dart';

const String _reel = String.fromEnvironment('REEL');
const String _aspect = String.fromEnvironment(
  'ASPECT',
  defaultValue: 'portrait',
);
const String _out = String.fromEnvironment('REEL_OUT');
const String _stills = String.fromEnvironment('REEL_STILLS');
const int _fps = 30;
const double _pixelRatio = 2;

void main() {
  testWidgets('render an intro reel', (tester) async {
    if (_out.isEmpty || _reel.isEmpty) {
      markTestSkipped('Set REEL and REEL_OUT to render frames.');
      return;
    }
    final reel = IntroReel.values.firstWhere((reel) => reel.slug == _reel);
    final size = switch (_aspect) {
      'landscape' => const Size(960, 540),
      'square' => const Size(540, 540),
      _ => const Size(540, 960),
    };
    await tester.runAsync(loadSkribbleFonts);
    tester.view
      ..physicalSize = size * _pixelRatio
      ..devicePixelRatio = _pixelRatio;
    addTearDown(tester.view.reset);

    final time = ValueNotifier<double>(0);
    await tester.pumpWidget(
      ValueListenableBuilder<double>(
        valueListenable: time,
        builder: (context, value, _) => reel.build(value),
      ),
    );
    final stills = [
      for (final value in _stills.split(','))
        if (value.trim().isNotEmpty) double.parse(value),
    ];
    final frames = reel.duration.inMilliseconds * _fps ~/ 1000;
    for (var frame = 0; frame < frames; frame++) {
      final seconds = frame / _fps;
      time.value = seconds;
      await tester.pump(const Duration(microseconds: 1000000 ~/ _fps));
      final name = stills.isEmpty
          ? frame.toString().padLeft(5, '0')
          : stills.contains(seconds)
          ? 'still-${seconds.toStringAsFixed(1)}'
          : null;
      if (name == null) continue;
      final layer = tester.binding.renderViews.first.debugLayer! as OffsetLayer;
      await tester.runAsync(() async {
        final image = await layer.toImage(Offset.zero & (size * _pixelRatio));
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        image.dispose();
        File('$_out/$name.png')
          ..createSync(recursive: true)
          ..writeAsBytesSync(png!.buffer.asUint8List());
      });
    }
  }, timeout: const Timeout(Duration(minutes: 60)));
}
