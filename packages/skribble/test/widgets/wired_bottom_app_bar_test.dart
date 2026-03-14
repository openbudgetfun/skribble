import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

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

    testWidgets('has default height of 56', (tester) async {
      await pumpSubject(tester);
      expect(find.byType(WiredBottomAppBar), findsOneWidget);
    });

    testWidgets('respects custom height', (tester) async {
      await pumpSubject(tester, height: 80);
      final bar = tester.widget<WiredBottomAppBar>(
        find.byType(WiredBottomAppBar),
      );
      expect(bar.height, 80);
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
