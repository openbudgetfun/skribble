import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  Widget buildSubject({
    Widget? child,
    double radius = 20,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: WiredAvatar(
            radius: radius,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            child: child,
          ),
        ),
      ),
    );
  }

  group('WiredAvatar', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.byType(WiredAvatar), findsOneWidget);
    });

    testWidgets('renders with initials', (tester) async {
      await tester.pumpWidget(buildSubject(child: const Text('JD')));
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('renders with icon', (tester) async {
      await tester.pumpWidget(buildSubject(child: const Icon(Icons.person)));
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('respects custom radius', (tester) async {
      await tester.pumpWidget(buildSubject(radius: 40));
      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(WiredAvatar),
          matching: find.byType(SizedBox).first,
        ),
      );
      expect(sizedBox.width, 80);
      expect(sizedBox.height, 80);
    });

    testWidgets('renders with custom background color', (tester) async {
      await tester.pumpWidget(buildSubject(backgroundColor: Colors.blue));
      expect(find.byType(WiredAvatar), findsOneWidget);
    });

    testWidgets('renders with custom foreground color', (tester) async {
      await tester.pumpWidget(
        buildSubject(foregroundColor: Colors.white, child: const Text('AB')),
      );
      expect(find.text('AB'), findsOneWidget);
    });

    testWidgets('default size is 40x40', (tester) async {
      await tester.pumpWidget(buildSubject());
      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(WiredAvatar),
          matching: find.byType(SizedBox).first,
        ),
      );
      expect(sizedBox.width, 40);
      expect(sizedBox.height, 40);
    });
  });
}
