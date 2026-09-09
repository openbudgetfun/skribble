import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_maps/skribble_maps.dart';
import 'package:vector_tile/raw/raw_vector_tile.dart' as raw;

import 'helpers/vector_tile_fixture.dart';

void main() {
  const coordinate = WiredMapTileCoordinate(3, 4, 2);
  const schema = WiredOpenMapTilesSchema();

  group('WiredOpenMapTilesSchema', () {
    test('classifies water polygons', () {
      final tile = schema.prepare(vectorTileFixture(), coordinate);

      expect(tile.features.single.kind, WiredMapFeatureKind.water);
      expect(tile.features.single.geometryType, WiredMapGeometryType.polygon);
    });

    test('classifies ordinary transportation as roads', () {
      final tile = schema.prepare(
        vectorTileFixture(
          layer: 'transportation',
          type: raw.VectorTile_GeomType.LINESTRING,
          properties: const {'class': 'primary'},
        ),
        coordinate,
      );

      expect(tile.features.single.kind, WiredMapFeatureKind.road);
    });

    test('classifies pedestrian transportation as paths', () {
      final tile = schema.prepare(
        vectorTileFixture(
          layer: 'transportation',
          type: raw.VectorTile_GeomType.LINESTRING,
          properties: const {'class': 'path'},
        ),
        coordinate,
      );

      expect(tile.features.single.kind, WiredMapFeatureKind.path);
    });

    test('extracts preferred labels', () {
      final tile = schema.prepare(
        vectorTileFixture(
          layer: 'place',
          type: raw.VectorTile_GeomType.POINT,
          properties: const {'name': 'London', 'name:en': 'London EN'},
        ),
        coordinate,
      );

      expect(tile.features.single.label, 'London EN');
    });

    test('drops unknown source layers', () {
      final tile = schema.prepare(
        vectorTileFixture(layer: 'unknown'),
        coordinate,
      );

      expect(tile.features, isEmpty);
    });

    test('produces deterministic feature seeds', () {
      final bytes = vectorTileFixture();

      final first = schema.prepare(bytes, coordinate).features.single.seed;
      final second = schema.prepare(bytes, coordinate).features.single.seed;

      expect(first, second);
    });

    test('normalizes geometry into tile coordinates', () {
      final tile = schema.prepare(vectorTileFixture(), coordinate);

      final points = tile.features.single.parts.expand((part) => part);
      expect(points.every((point) => point.dx >= 0 && point.dx <= 1), isTrue);
      expect(points.every((point) => point.dy >= 0 && point.dy <= 1), isTrue);
    });

    test('prepares a tile through the background compute path', () async {
      final tile = await schema.prepareAsync(
        vectorTileFixture(),
        coordinate,
      );

      expect(tile.features, hasLength(1));
      expect(tile.features.single.kind, WiredMapFeatureKind.water);
    });
  });
}
