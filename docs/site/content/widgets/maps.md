---
title: Maps
description: Render open vector map data as stable, hand-drawn geometry with markers, routes, offline PMTiles, and no proprietary map SDK.
---

# Maps

`skribble_maps` is a companion package for maps that should look drawn, not merely decorated with a paper texture. It decodes road, water, park, building, and boundary geometry from open vector tiles, then paints those shapes with a restrained version of Skribble's visual language.

The package owns its map viewport and rendering pipeline. It does not depend on a proprietary map SDK, `flutter_map`, or MapLibre. Its source imports neither Material nor Cupertino.

Treat this custom renderer as an illustrated-map option. For a global production app where minimizing map-engine maintenance matters more than wobbled basemap geometry, use MapLibre as the basemap and compose Wired markers, routes, and controls above it.

## Install

```bash
dart pub add skribble skribble_maps
```

```dart
import 'package:skribble/skribble.dart';
import 'package:skribble_maps/skribble_maps.dart';
```

## Start with an explicit online source

`WiredMap` has no basemap by default and causes no hidden network traffic. Add `WiredOpenFreeMapLayer` when you deliberately want the keyless public OpenFreeMap service:

```dart
const WiredMap(
  initialCenter: LatLng(51.5074, -0.1278),
  initialZoom: 13,
  basemap: WiredOpenFreeMapLayer(),
)
```

The public OpenFreeMap instance is useful for examples and development. It does not provide a service-level guarantee. Use a regional PMTiles archive or a vector-tile endpoint you control for a predictable production deployment.

## Compose a map

The map uses layers in ordinary Flutter paint order. Keep the basemap below application features and markers:

```dart
WiredMap(
  initialCenter: const LatLng(51.5242, -0.0778),
  initialZoom: 14,
  basemap: const WiredOpenFreeMapLayer(
    style: WiredMapStyle.paper,
  ),
  children: [
    WiredMapFeatureLayer(
      semanticLabel: 'Walking route',
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

Markers are real widgets. Their child can be a `WiredMapPin`, another Wired control, an animation, or an application-specific composition.

## Map widgets

| API                     | Purpose                                                           |
| ----------------------- | ----------------------------------------------------------------- |
| `WiredMap`              | Web Mercator viewport with pan, pinch, double-tap, and wheel zoom |
| `WiredMapController`    | Camera movement plus coordinate projection helpers                |
| `WiredVectorTileLayer`  | Decode and paint semantic MVT basemap geometry                    |
| `WiredOpenFreeMapLayer` | Explicit keyless OpenFreeMap setup with bounded memory caching    |
| `WiredMapMarkerLayer`   | Position arbitrary widgets at geographic coordinates              |
| `WiredMapPin`           | Seeded hand-drawn pin with interaction and semantics              |
| `WiredMapFeatureLayer`  | Draw tappable app-owned routes and polygons                       |
| `WiredMapAttribution`   | Visible hand-drawn provider attribution badge                     |
| `WiredMapZoomControls`  | Accessible hand-drawn zoom controls                               |

## Providers and schemas

The provider loads raw bytes. The schema adapter translates source-specific layer names into a small semantic vocabulary. The style decides how each role looks.

```text
provider bytes -> schema adapter -> semantic geometry -> rough painter
```

Included providers:

- `WiredNetworkVectorTileProvider` for an MVT URL template
- `WiredOpenFreeMapProvider` for OpenFreeMap's current TileJSON endpoint
- `WiredPmTilesVectorTileProvider` for a local or hosted PMTiles v3 archive
- `WiredMemoryVectorTileProvider` for fixtures and bundled small maps
- `WiredCachingTileProvider` for bounded byte caching and request coalescing

Included schemas:

- `WiredOpenMapTilesSchema` for OpenMapTiles layer names
- `WiredProtomapsSchema` for the Protomaps basemap schema

Create a `WiredMapSchemaAdapter` when your source uses different layer names or feature properties.

## Controlled and offline PMTiles

Open a regional vector archive before building its layer:

```dart
final provider = await WiredPmTilesVectorTileProvider.open(
  '/application-data/london.pmtiles',
  attribution: WiredMapAttributionData(
    text: '© Protomaps · © OpenStreetMap contributors',
    url: Uri.parse('https://www.openstreetmap.org/copyright'),
  ),
);

final basemap = WiredVectorTileLayer(
  provider: provider,
  schema: const WiredProtomapsSchema(),
  disposeProvider: true,
);
```

Native apps can use a local path or HTTP URL. Web apps use an HTTP URL served with CORS and byte-range support. The consuming app decides how an archive is downloaded, updated, stored, and licensed.

`open` accepts request headers or an `http.Client` for hosted archives. Use `WiredPmTilesVectorTileProvider.fromBytes` for data loaded from a Flutter asset. The provider also exposes the suggested center, center zoom, and geographic bounds stored in the archive.

## Styling and stable roughness

Use `WiredMapStyle.fromTheme` to follow `WiredTheme`, or start from the paper and night styles. A style assigns color, width, hatching, and roughness to semantic map roles instead of attempting to implement the full MapLibre style language.

Call `copyWith` to tune colors, roughness, hatching, and the zoom thresholds for buildings, paths, or road labels without rebuilding the complete style. `roadRoughnessFactor` reduces road displacement relative to other features, and `lineEchoOpacity` controls the faint second pencil pass.

The defaults keep the basemap quieter than product overlays. Roads use only a fraction of the general basemap roughness. Overzoom compensation prevents line widths, dash spacing, hatching, and jitter from growing each time the camera zooms beyond the provider's final tile level. App routes and polygons in `WiredMapFeatureLayer`, plus `WiredMapPin`, continue to use Skribble's normal rough engine.

Sketch noise is derived from global tile coordinates, feature role, pass, and style seed. Rebuilding or moving the camera does not reroll a road. Adjacent tiles use the same coordinate field at shared edges, reducing visible seams. Labels are placed in a separate screen-space pass so they stay upright and can be collision-filtered across tile boundaries.

## Loading, errors, and ownership

`WiredVectorTileLayer` exposes `loadingBuilder`, `errorBuilder`, and `onTileError`. Set `disposeProvider` when the layer owns the provider. The layer suppresses results from a replaced provider and bounds its prepared-tile cache. Built-in schemas prepare MVT data through Flutter's background compute path on native platforms and yield between tiles on web. Vector pictures are cached separately for fast pan and zoom, while `WiredCachingTileProvider` separately bounds raw bytes.

Provider attribution is shown by default. Supply `onAttributionTap` if the app can open the provider's attribution URL.

## Data is open, infrastructure is not automatically free

OpenStreetMap-derived data is available without a per-map-view license fee, but ODbL and attribution obligations still apply. The OpenStreetMap Foundation's public tile servers have separate usage policies and are not a general production CDN. This package does not configure those endpoints.

OpenFreeMap currently offers keyless public vector tiles, but its service can change or stop. PMTiles avoids a proprietary tile API, while storage, request, and bandwidth costs remain the application's responsibility.

See the [mapping library research](https://github.com/openbudgetfun/skribble/blob/main/docs/mapping-libraries-research.md) for the full comparison of Flutter renderers, licenses, data sources, and the recommendation to use MapLibre for a low-maintenance global production basemap.

## Deliberate limits

Version 1 does not include geocoding, routing, turn-by-turn navigation, satellite imagery, terrain, 3D rendering, arbitrary MapLibre style JSON, or a global offline dataset. Those concerns stay separate from the focused hand-drawn basemap and overlay API.
