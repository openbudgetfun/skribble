import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void _registerLicense(String packageName, String text) {
  LicenseRegistry.addLicense(
    () => Stream<LicenseEntry>.value(
      LicenseEntryWithLineBreaks([packageName], text),
    ),
  );
}

void main() {
  setUp(LicenseRegistry.reset);

  group('WiredLicensePage', () {
    testWidgets('renders without error and shows a loading state first', (
      tester,
    ) async {
      await pumpApp(tester, const WiredLicensePage());

      expect(find.byType(WiredLicensePage), findsOneWidget);
      expect(find.byType(WiredCircularProgress), findsOneWidget);
    });

    testWidgets('renders registered packages after loading', (tester) async {
      _registerLicense('skribble_pkg', 'MIT License');

      await pumpApp(tester, const WiredLicensePage());
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(WiredCircularProgress), findsNothing);
      expect(find.text('skribble_pkg'), findsOneWidget);
      expect(find.text('MIT License'), findsOneWidget);
    });

    testWidgets('sorts packages alphabetically', (tester) async {
      _registerLicense('beta_package', 'BSD');
      _registerLicense('alpha_package', 'MIT');

      await pumpApp(tester, const WiredLicensePage());
      await tester.pump(const Duration(milliseconds: 50));

      final alphaDx = tester.getTopLeft(find.text('alpha_package')).dy;
      final betaDx = tester.getTopLeft(find.text('beta_package')).dy;

      expect(alphaDx, lessThan(betaDx));
    });

    testWidgets('renders every paragraph of a license', (tester) async {
      _registerLicense(
        'multi_package',
        'Paragraph one.\n\nParagraph two.\n\nParagraph three.',
      );

      await pumpApp(tester, const WiredLicensePage());
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.textContaining('Paragraph one.'), findsOneWidget);
      expect(find.textContaining('Paragraph two.'), findsOneWidget);
      expect(find.textContaining('Paragraph three.'), findsOneWidget);
    });

    testWidgets('assigns licenses to every package they name', (tester) async {
      _registerLicense(
        'shared_package',
        'Single license text describing two libraries.',
      );

      // One entry naming two packages.
      LicenseRegistry.addLicense(
        () => Stream<LicenseEntry>.value(
          LicenseEntryWithLineBreaks(
            ['package_a', 'package_b'],
            '''
Shared license text describing two libraries.

Paragraph two.''',
          ),
        ),
      );

      await pumpApp(tester, const WiredLicensePage());
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('package_a'), findsOneWidget);
      expect(find.text('package_b'), findsOneWidget);
    });

    testWidgets('shows the application name', (tester) async {
      _registerLicense('any_package', 'MIT');

      await pumpApp(
        tester,
        const WiredLicensePage(applicationName: 'My Hand-Drawn App'),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('My Hand-Drawn App'), findsOneWidget);
    });

    testWidgets('shows the application version', (tester) async {
      _registerLicense('any_package', 'MIT');

      await pumpApp(
        tester,
        const WiredLicensePage(
          applicationName: 'My App',
          applicationVersion: '1.2.3',
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Version 1.2.3'), findsOneWidget);
      expect(find.text('My App'), findsOneWidget);
    });

    testWidgets('renders the application icon', (tester) async {
      _registerLicense('any_package', 'MIT');

      await pumpApp(
        tester,
        const WiredLicensePage(
          applicationIcon: Icon(Icons.apps),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.apps), findsOneWidget);
    });

    testWidgets('reports the number of packages in the header', (tester) async {
      _registerLicense('package_one', 'MIT');
      _registerLicense('package_two', 'BSD');

      await pumpApp(tester, const WiredLicensePage(applicationName: 'App'));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Built with 2 open source packages'), findsOneWidget);
    });

    testWidgets('reports zero packages when the registry is empty', (
      tester,
    ) async {
      await pumpApp(tester, const WiredLicensePage());

      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Built with 0 open source packages'), findsOneWidget);
      expect(find.byType(WiredCircularProgress), findsNothing);
    });

    testWidgets('showWiredLicensePage pushes a page with wired chrome', (
      tester,
    ) async {
      _registerLicense('pushed_package', 'MIT');

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => WiredButton(
              onPressed: () => showWiredLicensePage(
                context: context,
                applicationName: 'Storybook',
              ),
              child: const Text('Open Licenses'),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Open Licenses'));
      await tester.pumpAndSettle();

      expect(find.text('Licenses'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(find.text('pushed_package'), findsOneWidget);
      expect(find.text('Storybook'), findsOneWidget);

      // Back navigation returns to the trigger page.
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Open Licenses'), findsOneWidget);
    });
  });
}
