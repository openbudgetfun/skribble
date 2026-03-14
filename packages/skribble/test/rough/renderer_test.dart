import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  final config = DrawConfig.defaultValues;
  final filler = NoFiller(FillerConfig.defaultConfig);

  group('Generator', () {
    late Generator generator;

    setUp(() {
      generator = Generator(config, filler);
    });

    test('line produces a Drawable with ops', () {
      final drawable = generator.line(0, 0, 10, 10);
      expect(drawable.sets, isNotEmpty);
      expect(drawable.sets!.first.ops, isNotEmpty);
    });

    test('rectangle produces a Drawable with ops', () {
      final drawable = generator.rectangle(0, 0, 50, 30);
      expect(drawable.sets, isNotEmpty);
      // Rectangle has fill set + outline set; outline ops are non-empty
      expect(drawable.sets!.last.ops, isNotEmpty);
    });

    test('circle produces a Drawable with ops', () {
      final drawable = generator.circle(50, 50, 20);
      expect(drawable.sets, isNotEmpty);
    });

    test('ellipse produces a Drawable with ops', () {
      final drawable = generator.ellipse(50, 50, 30, 20);
      expect(drawable.sets, isNotEmpty);
    });

    test('polygon produces a Drawable with ops', () {
      final points = [PointD(0, 0), PointD(10, 0), PointD(5, 10)];
      final drawable = generator.polygon(points);
      expect(drawable.sets, isNotEmpty);
    });

    test('linearPath produces a Drawable with ops', () {
      final points = [PointD(0, 0), PointD(5, 5), PointD(10, 0)];
      final drawable = generator.linearPath(points);
      expect(drawable.sets, isNotEmpty);
    });

    test('arc produces a Drawable with ops', () {
      final drawable = generator.arc(50, 50, 30, 30, 0, 3.14);
      expect(drawable.sets, isNotEmpty);
    });

    test('arc closed produces a Drawable', () {
      final drawable = generator.arc(50, 50, 30, 30, 0, 3.14, true);
      expect(drawable.sets, isNotEmpty);
    });

    test('curvePath produces a Drawable with ops', () {
      final points = [
        PointD(0, 0),
        PointD(5, 10),
        PointD(10, 10),
        PointD(15, 0),
      ];
      final drawable = generator.curvePath(points);
      expect(drawable.sets, isNotEmpty);
    });

    test('Drawable stores DrawConfig options', () {
      final drawable = generator.line(0, 0, 10, 10);
      expect(drawable.options, config);
    });

    test('works with HachureFiller producing fill set', () {
      final hGen = Generator(config, HachureFiller(FillerConfig.defaultConfig));
      final drawable = hGen.rectangle(0, 0, 50, 30);
      // Rectangle with fill has ≥2 sets (fill + outline)
      expect(drawable.sets!.length, greaterThanOrEqualTo(2));
    });

    test('works with custom roughness', () {
      final rough = DrawConfig.build(roughness: 5, seed: 42);
      final rGen = Generator(rough, filler);
      final drawable = rGen.rectangle(0, 0, 50, 30);
      expect(drawable.sets, isNotEmpty);
    });
  });
}
