import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_docs_site/src/examples/catalog.dart';
import 'package:skribble_docs_site/src/examples/example.dart';
import 'package:skribble_maps/skribble_maps.dart';

Future<void> _pumpExample(WidgetTester tester, String id) async {
  await tester.pumpWidget(
    WiredMaterialApp(
      wiredTheme: WiredThemeData(),
      home: WiredScaffold(
        body: SingleChildScrollView(
          child: LiveExample(id: id, definition: examples[id]!),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('holding a preview pin selects it without loading a map', (
    tester,
  ) async {
    await _pumpExample(tester, 'map-features');
    await tester.longPress(find.bySemanticsLabel('Favourite café'));
    await tester.pumpAndSettle();
    expect(find.text('Selected: Favourite café'), findsOneWidget);
    expect(find.byType(WiredMap), findsNothing);
  });

  testWidgets('map preview explains how to start the online renderer', (
    tester,
  ) async {
    await _pumpExample(tester, 'map-online');
    expect(find.text('Load OpenFreeMap'), findsOneWidget);
    expect(find.byType(WiredMap), findsNothing);
  });

  testWidgets('pin previews are interactive before requesting an online map', (
    tester,
  ) async {
    await _pumpExample(tester, 'map-features');
    expect(find.byType(WiredMapPin), findsNWidgets(3));
    expect(find.byType(WiredMap), findsNothing);
    expect(find.text('Show the route on a map'), findsOneWidget);

    for (final place in ['Favourite café', 'Weekend market', 'Local gallery']) {
      await tester.tap(find.bySemanticsLabel(place));
      await tester.pumpAndSettle();
      expect(find.text('Selected: $place'), findsOneWidget);
      expect(find.byType(WiredMap), findsNothing);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('pin selection is announced to screen readers', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpExample(tester, 'map-features');
    await tester.tap(find.bySemanticsLabel('Favourite café'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.text('Selected: Favourite café')),
      matchesSemantics(
        label: 'Selected: Favourite café',
        isLiveRegion: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('the interactive pin preview fits narrow documentation pages', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpExample(tester, 'map-features');
    await tester.tap(find.bySemanticsLabel('Weekend market'));
    await tester.pumpAndSettle();
    expect(find.text('Selected: Weekend market'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
