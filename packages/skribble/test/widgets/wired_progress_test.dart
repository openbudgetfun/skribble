import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';
import '../helpers/pump_app.dart';

/// The marker fill: the first canvas inside the progress bar's stack.
Finder _markerOf(Finder progress) =>
    find.descendant(of: progress, matching: findWiredCanvas).first;

/// The pen's reserve across both edges of the bar.
double _inkExtent(WidgetTester tester) =>
    WiredTheme.of(tester.element(find.byType(WiredProgress))).inkExtent;

/// The width the marker actually paints: its box less the ink it insets.
double _paintedFill(WidgetTester tester) =>
    tester.getSize(_markerOf(find.byType(WiredProgress))).width -
    _inkExtent(tester);

/// The track's interior, inside its ink.
double _interior(WidgetTester tester) =>
    tester.getSize(find.byType(WiredProgress)).width - _inkExtent(tester);

void main() {
  group('WiredProgress', () {
    const size = Size(300, 40);

    testWidgets('fills the track to its value', (tester) async {
      await pumpWired(
        tester,
        const WiredProgress(value: .25),
        surfaceSize: size,
      );
      await tester.pumpAndSettle();
      final track = tester.getSize(find.byType(WiredProgress));
      expect(track.height, 20);
      expect(_paintedFill(tester), closeTo(_interior(tester) * .25, .01));
    });

    testWidgets('glides to a new value', (tester) async {
      await pumpWired(tester, const WiredProgress(value: 0), surfaceSize: size);
      await tester.pumpAndSettle();
      await pumpWired(tester, const WiredProgress(value: 1), surfaceSize: size);
      await tester.pump(const Duration(milliseconds: 100));
      final width = tester.getSize(find.byType(WiredProgress)).width;
      final midway = tester
          .getSize(_markerOf(find.byType(WiredProgress)))
          .width;
      expect(midway, greaterThan(0));
      expect(midway, lessThan(width));
      await tester.pumpAndSettle();
      expect(
        tester.getSize(_markerOf(find.byType(WiredProgress))).width,
        closeTo(width, .01),
      );
    });

    testWidgets('settles at once when motion is off', (tester) async {
      await pumpWired(
        tester,
        const WiredMotion(enabled: false, child: WiredProgress(value: 0)),
        surfaceSize: size,
      );
      await pumpWired(
        tester,
        const WiredMotion(enabled: false, child: WiredProgress(value: .5)),
        surfaceSize: size,
      );
      await tester.pump();
      expect(_paintedFill(tester), closeTo(_interior(tester) / 2, .01));
    });

    testWidgets('clamps values outside 0 to 1', (tester) async {
      await pumpWired(tester, const WiredProgress(value: 3), surfaceSize: size);
      await tester.pumpAndSettle();
      final width = tester.getSize(find.byType(WiredProgress)).width;
      expect(
        tester.getSize(_markerOf(find.byType(WiredProgress))).width,
        closeTo(width, .01),
      );
    });

    testWidgets('sweeps while the value is unknown', (tester) async {
      await pumpWired(tester, const WiredProgress(), surfaceSize: size);
      expect(tester.hasRunningAnimations, isTrue);
      final first = tester.getTopLeft(_markerOf(find.byType(WiredProgress)));
      await tester.pump(const Duration(milliseconds: 600));
      final later = tester.getTopLeft(_markerOf(find.byType(WiredProgress)));
      expect(later.dx, isNot(first.dx));

      // A known value stops the sweep.
      await pumpWired(
        tester,
        const WiredProgress(value: .5),
        surfaceSize: size,
      );
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('fills from the right in right-to-left text', (tester) async {
      await pumpWiredRtl(
        tester,
        const WiredProgress(value: .25),
        surfaceSize: size,
      );
      await tester.pumpAndSettle();
      final bar = tester.getRect(find.byType(WiredProgress));
      final marker = tester.getRect(_markerOf(find.byType(WiredProgress)));
      expect(marker.right, closeTo(bar.right, .01));
    });

    testWidgets('reports its label and percentage', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpWired(
        tester,
        const WiredProgress(value: .42, semanticLabel: 'Uploading'),
        surfaceSize: size,
      );
      expect(
        tester.getSemantics(find.byType(WiredProgress)),
        matchesSemantics(label: 'Uploading', value: '42%'),
      );
      semantics.dispose();
    });

    testWidgets('a short bar keeps a visible band inside its ink', (
      tester,
    ) async {
      await pumpWired(
        tester,
        const WiredProgress(value: .5, height: 12),
        surfaceSize: size,
      );
      await tester.pumpAndSettle();
      final bar = tester.getSize(find.byType(WiredProgress));
      // The ink takes about 11 units of a 12-unit box, which used to leave a
      // hairline; the box grows to fit the ink plus a band instead.
      expect(bar.height, greaterThanOrEqualTo(_inkExtent(tester) + 6));
    });

    testWidgets('a small value still paints its share of the track', (
      tester,
    ) async {
      await pumpWired(
        tester,
        const WiredProgress(value: .02),
        surfaceSize: size,
      );
      await tester.pumpAndSettle();
      // The marker used to inset its own ink from a box only 2% wide, which
      // painted nothing at all for small values.
      expect(_paintedFill(tester), greaterThan(0));
      expect(_paintedFill(tester), closeTo(_interior(tester) * .02, .01));
    });

    testWidgets('an empty bar draws no marker', (tester) async {
      await pumpWired(tester, const WiredProgress(value: 0), surfaceSize: size);
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(WiredProgress),
          matching: findWiredCanvas,
        ),
        findsOneWidget,
      );
    });

    testWidgets('isolates repaints', (tester) async {
      await pumpWired(
        tester,
        const WiredProgress(value: .5),
        surfaceSize: size,
      );
      expect(findRepaintBoundary, findsWidgets);
    });
  });
}
