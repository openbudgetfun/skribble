import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/src/wired_svg_icon_data.dart';

void main() {
  group('Icon Performance', () {
    test('WiredSvgIconData creation is fast', () {
      final stopwatch = Stopwatch()..start();

      // Test creating 1000 icon data objects
      for (int i = 0; i < 1000; i++) {
        WiredSvgIconData(
          width: 24,
          height: 24,
          primitives: [
            WiredSvgPrimitive.path('M12 2L2 22h20L12 2z'),
            WiredSvgPrimitive.path('M12 6l-6 12h12L12 6z'),
          ],
        );
      }

      stopwatch.stop();

      // Should complete in less than 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('WiredSvgPathPrimitive path building is fast', () {
      final primitive = WiredSvgPrimitive.path('M12 2L2 22h20L12 2z');

      final stopwatch = Stopwatch()..start();

      // Test building paths 1000 times
      for (int i = 0; i < 1000; i++) {
        primitive.buildPath();
      }

      stopwatch.stop();

      // Should complete in less than 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('multiple icon data objects can be created efficiently', () {
      final stopwatch = Stopwatch()..start();

      // Test creating a batch of icon data objects
      final icons = <WiredSvgIconData>[];
      for (int i = 0; i < 100; i++) {
        icons.add(
          WiredSvgIconData(
            width: 24,
            height: 24,
            primitives: [
              WiredSvgPrimitive.path('M12 2L2 22h20L12 2z'),
            ],
          ),
        );
      }

      stopwatch.stop();

      // Should complete in less than 50ms
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
      expect(icons.length, equals(100));
    });

    test('icon data memory usage is reasonable', () {
      // Create a large number of icon data objects
      final icons = <WiredSvgIconData>[];
      for (int i = 0; i < 1000; i++) {
        icons.add(
          WiredSvgIconData(
            width: 24,
            height: 24,
            primitives: [
              WiredSvgPrimitive.path('M12 2L2 22h20L12 2z'),
            ],
          ),
        );
      }

      // Verify we can create 1000 icons without issues
      expect(icons.length, equals(1000));

      // Verify each icon has correct properties
      for (final icon in icons) {
        expect(icon.width, equals(24));
        expect(icon.height, equals(24));
        expect(icon.primitives.length, equals(1));
      }
    });
  });
}
