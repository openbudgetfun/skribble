import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble/testing.dart';

import '../helpers/pump_app.dart';

void main() {
  Future<void> pumpSubject(
    WidgetTester tester, {
    Widget? child,
    Color? color,
    double? height,
    EdgeInsetsGeometry? padding,
  }) {
    return pumpApp(
      tester,
      WiredBottomAppBar(
        color: color,
        height: height,
        padding: padding,
        child: child,
      ),
      asBottomNav: true,
    );
  }

  group('WiredBottomAppBar', () {
    testWidgets('renders without error', (tester) async {
      await pumpSubject(tester);
      expect(find.byType(WiredBottomAppBar), findsOneWidget);
    });

    testWidgets('renders child content', (tester) async {
      await pumpSubject(
        tester,
        child: Row(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
            const Spacer(),
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          ],
        ),
      );
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('is at least 56 pixels tall by default', (tester) async {
      await pumpSubject(tester, child: const Text('Draft'));
      expect(tester.getSize(find.byType(WiredBottomAppBar)).height, 56);
    });

    testWidgets('treats a custom height as a minimum', (tester) async {
      await pumpSubject(tester, height: 80);
      expect(tester.getSize(find.byType(WiredBottomAppBar)).height, 80);

      await pumpSubject(
        tester,
        height: 40,
        child: const SizedBox(height: 60, width: 10),
      );
      // 60 of content plus 8 of ink padding above and below.
      expect(tester.getSize(find.byType(WiredBottomAppBar)).height, 76);
    });

    testWidgets('keeps text clear of its top line', (tester) async {
      await pumpSubject(tester, child: const Text('Make something lovely'));
      final root = tester.binding.renderViews.first;
      expect(crampedText(root, lines: true), isEmpty);

      final bar = tester.getRect(find.byType(WiredBottomAppBar));
      final text = tester.getRect(find.text('Make something lovely'));
      expect(text.top - bar.top, greaterThanOrEqualTo(8));
      // Centred, not pinned to the top.
      expect(
        (text.center.dy - bar.center.dy).abs(),
        lessThan(1),
      );
    });

    testWidgets('stays above the bottom inset on notched phones', (
      tester,
    ) async {
      await pumpApp(
        tester,
        MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(bottom: 34)),
          child: Builder(
            builder: (context) => const WiredBottomAppBar(child: Text('Home')),
          ),
        ),
        asBottomNav: true,
      );
      final bar = tester.getRect(find.byType(WiredBottomAppBar));
      final text = tester.getRect(find.text('Home'));
      expect(bar.height, 56 + 34);
      expect(bar.bottom - text.bottom, greaterThan(34));
    });

    testWidgets('renders with custom color', (tester) async {
      await pumpSubject(tester, color: Colors.amber);
      expect(find.byType(WiredBottomAppBar), findsOneWidget);
    });

    testWidgets('renders with custom padding', (tester) async {
      await pumpSubject(tester, padding: const EdgeInsets.all(24));
      expect(find.byType(WiredBottomAppBar), findsOneWidget);
    });

    testWidgets('child icon buttons are tappable', (tester) async {
      var tapped = false;
      await pumpSubject(
        tester,
        child: IconButton(
          onPressed: () => tapped = true,
          icon: const Icon(Icons.home),
        ),
      );
      await tester.tap(find.byIcon(Icons.home));
      expect(tapped, isTrue);
    });
  });
}
