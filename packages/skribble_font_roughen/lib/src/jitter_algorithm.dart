/// Deterministic jitter algorithm for roughening font glyph outlines.
///
/// This algorithm adds controlled random displacement to on-curve points
/// in font glyphs, creating a hand-drawn/sketchy feel while preserving
/// readability.
///
/// The jitter is deterministic: given the same seed and index, the same
/// displacement value is produced. This ensures that the same font with
/// the same configuration always produces the same output.
class JitterAlgorithm {
  const JitterAlgorithm({this.jitterAmount = 48.0});

  /// The maximum displacement in font units.
  ///
  /// At the default 2048 UPM this is ~2.3% of the em — clearly visible
  /// while keeping characters readable.
  final double jitterAmount;

  /// Fraction of the on-curve jitter applied to off-curve control points.
  static const double _offCurveFraction = 0.7;

  double jitterValue(int seed, int index, {int offset = 0}) {
    const hashA = 2654435761;
    const hashB = 40503;
    final h = (seed * hashA + (index + offset) * hashB) & 0xFFFFFFFF;
    return ((h % 1000) / 500.0 - 1.0) * jitterAmount;
  }

  List<Point> applyJitter(List<Point> points, int seed) {
    final result = <Point>[];
    var index = 0;

    for (final point in points) {
      if (point.isOnCurve) {
        final dx = jitterValue(seed, index);
        final dy = jitterValue(seed, index, offset: 7919);
        result.add(Point(x: point.x + dx, y: point.y + dy, isOnCurve: true));
      } else {
        final dx = jitterValue(seed, index, offset: 3571) * _offCurveFraction;
        final dy = jitterValue(seed, index, offset: 6811) * _offCurveFraction;
        result.add(Point(x: point.x + dx, y: point.y + dy, isOnCurve: false));
      }
      index++;
    }
    return result;
  }
}

/// Represents a point in a glyph outline.
class Point {
  /// Creates a point with the specified coordinates and curve status.
  const Point({
    required this.x,
    required this.y,
    required this.isOnCurve,
  });

  /// The x-coordinate in font units.
  final double x;

  /// The y-coordinate in font units.
  final double y;

  /// Whether this is an on-curve point (true) or off-curve control point (false).
  final bool isOnCurve;

  @override
  String toString() => 'Point($x, $y, onCurve: $isOnCurve)';
}
