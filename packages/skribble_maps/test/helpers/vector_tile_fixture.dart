import 'dart:typed_data';

import 'package:vector_tile/raw/raw_vector_tile.dart' as raw;

Uint8List vectorTileFixture({
  String layer = 'water',
  raw.VectorTile_GeomType type = raw.VectorTile_GeomType.POLYGON,
  List<int>? geometry,
  Map<String, String> properties = const {},
}) {
  final keys = properties.keys.toList();
  final values = properties.values
      .map((value) => raw.VectorTile_Value(stringValue: value))
      .toList();
  final tags = <int>[];
  for (var index = 0; index < keys.length; index++) {
    tags
      ..add(index)
      ..add(index);
  }
  final defaultGeometry = switch (type) {
    raw.VectorTile_GeomType.POINT => const [9, 4096, 4096],
    raw.VectorTile_GeomType.LINESTRING => const [9, 0, 4096, 10, 8192, 0],
    raw.VectorTile_GeomType.POLYGON => const [
      9,
      0,
      0,
      26,
      8192,
      0,
      0,
      8192,
      8191,
      0,
      15,
    ],
    _ => const <int>[],
  };
  final tile = raw.VectorTile(
    layers: [
      raw.VectorTile_Layer(
        name: layer,
        version: 2,
        extent: 4096,
        keys: keys,
        values: values,
        features: [
          raw.VectorTile_Feature(
            tags: tags,
            type: type,
            geometry: geometry ?? defaultGeometry,
          ),
        ],
      ),
    ],
  );
  return Uint8List.fromList(tile.writeToBuffer());
}
