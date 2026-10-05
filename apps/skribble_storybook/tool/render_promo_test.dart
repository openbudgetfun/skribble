// Renders skribble's promo reel to PNG frames on the test clock, so every run
// produces identical frames. Run through `scripts/render_promo.sh`, which also
// encodes the video, or directly:
//
//   flutter test tool/render_promo_test.dart --dart-define=PROMO_OUT=<dir>
//
// Frames are 1080x1080 at 30 frames a second.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_storybook/promo/promo_reel.dart';

const String _out = String.fromEnvironment('PROMO_OUT');
const int _fps = 30;
const double _side = 540;
const double _pixelRatio = 2;

/// Loads every bundled skribble font family, so text renders in the real
/// typefaces instead of the test font.
Future<void> _loadFonts() async {
  final manifest = File('../../packages/skribble_font_recursive/pubspec.yaml');
  String? family;
  final families = <String, List<String>>{};
  for (final line in manifest.readAsLinesSync()) {
    final name = RegExp(r'^\s*- family:\s*(\S+)').firstMatch(line);
    if (name != null) {
      family = name.group(1);
      families[family!] = [];
      continue;
    }
    final asset = RegExp(r'asset:\s*(\S+)').firstMatch(line);
    if (asset != null && family != null) families[family]!.add(asset.group(1)!);
  }
  for (final MapEntry(key: name, value: assets) in families.entries) {
    final loader = FontLoader('packages/skribble_font_recursive/$name');
    for (final asset in assets) {
      final bytes = File(
        '../../packages/skribble_font_recursive/$asset',
      ).readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }
}

void main() {
  testWidgets('render the promo reel', (tester) async {
    if (_out.isEmpty) {
      markTestSkipped('Set --dart-define=PROMO_OUT=<dir> to render frames.');
      return;
    }
    await tester.runAsync(_loadFonts);
    tester.view
      ..physicalSize = const Size(_side * _pixelRatio, _side * _pixelRatio)
      ..devicePixelRatio = _pixelRatio;
    addTearDown(tester.view.reset);

    final time = ValueNotifier<double>(0);
    await tester.pumpWidget(
      ValueListenableBuilder<double>(
        valueListenable: time,
        builder: (context, value, _) => PromoReel(time: value),
      ),
    );
    final frames = kPromoDuration.inSeconds * _fps;
    for (var frame = 0; frame < frames; frame++) {
      time.value = frame / _fps;
      await tester.pump(const Duration(microseconds: 1000000 ~/ _fps));
      final layer = tester.binding.renderViews.first.debugLayer! as OffsetLayer;
      await tester.runAsync(() async {
        final image = await layer.toImage(
          const Rect.fromLTWH(0, 0, _side * _pixelRatio, _side * _pixelRatio),
        );
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        image.dispose();
        File('$_out/${frame.toString().padLeft(5, '0')}.png')
          ..createSync(recursive: true)
          ..writeAsBytesSync(png!.buffer.asUint8List());
      });
    }
  }, timeout: const Timeout(Duration(minutes: 30)));
}
