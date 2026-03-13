import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredPageScaffold', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: WiredPageScaffold(child: Text('Page body'))),
      );
      expect(find.text('Page body'), findsOneWidget);
      expect(find.byType(WiredPageScaffold), findsOneWidget);
    });

    testWidgets('renders navigation bar when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WiredPageScaffold(
            navigationBar: WiredAppBar(title: const Text('Nav')),
            child: const Text('Content'),
          ),
        ),
      );
      expect(find.text('Nav'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });
  });

  group('WiredTabScaffold', () {
    testWidgets('renders tabs and initial page', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTabScaffold(
            tabs: const [
              WiredTabItem(icon: Icons.home, label: 'Home'),
              WiredTabItem(icon: Icons.settings, label: 'Settings'),
            ],
            tabBuilder: (_, i) => Center(child: Text('Page $i')),
          ),
        ),
      );
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Page 0'), findsOneWidget);
    });

    testWidgets('switches tabs on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTabScaffold(
            tabs: const [
              WiredTabItem(icon: Icons.home, label: 'Home'),
              WiredTabItem(icon: Icons.search, label: 'Search'),
            ],
            tabBuilder: (_, i) =>
                Center(child: Text(i == 0 ? 'Home Page' : 'Search Page')),
          ),
        ),
      );

      // Initially on Home
      expect(find.text('Home Page'), findsOneWidget);

      // Tap Search tab
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // IndexedStack keeps both, but Search tab should be on top
      expect(find.text('Search Page'), findsOneWidget);
    });

    testWidgets('renders with initial index', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTabScaffold(
            initialIndex: 1,
            tabs: const [
              WiredTabItem(icon: Icons.home, label: 'Home'),
              WiredTabItem(icon: Icons.person, label: 'Profile'),
            ],
            tabBuilder: (_, i) => Center(
              child: Text(i == 0 ? 'Home content' : 'Profile content'),
            ),
          ),
        ),
      );
      // Both exist in IndexedStack, but index 1 should be shown
      expect(find.text('Profile content'), findsOneWidget);
    });
  });
}
