import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

const ValueKey<String> _capture = ValueKey('capture');

void main() {
  testWidgets('startup status never inherits fallback text decorations', (
    tester,
  ) async {
    for (final materialHost in [true, false]) {
      final theme = WiredThemeData.cuddly();
      const screen = RepaintBoundary(
        key: _capture,
        child: WiredLoadingScreen(
          message: 'Getting the pens ready…',
          animating: false,
        ),
      );
      await tester.pumpWidget(
        materialHost
            ? WiredMaterialApp(wiredTheme: theme, home: screen)
            : SkribbleApp(wiredTheme: theme, home: screen),
      );
      final paragraph = tester.renderObject<RenderParagraph>(
        find.descendant(
          of: find.text('Getting the pens ready…'),
          matching: find.byType(RichText),
        ),
      );
      final style = paragraph.text.style!;
      expect(style.decoration ?? TextDecoration.none, TextDecoration.none);
      expect(style.fontWeight ?? FontWeight.normal, FontWeight.normal);
      expect(style.fontSize, 17);
      expect(style.color, theme.textColor.withValues(alpha: .72));
      final pixels = await _pixels(tester);

      for (var offset = 0; offset < pixels.length; offset += 4) {
        expect(
          pixels[offset] > 240 &&
              pixels[offset + 1] > 240 &&
              pixels[offset + 2] < 100,
          isFalse,
          reason: 'Startup must not paint the yellow fallback underline',
        );
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('renders the brand mark on paper', (tester) async {
    await tester.pumpWidget(_app(const WiredLoadingScreen()));

    expect(find.byType(WiredLoadingScreen), findsOneWidget);
    expect(find.byType(WiredLoader), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(WiredLoadingScreen)),
      const Size(800, 600),
    );
    expect(await _pixels(tester), isNot(orderedEquals(_empty)));
  });

  testWidgets('shows the status line only when provided', (tester) async {
    await tester.pumpWidget(
      _app(const WiredLoadingScreen(message: 'Getting the pens ready…')),
    );
    expect(find.text('Getting the pens ready…'), findsOneWidget);

    await tester.pumpWidget(_app(const WiredLoadingScreen()));
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('announces one live region for the whole wait', (tester) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      _app(const WiredLoadingScreen(message: 'Getting the pens ready…')),
    );
    expect(find.bySemanticsLabel('Getting the pens ready…'), findsOneWidget);
    expect(find.bySemanticsLabel('Loading'), findsNothing);

    await tester.pumpWidget(_app(const WiredLoadingScreen()));
    expect(find.bySemanticsLabel('Loading'), findsOneWidget);

    await tester.pumpWidget(
      _app(
        const WiredLoadingScreen(
          message: 'Getting the pens ready…',
          semanticLabel: 'Preparing the sketch',
        ),
      ),
    );
    expect(find.bySemanticsLabel('Preparing the sketch'), findsOneWidget);
    expect(find.bySemanticsLabel('Getting the pens ready…'), findsNothing);

    semantics.dispose();
  });

  testWidgets('settles the mark when motion is off', (tester) async {
    for (final mode in ['platform', 'local']) {
      Widget screen = const WiredLoadingScreen(
        message: 'Still fetching the ink…',
      );
      if (mode == 'platform') {
        screen = MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: screen,
        );
      } else {
        screen = const WiredLoadingScreen(
          message: 'Still fetching the ink…',
          animating: false,
        );
      }
      await tester.pumpWidget(_app(screen));
      final initial = await _pixels(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(await _pixels(tester), orderedEquals(initial), reason: mode);
      expect(tester.hasRunningAnimations, isFalse, reason: mode);
    }
  });

  testWidgets('borrows a caller-owned phase and leaves it alone', (
    tester,
  ) async {
    final phase = AnimationController(vsync: tester, value: .1);
    addTearDown(phase.dispose);

    await tester.pumpWidget(_app(WiredLoadingScreen(progress: phase)));
    final initial = await _pixels(tester);
    phase.value = .5;
    await tester.pump();
    expect(await _pixels(tester), isNot(orderedEquals(initial)));

    await tester.pumpWidget(_app(const SizedBox()));
    phase.value = .3;
    expect(phase.value, .3);
  });

  testWidgets('paints caller colors over the themed paper', (tester) async {
    const background = Color(0xff123456);
    await tester.pumpWidget(
      _app(
        const WiredLoadingScreen(
          backgroundColor: background,
          animating: false,
        ),
      ),
    );
    expect(await _pixelAt(tester, 2, 2), background);

    await tester.pumpWidget(_app(const WiredLoadingScreen(animating: false)));
    final themed = await _pixels(tester);
    await tester.pumpWidget(
      _app(
        WiredLoadingScreen(
          backgroundColor: WiredThemeData.cuddly().paperBackgroundColor,
          animating: false,
        ),
      ),
    );
    expect(await _pixels(tester), orderedEquals(themed));
  });

  testWidgets('scales the drawing with size', (tester) async {
    await tester.pumpWidget(
      _app(const WiredLoadingScreen(size: 48, animating: false)),
    );
    final small = _inked(await _pixels(tester));
    await tester.pumpWidget(
      _app(const WiredLoadingScreen(size: 144, animating: false)),
    );
    final large = _inked(await _pixels(tester));

    expect(small, greaterThan(0));
    expect(large, greaterThan(small));
  });

  testWidgets('defaults to the brand mark and the theme typeface', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const WiredLoadingScreen(
          message: 'Getting the pens ready…',
          animating: false,
        ),
      ),
    );

    final loader = tester.widget<WiredLoader>(find.byType(WiredLoader));
    expect(loader.style, WiredLoaderStyle.mark);
    expect(loader.semanticLabel, isNull);

    final theme = WiredThemeData.cuddly();
    final text = tester.widget<Text>(find.text('Getting the pens ready…'));
    expect(
      text.style?.fontFamily,
      'packages/${theme.fontPackage}/${theme.fontFamily}',
    );
    expect(text.textAlign, TextAlign.center);
  });

  testWidgets('survives tight, RTL, and zero-size constraints', (tester) async {
    for (final size in [0.0, 8.0, 96.0]) {
      await tester.pumpWidget(
        _app(
          Directionality(
            textDirection: TextDirection.rtl,
            child: WiredLoadingScreen(
              size: size,
              message: 'Waiting',
              animating: false,
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull, reason: '$size');
    }

    await tester.pumpWidget(
      _app(
        const SizedBox.square(
          dimension: 0,
          child: WiredLoadingScreen(animating: false),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}

final _empty = Uint8List(0);

Widget _app(Widget child) => MaterialApp(
  home: WiredTheme(
    data: WiredThemeData.cuddly(),
    child: RepaintBoundary(key: _capture, child: child),
  ),
);

Future<Uint8List> _pixels(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_capture),
  );
  final pixels = await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    return data!.buffer.asUint8List();
  });
  return pixels!;
}

Future<Color> _pixelAt(WidgetTester tester, int x, int y) async {
  final bytes = await _pixels(tester);
  final width = tester.getSize(find.byKey(_capture)).width.round();
  final offset = (y * width + x) * 4;
  return Color.fromARGB(
    bytes[offset + 3],
    bytes[offset],
    bytes[offset + 1],
    bytes[offset + 2],
  );
}

int _inked(Uint8List pixels) {
  final background = pixels.sublist(0, 4);
  var count = 0;
  for (var i = 0; i < pixels.length; i += 4) {
    if (pixels[i] != background[0] ||
        pixels[i + 1] != background[1] ||
        pixels[i + 2] != background[2]) {
      count++;
    }
  }
  return count;
}
