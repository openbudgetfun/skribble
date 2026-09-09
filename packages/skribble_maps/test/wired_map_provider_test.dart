import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:skribble_maps/skribble_maps.dart';

void main() {
  const coordinate = WiredMapTileCoordinate(3, 4, 2);

  group('Wired map tile providers', () {
    test('memory provider returns matching bytes', () async {
      final expected = Uint8List.fromList([1, 2, 3]);
      final provider = WiredMemoryVectorTileProvider(
        tiles: {coordinate: expected},
        cacheKey: 'fixture',
      );

      expect(await provider.load(coordinate), same(expected));
      expect(
        await provider.load(const WiredMapTileCoordinate(3, 0, 0)),
        isNull,
      );
    });

    test('network provider substitutes z/x/y', () async {
      Uri? requested;
      final provider = WiredNetworkVectorTileProvider(
        urlTemplate: 'https://example.test/{z}/{x}/{y}.mvt',
        attribution: const WiredMapAttributionData(text: 'Example'),
        client: MockClient((request) async {
          requested = request.url;
          return http.Response.bytes([4, 5, 6], 200);
        }),
      );

      expect(await provider.load(coordinate), [4, 5, 6]);
      expect(requested, Uri.parse('https://example.test/3/4/2.mvt'));
    });

    test('network provider treats a missing tile as empty', () async {
      final provider = WiredNetworkVectorTileProvider(
        urlTemplate: 'https://example.test/{z}/{x}/{y}.mvt',
        attribution: const WiredMapAttributionData(text: 'Example'),
        client: MockClient((_) async => http.Response('', 404)),
      );

      expect(await provider.load(coordinate), isNull);
    });

    test('OpenFreeMap provider resolves its current TileJSON template', () async {
      final requested = <Uri>[];
      final provider = WiredOpenFreeMapProvider(
        client: MockClient((request) async {
          requested.add(request.url);
          if (request.url.path == '/planet') {
            return http.Response(
              jsonEncode({
                'tiles': ['https://cdn.example/{z}/{x}/{y}.pbf'],
              }),
              200,
            );
          }
          return http.Response.bytes([7, 8], 200);
        }),
      );

      expect(await provider.load(coordinate), [7, 8]);
      expect(requested.last, Uri.parse('https://cdn.example/3/4/2.pbf'));
    });

    test('cache coalesces concurrent source requests', () async {
      final source = _CountingProvider();
      final provider = WiredCachingTileProvider(source: source);

      final results = await Future.wait([
        provider.load(coordinate),
        provider.load(coordinate),
      ]);

      expect(results[0], results[1]);
      expect(source.loads, 1);
    });

    test('cache evicts oldest bytes over budget', () async {
      final source = _CountingProvider();
      final provider = WiredCachingTileProvider(
        source: source,
        maximumBytes: 4,
      );
      const second = WiredMapTileCoordinate(3, 5, 2);

      await provider.load(coordinate);
      await provider.load(second);
      await provider.load(coordinate);

      expect(source.loads, 3);
      expect(provider.cachedBytes, 3);
    });

    test('cache optionally disposes its source', () async {
      final source = _CountingProvider();
      final provider = WiredCachingTileProvider(
        source: source,
        disposeSource: true,
      );

      await provider.dispose();

      expect(source.disposed, isTrue);
    });

    test('tile coordinates have stable value equality', () {
      expect(
        const WiredMapTileCoordinate(3, 4, 2),
        const WiredMapTileCoordinate(3, 4, 2),
      );
      expect('$coordinate', '3/4/2');
    });
  });
}

class _CountingProvider extends WiredMapTileProvider {
  int loads = 0;
  bool disposed = false;

  @override
  String get cacheKey => 'counting';

  @override
  int get minimumZoom => 0;

  @override
  int get maximumZoom => 20;

  @override
  WiredMapAttributionData get attribution =>
      const WiredMapAttributionData(text: '');

  @override
  Future<Uint8List?> load(WiredMapTileCoordinate coordinate) async {
    loads++;
    await Future<void>.delayed(Duration.zero);
    return Uint8List.fromList([coordinate.z, coordinate.x, coordinate.y]);
  }

  @override
  void dispose() {
    disposed = true;
  }
}
