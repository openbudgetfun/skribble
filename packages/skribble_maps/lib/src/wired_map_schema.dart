import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:skribble_maps/src/wired_map_provider.dart';
import 'package:vector_tile/vector_tile.dart' as mvt;

/// Semantic role assigned to decoded vector-tile geometry.
enum WiredMapFeatureKind {
  /// Broad land-cover polygons.
  land,

  /// Parks, forests, and other green areas.
  park,

  /// Lakes, oceans, and other water polygons.
  water,

  /// Rivers, canals, and streams.
  waterway,

  /// Buildings and building footprints.
  building,

  /// Administrative boundaries.
  boundary,

  /// Roads for motor vehicles.
  road,

  /// Rail and transit lines.
  rail,

  /// Paths, tracks, and pedestrian ways.
  path,

  /// A place or road label.
  label,
}

/// Geometry family used by a [WiredMapSemanticFeature].
enum WiredMapGeometryType {
  /// One or more points.
  point,

  /// One or more line strings.
  line,

  /// One or more polygon rings.
  polygon,
}

/// Decoded vector geometry normalized into one tile's 0-to-1 coordinate space.
@immutable
class WiredMapSemanticFeature {
  /// Creates a semantic feature.
  const WiredMapSemanticFeature({
    required this.kind,
    required this.geometryType,
    required this.parts,
    required this.seed,
    required this.sourceLayer,
    required this.properties,
    this.label,
  });

  /// Styling and painting role.
  final WiredMapFeatureKind kind;

  /// Geometry family.
  final WiredMapGeometryType geometryType;

  /// Geometry parts normalized into the tile's coordinate space.
  final List<List<Offset>> parts;

  /// Stable source-derived seed.
  final int seed;

  /// Original vector-tile layer name.
  final String sourceLayer;

  /// Decoded source properties.
  final Map<String, Object?> properties;

  /// Optional visible label.
  final String? label;
}

/// Fully prepared semantic content for one vector tile.
@immutable
class WiredPreparedMapTile {
  /// Creates prepared tile content.
  const WiredPreparedMapTile({
    required this.coordinate,
    required this.features,
  });

  /// Source tile coordinate.
  final WiredMapTileCoordinate coordinate;

  /// Features sorted into stable paint order.
  final List<WiredMapSemanticFeature> features;
}

/// Converts a source schema into Skribble's small semantic map vocabulary.
abstract class WiredMapSchemaAdapter {
  /// Allows constant source-schema adapters.
  const WiredMapSchemaAdapter();

  /// Stable adapter version included in prepared-tile cache identities.
  String get cacheKey;

  /// Decodes MVT [bytes] for [coordinate].
  WiredPreparedMapTile prepare(
    Uint8List bytes,
    WiredMapTileCoordinate coordinate,
  );

  /// Decodes and prepares one tile without blocking the calling frame.
  ///
  /// Custom adapters default to [prepare] on the current isolate. Built-in
  /// adapters use Flutter's background compute path on native platforms.
  Future<WiredPreparedMapTile> prepareAsync(
    Uint8List bytes,
    WiredMapTileCoordinate coordinate,
  ) async => prepare(bytes, coordinate);
}

/// Adapter for the documented OpenMapTiles layer schema.
class WiredOpenMapTilesSchema extends WiredMapSchemaAdapter {
  /// Creates an OpenMapTiles adapter.
  const WiredOpenMapTilesSchema({this.preferredLanguage = 'en'});

  /// Preferred suffix for localized names, such as `en` in `name:en`.
  final String preferredLanguage;

  @override
  String get cacheKey => 'openmaptiles-v1:$preferredLanguage';

  @override
  WiredPreparedMapTile prepare(
    Uint8List bytes,
    WiredMapTileCoordinate coordinate,
  ) {
    return _prepare(
      bytes,
      coordinate,
      classifyLayer: _classifyOpenMapTilesLayer,
      preferredLanguage: preferredLanguage,
    );
  }

