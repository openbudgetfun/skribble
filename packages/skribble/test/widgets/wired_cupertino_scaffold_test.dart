import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredPageScaffold', () {
    testWidgets('renders child content', (tester) async {
      await pumpApp(
        tester,
        const WiredPageScaffold(child: Text('Page body')),
      );
      expect(find.text('Page body'), findsOneWidget);
      expect(find.byType(WiredPageScaffold), findsOneWidget);
    });

    testWidgets('renders navigation bar when provided', (tester) async {
      await pumpApp(
        tester,
        WiredPageScaffold(
          navigationBar: WiredAppBar(title: const Text('Nav')),
          child: const Text('Content'),
        ),
      );
      expect(find.text('Nav'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });
  });

  group('WiredTabScaffold', () {
    testWidgets('renders tabs and initial page', (tester) async {
      await pumpApp(
        tester,
        WiredTabScaffold(
          tabs: const [
            WiredTabItem(icon: Icons.home, label: 'Home'),
            WiredTabItem(icon: Icons.settings, label: 'Settings'),
          ],
          tabBuilder: (_, i) => Center(child: Text('Page $i')),
        ),
      );
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Page 0'), findsOneWidget);
    });

    testWidgets('switches tabs on tap', (tester) async {
      await pumpApp(
        tester,
        WiredTabScaffold(
          tabs: const [
            WiredTabItem(icon: Icons.home, label: 'Home'),
            WiredTabItem(icon: Icons.search, label: 'Search'),
          ],
          tabBuilder: (_, i) =>
              Center(child: Text(i == 0 ? 'Home Page' : 'Search Page')),
        ),
      );

      expect(find.text('Home Page'), findsOneWidget);

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      expect(find.text('Search Page'), findsOneWidget);
    });

    testWidgets('renders with initial index', (tester) async {
      await pumpApp(
        tester,
        WiredTabScaffold(
          initialIndex: 1,
          tabs: const [
            WiredTabItem(icon: Icons.home, label: 'Home'),
            WiredTabItem(icon: Icons.person, label: 'Profile'),
          ],
          tabBuilder: (_, i) => Center(
            child: Text(i == 0 ? 'Home content' : 'Profile content'),
          ),
        ),
      );
      expect(find.text('Profile content'), findsOneWidget);
    });

    testWidgets('renders three tabs', (tester) async {
      await pumpApp(
        tester,
        WiredTabScaffold(
          tabs: const [
            WiredTabItem(icon: Icons.home, label: 'Home'),
            WiredTabItem(icon: Icons.search, label: 'Search'),
            WiredTabItem(icon: Icons.person, label: 'Profile'),
          ],
          tabBuilder: (_, i) => Center(child: Text('Tab $i')),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });
  });

  group('WiredPageScaffold', () {
    testWidgets('renders with custom background color', (tester) async {
      await pumpApp(
        tester,
        const WiredPageScaffold(
          backgroundColor: Colors.blue,
          child: Text('Custom bg'),
        ),
      );

      expect(find.text('Custom bg'), findsOneWidget);
    });
  });
}
