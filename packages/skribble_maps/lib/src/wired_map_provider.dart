import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:pmtiles/pmtiles.dart' as pm;

/// Address of one vector tile in a zoom/x/y pyramid.
@immutable
class WiredMapTileCoordinate {
  /// Creates a tile coordinate.
  const WiredMapTileCoordinate(this.z, this.x, this.y)
    : assert(z >= 0, 'z cannot be negative'),
      assert(x >= 0, 'x cannot be negative'),
      assert(y >= 0, 'y cannot be negative');

  /// Tile zoom.
  final int z;

  /// Tile column.
  final int x;

  /// Tile row.
  final int y;

  @override
  bool operator ==(Object other) =>
      other is WiredMapTileCoordinate &&
      other.z == z &&
      other.x == x &&
      other.y == y;

  @override
  int get hashCode => Object.hash(z, x, y);

  @override
  String toString() => '$z/$x/$y';
}

/// Attribution required by a vector-tile source.
@immutable
class WiredMapAttributionData {
  /// Creates provider attribution.
  const WiredMapAttributionData({required this.text, this.url});

  /// Visible attribution text.
  final String text;

  /// Optional provider or copyright page.
  final Uri? url;
}

/// Byte source for vector tiles.
abstract class WiredMapTileProvider {
  /// Stable namespace used for cache keys.
  String get cacheKey;

  /// Smallest native tile zoom.
  int get minimumZoom;

  /// Largest native tile zoom.
  int get maximumZoom;

  /// Visible attribution required by this source.
  WiredMapAttributionData get attribution;

  /// Loads uncompressed MVT bytes, or null when the tile is absent.
  Future<Uint8List?> load(WiredMapTileCoordinate coordinate);

  /// Releases files, clients, and other owned resources.
  FutureOr<void> dispose() {}
}

/// A deterministic in-memory vector-tile provider for fixtures and bundles.
class WiredMemoryVectorTileProvider extends WiredMapTileProvider {
  /// Creates an in-memory provider.
  WiredMemoryVectorTileProvider({
    required this.tiles,
    required this.cacheKey,
    this.minimumZoom = 0,
    this.maximumZoom = 20,
    this.attribution = const WiredMapAttributionData(text: ''),
  });

  /// Tile bytes keyed by coordinate.
  final Map<WiredMapTileCoordinate, Uint8List> tiles;

  @override
  final String cacheKey;

  @override
  final int minimumZoom;

  @override
  final int maximumZoom;

  @override
  final WiredMapAttributionData attribution;

  @override
  Future<Uint8List?> load(WiredMapTileCoordinate coordinate) async {
    return tiles[coordinate];
  }
}

/// Loads MVT files from a URL template containing `{z}`, `{x}`, and `{y}`.
class WiredNetworkVectorTileProvider extends WiredMapTileProvider {
  /// Creates a network tile provider.
  WiredNetworkVectorTileProvider({
    required this.urlTemplate,
    required this.attribution,
    this.minimumZoom = 0,
    this.maximumZoom = 14,
    this.headers = const {},
    http.Client? client,
    String? cacheKey,
  }) : cacheKey = cacheKey ?? urlTemplate,
       _client = client ?? http.Client(),
       _ownsClient = client == null;

  /// URL template used for tile requests.
  final String urlTemplate;

  /// Headers sent with tile requests.
  final Map<String, String> headers;

  final http.Client _client;
  final bool _ownsClient;

  @override
  final String cacheKey;

  @override
  final int minimumZoom;

  @override
  final int maximumZoom;

  @override
  final WiredMapAttributionData attribution;

  @override
  Future<Uint8List?> load(WiredMapTileCoordinate coordinate) async {
    final url = urlTemplate
        .replaceAll('{z}', '${coordinate.z}')
        .replaceAll('{x}', '${coordinate.x}')
        .replaceAll('{y}', '${coordinate.y}');
    final response = await _client.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 204 || response.statusCode == 404) return null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
        'Tile ${coordinate.z}/${coordinate.x}/${coordinate.y} returned '
        'HTTP ${response.statusCode}',
        Uri.parse(url),
      );
    }
    return response.bodyBytes;
  }

  @override
  void dispose() {
    if (_ownsClient) _client.close();
  }
}

