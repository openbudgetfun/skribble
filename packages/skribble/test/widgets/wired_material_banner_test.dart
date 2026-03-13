import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  Widget buildSubject({
    Widget content = const Text('Banner message'),
    Widget? leading,
    List<Widget> actions = const [],
    Color? backgroundColor,
    bool forceActionsBelow = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            WiredMaterialBanner(
              content: content,
              leading: leading,
              actions: actions,
              backgroundColor: backgroundColor,
              forceActionsBelow: forceActionsBelow,
            ),
          ],
        ),
      ),
    );
  }

  group('WiredMaterialBanner', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.byType(WiredMaterialBanner), findsOneWidget);
    });

    testWidgets('renders content text', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Banner message'), findsOneWidget);
    });

    testWidgets('renders leading widget', (tester) async {
      await tester.pumpWidget(
        buildSubject(leading: const Icon(Icons.warning, key: Key('lead'))),
      );
      expect(find.byKey(const Key('lead')), findsOneWidget);
    });

    testWidgets('renders action buttons', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          actions: [
            TextButton(onPressed: () {}, child: const Text('Dismiss')),
            TextButton(onPressed: () {}, child: const Text('Learn More')),
          ],
        ),
      );
      expect(find.text('Dismiss'), findsOneWidget);
      expect(find.text('Learn More'), findsOneWidget);
    });

    testWidgets('action button is tappable', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildSubject(
          actions: [
            TextButton(onPressed: () => tapped = true, child: const Text('OK')),
          ],
        ),
      );
      await tester.tap(find.text('OK'));
      expect(tapped, isTrue);
    });

    testWidgets('renders with custom background color', (tester) async {
      await tester.pumpWidget(buildSubject(backgroundColor: Colors.amber));
      expect(find.byType(WiredMaterialBanner), findsOneWidget);
    });

    testWidgets('forceActionsBelow puts actions below content', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          forceActionsBelow: true,
          actions: [TextButton(onPressed: () {}, child: const Text('Close'))],
        ),
      );
      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Banner message'), findsOneWidget);
    });

    testWidgets('calls onVisible on build', (tester) async {
      var visible = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredMaterialBanner(
              content: const Text('test'),
              onVisible: () => visible = true,
            ),
          ),
        ),
      );
      expect(visible, isTrue);
    });
  });
}
