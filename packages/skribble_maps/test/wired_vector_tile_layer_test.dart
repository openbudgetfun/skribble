import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble_maps/skribble_maps.dart';
import 'package:vector_tile/raw/raw_vector_tile.dart' as raw;

import 'helpers/pump_map.dart';
import 'helpers/vector_tile_fixture.dart';

void main() {
  const coordinate = WiredMapTileCoordinate(0, 0, 0);

  Widget subject(
    WiredMapTileProvider provider, {
    bool showAttribution = true,
    VoidCallback? onAttributionTap,
    WiredMapLoadingBuilder? loadingBuilder,
    WiredMapErrorBuilder? errorBuilder,
    int maximumConcurrentLoads = 4,
  }) {
    return WiredMap(
      initialZoom: 0,
      maximumZoom: 0,
      showZoomControls: false,
      basemap: WiredVectorTileLayer(
        provider: provider,
        schema: const _ImmediateOpenMapTilesSchema(),
        tileBuffer: 0,
        showAttribution: showAttribution,
        onAttributionTap: onAttributionTap,
        loadingBuilder: loadingBuilder,
        errorBuilder: errorBuilder,
        maximumConcurrentLoads: maximumConcurrentLoads,
      ),
    );
  }

  group('WiredVectorTileLayer', () {
    testWidgets('shows custom loading content', (tester) async {
      final provider = _DeferredProvider();
      await pumpMapApp(
        tester,
        subject(
          provider,
          loadingBuilder: (_) => const Center(child: Text('Sharpening pencil')),
        ),
      );

      expect(find.text('Sharpening pencil'), findsOneWidget);
    });

    testWidgets('shows custom error content', (tester) async {
      final provider = _ErrorProvider();
      await pumpMapApp(
        tester,
        subject(
          provider,
          errorBuilder: (_, error, _) => Text('Error: $error'),
        ),
      );
      await tester.pump();

      expect(find.textContaining('tile failed'), findsOneWidget);
    });

    testWidgets('renders prepared vector geometry', (tester) async {
      final provider = WiredMemoryVectorTileProvider(
        tiles: {coordinate: vectorTileFixture()},
        cacheKey: 'geometry',
      );
      await pumpMapApp(tester, subject(provider));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(WiredVectorTileLayer),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
      expect(find.text('Drawing the map…'), findsNothing);
    });

    testWidgets('shows provider attribution', (tester) async {
      final provider = WiredMemoryVectorTileProvider(
        tiles: {coordinate: vectorTileFixture()},
        cacheKey: 'attribution',
        attribution: const WiredMapAttributionData(text: '© Test maps'),
      );
      await pumpMapApp(tester, subject(provider));

      expect(find.text('© Test maps'), findsOneWidget);
    });

    testWidgets('can hide provider attribution', (tester) async {
      final provider = WiredMemoryVectorTileProvider(
        tiles: {coordinate: vectorTileFixture()},
        cacheKey: 'hidden-attribution',
        attribution: const WiredMapAttributionData(text: '© Test maps'),
      );
      await pumpMapApp(
        tester,
        subject(provider, showAttribution: false),
      );

      expect(find.text('© Test maps'), findsNothing);
    });

    testWidgets('activates provider attribution', (tester) async {
      var taps = 0;
      final provider = WiredMemoryVectorTileProvider(
        tiles: {coordinate: vectorTileFixture()},
        cacheKey: 'tappable-attribution',
        attribution: const WiredMapAttributionData(text: '© Test maps'),
      );
      await pumpMapApp(
        tester,
        subject(provider, onAttributionTap: () => taps++),
      );

      await tester.tap(find.text('© Test maps'));

      expect(taps, 1);
    });

    testWidgets('places decoded labels in screen space', (tester) async {
      final semantics = tester.ensureSemantics();
      final provider = WiredMemoryVectorTileProvider(
        tiles: {
          coordinate: vectorTileFixture(
            layer: 'place',
            type: raw.VectorTile_GeomType.POINT,
            properties: const {'name': 'Testville'},
          ),
        },
        cacheKey: 'labels',
      );
      await pumpMapApp(tester, subject(provider));
      await tester.pumpAndSettle();

      expect(find.text('Testville'), findsOneWidget);
      expect(find.bySemanticsLabel('Testville'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('treats a missing vector tile as a completed empty tile', (
      tester,
    ) async {
      final provider = WiredMemoryVectorTileProvider(
        tiles: const {},
        cacheKey: 'empty',
      );
      await pumpMapApp(tester, subject(provider));
      await tester.pump();

      expect(find.text('Drawing the map…'), findsNothing);
    });

    testWidgets('discards a prepared tile after its provider is replaced', (
      tester,
    ) async {
      final staleProvider = _DeferredProvider();
      await pumpMapApp(tester, subject(staleProvider));
      final freshProvider = WiredMemoryVectorTileProvider(
        tiles: {
          coordinate: vectorTileFixture(
            layer: 'place',
            type: raw.VectorTile_GeomType.POINT,
            properties: const {'name': 'Fresh place'},
          ),
        },
        cacheKey: 'fresh',
      );

      await pumpMapApp(tester, subject(freshProvider));
      await tester.pumpAndSettle();
      staleProvider.completer.complete(
        vectorTileFixture(
          layer: 'place',
          type: raw.VectorTile_GeomType.POINT,
          properties: const {'name': 'Stale place'},
        ),
      );
      await tester.pump();

      expect(find.text('Fresh place'), findsOneWidget);
      expect(find.text('Stale place'), findsNothing);
    });

    testWidgets('ignores a tile that completes after the layer unmounts', (
      tester,
    ) async {
      final provider = _DeferredProvider();
      await pumpMapApp(tester, subject(provider));

      await pumpMapApp(tester, const SizedBox.shrink());
      provider.completer.complete(vectorTileFixture());
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('bounds concurrent tile requests', (tester) async {
      final provider = _ConcurrencyProvider();
      await pumpMapApp(
        tester,
        WiredMap(
          initialZoom: 1,
          maximumZoom: 1,
          showZoomControls: false,
          basemap: WiredVectorTileLayer(
            provider: provider,
            maximumConcurrentLoads: 2,
          ),
        ),
      );

      expect(provider.active, 2);
      expect(provider.maximumActive, 2);
      provider.completeOne();
      await tester.pump();

      expect(provider.maximumActive, 2);
      expect(provider.started, greaterThan(2));
      provider.completeAll();
      await tester.pump();
    });
  });
}

class _ImmediateOpenMapTilesSchema extends WiredOpenMapTilesSchema {
  const _ImmediateOpenMapTilesSchema();

  @override
  Future<WiredPreparedMapTile> prepareAsync(
    Uint8List bytes,
    WiredMapTileCoordinate coordinate,
  ) async => prepare(bytes, coordinate);
}

class _DeferredProvider extends WiredMapTileProvider {
  final Completer<Uint8List?> completer = Completer();

  @override
  String get cacheKey => 'deferred';

  @override
  int get minimumZoom => 0;

  @override
  int get maximumZoom => 0;

  @override
  WiredMapAttributionData get attribution =>
      const WiredMapAttributionData(text: '');

  @override
  Future<Uint8List?> load(WiredMapTileCoordinate coordinate) {
    return completer.future;
  }
}

class _ErrorProvider extends WiredMapTileProvider {
  @override
  String get cacheKey => 'error';

  @override
  int get minimumZoom => 0;

  @override
  int get maximumZoom => 0;

  @override
  WiredMapAttributionData get attribution =>
      const WiredMapAttributionData(text: '');

  @override
  Future<Uint8List?> load(WiredMapTileCoordinate coordinate) {
    return Future.error(StateError('tile failed'));
  }
}

class _ConcurrencyProvider extends WiredMapTileProvider {
  final List<Completer<Uint8List?>> _pending = [];
  int active = 0;
  int maximumActive = 0;
  int started = 0;

  @override
  String get cacheKey => 'concurrency';

  @override
  int get minimumZoom => 1;

  @override
  int get maximumZoom => 1;

  @override
  WiredMapAttributionData get attribution =>
      const WiredMapAttributionData(text: '');

  @override
  Future<Uint8List?> load(WiredMapTileCoordinate coordinate) async {
    started++;
    active++;
    maximumActive = active > maximumActive ? active : maximumActive;
    final completer = Completer<Uint8List?>();
    _pending.add(completer);
    try {
      return await completer.future;
    } finally {
      active--;
    }
  }

  void completeOne() {
    _pending.removeAt(0).complete(null);
  }

  void completeAll() {
    for (final completer in _pending) {
      completer.complete(null);
    }
    _pending.clear();
  }
}
