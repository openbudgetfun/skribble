import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_icons_bxs/skribble_icons_bxs.dart';

void main() {
  group('kBxsIcons', () {
    test('ships a populated catalog', () {
      expect(kBxsIcons, isNotEmpty);
      expect(kBxsIconCodePoints, isNotEmpty);
    });

    test('every codepoint has geometry', () {
      for (final codePoint in kBxsIconCodePoints.values) {
        expect(
          kBxsIcons[codePoint],
          isNotNull,
          reason: '0x${codePoint.toRadixString(16)} has no geometry',
        );
      }
    });

    test('every entry has primitives and positive dimensions', () {
      for (final entry in kBxsIcons.entries) {
        final label = '0x${entry.key.toRadixString(16)}';
        expect(entry.value.primitives, isNotEmpty, reason: '$label empty');
        expect(entry.value.width, greaterThan(0), reason: '$label width');
        expect(entry.value.height, greaterThan(0), reason: '$label height');
      }
    });

    test('codepoints stay inside the reserved bxs band', () {
      for (final codePoint in kBxsIcons.keys) {
        expect(
          codePoint,
          inInclusiveRange(0xf100, 0xf3ff),
          reason: '0x${codePoint.toRadixString(16)} escaped the bxs band',
        );
      }
    });

    test('rendering one entry produces no error', () async {
      final data = kBxsIcons.values.first;
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      for (final primitive in data.primitives) {
        canvas
          ..drawPath(
            primitive.buildPath(),
            Paint()..style = PaintingStyle.fill,
          )
          ..drawPath(
            primitive.buildStrokePath(),
            Paint()..style = PaintingStyle.stroke,
          );
      }
      recorder.endRecording().dispose();
    });
  });

  group('lookupBxsIconByIdentifier', () {
    test('resolves a known identifier', () {
      final identifier = kBxsIconCodePoints.keys.first;
      expect(lookupBxsIconByIdentifier(identifier), isNotNull);
    });

    test('returns null for unknown identifiers', () {
      expect(lookupBxsIconByIdentifier('not_a_real_icon'), isNull);
    });

    test('count accessor matches the generated map', () {
      expect(bxsIconCount, kBxsIconCodePoints.length);
    });
  });
}
