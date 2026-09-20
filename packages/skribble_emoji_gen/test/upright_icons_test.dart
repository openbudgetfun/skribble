import 'package:skribble_emoji_gen/svg_transform.dart';
import 'package:test/test.dart';

void main() {
  test('decimal ties and zero ignore insignificant arithmetic drift', () {
    const source = 'M15.0225 0L15.0225 11.902';
    final below = SvgTransform.parse('translate(-1e-14 -1e-14)').path(source);
    final above = SvgTransform.parse('translate(1e-14 1e-14)').path(source);
    expect(below, above);
    expect(below, isNot(contains('-0.000')));
  });

  test(
    'vertical stems retain their authored endpoints at every source size',
    () {
      for (final height in [16, 24, 48, 72, 256]) {
        final path = SvgTransform.parse('').path('M10 2L10 $height');
        expect(path, startsWith('M10.000 2.000'));
        expect(path, endsWith('10.000 ${height.toStringAsFixed(3)}'));
        final values = RegExp(r'-?\d+\.\d+')
            .allMatches(path)
            .map((match) => double.parse(match[0]!))
            .toList();
        // Cubic controls wander to both sides without shifting the stem's axis.
        expect(values[2], lessThan(10));
        expect(values[4], greaterThan(10));
        expect((values[2] + values[4]) / 2, closeTo(10, 0.001));
      }
    },
  );

  test(
    'source transforms and deliberately diagonal artwork keep their direction',
    () {
      final path = SvgTransform.parse('translate(3 7) scale(2)')
          .path('M2 4L8 10');
      expect(path, startsWith('M7.000 15.000'));
      expect(path, endsWith('19.000 27.000'));
    },
  );

  test(
    'closed contours share exact joins and repeated generation is stable',
    () {
      const source = 'M2 2H22V22H2Z M8 8V16H16V8Z';
      final transform = SvgTransform.parse('');
      final path = transform.path(source);
      expect(path, transform.path(source));
      expect(path, contains('2.000 2.000Z'));
      expect(path, endsWith('8.000 8.000Z'));
      expect('M'.allMatches(path), hasLength(2));
    },
  );

  test('curves preserve endpoints and degenerate segments stay finite', () {
    final path = SvgTransform.parse('').path('M4 4L4 4C4 2 8 2 8 4Z');
    expect(path, startsWith('M4.000 4.000C'));
    expect(path, contains('8.000 4.000'));
    expect(path, endsWith('4.000 4.000Z'));
    expect(path, isNot(contains('NaN')));
  });
}