/// Reads OpenFreeMap's current TileJSON and then loads its OpenMapTiles data.
///
/// This provider requires no API key. It is intended for explicit examples
/// and development. For a controlled production or offline source, use
/// [WiredPmTilesVectorTileProvider].
class WiredOpenFreeMapProvider extends WiredMapTileProvider {
  /// Creates an OpenFreeMap provider.
  WiredOpenFreeMapProvider({
    Uri? tileJsonUri,
    this.headers = const {},
    http.Client? client,
  }) : tileJsonUri =
           tileJsonUri ?? Uri.parse('https://tiles.openfreemap.org/planet'),
       _client = client ?? http.Client(),
       _ownsClient = client == null;

  /// The public TileJSON endpoint.
  final Uri tileJsonUri;

  /// Headers sent to the TileJSON and tile endpoints.
  final Map<String, String> headers;

  final http.Client _client;
  final bool _ownsClient;
  Future<String>? _template;

  @override
  String get cacheKey => tileJsonUri.toString();

  @override
  int get minimumZoom => 0;

  @override
  int get maximumZoom => 14;

  @override
  WiredMapAttributionData get attribution => WiredMapAttributionData(
    text: 'OpenFreeMap · © OpenMapTiles · © OpenStreetMap contributors',
    url: Uri.parse('https://openfreemap.org/'),
  );

  @override
  Future<Uint8List?> load(WiredMapTileCoordinate coordinate) async {
    final template = await (_template ??= _loadTemplate());
    final url = template
        .replaceAll('{z}', '${coordinate.z}')
        .replaceAll('{x}', '${coordinate.x}')
        .replaceAll('{y}', '${coordinate.y}');
    final response = await _client.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 204 || response.statusCode == 404) return null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
        'OpenFreeMap tile $coordinate returned HTTP ${response.statusCode}',
        Uri.parse(url),
      );
    }
    return response.bodyBytes;
  }

  Future<String> _loadTemplate() async {
    final response = await _client.get(tileJsonUri, headers: headers);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
        'OpenFreeMap TileJSON returned HTTP ${response.statusCode}',
        tileJsonUri,
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('OpenFreeMap TileJSON must be an object');
    }
    final tiles = decoded['tiles'];
    if (tiles is! List || tiles.isEmpty || tiles.first is! String) {
      throw const FormatException('OpenFreeMap TileJSON has no tile template');
    }
    return tiles.first as String;
  }

  @override
  void dispose() {
    if (_ownsClient) _client.close();
  }
}

/// Reads vector tiles from a local or HTTP PMTiles v3 archive.
class WiredPmTilesVectorTileProvider extends WiredMapTileProvider {
  WiredPmTilesVectorTileProvider._({
    required pm.PmTilesArchive archive,
    required this.cacheKey,
    required this.attribution,
  }) : _archive = archive,
       minimumZoom = archive.minZoom,
       maximumZoom = archive.maxZoom;

  /// Opens [pathOrUrl] as a vector PMTiles archive.
  static Future<WiredPmTilesVectorTileProvider> open(
    String pathOrUrl, {
    required WiredMapAttributionData attribution,
    Map<String, String>? headers,
    http.Client? client,
    bool strict = false,
  }) async {
    final isNetwork = pathOrUrl.startsWith('http://') ||
        pathOrUrl.startsWith('https://');
    final archive = isNetwork
        ? await pm.PmTilesArchive.fromUri(
            Uri.parse(pathOrUrl),
            headers: headers,
            client: client,
            strict: strict,
          )
        : await pm.PmTilesArchive.from(pathOrUrl, strict: strict);
    return _validated(
      archive,
      cacheKey: 'pmtiles:$pathOrUrl',
      attribution: attribution,
    );
  }

  /// Opens in-memory PMTiles [bytes], including bytes loaded from an asset.
  static Future<WiredPmTilesVectorTileProvider> fromBytes(
    List<int> bytes, {
    required WiredMapAttributionData attribution,
    String cacheKey = 'pmtiles:memory',
    bool strict = false,
  }) async {
    final archive = await pm.PmTilesArchive.fromBytes(bytes, strict: strict);
    return _validated(
      archive,
      cacheKey: cacheKey,
      attribution: attribution,
    );
  }

