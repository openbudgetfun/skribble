import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

final _transparentImage = Uint8List.fromList(const <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0xF8,
  0x0F,
  0x04,
  0x00,
  0x09,
  0xFB,
  0x03,
  0xFD,
  0xA0,
  0x55,
  0xDA,
  0xC1,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

class _FailingImageProvider extends ImageProvider<_FailingImageProvider> {
  const _FailingImageProvider();

  @override
  Future<_FailingImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_FailingImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    _FailingImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return OneFrameImageStreamCompleter(
      Future<ImageInfo>.error(StateError('image decode failed')),
    );
  }
}

void main() {
  Future<void> pumpSubject(
    WidgetTester tester, {
    Widget? child,
    double radius = 20,
    double? minRadius,
    double? maxRadius,
    Color? backgroundColor,
    Color? foregroundColor,
    ImageProvider? backgroundImage,
    ImageProvider? foregroundImage,
  }) {
    return pumpApp(
      tester,
      Center(
        child: WiredAvatar(
          radius: radius,
          minRadius: minRadius,
          maxRadius: maxRadius,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          backgroundImage: backgroundImage,
          foregroundImage: foregroundImage,
          child: child,
        ),
      ),
    );
  }

  group('WiredAvatar', () {
    test('asserts when minRadius is greater than maxRadius', () {
      expect(
        () => WiredAvatar(radius: 20, minRadius: 30, maxRadius: 10),
        throwsAssertionError,
      );
    });
    testWidgets('renders without error', (tester) async {
      await pumpSubject(tester);
      expect(find.byType(WiredAvatar), findsOneWidget);
    });

    testWidgets('renders with initials', (tester) async {
      await pumpSubject(tester, child: const Text('JD'));
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('renders with icon', (tester) async {
      await pumpSubject(tester, child: const Icon(Icons.person));
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('respects custom radius', (tester) async {
      await pumpSubject(tester, radius: 40);
      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(WiredAvatar),
          matching: find.byType(SizedBox).first,
        ),
      );
      expect(sizedBox.width, 80);
      expect(sizedBox.height, 80);
    });

    testWidgets('renders with custom background color', (tester) async {
      await pumpSubject(tester, backgroundColor: Colors.blue);
      expect(find.byType(WiredAvatar), findsOneWidget);
    });

    testWidgets('renders with custom foreground color', (tester) async {
      await pumpSubject(
        tester,
        foregroundColor: Colors.white,
        child: const Text('AB'),
      );
      expect(find.text('AB'), findsOneWidget);
    });

    testWidgets('clamps to minRadius when radius is too small', (tester) async {
      await pumpSubject(tester, radius: 10, minRadius: 18);
      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(WiredAvatar),
          matching: find.byType(SizedBox).first,
        ),
      );
      expect(sizedBox.width, 36);
      expect(sizedBox.height, 36);
    });

    testWidgets('clamps to maxRadius when radius is too large', (tester) async {
      await pumpSubject(tester, radius: 42, maxRadius: 24);
      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(WiredAvatar),
          matching: find.byType(SizedBox).first,
        ),
      );
      expect(sizedBox.width, 48);
      expect(sizedBox.height, 48);
    });

    testWidgets('renders background image when provided', (tester) async {
      await pumpSubject(
        tester,
        backgroundImage: MemoryImage(_transparentImage),
      );
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(ClipOval), findsOneWidget);
    });

    testWidgets('renders foreground image when provided', (tester) async {
      await pumpSubject(
        tester,
        foregroundImage: MemoryImage(_transparentImage),
      );
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(ClipOval), findsOneWidget);
    });

    testWidgets('falls back to child when background image fails', (tester) async {
      await pumpSubject(
        tester,
        backgroundImage: const _FailingImageProvider(),
        child: const Text('XY'),
      );
      await tester.pump();

      expect(find.text('XY'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('falls back to default icon when image fails and no child', (
      tester,
    ) async {
      await pumpSubject(
        tester,
        backgroundImage: const _FailingImageProvider(),
      );
      await tester.pump();

      expect(find.byType(WiredIcon), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('default size is 40x40', (tester) async {
      await pumpSubject(tester);
      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(WiredAvatar),
          matching: find.byType(SizedBox).first,
        ),
      );
      expect(sizedBox.width, 40);
      expect(sizedBox.height, 40);
    });
  });
}
