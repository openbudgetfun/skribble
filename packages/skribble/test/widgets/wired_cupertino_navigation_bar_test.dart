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
    Color? backgroundColor,
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
          backgroundColor: backgroundColor,
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
      const bar = WiredCupertinoNavigationBar();
      expect(bar.preferredSize.height, 44);
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
  });
}
