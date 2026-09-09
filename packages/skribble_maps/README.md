# skribble_maps

Hand-drawn vector maps for Flutter, built as a companion to [`skribble`](https://pub.dev/packages/skribble).

`skribble_maps` owns its Web Mercator camera and vector geometry renderer. It does not wrap Google Maps, Mapbox, MapLibre, or `flutter_map`, and it does not make a network request until you provide a basemap. Roads, waterways, boundaries, and building outlines are decoded from MVT data and redrawn as stable, restrained geometry. App-owned pins, routes, and areas keep the stronger Skribble roughness.

This renderer is an illustrated-map option, not a replacement for a mature map engine in every product. For a global production application, especially one whose team does not want to maintain cartographic rendering and offline update logic, use MapLibre for the basemap and place Wired overlays above it. The [mapping research](../../docs/mapping-libraries-research.md) explains the trade-off.

## Features

- Widgets-only map viewport with pan, pinch, double-tap, and pointer-wheel zoom
- Direct Mapbox Vector Tile decoding
- OpenMapTiles and Protomaps semantic schema adapters
- Keyless OpenFreeMap provider for explicit examples and development
- Local or hosted PMTiles archives for controlled and offline delivery
- Bounded raw-byte, prepared-tile, and vector-picture caches
- Background MVT preparation on native platforms and cooperative web yielding
- Deterministic rough roads, paths, water, parks, buildings, and boundaries
- Screen-space labels with collision filtering
- Arbitrary Flutter widgets as geographic markers
- Hand-drawn pins, routes, polygons, zoom controls, and attribution
- No Material or Cupertino imports in the package

## Install

```bash
dart pub add skribble skribble_maps
```

```dart
import 'package:skribble/skribble.dart';
import 'package:skribble_maps/skribble_maps.dart';
```

Place the map below a `WiredTheme` or `WiredMaterialApp`.

## Keyless online map

OpenFreeMap is available as an explicit online source. It has no API key, but its public service is provided without an availability guarantee. Use it for examples and development, or point the provider at an instance you control.

```dart
const WiredMap(
  initialCenter: LatLng(51.5074, -0.1278),
  initialZoom: 13,
  basemap: WiredOpenFreeMapLayer(),
)
```

`WiredMap` intentionally has no network-backed default. Omitting `basemap` creates a fully interactive blank paper surface for app-owned geometry.

## Markers and app geometry

Markers stay as ordinary widgets, so they retain Flutter interaction, semantics, animation, and composition.

```dart
WiredMap(
  initialCenter: const LatLng(51.5242, -0.0778),
  initialZoom: 14,
  basemap: const WiredOpenFreeMapLayer(),
  children: [
    WiredMapFeatureLayer(
      features: [
        WiredMapPolyline(
          points: const [
            LatLng(51.5228, -0.0810),
            LatLng(51.5242, -0.0778),
            LatLng(51.5260, -0.0740),
          ],
          color: const Color(0xFFD95C45),
          strokeWidth: 4,
        ),
      ],
    ),
    WiredMapMarkerLayer(
      markers: [
        WiredMapMarker(
          point: const LatLng(51.5242, -0.0778),
          semanticLabel: 'Favourite café',
          onTap: selectCafe,
          child: const WiredMapPin(child: Text('☕')),
        ),
      ],
    ),
  ],
)
```

Use `WiredMapController.project` and `WiredMapController.camera.unproject` when an overlay needs to translate between coordinates and viewport pixels.

## Custom HTTP vector tiles

Any endpoint that serves uncompressed MVT bytes can be used through a URL template. The source must allow your application's traffic and, on web, return appropriate CORS headers.

```dart
final provider = WiredCachingTileProvider(
  source: WiredNetworkVectorTileProvider(
    urlTemplate: 'https://maps.example.com/{z}/{x}/{y}.pbf',
    attribution: WiredMapAttributionData(
      text: '© My map · © OpenStreetMap contributors',
      url: Uri.parse('https://www.openstreetmap.org/copyright'),
    ),
  ),
  maximumBytes: 32 * 1024 * 1024,
  disposeSource: true,
);

WiredMap(
  basemap: WiredVectorTileLayer(
    provider: provider,
    schema: const WiredOpenMapTilesSchema(),
    disposeProvider: true,
  ),
)
```

Use `WiredProtomapsSchema` for archives built with the Protomaps basemap schema. Implement `WiredMapSchemaAdapter` for another source schema.

## PMTiles and offline data

PMTiles stores a complete tile pyramid in one archive. A consuming app chooses the region, storage location, update policy, and attribution.

```dart
final provider = await WiredPmTilesVectorTileProvider.open(
  '/application-data/london.pmtiles',
  attribution: WiredMapAttributionData(
    text: '© Protomaps · © OpenStreetMap contributors',
    url: Uri.parse('https://www.openstreetmap.org/copyright'),
  ),
);

final layer = WiredVectorTileLayer(
  provider: provider,
  schema: const WiredProtomapsSchema(),
  disposeProvider: true,
);
```

Native platforms can open a local path or an HTTP URL. Browser builds use an HTTP URL whose server supports CORS and byte-range requests. Do not hotlink a Protomaps daily build in an application. Extract the region you need and host or distribute it through infrastructure you control.

Pass `headers` or an `http.Client` to `open` for an authenticated hosted archive. Use `WiredPmTilesVectorTileProvider.fromBytes` for archive bytes read from a Flutter asset. The provider exposes the center, center zoom, and bounds stored in the archive header.

## Styling

`WiredMapStyle.fromTheme` follows the nearest `WiredTheme`. Two ready-made styles are also provided:

```dart
const WiredOpenFreeMapLayer(style: WiredMapStyle.paper)
const WiredOpenFreeMapLayer(style: WiredMapStyle.night)
```

Use `copyWith` to tune colors, stroke width, roughness, seeds, hatching, or the zoom thresholds for buildings, paths, and road labels. `roadRoughnessFactor` keeps roads steadier than other basemap features, while `lineEchoOpacity` controls the faint offset pencil edge.

The defaults prioritize navigation clarity. Basemap roughness is lower than the normal Wired widget roughness, road displacement is reduced again, and the offset echo is faint. Overzoomed source tiles normalize line width, dash spacing, hatching, and displacement so zooming past the provider's maximum tile level does not magnify the effect. `WiredMapFeatureLayer` and `WiredMapPin` are independent of these basemap controls and remain more expressive.

The style is deliberately semantic rather than a MapLibre JSON interpreter. It covers the map roles used by a readable check-in basemap without importing the complexity of a general GIS styling engine.

## Data and attribution

The package code is open source, but map data has its own license and service terms. OpenStreetMap-derived data normally requires visible attribution and is subject to ODbL. OpenMapTiles schema and Protomaps artifacts have additional attribution guidance.

The public OpenStreetMap tile endpoints are not a free production CDN and must not be used for bulk or offline downloads. `skribble_maps` does not configure them. `WiredVectorTileLayer` shows provider attribution by default; do not hide it unless your data source permits that.

Read the repository's [`mapping-libraries-research.md`](../../docs/mapping-libraries-research.md) for the current production recommendation, ecosystem comparison, licenses, and operating tradeoffs.

## Scope

This package renders an interactive vector basemap and app-owned overlays. It does not provide geocoding, search, routing, turn-by-turn navigation, satellite imagery, terrain, 3D extrusion, or a global offline dataset.
