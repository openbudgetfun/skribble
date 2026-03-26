import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  Future<void> pumpSubject(
    WidgetTester tester, {
    Widget? leading,
    Widget? middle,
    Widget? trailing,
    bool automaticallyImplyLeading = false,
    bool automaticallyImplyMiddle = true,
    String? previousPageTitle,
    Color? backgroundColor,
    EdgeInsetsDirectional? padding,
    Border? border,
  }) {
    return pumpApp(
      tester,
      PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: WiredCupertinoNavigationBar(
          leading: leading,
          middle: middle,
          trailing: trailing,
          automaticallyImplyLeading: automaticallyImplyLeading,
          automaticallyImplyMiddle: automaticallyImplyMiddle,
          previousPageTitle: previousPageTitle,
          backgroundColor: backgroundColor,
          padding: padding,
          border: border,
        ),
      ),
      asAppBar: true,
    );
  }

  group('WiredCupertinoNavigationBar', () {
    testWidgets('renders without error', (tester) async {
      await pumpSubject(tester);
      expect(find.byType(WiredCupertinoNavigationBar), findsOneWidget);
    });

    testWidgets('renders middle title', (tester) async {
      await pumpSubject(tester, middle: const Text('Settings'));
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders leading widget', (tester) async {
      await pumpSubject(
        tester,
        leading: const Icon(Icons.menu, key: Key('leading')),
      );
      expect(find.byKey(const Key('leading')), findsOneWidget);
    });

    testWidgets('renders trailing widget', (tester) async {
      await pumpSubject(
        tester,
        trailing: const Icon(Icons.more_vert, key: Key('trailing')),
      );
      expect(find.byKey(const Key('trailing')), findsOneWidget);
    });

    testWidgets('renders with custom background color', (tester) async {
      await pumpSubject(tester, backgroundColor: Colors.amber);
      expect(find.byType(WiredCupertinoNavigationBar), findsOneWidget);
    });

    testWidgets('has correct preferred size', (tester) async {
      await pumpSubject(tester);

      final bar = tester.widget<WiredCupertinoNavigationBar>(
        find.byType(WiredCupertinoNavigationBar),
      );
      expect(bar.preferredSize.height, 44);
      expect(
        bar.shouldFullyObstruct(
          tester.element(find.byType(WiredCupertinoNavigationBar)),
        ),
        isTrue,
      );
    });

    testWidgets('supports custom padding and border parameters', (tester) async {
      const customPadding = EdgeInsetsDirectional.only(start: 20, end: 12);
      await pumpSubject(
        tester,
        padding: customPadding,
        border: Border.symmetric(horizontal: BorderSide(color: Colors.red)),
      );

      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(WiredCupertinoNavigationBar),
          matching: find.byType(Padding),
        ),
      );
      expect(padding.padding, customPadding);
    });

    testWidgets('auto-implies middle title from route name when enabled', (
      tester,
    ) async {
      await pumpSubject(tester);
      expect(find.text('/'), findsOneWidget);
    });

    testWidgets('does not auto-imply middle title when disabled', (tester) async {
      await pumpSubject(tester, automaticallyImplyMiddle: false);
      expect(find.text('/'), findsNothing);
    });

    testWidgets('renders all three slots together', (tester) async {
      await pumpSubject(
        tester,
        leading: const Text('Back'),
        middle: const Text('Title'),
        trailing: const Text('Done'),
      );
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('auto-implied back button pops when route can pop', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    unawaited(
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => Scaffold(
                            appBar: const WiredCupertinoNavigationBar(
                              automaticallyImplyLeading: true,
                              previousPageTitle: 'Home',
                            ),
                            body: const Text('Details page'),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byIcon(CupertinoIcons.back), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);

      await tester.tap(find.byIcon(CupertinoIcons.back));
      await tester.pumpAndSettle();

      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Details page'), findsNothing);
    });

    testWidgets('does not auto-imply back button when disabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    unawaited(
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const Scaffold(
                            appBar: WiredCupertinoNavigationBar(
                              automaticallyImplyLeading: false,
                            ),
                            body: Text('Details page'),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byIcon(CupertinoIcons.back), findsNothing);
      expect(find.text('Details page'), findsOneWidget);
    });
  });
}
