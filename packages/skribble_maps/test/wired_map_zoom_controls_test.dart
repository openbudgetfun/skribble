import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_maps/skribble_maps.dart';

import 'helpers/pump_map.dart' show buildTestMapView;

// This file deliberately registers no icon catalog, like an app that only
// depends on skribble_maps.
void main() {
  // A real app shell, so Tab traversal and Enter/Space activation are bound.
  Future<WiredMapController> pumpControls(
    WidgetTester tester, {
    double zoom = 5,
  }) async {
    final controller = WiredMapController(initialZoom: zoom);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      WidgetsApp(
        color: const Color(0xFFFFFFFF),
        pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, _, _) => builder(context),
        ),
        home: WiredTheme(
          data: WiredThemeData(),
          child: WiredMap(
            controller: controller,
            mapViewBuilder: buildTestMapView,
          ),
        ),
      ),
    );
    return controller;
  }

  group('WiredMapZoomControls', () {
    testWidgets('draw plus and minus without a registered icon catalog', (
      tester,
    ) async {
      await pumpControls(tester);

      expect(lookupMaterialRoughIconByIdentifier('add'), isNull);
      expect(find.byType(WiredSvgIcon), findsNothing);
      final glyphs = find.descendant(
        of: find.byType(WiredMapZoomControls),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint &&
              widget.painter != null &&
              widget.size == const Size.square(22),
        ),
      );
      expect(glyphs, findsNWidgets(2));

      for (final glyph in glyphs.evaluate()) {
        final box = glyph.renderObject! as RenderBox;
        expect(box.size, const Size.square(22));
      }
    });

    testWidgets('screen readers can activate zoom in and zoom out', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final controller = await pumpControls(tester);

      final zoomIn = tester.getSemantics(find.bySemanticsLabel('Zoom in'));
      expect(zoomIn.flagsCollection.isButton, isTrue);
      expect(zoomIn.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

      tester.semantics.tap(find.semantics.byLabel('Zoom in'));
      await tester.pump(const Duration(milliseconds: 350));
      expect(controller.camera.zoom, 6);

      tester.semantics.tap(find.semantics.byLabel('Zoom out'));
      await tester.pump(const Duration(milliseconds: 350));
      expect(controller.camera.zoom, 5);
      semantics.dispose();
    });

    testWidgets('keyboard focus and Enter or Space zoom the map', (
      tester,
    ) async {
      final controller = await pumpControls(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump(const Duration(milliseconds: 350));
      expect(controller.camera.zoom, 6);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump(const Duration(milliseconds: 350));
      expect(controller.camera.zoom, 5);
    });

    testWidgets('a disabled control is skipped by focus and screen readers', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final controller = await pumpControls(tester, zoom: 20);

      final zoomIn = tester.getSemantics(find.bySemanticsLabel('Zoom in'));
      expect(zoomIn.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);

      // Focus lands on Zoom out, the only enabled control.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump(const Duration(milliseconds: 350));
      expect(controller.camera.zoom, 19);
      semantics.dispose();
    });
  });
}
