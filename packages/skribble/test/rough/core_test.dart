import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('Op', () {
    test('move creates move operation', () {
      final op = Op.move(PointD(1, 2));
      expect(op.op, OpType.move);
      expect(op.data.length, 1);
      expect(op.data[0].x, 1);
      expect(op.data[0].y, 2);
    });

    test('lineTo creates lineTo operation', () {
      final op = Op.lineTo(PointD(3, 4));
      expect(op.op, OpType.lineTo);
      expect(op.data.length, 1);
    });

    test('curveTo creates curveTo operation with 3 points', () {
      final op = Op.curveTo(PointD(1, 1), PointD(2, 2), PointD(3, 3));
      expect(op.op, OpType.curveTo);
      expect(op.data.length, 3);
    });
  });

  group('OpSet', () {
    test('creates with type and ops', () {
      final opSet = OpSet(type: OpSetType.path, ops: [Op.move(PointD(0, 0))]);
      expect(opSet.type, OpSetType.path);
      expect(opSet.ops!.length, 1);
    });

    test('creates empty with null fields', () {
      final opSet = OpSet();
      expect(opSet.type, isNull);
      expect(opSet.ops, isNull);
    });

    test('supports all OpSetType values', () {
      for (final type in OpSetType.values) {
        final opSet = OpSet(type: type, ops: []);
        expect(opSet.type, type);
      }
    });
  });

  group('Line', () {
    test('computes length for horizontal line', () {
      final line = Line(PointD(0, 0), PointD(10, 0));
      expect(line.length, 10.0);
    });

    test('computes length for vertical line', () {
      final line = Line(PointD(0, 0), PointD(0, 5));
      expect(line.length, 5.0);
    });

    test('computes length for diagonal line', () {
      final line = Line(PointD(0, 0), PointD(3, 4));
      expect(line.length, 5.0);
    });

    test('zero-length line has length 0', () {
      final line = Line(PointD(5, 5), PointD(5, 5));
      expect(line.length, 0.0);
    });

    test('onSegment returns true for midpoint', () {
      final line = Line(PointD(0, 0), PointD(10, 10));
      expect(line.onSegment(PointD(5, 5)), isTrue);
    });

    test('onSegment returns false for point outside', () {
      final line = Line(PointD(0, 0), PointD(10, 10));
      expect(line.onSegment(PointD(15, 15)), isFalse);
    });

    test('onSegment returns true for endpoint', () {
      final line = Line(PointD(0, 0), PointD(10, 10));
      expect(line.onSegment(PointD(0, 0)), isTrue);
      expect(line.onSegment(PointD(10, 10)), isTrue);
    });

    test('intersects returns true for crossing lines', () {
      final line1 = Line(PointD(0, 0), PointD(10, 10));
      final line2 = Line(PointD(0, 10), PointD(10, 0));
      expect(line1.intersects(line2), isTrue);
    });

    test('intersects returns false for parallel lines', () {
      final line1 = Line(PointD(0, 0), PointD(10, 0));
      final line2 = Line(PointD(0, 5), PointD(10, 5));
      expect(line1.intersects(line2), isFalse);
    });

    test('isMidPointInPolygon returns true for enclosed segment', () {
      final polygon = [
        PointD(0, 0),
        PointD(10, 0),
        PointD(10, 10),
        PointD(0, 10),
      ];
      final line = Line(PointD(3, 3), PointD(7, 7));
      expect(line.isMidPointInPolygon(polygon), isTrue);
    });

    test('isMidPointInPolygon returns false for external segment', () {
      final polygon = [
        PointD(0, 0),
        PointD(10, 0),
        PointD(10, 10),
        PointD(0, 10),
      ];
      final line = Line(PointD(20, 20), PointD(30, 30));
      expect(line.isMidPointInPolygon(polygon), isFalse);
    });
  });
}
