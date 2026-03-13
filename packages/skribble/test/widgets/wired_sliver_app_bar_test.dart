import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  Widget buildSubject({
    Widget? title,
    Widget? leading,
    List<Widget>? actions,
    Widget? flexibleSpace,
    double? expandedHeight,
    bool pinned = false,
    bool floating = false,
    Color? backgroundColor,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
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
      ),
    );
  }

  group('WiredSliverAppBar', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.byType(WiredSliverAppBar), findsOneWidget);
    });

    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(buildSubject(title: const Text('Sliver Title')));
      expect(find.text('Sliver Title'), findsOneWidget);
    });

    testWidgets('renders leading widget', (tester) async {
      await tester.pumpWidget(
        buildSubject(leading: const Icon(Icons.menu, key: Key('lead'))),
      );
      expect(find.byKey(const Key('lead')), findsOneWidget);
    });

    testWidgets('renders actions', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search, key: Key('action')),
            ),
          ],
        ),
      );
      expect(find.byKey(const Key('action')), findsOneWidget);
    });

    testWidgets('renders with expanded height', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          expandedHeight: 200,
          pinned: true,
          title: const Text('Expanded'),
        ),
      );
      expect(find.text('Expanded'), findsOneWidget);
    });

    testWidgets('renders with flexible space', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          expandedHeight: 200,
          flexibleSpace: Container(color: Colors.blue, key: const Key('flex')),
        ),
      );
      expect(find.byKey(const Key('flex')), findsOneWidget);
    });

    testWidgets('renders with custom background', (tester) async {
      await tester.pumpWidget(buildSubject(backgroundColor: Colors.teal));
      expect(find.byType(WiredSliverAppBar), findsOneWidget);
    });

    testWidgets('collapses on scroll', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          expandedHeight: 200,
          pinned: true,
          title: const Text('Collapse'),
        ),
      );
      // Scroll down
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Collapse'), findsOneWidget);
    });
  });
}
