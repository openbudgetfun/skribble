import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredAboutDialog', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(tester, WiredAboutDialog(applicationName: 'Test App'));
      expect(find.byType(WiredAboutDialog), findsOneWidget);
      expect(find.text('Test App'), findsOneWidget);
    });

    testWidgets('renders version', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WiredAboutDialog(
              applicationName: 'App',
              applicationVersion: '1.0.0',
            ),
          ),
        ),
      );
      expect(find.text('1.0.0'), findsOneWidget);
    });

    testWidgets('renders icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WiredAboutDialog(
              applicationName: 'App',
              applicationIcon: FlutterLogo(size: 48),
            ),
          ),
        ),
      );
      expect(find.byType(FlutterLogo), findsOneWidget);
    });

    testWidgets('renders legalese', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WiredAboutDialog(
              applicationName: 'App',
              applicationLegalese: '© 2026 Skribble',
            ),
          ),
        ),
      );
      expect(find.text('© 2026 Skribble'), findsOneWidget);
    });

    testWidgets('renders additional children', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WiredAboutDialog(
              applicationName: 'App',
              children: [Text('Extra info')],
            ),
          ),
        ),
      );
      expect(find.text('Extra info'), findsOneWidget);
    });

    testWidgets('close button closes dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showWiredAboutDialog(
                  context: context,
                  applicationName: 'My App',
                  applicationVersion: '2.0',
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();
      expect(find.text('My App'), findsOneWidget);
      expect(find.text('2.0'), findsOneWidget);

      await tester.tap(find.text('CLOSE'));
      await tester.pumpAndSettle();
      expect(find.text('My App'), findsNothing);
    });

    testWidgets('renders all elements together', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WiredAboutDialog(
              applicationName: 'Skribble',
              applicationVersion: '0.1.0',
              applicationIcon: FlutterLogo(size: 40),
              applicationLegalese: '© Test',
            ),
          ),
        ),
      );
      expect(find.text('Skribble'), findsOneWidget);
      expect(find.text('0.1.0'), findsOneWidget);
      expect(find.text('© Test'), findsOneWidget);
      expect(find.byType(FlutterLogo), findsOneWidget);
    });
  });
}
