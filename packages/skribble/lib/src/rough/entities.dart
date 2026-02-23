import 'dart:math';

import 'config.dart';
import 'core.dart';
import 'geometry.dart';

class Drawable {
  String? shape;
  DrawConfig? options;
  List<OpSet>? sets;

  Drawable({this.shape, this.options, this.sets});
}

class PointD extends Point<double> {
  PointD(super.x, super.y);

  bool isInPolygon(List<PointD> points) {
    final int vertices = points.length;

    if (vertices < 3) {
      return false;
    }
    final PointD extreme = PointD(double.maxFinite, y);
    int count = 0;
    for (int i = 0; i < vertices; i++) {
      final PointD current = points[i];
      final PointD next = points[(i + 1) % vertices];
      if (Line(current, next).intersects(Line(this, extreme))) {
        if (getOrientation(current, this, next) ==
            PointsOrientation.collinear) {
          return Line(current, next).onSegment(this);
        }
        count++;
      }
    }
    return count % 2 == 1;
  }

  @override
  String toString() {
    return 'PointD{x:$x, y:$y}';
  }
}
