import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('Drawable', () {
    test('creates with default null fields', () {
      final drawable = Drawable();
      expect(drawable.shape, isNull);
      expect(drawable.options, isNull);
      expect(drawable.sets, isNull);
    });

    test('creates with all fields', () {
      final drawable = Drawable(
        shape: 'rectangle',
        options: DrawConfig.defaultValues,
        sets: [OpSet(type: OpSetType.path, ops: [])],
      );
      expect(drawable.shape, 'rectangle');
      expect(drawable.options, isNotNull);
      expect(drawable.sets!.length, 1);
    });
  });

  group('PointD', () {
    test('stores x and y coordinates', () {
      final point = PointD(3.5, 7.2);
      expect(point.x, 3.5);
      expect(point.y, 7.2);
    });

    test('toString returns readable format', () {
      final point = PointD(1.0, 2.0);
      expect(point.toString(), contains('1.0'));
      expect(point.toString(), contains('2.0'));
    });

    test('isInPolygon returns true for point inside square', () {
      final polygon = [
        PointD(0, 0),
        PointD(10, 0),
        PointD(10, 10),
        PointD(0, 10),
      ];
      expect(PointD(5, 5).isInPolygon(polygon), isTrue);
    });

    test('isInPolygon returns false for point outside square', () {
      final polygon = [
        PointD(0, 0),
        PointD(10, 0),
        PointD(10, 10),
        PointD(0, 10),
      ];
      expect(PointD(15, 15).isInPolygon(polygon), isFalse);
    });

    test('isInPolygon returns false for fewer than 3 points', () {
      expect(PointD(1, 1).isInPolygon([PointD(0, 0), PointD(2, 2)]), isFalse);
      expect(PointD(1, 1).isInPolygon([]), isFalse);
    });

    test('isInPolygon works for triangle', () {
      final triangle = [PointD(0, 0), PointD(10, 0), PointD(5, 10)];
      expect(PointD(5, 3).isInPolygon(triangle), isTrue);
      expect(PointD(0, 10).isInPolygon(triangle), isFalse);
    });

    test('isInPolygon works for concave polygon', () {
      // L-shaped polygon
      final lShape = [
        PointD(0, 0),
        PointD(10, 0),
        PointD(10, 5),
        PointD(5, 5),
        PointD(5, 10),
        PointD(0, 10),
      ];
      // Inside the L
      expect(PointD(2, 2).isInPolygon(lShape), isTrue);
      expect(PointD(2, 8).isInPolygon(lShape), isTrue);
      // Inside the notch (outside the L)
      expect(PointD(8, 8).isInPolygon(lShape), isFalse);
    });

    test('equality via Point base class', () {
      final a = PointD(1.0, 2.0);
      final b = PointD(1.0, 2.0);
      expect(a, equals(b));
    });
  });
}
