import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble/src/rough/geometry.dart';

void main() {
  group('geometry helpers', () {
    test('rotatePoints returns empty list for null input', () {
      final rotated = rotatePoints(null, PointD(0, 0), 45);
      expect(rotated, isEmpty);
    });

    test('rotatePoints returns empty list for empty input', () {
      final rotated = rotatePoints(<PointD>[], PointD(0, 0), 45);
      expect(rotated, isEmpty);
    });

    test('rotatePoint rotates around origin by 90 degrees', () {
      final rotated = rotatePoint(PointD(1, 0), PointD(0, 0), 90);

      expect(rotated.x, closeTo(0, 1e-9));
      expect(rotated.y, closeTo(1, 1e-9));
    });

    test('rotatePoint rotates around custom center', () {
      final rotated = rotatePoint(PointD(3, 1), PointD(2, 1), 180);

      expect(rotated.x, closeTo(1, 1e-9));
      expect(rotated.y, closeTo(1, 1e-9));
    });

    test('rotatePoints rotates each point in list', () {
      final rotated = rotatePoints(
        <PointD>[PointD(1, 0), PointD(0, 1)],
        PointD(0, 0),
        90,
      );

      expect(rotated, hasLength(2));
      expect(rotated[0].x, closeTo(0, 1e-9));
      expect(rotated[0].y, closeTo(1, 1e-9));
      expect(rotated[1].x, closeTo(-1, 1e-9));
      expect(rotated[1].y, closeTo(0, 1e-9));
    });

    test('rotateLines rotates line endpoints', () {
      final lines = <Line>[Line(PointD(1, 0), PointD(1, 1))];

      final rotated = rotateLines(lines, PointD(0, 0), 90);

      expect(rotated, hasLength(1));
      expect(rotated.first.source.x, closeTo(0, 1e-9));
      expect(rotated.first.source.y, closeTo(1, 1e-9));
      expect(rotated.first.target.x, closeTo(-1, 1e-9));
      expect(rotated.first.target.y, closeTo(1, 1e-9));
    });

    test('getOrientation returns collinear for aligned points', () {
      final orientation = getOrientation(
        PointD(0, 0),
        PointD(1, 1),
        PointD(2, 2),
      );

      expect(orientation, PointsOrientation.collinear);
    });

    test('getOrientation returns clockwise', () {
      final orientation = getOrientation(
        PointD(0, 0),
        PointD(4, 4),
        PointD(1, 2),
      );

      expect(orientation, PointsOrientation.clockwise);
    });

    test('getOrientation returns counterclockwise', () {
      final orientation = getOrientation(
        PointD(0, 0),
        PointD(4, 4),
        PointD(2, 1),
      );

      expect(orientation, PointsOrientation.counterclockwise);
    });

    test('onSegmentPoints returns true when point is on segment', () {
      expect(
        onSegmentPoints(PointD(0, 0), PointD(5, 5), PointD(10, 10)),
        isTrue,
      );
    });

    test('onSegmentPoints returns false when point is outside segment', () {
      expect(
        onSegmentPoints(PointD(0, 0), PointD(12, 12), PointD(10, 10)),
        isFalse,
      );
    });
  });

  group('geometry data classes', () {
    test('ComputedEllipsePoints stores core and all points', () {
      final computed = ComputedEllipsePoints(
        corePoints: <PointD>[PointD(1, 1)],
        allPoints: <PointD>[PointD(2, 2)],
      );

      expect(computed.corePoints, hasLength(1));
      expect(computed.allPoints, hasLength(1));
    });

    test('EllipseParams supports nullable and explicit values', () {
      final defaults = EllipseParams();
      expect(defaults.rx, isNull);
      expect(defaults.ry, isNull);
      expect(defaults.increment, isNull);

      final params = EllipseParams(rx: 10, ry: 8, increment: 0.15);
      expect(params.rx, 10);
      expect(params.ry, 8);
      expect(params.increment, 0.15);
    });

    test('EllipseResult stores opSet and estimatedPoints', () {
      final opSet = OpSet(type: OpSetType.path, ops: <Op>[]);
      final result = EllipseResult(
        opSet: opSet,
        estimatedPoints: <PointD>[PointD(3, 4)],
      );

      expect(result.opSet, same(opSet));
      expect(result.estimatedPoints, hasLength(1));
      expect(result.estimatedPoints!.first.x, 3);
      expect(result.estimatedPoints!.first.y, 4);
    });

    test('Edge copyWith overrides selected fields and preserves others', () {
      final edge = Edge(yMin: 1, yMax: 9, x: 2, slope: 0.5);

      final copied = edge.copyWith(yMax: 12, slope: 1.25);

      expect(copied.yMin, 1);
      expect(copied.yMax, 12);
      expect(copied.x, 2);
      expect(copied.slope, 1.25);
    });

    test('Edge toString includes all fields', () {
      final edge = Edge(yMin: 1, yMax: 2, x: 3, slope: 4);
      final text = edge.toString();

      expect(text, contains('yMin: 1.0'));
      expect(text, contains('yMax: 2.0'));
      expect(text, contains('x: 3.0'));
      expect(text, contains('slope: 4.0'));
    });

    test('ActiveEdge stores mutable scan position and edge reference', () {
      final edge = Edge(yMin: 0, yMax: 5, x: 1, slope: 0.2);
      final active = ActiveEdge(1.0, edge);

      expect(active.s, 1.0);
      expect(active.edge, same(edge));

      active.s = 3.5;
      expect(active.s, 3.5);
    });
  });
}
