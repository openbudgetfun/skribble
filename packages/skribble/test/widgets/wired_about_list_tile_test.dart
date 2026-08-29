import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredAboutListTile', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(tester, const WiredAboutListTile());

      expect(find.byType(WiredAboutListTile), findsOneWidget);
    });

    testWidgets('renders default About label', (tester) async {
      await pumpApp(tester, const WiredAboutListTile());

      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('renders label with application name', (tester) async {
      await pumpApp(
        tester,
        const WiredAboutListTile(applicationName: 'Sketchbook'),
      );

      expect(find.text('About Sketchbook'), findsOneWidget);
    });

    testWidgets('renders custom child as label', (tester) async {
      await pumpApp(
        tester,
        const WiredAboutListTile(
          applicationName: 'Sketchbook',
          child: Text('License info'),
        ),
      );

      expect(find.text('License info'), findsOneWidget);
      expect(find.text('About Sketchbook'), findsNothing);
    });

    testWidgets('renders icon', (tester) async {
      await pumpApp(
        tester,
        const WiredAboutListTile(icon: Icon(Icons.info_outline)),
      );

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('opens about dialog on tap', (tester) async {
      await pumpApp(
        tester,
        const WiredAboutListTile(
          icon: Icon(Icons.info_outline),
          applicationName: 'Sketchbook',
          applicationVersion: '1.2.3',
          applicationLegalese: 'Made with pencil and paper.',
        ),
      );

      await tester.tap(find.byType(WiredAboutListTile));
      await tester.pumpAndSettle();

      expect(find.byType(WiredAboutDialog), findsOneWidget);
      expect(find.text('Sketchbook'), findsOneWidget);
      expect(find.text('1.2.3'), findsOneWidget);
      expect(find.text('Made with pencil and paper.'), findsOneWidget);
    });

    testWidgets('dialog closes via Close button', (tester) async {
      await pumpApp(tester, const WiredAboutListTile());

      await tester.tap(find.byType(WiredAboutListTile));
      await tester.pumpAndSettle();
      expect(find.byType(WiredAboutDialog), findsOneWidget);

      await tester.tap(find.text('CLOSE'));
      await tester.pumpAndSettle();
      expect(find.byType(WiredAboutDialog), findsNothing);
    });

    testWidgets('passes application icon and children to the dialog', (
      tester,
    ) async {
      await pumpApp(
        tester,
        const WiredAboutListTile(
          applicationName: 'Sketchbook',
          applicationIcon: Icon(Icons.brush),
          aboutBoxChildren: [Text('Extra box content')],
        ),
      );

      await tester.tap(find.byType(WiredAboutListTile));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.brush), findsOneWidget);
      expect(find.text('Extra box content'), findsOneWidget);
    });

    testWidgets('marks button semantics', (tester) async {
      await pumpApp(
        tester,
        const WiredAboutListTile(semanticLabel: 'Open about page'),
      );

      expect(find.bySemanticsLabel('Open about page'), findsOneWidget);
      final anyButtonSemantics = find.descendant(
        of: find.byType(WiredAboutListTile),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && (widget.properties.button ?? false),
        ),
      );
      expect(anyButtonSemantics, findsAtLeast(1));
    });

    testWidgets('dialog opens from tile inside scrolled list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                const WiredAboutListTile(applicationName: 'Deep'),
                Container(height: 400, color: Colors.grey),
              ],
            ),
          ),
        ),
      );

      await tester.scrollUntilVisible(
        find.text('About Deep'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('About Deep'));
      await tester.pumpAndSettle();

      expect(find.byType(WiredAboutDialog), findsOneWidget);
    });
  });
}