  static Future<WiredPmTilesVectorTileProvider> _validated(
    pm.PmTilesArchive archive, {
    required String cacheKey,
    required WiredMapAttributionData attribution,
  }) async {
    if (archive.tileType != pm.TileType.mvt) {
      await archive.close();
      throw ArgumentError.value(
        archive.tileType,
        'archive',
        'The PMTiles archive must contain MVT vector tiles',
      );
    }
    return WiredPmTilesVectorTileProvider._(
      archive: archive,
      cacheKey: cacheKey,
      attribution: attribution,
    );
  }

  final pm.PmTilesArchive _archive;

  @override
  final String cacheKey;

  @override
  final int minimumZoom;

  @override
  final int maximumZoom;

  @override
  final WiredMapAttributionData attribution;

  /// Suggested initial center stored in the archive header.
  LatLng get center => _archive.centerPosition;

  /// Suggested initial zoom stored in the archive header.
  int get centerZoom => _archive.centerZoom;

  /// South-west bound stored in the archive header.
  LatLng get minimumPosition => _archive.minPosition;

  /// North-east bound stored in the archive header.
  LatLng get maximumPosition => _archive.maxPosition;

  @override
  Future<Uint8List?> load(WiredMapTileCoordinate coordinate) async {
    final id = pm.ZXY(coordinate.z, coordinate.x, coordinate.y).toTileId();
    try {
      final tile = await _archive.tile(id);
      return Uint8List.fromList(tile.bytes());
    } on pm.TileNotFoundException {
      return null;
    }
  }

  @override
  Future<void> dispose() => _archive.close();
}

/// Adds a bounded in-memory byte cache and request coalescing to a provider.
class WiredCachingTileProvider extends WiredMapTileProvider {
  /// Creates a caching provider.
  WiredCachingTileProvider({
    required this.source,
    this.maximumBytes = 24 * 1024 * 1024,
    this.disposeSource = false,
  }) : assert(maximumBytes >= 0, 'maximumBytes cannot be negative');

  /// Wrapped source.
  final WiredMapTileProvider source;

  /// Maximum bytes retained in memory.
  final int maximumBytes;

  /// Whether [dispose] also disposes [source].
  final bool disposeSource;

  final LinkedHashMap<WiredMapTileCoordinate, Uint8List> _cache =
      LinkedHashMap();
  final Map<WiredMapTileCoordinate, Future<Uint8List?>> _inFlight = {};
  int _bytes = 0;

  /// Number of bytes currently retained.
  int get cachedBytes => _bytes;

  @override
  String get cacheKey => source.cacheKey;

  @override
  int get minimumZoom => source.minimumZoom;

  @override
  int get maximumZoom => source.maximumZoom;

  @override
  WiredMapAttributionData get attribution => source.attribution;

  @override
  Future<Uint8List?> load(WiredMapTileCoordinate coordinate) {
    final cached = _cache.remove(coordinate);
    if (cached != null) {
      _cache[coordinate] = cached;
      return Future.value(cached);
    }
    return _inFlight.putIfAbsent(coordinate, () => _load(coordinate));
  }

  Future<Uint8List?> _load(WiredMapTileCoordinate coordinate) async {
    try {
      final bytes = await source.load(coordinate);
      if (bytes != null && maximumBytes > 0 && bytes.length <= maximumBytes) {
        _cache[coordinate] = bytes;
        _bytes += bytes.length;
        while (_bytes > maximumBytes && _cache.isNotEmpty) {
          final oldest = _cache.keys.first;
          _bytes -= _cache.remove(oldest)!.length;
        }
      }
      return bytes;
    } finally {
      _inFlight.remove(coordinate)?.ignore();
    }
  }

  /// Clears cached tile bytes.
  void clear() {
    _cache.clear();
    _bytes = 0;
  }

  @override
  FutureOr<void> dispose() {
    clear();
    if (disposeSource) return source.dispose();
  }
}