  @override
  Future<WiredPreparedMapTile> prepareAsync(
    Uint8List bytes,
    WiredMapTileCoordinate coordinate,
  ) {
    return compute(
      _prepareOpenMapTiles,
      (
        bytes: bytes,
        z: coordinate.z,
        x: coordinate.x,
        y: coordinate.y,
        preferredLanguage: preferredLanguage,
      ),
      debugLabel: 'skribble_maps: OpenMapTiles ${coordinate.z}',
    );
  }
}

/// Adapter for the semantic layer names in Protomaps basemap archives.
class WiredProtomapsSchema extends WiredMapSchemaAdapter {
  /// Creates a Protomaps adapter.
  const WiredProtomapsSchema({this.preferredLanguage = 'en'});

  /// Preferred suffix for localized names.
  final String preferredLanguage;

  @override
  String get cacheKey => 'protomaps-v1:$preferredLanguage';

  @override
  WiredPreparedMapTile prepare(
    Uint8List bytes,
    WiredMapTileCoordinate coordinate,
  ) {
    return _prepare(
      bytes,
      coordinate,
      classifyLayer: _classifyProtomapsLayer,
      preferredLanguage: preferredLanguage,
    );
  }

  @override
  Future<WiredPreparedMapTile> prepareAsync(
    Uint8List bytes,
    WiredMapTileCoordinate coordinate,
  ) {
    return compute(
      _prepareProtomaps,
      (
        bytes: bytes,
        z: coordinate.z,
        x: coordinate.x,
        y: coordinate.y,
        preferredLanguage: preferredLanguage,
      ),
      debugLabel: 'skribble_maps: Protomaps ${coordinate.z}',
    );
  }
}

typedef _PrepareMessage = ({
  Uint8List bytes,
  int z,
  int x,
  int y,
  String preferredLanguage,
});

WiredPreparedMapTile _prepareOpenMapTiles(_PrepareMessage message) {
  return _prepare(
    message.bytes,
    WiredMapTileCoordinate(message.z, message.x, message.y),
    classifyLayer: _classifyOpenMapTilesLayer,
    preferredLanguage: message.preferredLanguage,
  );
}

WiredPreparedMapTile _prepareProtomaps(_PrepareMessage message) {
  return _prepare(
    message.bytes,
    WiredMapTileCoordinate(message.z, message.x, message.y),
    classifyLayer: _classifyProtomapsLayer,
    preferredLanguage: message.preferredLanguage,
  );
}

WiredMapFeatureKind? _classifyOpenMapTilesLayer(
  String layer,
  Map<String, Object?> properties,
) {
  return switch (layer) {
    'landcover' || 'landuse' =>
      _isGreen(properties)
          ? WiredMapFeatureKind.park
          : WiredMapFeatureKind.land,
    'park' => WiredMapFeatureKind.park,
    'water' => WiredMapFeatureKind.water,
    'waterway' => WiredMapFeatureKind.waterway,
    'building' => WiredMapFeatureKind.building,
    'boundary' => WiredMapFeatureKind.boundary,
    'transportation' => _transportationKind(properties),
    'place' ||
    'transportation_name' ||
    'water_name' => WiredMapFeatureKind.label,
    _ => null,
  };
}

WiredMapFeatureKind? _classifyProtomapsLayer(
  String layer,
  Map<String, Object?> properties,
) {
  return switch (layer) {
    'earth' || 'landuse' || 'landcover' =>
      _isGreen(properties)
          ? WiredMapFeatureKind.park
          : WiredMapFeatureKind.land,
    'water' => WiredMapFeatureKind.water,
    'waterway' => WiredMapFeatureKind.waterway,
    'buildings' => WiredMapFeatureKind.building,
    'boundaries' => WiredMapFeatureKind.boundary,
    'roads' => _transportationKind(properties),
    'places' || 'pois' => WiredMapFeatureKind.label,
    _ => null,
  };
}

