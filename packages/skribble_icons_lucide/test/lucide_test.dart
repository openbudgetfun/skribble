import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_icons_lucide/skribble_icons_lucide.dart';

void main() {
  group('kLucideIcons', () {
    test('ships a populated catalog', () {
      expect(kLucideIcons, isNotEmpty);
      expect(kLucideIconCodePoints, isNotEmpty);
    });

    test('every codepoint has geometry', () {
      for (final codePoint in kLucideIconCodePoints.values) {
        expect(
          kLucideIcons[codePoint],
          isNotNull,
          reason: '0x${codePoint.toRadixString(16)} has no geometry',
        );
      }
    });

    test('every entry has primitives and positive dimensions', () {
      for (final entry in kLucideIcons.entries) {
        final label = '0x${entry.key.toRadixString(16)}';
        expect(entry.value.primitives, isNotEmpty, reason: '$label empty');
        expect(entry.value.width, greaterThan(0), reason: '$label width');
        expect(entry.value.height, greaterThan(0), reason: '$label height');
      }
    });

    test('codepoints stay inside the reserved lucide band', () {
      for (final codePoint in kLucideIcons.keys) {
        expect(
          codePoint,
          inInclusiveRange(0xe000, 0xefff),
          reason: '0x${codePoint.toRadixString(16)} escaped the lucide band',
        );
      }
    });

    test('rendering one entry produces no error', () async {
      final data = kLucideIcons.values.first;
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

  group('lookupLucideIconByIdentifier', () {
    test('resolves a known identifier', () {
      final identifier = kLucideIconCodePoints.keys.first;
      expect(lookupLucideIconByIdentifier(identifier), isNotNull);
    });

    test('returns null for unknown identifiers', () {
      expect(lookupLucideIconByIdentifier('not_a_real_icon'), isNull);
    });

    test('count accessor matches the generated map', () {
      expect(lucideIconCount, kLucideIconCodePoints.length);
    });
  });
}
