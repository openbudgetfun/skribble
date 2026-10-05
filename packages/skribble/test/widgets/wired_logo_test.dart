import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

/// The colour of the logo's pixel at [point] in its 100-unit design space.
Future<Color> _pixel(WidgetTester tester, Offset point) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find
        .descendant(
          of: find.byType(WiredLogo),
          matching: find.byType(RepaintBoundary),
        )
        .first,
  );
  final size = boundary.size;
  final x = (point.dx * size.width / 100).round();
  final y = (point.dy * size.height / 100).round();
  final bytes = (await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData();
    image.dispose();
    return data;
  }))!;
  final offset = (y * size.width.round() + x) * 4;
  return Color.fromARGB(
    bytes.getUint8(offset + 3),
    bytes.getUint8(offset),
    bytes.getUint8(offset + 1),
    bytes.getUint8(offset + 2),
  );
}

Finder _layers() => find.descendant(
  of: find.byType(WiredLogo),
  matching: find.byType(WiredCanvas),
);

void main() {
  testWidgets('uses the default 48 px square', (tester) async {
    await tester.pumpWidget(_app(const WiredLogo()));
    expect(tester.getSize(find.byType(WiredLogo)), const Size(48, 48));
    expect(tester.takeException(), isNull);
  });

  testWidgets('announces one image with the brand name', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(const WiredLogo()));
    expect(find.bySemanticsLabel('Skribble'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('can be silent beside a wordmark', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(const WiredLogo(semanticLabel: null)));
    expect(find.bySemanticsLabel('Skribble'), findsNothing);
    semantics.dispose();
  });

  testWidgets('supports a custom accessible label', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(const WiredLogo(semanticLabel: 'Made with Skribble')),
    );
    expect(find.bySemanticsLabel('Made with Skribble'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('fits tight rectangular constraints without layout overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const SizedBox(
          width: 24,
          height: 16,
          child: WiredLogo(size: 96),
        ),
      ),
    );
    expect(tester.getSize(find.byType(WiredLogo)), const Size(24, 16));
    expect(tester.takeException(), isNull);
  });

  testWidgets('inks a marker face and rosy cheeks', (tester) async {
    await tester.pumpWidget(_app(const WiredLogo(size: 100)));
    expect(_layers(), findsNWidgets(3));
    // Between the eyes, the face shows the theme's marker colour.
    expect(await _pixel(tester, const Offset(50, 40)), WiredPalette.lilac);
    // The cheek beside the smile is blush.
    expect(await _pixel(tester, const Offset(33.5, 55)), WiredPalette.blush);
  });

  testWidgets('takes its colours from the theme at night', (tester) async {
    await tester.pumpWidget(
      _app(
        WiredTheme(
          data: WiredThemeData.cuddly(brightness: Brightness.dark),
          child: const WiredLogo(size: 100),
        ),
      ),
    );
    expect(await _pixel(tester, const Offset(50, 40)), WiredPalette.dusk);
    // The left bracket is inked in the night text colour.
    expect(await _pixel(tester, const Offset(9.5, 50)), WiredPalette.paper);
  });

  testWidgets('transparent face and cheeks leave a single-colour mark', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const WiredLogo(
          size: 100,
          color: WiredPalette.coral,
          faceColor: Color(0x00000000),
          cheekColor: Color(0x00000000),
        ),
      ),
    );
    expect(_layers(), findsOneWidget);
    expect(await _pixel(tester, const Offset(9.5, 50)), WiredPalette.coral);
    expect((await _pixel(tester, const Offset(50, 40))).a, 0);
  });

  testWidgets('draws itself in under a draw transition', (tester) async {
    final progress = ValueNotifier<double>(0);
    addTearDown(progress.dispose);
    await tester.pumpWidget(
      _app(
        ValueListenableBuilder<double>(
          valueListenable: progress,
          builder: (context, value, _) => WiredDrawTransition(
            progress: AlwaysStoppedAnimation(value),
            child: const WiredLogo(size: 100),
          ),
        ),
      ),
    );
    // Before the pen moves, the bracket is still blank paper.
    expect((await _pixel(tester, const Offset(9.5, 50))).a, 0);
    progress.value = 1;
    await tester.pump();
    expect(await _pixel(tester, const Offset(9.5, 50)), WiredPalette.ink);
    expect(tester.takeException(), isNull);
  });

  testWidgets('zero size and rapid theme changes remain still', (tester) async {
    await tester.pumpWidget(_app(const WiredLogo(size: 0)));
    expect(tester.getSize(find.byType(WiredLogo)), Size.zero);
    for (final brightness in [
      Brightness.light,
      Brightness.dark,
      Brightness.light,
    ]) {
      await tester.pumpWidget(
        _app(
          WiredTheme(
            data: WiredThemeData.cuddly(brightness: brightness),
            child: const WiredLogo(),
          ),
        ),
      );
    }
    expect(tester.takeException(), isNull);
    expect(tester.hasRunningAnimations, isFalse);
  });
}

Widget _app(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: WiredTheme(
    data: WiredThemeData.cuddly(),
    child: Center(child: child),
  ),
);
