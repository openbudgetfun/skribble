import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  Future<void> pumpSubject(
    WidgetTester tester, {
    Widget content = const Text('Banner message'),
    Widget? leading,
    List<Widget> actions = const [],
    Color? backgroundColor,
    bool forceActionsBelow = false,
  }) async {
    await pumpApp(
      tester,
      Column(
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
    );
  }

  group('WiredMaterialBanner', () {
    testWidgets('renders without error', (tester) async {
      await pumpSubject(tester);
      expect(find.byType(WiredMaterialBanner), findsOneWidget);
    });

    testWidgets('renders content text', (tester) async {
      await pumpSubject(tester);
      expect(find.text('Banner message'), findsOneWidget);
    });

    testWidgets('renders leading widget', (tester) async {
      await pumpSubject(
        tester,
        leading: const Icon(Icons.warning, key: Key('lead')),
      );
      expect(find.byKey(const Key('lead')), findsOneWidget);
    });

    testWidgets('renders action buttons', (tester) async {
      await pumpSubject(
        tester,
        actions: [
          TextButton(onPressed: () {}, child: const Text('Dismiss')),
          TextButton(onPressed: () {}, child: const Text('Learn More')),
        ],
      );
      expect(find.text('Dismiss'), findsOneWidget);
      expect(find.text('Learn More'), findsOneWidget);
    });

    testWidgets('action button is tappable', (tester) async {
      var tapped = false;
      await pumpSubject(
        tester,
        actions: [
          TextButton(onPressed: () => tapped = true, child: const Text('OK')),
        ],
      );
      await tester.tap(find.text('OK'));
      expect(tapped, isTrue);
    });

    testWidgets('renders with custom background color', (tester) async {
      await pumpSubject(tester, backgroundColor: Colors.amber);
      expect(find.byType(WiredMaterialBanner), findsOneWidget);
    });

    testWidgets('forceActionsBelow puts actions below content', (tester) async {
      await pumpSubject(
        tester,
        forceActionsBelow: true,
        actions: [TextButton(onPressed: () {}, child: const Text('Close'))],
      );
      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Banner message'), findsOneWidget);
    });

    testWidgets('forceActionsBelow applies default leading padding', (
      tester,
    ) async {
      await pumpSubject(
        tester,
        forceActionsBelow: true,
        leading: const Icon(Icons.info, key: Key('below-leading')),
      );

      final padding = tester.widget<Padding>(
        find.ancestor(
          of: find.byKey(const Key('below-leading')),
          matching: find.byType(Padding),
        ),
      );

      expect(padding.padding, const EdgeInsets.only(right: 16));
    });

    testWidgets('calls onVisible on build', (tester) async {
      var visible = false;
      await pumpApp(
        tester,
        WiredMaterialBanner(
          content: const Text('test'),
          onVisible: () => visible = true,
        ),
      );
      expect(visible, isTrue);
    });

    testWidgets('showWiredMaterialBanner shows a MaterialBanner', (
      tester,
    ) async {
      ScaffoldFeatureController<MaterialBanner, MaterialBannerClosedReason>?
      controller;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  controller = showWiredMaterialBanner(
                    context,
                    content: const Text('ignored by helper placeholder'),
                  );
                },
                child: const Text('Show Banner'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Banner'));
      await tester.pump();

      expect(controller, isNotNull);
      expect(find.byType(MaterialBanner), findsOneWidget);
    });
  });
}
