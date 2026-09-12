import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  for (final style in WiredLoaderStyle.values) {
    testWidgets(
      '${style.name} changes ink across phases without changing layout',
      (tester) async {
        final phase = AnimationController(vsync: tester, value: .1);
        addTearDown(phase.dispose);
        await tester.pumpWidget(
          _app(WiredLoader(style: style, progress: phase, size: 72)),
        );
        final initial = await _pixels(tester);
        expect(initial.any((byte) => byte != 0), isTrue);
        expect(tester.getSize(find.byType(WiredLoader)), const Size.square(72));
        phase.value = .4;
        await tester.pump();
        expect(await _pixels(tester), isNot(orderedEquals(initial)));
        phase.value = .1;
        await tester.pump();
        expect(await _pixels(tester), orderedEquals(initial));
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'reduced motion, disabled ancestors, and ticker mode stop all clocks',
    (tester) async {
      for (final mode in ['platform', 'ancestor', 'ticker', 'local']) {
        Widget content = WiredLoader(animating: mode != 'local');
        if (mode == 'platform') {
          content = MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: content,
          );
        }
        if (mode == 'ancestor') {
          content = WiredMotion(
            enabled: false,
            child: WiredMotion(child: content),
          );
        }
        if (mode == 'ticker') {
          content = TickerMode(enabled: false, child: content);
        }
        await tester.pumpWidget(_app(content));
        final initial = await _pixels(tester);
        await tester.pump(const Duration(seconds: 1));
        expect(await _pixels(tester), orderedEquals(initial), reason: mode);
        expect(tester.hasRunningAnimations, isFalse, reason: mode);
      }
    },
  );

  testWidgets(
    'borrowed progress detaches when settled and remains caller owned',
    (tester) async {
      final phase = AnimationController(vsync: tester);
      addTearDown(phase.dispose);
      await tester.pumpWidget(
        _app(WiredLoader(progress: phase, animating: false)),
      );
      final initial = await _pixels(tester);
      phase.value = .8;
      await tester.pump();
      expect(await _pixels(tester), orderedEquals(initial));
      await tester.pumpWidget(_app(WiredLoader(progress: phase)));
      expect(await _pixels(tester), isNot(orderedEquals(initial)));
      await tester.pumpWidget(_app(const SizedBox()));
      phase.value = .3;
      expect(phase.value, .3);
    },
  );

  testWidgets('supports rapid start, stop, duration and ownership changes', (
    tester,
  ) async {
    final phase = AnimationController(vsync: tester, value: .6);
    addTearDown(phase.dispose);
    for (var i = 0; i < 12; i++) {
      await tester.pumpWidget(
        _app(
          WiredLoader(
            animating: i.isEven,
            duration: Duration(milliseconds: 800 + i * 100),
            progress: i % 3 == 0 ? phase : null,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.hasRunningAnimations, i.isEven && i % 3 != 0);
    }
    await tester.pumpWidget(_app(const WiredLoadingIndicator()));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpWidget(_app(const SizedBox()));
    expect(tester.hasRunningAnimations, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('small bounds, zero size, RTL and themed ink render safely', (
    tester,
  ) async {
    for (final style in WiredLoaderStyle.values) {
      for (final size in [0.0, 8.0, 24.0]) {
        await tester.pumpWidget(
          _app(
            SizedBox.square(
              dimension: size,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: WiredLoader(style: style, size: 72, animating: false),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      }
    }
    await tester.pumpWidget(
      _app(const WiredLoader(color: Color(0xffee0000), animating: false)),
    );
    final red = await _pixels(tester);
    await tester.pumpWidget(
      _app(const WiredLoader(color: Color(0xff0000ee), animating: false)),
    );
    expect(await _pixels(tester), isNot(orderedEquals(red)));
  });

  testWidgets('announces a stable localizable label and supports decoration', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      _app(const WiredLoader(semanticLabel: 'Preparing sketch')),
    );
    expect(find.bySemanticsLabel('Preparing sketch'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.bySemanticsLabel('Preparing sketch'), findsOneWidget);
    await tester.pumpWidget(_app(const WiredLoader(semanticLabel: null)));
    expect(find.bySemanticsLabel('Loading'), findsNothing);
    semantics.dispose();
  });
}

Widget _app(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: Center(
    child: RepaintBoundary(key: const ValueKey('capture'), child: child),
  ),
);

Future<Uint8List> _pixels(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('capture')),
  );
  final pixels = await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    return data!.buffer.asUint8List();
  });
  return pixels!;
}
