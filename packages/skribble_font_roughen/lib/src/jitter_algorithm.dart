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
  /// Creates a jitter algorithm with the specified amount.
  const JitterAlgorithm({this.jitterAmount = 12.0});

  /// The maximum displacement in font units.
  ///
  /// Higher values create more sketchy/rough appearance.
  /// Recommended range: 5-25 font units.
  final double jitterAmount;

  /// Generates a deterministic jitter value for a given seed and index.
  ///
  /// The algorithm uses a hash-based approach to produce pseudo-random
  /// values that are consistent for the same inputs.
  ///
  /// [seed] - A seed value, typically the glyph's Unicode codepoint.
  /// [index] - The point index within the glyph.
  /// [offset] - An offset to produce different X/Y values from the same seed/index.
  double jitterValue(int seed, int index, {int offset = 0}) {
    // Hash constants for deterministic pseudo-random generation
    const hashA = 2654435761;
    const hashB = 40503;

    final h = (seed * hashA + (index + offset) * hashB) & 0xFFFFFFFF;
    return ((h % 1000) / 500.0 - 1.0) * jitterAmount;
  }

  /// Applies jitter to a list of point coordinates.
  ///
  /// Takes a list of [Point] objects and returns a new list with
  /// jitter applied to on-curve points only.
  ///
  /// [points] - The original glyph outline points.
  /// [seed] - The seed value for deterministic jitter (typically Unicode codepoint).
  List<Point> applyJitter(List<Point> points, int seed) {
    final result = <Point>[];
    var index = 0;

    for (final point in points) {
      if (point.isOnCurve) {
        final dx = jitterValue(seed, index);
        final dy = jitterValue(seed, index, offset: 7919);
        result.add(
          Point(
            x: point.x + dx,
            y: point.y + dy,
            isOnCurve: true,
          ),
        );
      } else {
        result.add(point);
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
