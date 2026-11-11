import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

Widget host(Widget child, {bool reduced = false}) => MediaQuery(
  data: MediaQueryData(disableAnimations: reduced),
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: Center(child: child),
  ),
);

/// Records the theme seed and boil offset it is built with.
class _Probe extends StatelessWidget {
  const _Probe(this.seen);

  final List<(int, int)> seen;

  @override
  Widget build(BuildContext context) {
    seen.add((
      WiredTheme.of(context).drawConfig.seed,
      WiredBoil.seedOffsetOf(context),
    ));
    return const SizedBox(width: 40, height: 40);
  }
}

void main() {
  testWidgets('cycles through different drawings a few times a second', (
    tester,
  ) async {
    final seen = <(int, int)>[];
    await tester.pumpWidget(host(WiredBoil(child: _Probe(seen))));
    final base = seen.single.$1;
    expect(seen.single.$2, 0);
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 125));
    }
    final seeds = seen.map((entry) => entry.$1).toSet();
    expect(seeds, contains(base));
    expect(seeds.length, 3);
    expect(seen.map((entry) => entry.$2).toSet().length, 3);
  });

  testWidgets('keeps its child state while boiling', (tester) async {
    final key = GlobalKey<EditableTextState>();
    final controller = TextEditingController(text: 'keep me');
    final focus = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      host(
        WiredBoil(
          child: SizedBox(
            width: 120,
            child: EditableText(
              key: key,
              controller: controller,
              focusNode: focus,
              style: const TextStyle(),
              cursorColor: const Color(0xFF000000),
              backgroundCursorColor: const Color(0xFF000000),
            ),
          ),
        ),
      ),
    );
    final state = key.currentState;
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 130));
    }
    expect(key.currentState, same(state));
  });

  testWidgets('rests on the usual drawing with reduced motion', (
    tester,
  ) async {
    final seen = <(int, int)>[];
    await tester.pumpWidget(
      host(WiredBoil(child: _Probe(seen)), reduced: true),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(seen.map((entry) => entry.$2).toSet(), {0});
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('stops when disabled and when motion is off', (tester) async {
    final seen = <(int, int)>[];
    await tester.pumpWidget(
      host(WiredBoil(enabled: false, child: _Probe(seen))),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(seen.map((entry) => entry.$2).toSet(), {0});

    seen.clear();
    await tester.pumpWidget(
      host(
        WiredMotion(enabled: false, child: WiredBoil(child: _Probe(seen))),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(seen.map((entry) => entry.$2).toSet(), {0});
  });

  testWidgets('boils seeded shapes and doodles too', (tester) async {
    await tester.pumpWidget(
      host(
        const WiredBoil(
          framesPerSecond: 12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 120, height: 60, child: WiredCard(seed: 4)),
              WiredDoodle(kind: WiredDoodleKind.sun, size: 48),
            ],
          ),
        ),
      ),
    );
    final first = tester
        .widget<WiredCanvas>(
          find.descendant(
            of: find.byType(WiredCard),
            matching: find.byType(WiredCanvas),
          ),
        )
        .painter;
    await tester.pump(const Duration(milliseconds: 90));
    expect(tester.takeException(), isNull);
    expect(find.byType(WiredDoodle), findsOneWidget);
    // The card's painter is unchanged; its draw config carries the boil.
    expect(first, isA<WiredRoundedRectangleBase>());
    expect(
      WiredBoil.seedOffsetOf(tester.element(find.byType(WiredCard))),
      7919,
    );
  });

  testWidgets('more drawings cycle through more seeds', (tester) async {
    final seen = <(int, int)>[];
    await tester.pumpWidget(
      host(WiredBoil(drawings: 4, framesPerSecond: 10, child: _Probe(seen))),
    );
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(seen.map((entry) => entry.$2).toSet().length, 4);
    await tester.pumpWidget(host(const SizedBox()));
  });
}
