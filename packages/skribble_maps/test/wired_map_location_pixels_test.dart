import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_maps/skribble_maps.dart';

import 'helpers/pump_map.dart';

void main() {
  testWidgets('all heading treatments preserve map detail and stable ink', (
    tester,
  ) async {
    const key = Key('location-ink');
    const blue = [0x34, 0x78, 0xE5];
    Future<ByteData> render(
      WiredMapHeadingStyle style,
      Color background, {
      int seed = 37,
    }) async {
      await pumpMapApp(
        tester,
        RepaintBoundary(
          key: key,
          child: ColoredBox(
            color: background,
            child: WiredMapLocation(
              heading: 35,
              headingStyle: style,
              seed: seed,
            ),
          ),
        ),
        size: const Size(128, 128),
      );
      await tester.pumpAndSettle();

      return (await tester.runAsync(() async {
        final image = await tester
            .renderObject<RenderRepaintBoundary>(find.byKey(key))
            .toImage();
        final bytes = (await image.toByteData())!;
        image.dispose();
        return bytes;
      }))!;
    }

    for (final background in [
      const Color(0xFFF6F2E9),
      const Color(0xFF272E32),
    ]) {
      final rgb = [
        (background.r * 255).round(),
        (background.g * 255).round(),
        (background.b * 255).round(),
      ];
      final coverage = <WiredMapHeadingStyle, int>{};

      for (final style in WiredMapHeadingStyle.values) {
        final pixels = await render(style, background);
        final repeated = await render(style, background);
        final anotherSeed = await render(style, background, seed: 91);
        expect(pixels.buffer.asUint8List(), repeated.buffer.asUint8List());
        expect(
          pixels.buffer.asUint8List(),
          isNot(anotherSeed.buffer.asUint8List()),
        );
        expect(pixels.getUint32((64 * 128 + 64) * 4), 0x3478E5FF);
        var changed = 0;

        for (var y = 0; y < 128; y++) {
          for (var x = 0; x < 128; x++) {
            // Exclude the opaque dot and its white rim. Only the fan should
            // blend with the map; its ink must never obscure it completely.
            if (math.pow(x - 64, 2) + math.pow(y - 64, 2) <= 15 * 15) continue;
            final offset = (y * 128 + x) * 4;
            var differs = false;

            for (var channel = 0; channel < 3; channel++) {
              final value = pixels.getUint8(offset + channel);
              final difference = (value - rgb[channel]).abs();
              final maximumDifference =
                  ((blue[channel] - rgb[channel]).abs() * 0.4).ceil() + 1;
              expect(difference, lessThanOrEqualTo(maximumDifference));
              differs = differs || difference != 0;

              if (y > 84) expect(value, rgb[channel]);
            }

            if (differs) changed++;
          }
        }

        expect(changed, greaterThan(30));
        coverage[style] = changed;
      }

      expect(
        coverage[WiredMapHeadingStyle.hatching],
        lessThan(coverage[WiredMapHeadingStyle.wash]!),
      );
      expect(
        coverage[WiredMapHeadingStyle.washAndHatching],
        greaterThan(coverage[WiredMapHeadingStyle.hatching]!),
      );
    }
  });
}
