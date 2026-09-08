import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_icons/skribble_icons.dart';

void main() {
  test('every curated icon fits its declared viewBox', () {
    expect(kSkribbleCustomIconsRough.length, 30);
    for (final entry in kSkribbleCustomIconsRough.entries) {
      final data = entry.value;
      for (final shape in data.primitives) {
        final bounds = shape.buildPath().getBounds();
        expect(bounds.left, greaterThanOrEqualTo(-1), reason: '${entry.key}');
        expect(bounds.top, greaterThanOrEqualTo(-1), reason: '${entry.key}');
        expect(
          bounds.right,
          lessThanOrEqualTo(data.width + 1),
          reason: '${entry.key}',
        );
        expect(
          bounds.bottom,
          lessThanOrEqualTo(data.height + 1),
          reason: '${entry.key}',
        );
      }
    }
  });
}
