import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_maps/skribble_maps.dart';

void main() {
  group('WiredMapCamera', () {
    test('round-trips coordinates through the viewport', () {
      const camera = WiredMapCamera(
        center: LatLng(51.5, -0.12),
        zoom: 12,
        viewportSize: Size(400, 300),
        minimumZoom: 0,
        maximumZoom: 20,
      );
      const coordinate = LatLng(51.503, -0.09);

      final roundTrip = camera.unproject(camera.project(coordinate));

      expect(roundTrip.latitude, closeTo(coordinate.latitude, 0.000001));
      expect(roundTrip.longitude, closeTo(coordinate.longitude, 0.000001));
    });

    test('projects the camera center to the viewport center', () {
      const camera = WiredMapCamera(
        center: LatLng(20, 30),
        zoom: 4,
        viewportSize: Size(320, 240),
        minimumZoom: 0,
        maximumZoom: 20,
      );

      expect(camera.project(camera.center), const Offset(160, 120));
    });

    test('wraps across the antimeridian by the shortest path', () {
      const camera = WiredMapCamera(
        center: LatLng(0, 179),
        zoom: 3,
        viewportSize: Size(400, 300),
        minimumZoom: 0,
        maximumZoom: 20,
      );

      expect(camera.project(const LatLng(0, -179)).dx, greaterThan(200));
      expect(camera.project(const LatLng(0, -179)).dx, lessThan(230));
    });

    test('clamps Web Mercator latitude', () {
      final north = WiredMapCamera.projectToWorld(const LatLng(90, 0), 0);
      final limit = WiredMapCamera.projectToWorld(
        const LatLng(wiredMapMaximumLatitude, 0),
        0,
      );

      expect(north.dy, closeTo(limit.dy, 0.000001));
    });

    test('controller clamps zoom limits', () {
      final controller = WiredMapController(
        minimumZoom: 2,
        maximumZoom: 5,
      )..zoomTo(50);

      expect(controller.camera.zoom, 5);
    });

    test('focal zoom preserves the anchored coordinate', () {
      final controller = WiredMapController(initialZoom: 4)
        ..updateViewport(const Size(400, 300));
      const focal = Offset(80, 90);
      final before = controller.camera.unproject(focal);

      controller.zoomBy(2, focalPoint: focal);
      final after = controller.camera.unproject(focal);

      expect(after.latitude, closeTo(before.latitude, 0.000001));
      expect(after.longitude, closeTo(before.longitude, 0.000001));
    });

    test('world size doubles at each zoom', () {
      const camera = WiredMapCamera(
        center: LatLng(0, 0),
        zoom: 5,
        viewportSize: Size.zero,
        minimumZoom: 0,
        maximumZoom: 20,
      );

      expect(camera.worldSize, wiredMapTileSize * math.pow(2, 5));
    });
  });

  group('WiredMapTileCoverage', () {
    test('clamps tile rows at the poles', () {
      const camera = WiredMapCamera(
        center: LatLng(wiredMapMaximumLatitude, 0),
        zoom: 2,
        viewportSize: Size(300, 300),
        minimumZoom: 0,
        maximumZoom: 20,
      );

      final placements = WiredMapTileCoverage.visible(camera, 2);

      expect(placements.every((tile) => tile.coordinate.y >= 0), isTrue);
      expect(placements.every((tile) => tile.coordinate.y < 4), isTrue);
    });

    test('normalizes repeated-world tile columns', () {
      const camera = WiredMapCamera(
        center: LatLng(0, 179),
        zoom: 1,
        viewportSize: Size(800, 300),
        minimumZoom: 0,
        maximumZoom: 20,
      );

      final placements = WiredMapTileCoverage.visible(camera, 1);

      expect(placements.any((tile) => tile.worldX != tile.coordinate.x), isTrue);
      expect(placements.every((tile) => tile.coordinate.x < 2), isTrue);
    });
  });
}
