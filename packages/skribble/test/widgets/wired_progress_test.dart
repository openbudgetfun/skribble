import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/finders.dart';
import '../helpers/pump_app.dart';

/// The marker fill: the first canvas inside the progress bar's stack.
Finder _markerOf(Finder progress) =>
    find.descendant(of: progress, matching: findWiredCanvas).first;

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
      expect(
        tester.getSize(_markerOf(find.byType(WiredProgress))).width,
        closeTo(track.width * .25, .01),
      );
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
      final width = tester.getSize(find.byType(WiredProgress)).width;
      expect(
        tester.getSize(_markerOf(find.byType(WiredProgress))).width,
        closeTo(width / 2, .01),
      );
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
