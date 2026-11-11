import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

Finder get _paint => find.descendant(
  of: find.byType(WiredHighlight),
  matching: find.byType(CustomPaint),
);

void main() {
  group('WiredHighlight', () {
    testWidgets('renders its child and paints a swipe behind it', (
      tester,
    ) async {
      await pumpWired(
        tester,
        const WiredHighlight(child: Text('pop')),
      );
      await tester.pumpAndSettle();
      expect(find.text('pop'), findsOneWidget);
      expect(_paint, findsOneWidget);
      expect(tester.widget<CustomPaint>(_paint).painter, isNotNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('wraps its child with the padding around it', (tester) async {
      await pumpWired(
        tester,
        const WiredHighlight(
          padding: EdgeInsets.all(10),
          child: SizedBox(width: 50, height: 20),
        ),
      );
      expect(tester.getSize(find.byType(WiredHighlight)), const Size(70, 40));

      await pumpWired(
        tester,
        const WiredHighlight(
          padding: EdgeInsets.zero,
          child: SizedBox.shrink(),
        ),
      );
      expect(tester.getSize(find.byType(WiredHighlight)), Size.zero);
      expect(tester.takeException(), isNull);
    });

    testWidgets('draws itself on, then stops ticking', (tester) async {
      await pumpWired(
        tester,
        const WiredHighlight(
          delay: Duration(milliseconds: 100),
          child: Text('pop'),
        ),
      );
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('is drawn at once without animate or with reduced motion', (
      tester,
    ) async {
      await pumpWired(
        tester,
        const WiredHighlight(animate: false, child: Text('still')),
      );
      expect(tester.hasRunningAnimations, isFalse);

      await pumpWired(
        tester,
        const WiredMotion(
          enabled: false,
          child: WiredHighlight(child: Text('calm')),
        ),
      );
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('inks its child to read on the swipe in a dark theme', (
      tester,
    ) async {
      await pumpWired(
        tester,
        const WiredHighlight(child: Text('glow')),
        theme: WiredThemeData.cuddly(brightness: Brightness.dark),
      );
      final style = DefaultTextStyle.of(tester.element(find.text('glow')));
      expect(style.style.color, WiredPalette.night);

      await pumpWired(
        tester,
        const WiredHighlight(
          style: WiredHighlightStyle.underline,
          child: Text('line'),
        ),
        theme: WiredThemeData.cuddly(brightness: Brightness.dark),
      );
      final underline = DefaultTextStyle.of(tester.element(find.text('line')));
      expect(underline.style.color, WiredPalette.paper);
    });

    testWidgets('follows an enclosing entrance when not animating itself', (
      tester,
    ) async {
      await pumpWired(
        tester,
        const WiredEntrance(
          child: WiredHighlight(animate: false, child: Text('along')),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
      expect(find.text('along'), findsOneWidget);
    });

    testWidgets('lays out the same in RTL and with scaled text', (
      tester,
    ) async {
      await pumpWiredRtl(
        tester,
        const WiredHighlight(child: Text('مرحبا')),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await pumpWiredScaled(
        tester,
        const WiredHighlight(child: Text('big')),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(WiredHighlight)).height,
        greaterThan(30),
      );
    });

    testWidgets('keeps its child semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpWired(
        tester,
        const WiredHighlight(child: Text('Read me')),
      );
      expect(find.bySemanticsLabel('Read me'), findsOneWidget);
      handle.dispose();
    });
  });
}
