import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_icons_simple/skribble_icons_simple.dart';

void main() {
  group('kSimpleIcons', () {
    test('ships the full Simple Icons set', () {
      expect(kSimpleIcons, hasLength(greaterThan(3400)));
      expect(kSimpleIconCodePoints, hasLength(kSimpleIcons.length));
    });

    test('every codepoint has geometry', () {
      for (final codePoint in kSimpleIconCodePoints.values) {
        expect(
          kSimpleIcons[codePoint],
          isNotNull,
          reason: '0x${codePoint.toRadixString(16)} has no geometry',
        );
      }
    });

    test('every entry has primitives and positive dimensions', () {
      for (final entry in kSimpleIcons.entries) {
        final label = '0x${entry.key.toRadixString(16)}';
        expect(entry.value.primitives, isNotEmpty, reason: '$label empty');
        expect(entry.value.width, greaterThan(0), reason: '$label width');
        expect(entry.value.height, greaterThan(0), reason: '$label height');
      }
    });

    test('codepoints stay inside the supplementary private-use band', () {
      for (final codePoint in kSimpleIcons.keys) {
        expect(
          codePoint,
          inInclusiveRange(0xf0000, 0xf0fff),
          reason:
              '0x${codePoint.toRadixString(16)} escaped the Simple Icons band',
        );
      }
    });

    test('well-known brands resolve', () {
      expect(lookupSimpleIconByIdentifier('github'), isNotNull);
      expect(lookupSimpleIconByIdentifier('flutter'), isNotNull);
      expect(lookupSimpleIconByIdentifier('docker'), isNotNull);
    });

    test('brands upstream deprecated resolve to null', () {
      // Simple Icons keeps 273 removed slugs marked `hidden` so existing
      // published names do not break. This catalog matches Iconify's published
      // count and leaves them out, so a deprecated mark is a lookup miss rather
      // than a ghost logo.
      expect(lookupSimpleIconByIdentifier('visualstudiocode'), isNull);
    });

    test('rendering one entry produces no error', () {
      final data = kSimpleIcons.values.first;
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

  group('lookupSimpleIconByIdentifier', () {
    test('returns null for unknown identifiers', () {
      expect(lookupSimpleIconByIdentifier('not_a_real_brand'), isNull);
    });

    test('count accessor matches the generated map', () {
      expect(simpleIconCount, kSimpleIconCodePoints.length);
      expect(simpleIconIdentifiers, hasLength(simpleIconCount));
      expect(simpleIconCodePoints, hasLength(simpleIconCount));
    });
  });
}
