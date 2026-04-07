import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  Future<void> pumpWiredScaffold(
    WidgetTester tester,
    Widget widget, {
    WiredThemeData? wiredTheme,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: WiredTheme(data: wiredTheme ?? WiredThemeData(), child: widget),
      ),
    );
  }

  group('WiredScaffold', () {
    testWidgets('renders app bar and body content', (tester) async {
      await pumpWiredScaffold(
        tester,
        const WiredScaffold(
          appBar: WiredAppBar(title: Text('Sketch Shell')),
          body: Text('Hello Skribble'),
        ),
      );

      expect(find.text('Sketch Shell'), findsOneWidget);
      expect(find.text('Hello Skribble'), findsOneWidget);
      expect(find.byType(WiredScaffold), findsOneWidget);
    });

    testWidgets('uses theme paper background by default', (tester) async {
      final theme = WiredThemeData(fillColor: const Color(0xFFFFF4D6));

      await pumpWiredScaffold(
        tester,
        const WiredScaffold(body: SizedBox.shrink()),
        wiredTheme: theme,
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, theme.paperBackgroundColor);
    });

    testWidgets('respects custom background color override', (tester) async {
      await pumpWiredScaffold(
        tester,
        const WiredScaffold(
          backgroundColor: Colors.pink,
          body: SizedBox.shrink(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.pink);
    });

    testWidgets('applies body padding and safe area when requested', (
      tester,
    ) async {
      await pumpWiredScaffold(
        tester,
        const WiredScaffold(
          applySafeArea: true,
          bodyPadding: EdgeInsets.all(24),
          body: Text('Padded body'),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(Padding), findsWidgets);
      expect(find.text('Padded body'), findsOneWidget);
    });

    testWidgets('renders common scaffold slots', (tester) async {
      await pumpWiredScaffold(
        tester,
        WiredScaffold(
          body: const Text('Body'),
          floatingActionButton: WiredIconButton(
            icon: Icons.edit,
            onPressed: () {},
          ),
          bottomNavigationBar: const SizedBox(
            height: 40,
            child: Center(child: Text('Bottom nav')),
          ),
          persistentFooterButtons: const [Text('Footer action')],
          bottomSheet: const SizedBox(
            height: 32,
            child: Center(child: Text('Bottom sheet')),
          ),
        ),
      );

      expect(find.text('Body'), findsOneWidget);
      expect(find.text('Bottom nav'), findsOneWidget);
      expect(find.text('Footer action'), findsOneWidget);
      expect(find.text('Bottom sheet'), findsOneWidget);
      expect(find.byType(WiredIconButton), findsOneWidget);
    });

    testWidgets('renders drawer content', (tester) async {
      await pumpWiredScaffold(
        tester,
        const WiredScaffold(
          appBar: WiredAppBar(title: Text('Drawer host')),
          drawer: Drawer(child: Center(child: Text('Sketch drawer'))),
          body: SizedBox.shrink(),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Sketch drawer'), findsOneWidget);
    });
  });
}
