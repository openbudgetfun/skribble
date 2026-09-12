import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_maps/skribble_maps.dart';

import 'helpers/pump_map.dart';

void main() {
  test('rejects non-finite headings and invalid extents', () {
    for (final size in [0.0, -1.0, double.infinity, double.nan]) {
      expect(() => WiredMapLocation(size: size), throwsAssertionError);
    }

    for (final heading in [
      double.infinity,
      double.negativeInfinity,
      double.nan,
    ]) {
      expect(() => WiredMapLocation(heading: heading), throwsAssertionError);
    }
  });

  testWidgets('location is centered, labeled and passes taps through', (
    tester,
  ) async {
    var taps = 0;
    final semantics = tester.ensureSemantics();

    await pumpMapApp(
      tester,
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => taps++,
        child: const Center(child: WiredMapLocation()),
      ),
    );
    expect(tester.getSize(find.byType(WiredMapLocation)), const Size(128, 128));
    expect(find.bySemanticsLabel('Current location'), findsOneWidget);
    await tester.tapAt(tester.getCenter(find.byType(WiredMapLocation)));
    semantics.dispose();
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('layer follows coordinates and camera without changing size', (
    tester,
  ) async {
    final controller = WiredMapController(initialZoom: 14);
    addTearDown(controller.dispose);
    const point = LatLng(0.001, 0.001);
    await pumpMapApp(
      tester,
      WiredMap(
        controller: controller,
        mapViewBuilder: buildTestMapView,
        children: const [WiredMapLocationLayer(point: point, heading: 90)],
      ),
    );
    final origin = tester.getTopLeft(find.byType(WiredMap));
    expect(
      tester.getCenter(find.byType(WiredMapLocation)),
      origin + controller.camera.project(point),
    );
    await controller.move(point, zoom: 16);
    await tester.pumpAndSettle();
    expect(
      tester.getCenter(find.byType(WiredMapLocation)),
      origin + const Offset(200, 200),
    );
    expect(tester.getSize(find.byType(WiredMapLocation)), const Size(128, 128));
    expect(tester.takeException(), isNull);
  });

  testWidgets('heading rotates the fan, wraps and never moves the dot', (
    tester,
  ) async {
    const key = Key('ink');
    Future<ByteData> render(double? heading) async {
      await pumpMapApp(
        tester,
        RepaintBoundary(
          key: key,
          child: WiredMapLocation(heading: heading),
        ),
        size: const Size(128, 128),
      );
      await tester.pumpAndSettle();
      return (await tester.runAsync(() async {
        final image = await tester
            .renderObject<RenderRepaintBoundary>(find.byKey(key))
            .toImage();
        final bytes = (await image.toByteData())!;
        image.dispose();
        return bytes;
      }))!;
    }

    final northBytes = await render(0);
    final eastBytes = await render(90);
    final wrappedBytes = await render(450);
    final absentBytes = await render(null);
    int alpha(ByteData data, int x, int y) =>
        data.getUint8((y * 128 + x) * 4 + 3);

    expect(
      northBytes.buffer.asUint8List(),
      isNot(eastBytes.buffer.asUint8List()),
    );
    expect(eastBytes.buffer.asUint8List(), wrappedBytes.buffer.asUint8List());
    expect(alpha(northBytes, 64, 35), inInclusiveRange(1, 61));
    expect(alpha(eastBytes, 64, 35), 0);
    expect(alpha(eastBytes, 93, 64), inInclusiveRange(1, 61));
    expect(alpha(absentBytes, 64, 35), 0);

    for (final bytes in [northBytes, eastBytes, wrappedBytes, absentBytes]) {
      expect(bytes.getUint32((64 * 128 + 64) * 4), 0x3478E5FF);
    }
  });

  testWidgets('all styles fit tight constraints and rapid heading updates', (
    tester,
  ) async {
    for (final style in WiredMapHeadingStyle.values) {
      for (final heading in [359.0, 0.0, 1.0, -90.0, null]) {
        await pumpMapApp(
          tester,
          WiredMapLocation(heading: heading, headingStyle: style),
          size: const Size(24, 18),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    }
  });
}
