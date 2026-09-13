import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  Future<void> pumpSubject(
    WidgetTester tester, {
    bool value = false,
    ValueChanged<bool>? onChanged,
    Color? activeTrackColor,
    Color? inactiveTrackColor,
    Color? thumbColor,
    String? semanticLabel,
  }) {
    return pumpApp(
      tester,
      Center(
        child: WiredCupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: activeTrackColor,
          inactiveTrackColor: inactiveTrackColor,
          thumbColor: thumbColor,
          semanticLabel: semanticLabel,
        ),
      ),
    );
  }

  group('WiredCupertinoSwitch', () {
    testWidgets('renders without error', (tester) async {
      await pumpSubject(tester, onChanged: (_) {});
      expect(find.byType(WiredCupertinoSwitch), findsOneWidget);
    });

    testWidgets('calls onChanged when tapped', (tester) async {
      bool? toggled;
      await pumpSubject(tester, onChanged: (v) => toggled = v);
      await tester.tap(find.byType(WiredCupertinoSwitch));
      expect(toggled, isTrue);
    });

    testWidgets('does not call onChanged when disabled', (tester) async {
      bool? toggled;
      await pumpSubject(tester);
      await tester.tap(find.byType(WiredCupertinoSwitch));
      expect(toggled, isNull);
    });

    testWidgets('animates thumb on value change', (tester) async {
      var current = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: WiredCupertinoSwitch(
                    value: current,
                    onChanged: (v) => setState(() => current = v),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(WiredCupertinoSwitch));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
    });

    testWidgets('renders with custom active track color', (tester) async {
      await pumpSubject(
        tester,
        value: true,
        onChanged: (_) {},
        activeTrackColor: Colors.purple,
      );
      expect(find.byType(WiredCupertinoSwitch), findsOneWidget);
    });

    testWidgets('renders with custom thumb color', (tester) async {
      await pumpSubject(tester, onChanged: (_) {}, thumbColor: Colors.yellow);
      expect(find.byType(WiredCupertinoSwitch), findsOneWidget);
    });

    testWidgets('has reduced opacity when disabled', (tester) async {
      await pumpSubject(tester);
      final opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(opacity.opacity, 0.4);
    });

    testWidgets('has semantic label when provided', (tester) async {
      await pumpSubject(
        tester,
        onChanged: (_) {},
        semanticLabel: 'Dark mode toggle',
      );
      expect(find.bySemanticsLabel('Dark mode toggle'), findsOneWidget);
    });

    testWidgets('thumb travels the full track width in LTR', (tester) async {
      Finder thumb() => find
          .descendant(
            of: find.byType(WiredCupertinoSwitch),
            matching: find.byType(WiredCanvas),
          )
          .last;

      await pumpSubject(tester);
      final switchLeft = tester
          .getTopLeft(
            find.byType(WiredCupertinoSwitch),
          )
          .dx;

      // The inset thumb starts two pixels into the track.
      expect(tester.getTopLeft(thumb()).dx, switchLeft + 2);

      await pumpSubject(tester, value: true);
      await tester.pumpAndSettle();

      // Track (52) minus thumb (28) and its two-pixel inset is the travel.
      expect(tester.getTopLeft(thumb()).dx, switchLeft + 22);
    });

    testWidgets(
      'thumb travel is unchanged under right-to-left directionality',
      (tester) async {
        // The inset thumb is positioned with a physical `Positioned(left: ...)`
        // offset, so an RTL ambient direction does not move it. Pin that
        // behaviour: the shared thumb animation must not change travel based
        // on text direction.
        Finder thumb() => find
            .descendant(
              of: find.byType(WiredCupertinoSwitch),
              matching: find.byType(WiredCanvas),
            )
            .last;

        Future<void> pumpRtl(bool value) => pumpApp(
          tester,
          Directionality(
            textDirection: TextDirection.rtl,
            child: Center(
              child: WiredCupertinoSwitch(
                value: value,
                onChanged: (_) {},
              ),
            ),
          ),
        );

        await pumpRtl(false);
        final switchLeft = tester
            .getTopLeft(
              find.byType(WiredCupertinoSwitch),
            )
            .dx;

        expect(tester.getTopLeft(thumb()).dx, switchLeft + 2);

        await pumpRtl(true);
        await tester.pumpAndSettle();

        expect(tester.getTopLeft(thumb()).dx, switchLeft + 22);
      },
    );
  });
}
