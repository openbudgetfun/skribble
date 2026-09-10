import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_maps/skribble_maps.dart';

import 'helpers/pump_map.dart';

void main() {
  Widget subject(List<WiredMapMarker> markers) {
    return WiredMap(
      initialZoom: 4,
      showZoomControls: false,
      mapViewBuilder: buildTestMapView,
      children: [WiredMapMarkerLayer(markers: markers)],
    );
  }

  group('WiredMapMarkerLayer', () {
    testWidgets('holding a marker selects without firing its tap', (
      tester,
    ) async {
      var taps = 0;
      var holds = 0;
      final semantics = tester.ensureSemantics();
      await pumpMapApp(
        tester,
        subject([
          WiredMapMarker(
            point: const LatLng(0, 0),
            semanticLabel: 'Cafe',
            onTap: () => taps++,
            onLongPress: () => holds++,
            child: const WiredMapPin(),
          ),
        ]),
      );
      await tester.longPress(find.byType(WiredMapPin));
      await tester.pumpAndSettle();
      expect(holds, 1);
      expect(taps, 0);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Cafe')),
        matchesSemantics(
          label: 'Cafe',
          isButton: true,
          hasTapAction: true,
          hasLongPressAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('moving off a marker cancels long-press selection', (
      tester,
    ) async {
      var holds = 0;
      await pumpMapApp(
        tester,
        subject([
          WiredMapMarker(
            point: const LatLng(0, 0),
            onLongPress: () => holds++,
            child: const WiredMapPin(),
          ),
        ]),
      );
      await tester.drag(find.byType(WiredMapPin), const Offset(100, 0));
      await tester.pumpAndSettle();
      expect(holds, 0);
      await tester.longPress(find.byType(WiredMapPin));
      await tester.pumpAndSettle();
      expect(holds, 1);
    });

    testWidgets('renders marker content', (tester) async {
      await pumpMapApp(
        tester,
        subject([
          const WiredMapMarker(point: LatLng(0, 0), child: Text('Here')),
        ]),
      );

      expect(find.text('Here'), findsOneWidget);
    });

    testWidgets('anchors a centered marker at the map center', (tester) async {
      await pumpMapApp(
        tester,
        subject([
          const WiredMapMarker(
            point: LatLng(0, 0),
            alignment: Alignment.center,
            child: ColoredBox(color: Color(0xFF000000)),
          ),
        ]),
      );

      expect(
        tester.getCenter(find.byType(ColoredBox).last),
        tester.getCenter(find.byType(WiredMap)),
      );
    });

    testWidgets('respects marker dimensions', (tester) async {
      await pumpMapApp(
        tester,
        subject([
          const WiredMapMarker(
            point: LatLng(0, 0),
            width: 70,
            height: 30,
            child: Text('Sized'),
          ),
        ]),
      );

      expect(tester.getSize(find.text('Sized')), const Size(70, 30));
    });

    testWidgets('calls the marker tap callback', (tester) async {
      var taps = 0;
      await pumpMapApp(
        tester,
        subject([
          WiredMapMarker(
            point: const LatLng(0, 0),
            onTap: () => taps++,
            child: const Text('Tap marker'),
          ),
        ]),
      );

      await tester.tap(find.text('Tap marker'));
      await tester.pump(const Duration(milliseconds: 350));

      expect(taps, 1);
    });

    testWidgets('handles rapid marker taps', (tester) async {
      var taps = 0;
      await pumpMapApp(
        tester,
        subject([
          WiredMapMarker(
            point: const LatLng(0, 0),
            onTap: () => taps++,
            child: const Text('Tap marker'),
          ),
        ]),
      );

      await tester.tap(find.text('Tap marker'));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.tap(find.text('Tap marker'));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.tap(find.text('Tap marker'));
      await tester.pump(const Duration(milliseconds: 350));

      expect(taps, 3);
    });

    testWidgets('exposes marker semantics', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpMapApp(
        tester,
        subject([
          WiredMapMarker(
            point: const LatLng(0, 0),
            semanticLabel: 'Favourite café',
            onTap: () {},
            child: const Text('Café'),
          ),
        ]),
      );

      expect(find.bySemanticsLabel('Favourite café'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('removes markers after a rebuild', (tester) async {
      await pumpMapApp(
        tester,
        subject([
          const WiredMapMarker(point: LatLng(0, 0), child: Text('Gone')),
        ]),
      );
      await pumpMapApp(tester, subject(const []));

      expect(find.text('Gone'), findsNothing);
    });
  });
}
