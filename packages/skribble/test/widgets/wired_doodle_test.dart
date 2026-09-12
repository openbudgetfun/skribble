import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble/src/doodles/doodle_geometry.dart';

void main() {
  test('seeded curves are repeatable, distinct, closed, and bounded', () {
    for (final kind in WiredDoodleKind.values) {
      final first = doodleGeometry(kind, seed: 8);
      expect(
        first.map((s) => s.svgPath),
        doodleGeometry(kind, seed: 8).map((s) => s.svgPath),
      );
      expect(
        first.map((s) => s.svgPath),
        isNot(doodleGeometry(kind, seed: 21).map((s) => s.svgPath)),
      );

      for (final seed in [-100, 0, 1, 65520]) {
        for (final stroke in doodleGeometry(kind, seed: seed, amplitude: 3)) {
          if (stroke.closed) expect(stroke.curves.last.end, stroke.start);

          for (final point in [
            stroke.start,
            ...stroke.curves.expand((c) => [c.first, c.second, c.end]),
          ]) {
            expect(point.x, inInclusiveRange(-3, 103));
            expect(point.y, inInclusiveRange(-3, 103));
          }
        }
      }
    }
  });

  test('scribble seeds vary loop count and angle while staying smooth', () {
    final threeTurns = doodleGeometry(
      WiredDoodleKind.scribble,
      seed: 1,
    ).single;
    final fourTurns = doodleGeometry(
      WiredDoodleKind.scribble,
      seed: 8,
    ).single;

    expect(threeTurns.curves.length, isNot(fourTurns.curves.length));
    expect(threeTurns.svgPath, isNot(fourTurns.svgPath));
    expect(threeTurns.curves.first.first, isNot(fourTurns.curves.first.first));
  });

  testWidgets('renders every kind and seed changes only the drawing', (
    tester,
  ) async {
    for (final kind in WiredDoodleKind.values) {
      await tester.pumpWidget(_app(WiredDoodle(kind: kind, size: 96)));
      expect(tester.getSize(find.byType(WiredDoodle)), const Size(96, 96));
      expect(tester.takeException(), isNull);
    }

    await tester.pumpWidget(
      _app(const WiredDoodle(kind: WiredDoodleKind.butterfly, seed: 1)),
    );
    final first = await _pixels(tester);
    await tester.pumpWidget(
      _app(const WiredDoodle(kind: WiredDoodleKind.butterfly, seed: 21)),
    );
    final changed = await _pixels(tester);
    expect(changed, isNot(orderedEquals(first)));
    await tester.pumpWidget(
      _app(const WiredDoodle(kind: WiredDoodleKind.butterfly, seed: 1)),
    );
    expect(await _pixels(tester), orderedEquals(first));
  });

  testWidgets('supports zero size and tight non-square bounds', (tester) async {
    await tester.pumpWidget(
      _app(const WiredDoodle(kind: WiredDoodleKind.heart, size: 0)),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(
      _app(
        const SizedBox(
          width: 32,
          height: 20,
          child: WiredDoodle(kind: WiredDoodleKind.flower),
        ),
      ),
    );
    expect(tester.getSize(find.byType(WiredDoodle)), const Size(32, 20));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'decorative ink passes taps through and only exposes explicit labels',
    (tester) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(
        _app(
          Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => taps++,
                child: const SizedBox(
                  width: 100,
                  height: 100,
                  child: Text('Content'),
                ),
              ),
              const WiredDoodle(kind: WiredDoodleKind.heart, size: 100),
            ],
          ),
        ),
      );
      await tester.tapAt(tester.getCenter(find.byType(WiredDoodle)));
      expect(taps, 1);
      expect(find.bySemanticsLabel('heart'), findsNothing);
      await tester.pumpWidget(
        _app(
          const WiredDoodle(
            kind: WiredDoodleKind.heart,
            semanticLabel: 'Made with love',
          ),
        ),
      );
      expect(find.bySemanticsLabel('Made with love'), findsOneWidget);
      semantics.dispose();
    },
  );

  testWidgets('ink entrance completes and respects reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        WiredDraw(child: const WiredDoodle(kind: WiredDoodleKind.butterfly)),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
    await tester.pumpWidget(
      _app(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: WiredDraw(
            child: const WiredDoodle(kind: WiredDoodleKind.heart),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('logo semantics and theme ink update', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(const WiredLogo(size: 96)));
    expect(find.bySemanticsLabel('Skribble'), findsOneWidget);
    expect(tester.getSize(find.byType(WiredLogo)), const Size(96, 96));
    final light = await _pixels(tester);
    await tester.pumpWidget(
      _app(const WiredLogo(size: 96, color: WiredPalette.paper)),
    );
    expect(await _pixels(tester), isNot(orderedEquals(light)));
    semantics.dispose();
  });

  testWidgets('closed contour washes change pixels without changing size', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const WiredDoodle(kind: WiredDoodleKind.heart)),
    );
    final outline = await _pixels(tester);
    await tester.pumpWidget(
      _app(
        const WiredDoodle(
          kind: WiredDoodleKind.heart,
          fillColor: WiredPalette.peach,
        ),
      ),
    );
    expect(tester.getSize(find.byType(WiredDoodle)), const Size(64, 64));
    expect(await _pixels(tester), isNot(orderedEquals(outline)));
  });

  testWidgets('roughness changes the pen without resetting the seed', (
    tester,
  ) async {
    Widget themed(WiredRoughness level) => _app(
      WiredTheme(
        data: WiredThemeData.cuddly(roughnessLevel: level),
        child: const WiredDoodle(kind: WiredDoodleKind.butterfly, seed: 21),
      ),
    );
    await tester.pumpWidget(themed(WiredRoughness.gentle));
    final gentle = await _pixels(tester);
    await tester.pumpWidget(themed(WiredRoughness.expressive));
    expect(await _pixels(tester), isNot(orderedEquals(gentle)));
    await tester.pumpWidget(themed(WiredRoughness.gentle));
    expect(await _pixels(tester), orderedEquals(gentle));
  });

  testWidgets('rapid seed and kind changes leave no animation running', (
    tester,
  ) async {
    for (var seed = 0; seed < 20; seed++) {
      await tester.pumpWidget(
        _app(
          WiredDoodle(
            kind: WiredDoodleKind.values[seed % WiredDoodleKind.values.length],
            seed: seed,
          ),
        ),
      );
    }
    expect(tester.hasRunningAnimations, isFalse);
    expect(tester.takeException(), isNull);
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
