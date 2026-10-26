import 'package:skribble_rough/skribble_rough.dart';
import 'package:test/test.dart';

void main() {
  test(
    'fillers built without a configuration each own their random stream',
    () {
      final square = [
        PointD(0, 0),
        PointD(100, 0),
        PointD(100, 100),
        PointD(0, 100),
      ];

      final first = HachureFiller().fill(square);
      final second = HachureFiller().fill(square);
      final dots = DotFiller().fill(square);

      expect(first.type, second.type);
      expect(first.ops.length, second.ops.length);
      for (var i = 0; i < first.ops.length; i++) {
        expect(first.ops[i].op, second.ops[i].op);
        expect(first.ops[i].data.length, second.ops[i].data.length);
      }
      expect(first.ops.length, isNot(dots.ops.length));
    },
  );

  test('the default config is a fresh stream, not the theme shared one', () {
    // Two default configs draw the same polygon the same way.
    final square = [
      PointD(0, 0),
      PointD(50, 0),
      PointD(50, 50),
      PointD(0, 50),
    ];
    final a = HachureFiller(FillerConfig.defaultConfig).fill(square);
    final b = HachureFiller(FillerConfig.defaultConfig).fill(square);
    expect(a.ops.length, b.ops.length);
  });
}
