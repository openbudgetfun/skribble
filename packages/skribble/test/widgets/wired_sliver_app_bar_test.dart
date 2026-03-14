import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  Future<void> pumpSubject(
    WidgetTester tester, {
    Widget? title,
    Widget? leading,
    List<Widget>? actions,
    Widget? flexibleSpace,
    double? expandedHeight,
    bool pinned = false,
    bool floating = false,
    Color? backgroundColor,
  }) {
    return pumpApp(
      tester,
      CustomScrollView(
        slivers: [
          WiredSliverAppBar(
            title: title,
            leading: leading,
            actions: actions,
            flexibleSpace: flexibleSpace,
            expandedHeight: expandedHeight,
            pinned: pinned,
            floating: floating,
            backgroundColor: backgroundColor,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => ListTile(title: Text('Item $i')),
              childCount: 20,
            ),
          ),
        ],
      ),
    );
  }

  group('WiredSliverAppBar', () {
    testWidgets('renders without error', (tester) async {
      await pumpSubject(tester);
      expect(find.byType(WiredSliverAppBar), findsOneWidget);
    });

    testWidgets('renders title', (tester) async {
      await pumpSubject(tester, title: const Text('Sliver Title'));
      expect(find.text('Sliver Title'), findsOneWidget);
    });

    testWidgets('renders leading widget', (tester) async {
      await pumpSubject(
        tester,
        leading: const Icon(Icons.menu, key: Key('lead')),
      );
      expect(find.byKey(const Key('lead')), findsOneWidget);
    });

    testWidgets('renders actions', (tester) async {
      await pumpSubject(
        tester,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, key: Key('action')),
          ),
        ],
      );
      expect(find.byKey(const Key('action')), findsOneWidget);
    });

    testWidgets('renders with expanded height', (tester) async {
      await pumpSubject(
        tester,
        expandedHeight: 200,
        pinned: true,
        title: const Text('Expanded'),
      );
      expect(find.text('Expanded'), findsOneWidget);
    });

    testWidgets('renders with flexible space', (tester) async {
      await pumpSubject(
        tester,
        expandedHeight: 200,
        flexibleSpace: Container(color: Colors.blue, key: const Key('flex')),
      );
      expect(find.byKey(const Key('flex')), findsOneWidget);
    });

    testWidgets('renders with custom background', (tester) async {
      await pumpSubject(tester, backgroundColor: Colors.teal);
      expect(find.byType(WiredSliverAppBar), findsOneWidget);
    });

    testWidgets('collapses on scroll', (tester) async {
      await pumpSubject(
        tester,
        expandedHeight: 200,
        pinned: true,
        title: const Text('Collapse'),
      );
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Collapse'), findsOneWidget);
    });
  });
}
