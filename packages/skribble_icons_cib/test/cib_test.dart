import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_icons_cib/skribble_icons_cib.dart';

void main() {
  group('kCibIcons', () {
    test('ships a populated catalog', () {
      expect(kCibIcons, isNotEmpty);
      expect(kCibIconCodePoints, isNotEmpty);
    });

    test('every codepoint has geometry', () {
      for (final codePoint in kCibIconCodePoints.values) {
        expect(
          kCibIcons[codePoint],
          isNotNull,
          reason: '0x${codePoint.toRadixString(16)} has no geometry',
        );
      }
    });

    test('every entry has primitives and positive dimensions', () {
      for (final entry in kCibIcons.entries) {
        final label = '0x${entry.key.toRadixString(16)}';
        expect(entry.value.primitives, isNotEmpty, reason: '$label empty');
        expect(entry.value.width, greaterThan(0), reason: '$label width');
        expect(entry.value.height, greaterThan(0), reason: '$label height');
      }
    });

    test('codepoints stay inside the reserved cib band', () {
      for (final codePoint in kCibIcons.keys) {
        expect(
          codePoint,
          inInclusiveRange(0xf400, 0xf7ff),
          reason: '0x${codePoint.toRadixString(16)} escaped the cib band',
        );
      }
    });

    test('rendering one entry produces no error', () async {
      final data = kCibIcons.values.first;
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

  group('lookupCibIconByIdentifier', () {
    test('resolves a known identifier', () {
      final identifier = kCibIconCodePoints.keys.first;
      expect(lookupCibIconByIdentifier(identifier), isNotNull);
    });

    test('returns null for unknown identifiers', () {
      expect(lookupCibIconByIdentifier('not_a_real_icon'), isNull);
    });

    test('count accessor matches the generated map', () {
      expect(cibIconCount, kCibIconCodePoints.length);
    });
  });
}
