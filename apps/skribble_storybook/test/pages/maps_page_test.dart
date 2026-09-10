import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_maps/skribble_maps.dart';
import 'package:skribble_storybook/pages/maps_page.dart';

/// Replaces only the native renderer; projection and overlays remain real.
Widget _basemap(BuildContext context) =>
    const ColoredBox(color: Color(0xfff3f0e8));

Future<void> _pumpMap(WidgetTester tester, {double textScale = 1}) async {
  await tester.pumpWidget(
    WiredMaterialApp(
      wiredTheme: WiredThemeData(),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: const MapsPage(mapViewBuilder: _basemap),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('holding a map pin names the selected stop', (tester) async {
    await _pumpMap(tester);
    await tester.longPress(find.bySemanticsLabel('Brick Lane market'));
    await tester.pumpAndSettle();
    expect(find.text('Brick Lane market'), findsOneWidget);
  });

  testWidgets('waits for loaded tiles after changing cities or palettes', (
    tester,
  ) async {
    await _pumpMap(tester);
    expect(find.text('Loading map…'), findsOneWidget);

    tester.widget<WiredMap>(find.byType(WiredMap)).onMapIdle!();
    await tester.pumpAndSettle();
    expect(find.text('Map ready'), findsOneWidget);

    final map = tester.widget<WiredMap>(find.byType(WiredMap));
    map.onCameraChanged!(map.controller!.camera);
    await tester.pumpAndSettle();
    expect(find.text('Loading map…'), findsOneWidget);
    map.onMapIdle!();
    await tester.pumpAndSettle();
    expect(find.text('Map ready'), findsOneWidget);

    for (final choice in ['Tokyo', 'Night', 'Paper', 'London']) {
      await tester.tap(find.text(choice));
      await tester.pumpAndSettle();
      expect(find.text('Loading map…'), findsOneWidget);
      tester.widget<WiredMap>(find.byType(WiredMap)).onMapIdle!();
      await tester.pumpAndSettle();
      expect(find.text('Map ready'), findsOneWidget);

      await tester.tap(find.text(choice));
      await tester.pumpAndSettle();
      expect(find.text('Map ready'), findsOneWidget);
    }
  });

  testWidgets('selects stops and clears the selection when changing cities', (
    tester,
  ) async {
    await _pumpMap(tester);
    expect(find.text('Tap a pin to choose the next stop'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Brick Lane market'));
    await tester.pumpAndSettle();
    expect(find.text('Brick Lane market'), findsOneWidget);

    await tester.tap(find.text('Dubai'));
    await tester.pumpAndSettle();
    expect(find.text('Tap a pin to choose the next stop'), findsOneWidget);
    expect(find.bySemanticsLabel('Brick Lane market'), findsNothing);
    await tester.tap(find.bySemanticsLabel('Dubai Mall'));
    await tester.pumpAndSettle();
    expect(find.text('Dubai Mall'), findsOneWidget);

    await tester.tap(find.text('Tokyo'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Shibuya crossing'));
    await tester.pumpAndSettle();
    expect(find.text('Shibuya crossing'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('night mode preserves selection and keeps markers interactive', (
    tester,
  ) async {
    await _pumpMap(tester);
    await tester.tap(find.bySemanticsLabel('Brick Lane market'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Night'));
    await tester.pumpAndSettle();
    expect(find.text('Brick Lane market'), findsOneWidget);
    expect(
      tester.widget<WiredMap>(find.byType(WiredMap)).style,
      WiredMapStyle.night,
    );
    await tester.tap(find.bySemanticsLabel('Coffee stop'));
    await tester.pumpAndSettle();
    expect(find.text('Coffee stop'), findsOneWidget);

    await tester.tap(find.text('Paper'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<WiredMap>(find.byType(WiredMap)).style,
      WiredMapStyle.paper,
    );
    expect(find.text('Coffee stop'), findsOneWidget);
  });

  testWidgets(
    'zoom moves projected pins and restores their original position',
    (
      tester,
    ) async {
      await _pumpMap(tester);
      final pin = find.bySemanticsLabel('Coffee stop');
      final original = tester.getCenter(pin);

      await tester.tap(find.bySemanticsLabel('Zoom in'));
      await tester.pumpAndSettle();
      expect(tester.getCenter(pin), isNot(original));

      await tester.tap(find.bySemanticsLabel('Zoom out'));
      await tester.pumpAndSettle();
      expect((tester.getCenter(pin) - original).distance, lessThan(.01));
      await tester.tap(pin);
      await tester.pumpAndSettle();
      expect(find.text('Coffee stop'), findsOneWidget);
    },
  );

  testWidgets('announces a selected stop through a live region', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpMap(tester);
    await tester.tap(find.bySemanticsLabel('Brick Lane market'));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.text('Brick Lane market')),
      matchesSemantics(label: 'Brick Lane market', isLiveRegion: true),
    );
    semantics.dispose();
  });

  for (final size in [
    const Size(320, 740),
    const Size(390, 844),
    const Size(844, 390),
    const Size(1440, 900),
  ]) {
    testWidgets('map controls and selected stop fit at $size', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _pumpMap(tester);
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(WiredMap)).height, greaterThan(80));
      await tester.tap(find.text('Dubai'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('large text fits a phone and keeps the map reachable', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpMap(tester, textScale: 2);
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.byType(WiredMap), 150);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(WiredMap)).height, greaterThan(80));
    expect(tester.takeException(), isNull);
  });

  testWidgets('repeated city changes and disposal leave no pending errors', (
    tester,
  ) async {
    await _pumpMap(tester);
    for (final city in ['Dubai', 'Tokyo', 'London', 'Tokyo', 'Dubai']) {
      await tester.tap(find.text(city));
      await tester.pump();
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
