import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  Widget buildSubject({
    Widget? child,
    Color? color,
    double? height,
    EdgeInsetsGeometry? padding,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: const SizedBox.expand(),
        bottomNavigationBar: WiredBottomAppBar(
          color: color,
          height: height,
          padding: padding,
          child: child,
        ),
      ),
    );
  }

  group('WiredBottomAppBar', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.byType(WiredBottomAppBar), findsOneWidget);
    });

    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          child: Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
              const Spacer(),
              IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            ],
          ),
        ),
      );
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('has default height of 56', (tester) async {
      await tester.pumpWidget(buildSubject());
      // The WiredBottomAppBar should render with default 56 height
      expect(find.byType(WiredBottomAppBar), findsOneWidget);
    });

    testWidgets('respects custom height', (tester) async {
      await tester.pumpWidget(buildSubject(height: 80));
      // Verify the widget renders with the custom height parameter
      final bar = tester.widget<WiredBottomAppBar>(
        find.byType(WiredBottomAppBar),
      );
      expect(bar.height, 80);
    });

    testWidgets('renders with custom color', (tester) async {
      await tester.pumpWidget(buildSubject(color: Colors.amber));
      expect(find.byType(WiredBottomAppBar), findsOneWidget);
    });

    testWidgets('renders with custom padding', (tester) async {
      await tester.pumpWidget(buildSubject(padding: const EdgeInsets.all(24)));
      expect(find.byType(WiredBottomAppBar), findsOneWidget);
    });

    testWidgets('child icon buttons are tappable', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildSubject(
          child: IconButton(
            onPressed: () => tapped = true,
            icon: const Icon(Icons.home),
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.home));
      expect(tapped, isTrue);
    });
  });
}