WiredPreparedMapTile _prepare(
  Uint8List bytes,
  WiredMapTileCoordinate coordinate, {
  required WiredMapFeatureKind? Function(
    String layer,
    Map<String, Object?> properties,
  )
  classifyLayer,
  required String preferredLanguage,
}) {
  final tile = mvt.VectorTile.fromBytes(bytes: bytes);
  final output = <WiredMapSemanticFeature>[];
  for (final layer in tile.layers) {
    for (final feature in layer.features) {
      final properties = <String, Object?>{
        for (final entry in feature.decodeProperties().entries)
          entry.key: _dartValue(entry.value),
      };
      final kind = classifyLayer(layer.name, properties);
      if (kind == null) continue;
      final decoded = _decodeParts(feature, layer.extent);
      if (decoded == null || decoded.parts.isEmpty) continue;
      final label = kind == WiredMapFeatureKind.label
          ? _label(properties, preferredLanguage)
          : null;
      if (kind == WiredMapFeatureKind.label && label == null) continue;
      output.add(
        WiredMapSemanticFeature(
          kind: kind,
          geometryType: decoded.type,
          parts: decoded.parts,
          seed: _featureSeed(
            coordinate,
            layer.name,
            feature.id.toInt(),
            properties,
          ),
          sourceLayer: layer.name,
          properties: Map.unmodifiable(properties),
          label: label,
        ),
      );
    }
  }
  output.sort((a, b) => a.kind.index.compareTo(b.kind.index));
  return WiredPreparedMapTile(
    coordinate: coordinate,
    features: List.unmodifiable(output),
  );
}

_DecodedGeometry? _decodeParts(mvt.VectorTileFeature feature, int extent) {
  List<Offset> normalized(List<List<int>> points) => [
    for (final point in points)
      if (point.length >= 2) Offset(point[0] / extent, point[1] / extent),
  ];

  return switch (feature.type) {
    mvt.VectorTileGeomType.POINT => _DecodedGeometry(
      WiredMapGeometryType.point,
      [
        for (final point in feature.decodePoint()) normalized([point]),
      ],
    ),
    mvt.VectorTileGeomType.LINESTRING => _DecodedGeometry(
      WiredMapGeometryType.line,
      [for (final line in feature.decodeLineString()) normalized(line)],
    ),
    mvt.VectorTileGeomType.POLYGON => _DecodedGeometry(
      WiredMapGeometryType.polygon,
      [
        for (final polygon in feature.decodePolygon())
          for (final ring in polygon) normalized(ring),
      ],
    ),
    _ => null,
  };
}

Object? _dartValue(mvt.VectorTileValue value) {
  return value.dartStringValue ??
      value.dartDoubleValue ??
      value.dartIntValue?.toInt() ??
      value.dartBoolValue;
}

WiredMapFeatureKind _transportationKind(Map<String, Object?> properties) {
  final classification = properties['class'];
  if (classification == 'rail' || classification == 'transit') {
    return WiredMapFeatureKind.rail;
  }
  if (classification == 'path' ||
      classification == 'pedestrian' ||
      classification == 'track') {
    return WiredMapFeatureKind.path;
  }
  return WiredMapFeatureKind.road;
}

bool _isGreen(Map<String, Object?> properties) {
  return const {
    'wood',
    'forest',
    'grass',
    'farmland',
    'park',
    'cemetery',
    'pitch',
  }.contains(properties['class']);
}

String? _label(Map<String, Object?> properties, String language) {
  for (final key in ['name:$language', 'name_$language', 'name']) {
    final value = properties[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
  }
  return null;
}

int _featureSeed(
  WiredMapTileCoordinate coordinate,
  String layer,
  int id,
  Map<String, Object?> properties,
) {
  final stableIdentity = id != 0
      ? '$id'
      : '${properties['class']}:${properties['name']}:${properties['ref']}';
  var hash = 0x811C9DC5;
  final input =
      '${coordinate.z}/${coordinate.x}/${coordinate.y}:$layer:'
      '$stableIdentity';
  for (final unit in input.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0x7FFFFFFF;
  }
  return hash;
}

class _DecodedGeometry {
  const _DecodedGeometry(this.type, this.parts);

  final WiredMapGeometryType type;
  final List<List<Offset>> parts;
}
