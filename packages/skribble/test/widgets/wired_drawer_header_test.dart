import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredDrawerHeader', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(tester, WiredDrawerHeader(child: Text('Header')));
      expect(find.byType(WiredDrawerHeader), findsOneWidget);
      expect(find.text('Header'), findsOneWidget);
    });

    testWidgets('renders with custom decoration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredDrawerHeader(
              decoration: BoxDecoration(color: Colors.blue.shade100),
              child: const Text('Styled'),
            ),
          ),
        ),
      );
      expect(find.text('Styled'), findsOneWidget);
    });

    testWidgets('respects custom padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WiredDrawerHeader(
              padding: EdgeInsets.all(32),
              child: Text('Padded'),
            ),
          ),
        ),
      );
      expect(find.text('Padded'), findsOneWidget);
    });
  });

  group('WiredUserAccountsDrawerHeader', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WiredUserAccountsDrawerHeader(
              accountName: Text('John Doe'),
              accountEmail: Text('john@example.com'),
            ),
          ),
        ),
      );
      expect(find.byType(WiredUserAccountsDrawerHeader), findsOneWidget);
    });

    testWidgets('renders account name and email', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WiredUserAccountsDrawerHeader(
              accountName: Text('Jane'),
              accountEmail: Text('jane@test.com'),
            ),
          ),
        ),
      );
      expect(find.text('Jane'), findsOneWidget);
      expect(find.text('jane@test.com'), findsOneWidget);
    });

    testWidgets('renders avatar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WiredUserAccountsDrawerHeader(
              currentAccountPicture: WiredAvatar(radius: 30, child: Text('JD')),
              accountName: Text('John'),
              accountEmail: Text('john@e.com'),
            ),
          ),
        ),
      );
      expect(find.byType(WiredAvatar), findsOneWidget);
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('calls onDetailsPressed', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredUserAccountsDrawerHeader(
              accountName: const Text('Test'),
              onDetailsPressed: () => pressed = true,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(WiredUserAccountsDrawerHeader));
      expect(pressed, isTrue);
    });

    testWidgets('renders other account pictures', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WiredUserAccountsDrawerHeader(
              currentAccountPicture: WiredAvatar(child: Text('A')),
              otherAccountsPictures: [
                WiredAvatar(radius: 14, child: Text('B')),
                WiredAvatar(radius: 14, child: Text('C')),
              ],
              accountName: Text('A'),
            ),
          ),
        ),
      );
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });
  });
}
