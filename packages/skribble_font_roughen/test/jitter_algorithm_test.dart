import 'package:skribble_font_roughen/src/jitter_algorithm.dart';
import 'package:test/test.dart';

void main() {
  group('JitterAlgorithm', () {
    test('produces deterministic values for same inputs', () {
      final jitter = JitterAlgorithm(jitterAmount: 12.0);

      final value1 = jitter.jitterValue(65, 0); // seed=65 (letter 'A')
      final value2 = jitter.jitterValue(65, 0);

      expect(value1, equals(value2));
    });

    test('produces different values for different seeds', () {
      final jitter = JitterAlgorithm(jitterAmount: 12.0);

      final value1 = jitter.jitterValue(65, 0); // 'A'
      final value2 = jitter.jitterValue(66, 0); // 'B'

      expect(value1, isNot(equals(value2)));
    });

    test('produces different values for different indices', () {
      final jitter = JitterAlgorithm(jitterAmount: 12.0);

      final value1 = jitter.jitterValue(65, 0);
      final value2 = jitter.jitterValue(65, 1);

      expect(value1, isNot(equals(value2)));
    });

    test('respects jitter amount bounds', () {
      final jitter = JitterAlgorithm(jitterAmount: 10.0);

      // Test multiple values to ensure they're within bounds
      for (var seed = 0; seed < 100; seed++) {
        for (var index = 0; index < 10; index++) {
          final value = jitter.jitterValue(seed, index);
          expect(value, greaterThanOrEqualTo(-10.0));
          expect(value, lessThanOrEqualTo(10.0));
        }
      }
    });

    test('applies jitter only to on-curve points', () {
      final jitter = JitterAlgorithm(jitterAmount: 12.0);

      final points = [
        Point(x: 100, y: 100, isOnCurve: true),
        Point(x: 150, y: 150, isOnCurve: false), // Control point
        Point(x: 200, y: 200, isOnCurve: true),
      ];

      final result = jitter.applyJitter(points, 65);

      expect(result.length, equals(3));

      // On-curve points should be modified
      expect(result[0].x, isNot(equals(100)));
      expect(result[0].y, isNot(equals(100)));
      expect(result[0].isOnCurve, isTrue);

      // Control point should remain unchanged
      expect(result[1].x, equals(150));
      expect(result[1].y, equals(150));
      expect(result[1].isOnCurve, isFalse);

      // Second on-curve point should be modified
      expect(result[2].x, isNot(equals(200)));
      expect(result[2].y, isNot(equals(200)));
      expect(result[2].isOnCurve, isTrue);
    });

    test('preserves point count after jitter', () {
      final jitter = JitterAlgorithm(jitterAmount: 12.0);

      final points = [
        Point(x: 0, y: 0, isOnCurve: true),
        Point(x: 50, y: 50, isOnCurve: false),
        Point(x: 100, y: 0, isOnCurve: true),
        Point(x: 150, y: -50, isOnCurve: false),
        Point(x: 200, y: 0, isOnCurve: true),
      ];

      final result = jitter.applyJitter(points, 42);

      expect(result.length, equals(points.length));
    });
  });

  group('Point', () {
    test('stores coordinates and curve status', () {
      final point = Point(x: 123.45, y: 678.90, isOnCurve: true);

      expect(point.x, equals(123.45));
      expect(point.y, equals(678.90));
      expect(point.isOnCurve, isTrue);
    });

    test('toString returns readable format', () {
      final point = Point(x: 100, y: 200, isOnCurve: false);

      expect(point.toString(), equals('Point(100.0, 200.0, onCurve: false)'));
    });
  });
}
