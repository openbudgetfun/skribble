---
title: Maps
description: Use a crisp MapLibre basemap with hand-drawn Skribble pins, routes, areas, and controls.
---

# Maps

`skribble_maps` combines MapLibre cartography with Skribble interaction design. MapLibre loads and renders the basemap. Skribble draws the app-owned overlays above it.

The package does not decode or roughen downloaded road and building geometry. MapLibre handles vector tiles, labels, source schemas, camera gestures, and cache behavior.

## Install

```bash
dart pub add skribble skribble_maps
```

```dart
// Static example: setup
import 'package:skribble/skribble.dart';
import 'package:skribble_maps/skribble_maps.dart';
```

## Create a map

The default paper style is OpenFreeMap Positron. It is global and does not need an API key. Select Load OpenFreeMap to start the live map. This explicitly loads the online renderer and basemap while leaving normal document scrolling available.

```dart
// Live example: map-online
HookBuilder(
  builder: (context) {
    final online = useState(false);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WiredButton(
          onPressed: () => online.value = !online.value,
          child: Text(online.value ? 'Close the map' : 'Load OpenFreeMap'),
        ),
        if (online.value) ...[
          const SizedBox(height: 16),
          const SizedBox(
            height: 300,
            child: WiredMap(
              initialCenter: LatLng(51.5074, -0.1278),
              initialZoom: 13,
              scrollGesturesEnabled: false,
            ),
          ),
        ],
      ],
    );
  },
)
```

MapLibre requests the tiles visible around Dubai. Panning to another area requests its tiles. There is no city-specific preprocessing step in the application.

Choose another included style or provide any MapLibre style URL, local style, or raw JSON:

```dart
// Static example: external-asset
const WiredMap(
  style: WiredMapStyle.liberty,
)

const WiredMap(
  style: WiredMapStyle(
    styleString: 'https://maps.example.com/style.json',
  ),
)
```

OpenFreeMap's public service has no availability guarantee. Keep the style configurable so a production app can move to a contracted provider or its own tile infrastructure without changing the map widgets.

## Draw pins and routes

```dart
// Live example: map-features
HookBuilder(
  builder: (context) {
    final online = useState(false);
    return Column(
      children: [
        const WiredMapPin(
          icon: WiredMapPinIcon.coffee,
          semanticLabel: 'Favourite café',
        ),
        const SizedBox(height: 16),
        WiredButton(
          onPressed: () => online.value = !online.value,
          child: Text(
            online.value ? 'Close the route' : 'Show the route on a map',
          ),
        ),
        if (online.value) ...[
          const SizedBox(height: 16),
          const SizedBox(
            height: 300,
            child: WiredMap(
              initialCenter: LatLng(51.5242, -0.0778),
              initialZoom: 14,
              scrollGesturesEnabled: false,
              children: [
                WiredMapFeatureLayer(
                  semanticLabel: 'Walking route',
                  features: [
                    WiredMapPolyline(
                      points: [
                        LatLng(51.5228, -0.0810),
                        LatLng(51.5242, -0.0778),
                        LatLng(51.5260, -0.0740),
                      ],
                      color: Color(0xffb2533d),
                      strokeWidth: 4,
                    ),
                  ],
                ),
                WiredMapMarkerLayer(
                  markers: [
                    WiredMapMarker(
                      point: LatLng(51.5242, -0.0778),
                      semanticLabel: 'Favourite café',
                      child: WiredMapPin(icon: WiredMapPinIcon.coffee),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  },
)
```

Pins default to 52 by 64 logical pixels with a 28-pixel rough vector icon. The built-in icon choices are `place`, `checkIn`, `coffee`, `market`, `gallery`, `favorite`, and `person`. Each icon uses the same Skribble rough drawing system as the pin outline.

Use low-saturation fills and one consistent ink color when several categories share a map. The glyph should carry the category. Color should support selection or status rather than make every category compete.

## Map widgets

| API                    | Purpose                                                    |
| ---------------------- | ---------------------------------------------------------- |
| `WiredMap`             | MapLibre basemap with Flutter overlays                     |
| `WiredMapController`   | Camera movement plus flat projection helpers               |
| `WiredMapStyle`        | MapLibre style string and attribution-button color         |
| `WiredMapMarkerLayer`  | Position a small set of Flutter widgets on the map         |
| `WiredMapPin`          | Interactive hand-drawn pin with typed rough category icons |
| `WiredMapFeatureLayer` | Draw tappable app-owned routes and polygons                |
| `WiredMapAttribution`  | Optional hand-drawn provider attribution badge             |
| `WiredMapZoomControls` | Accessible hand-drawn zoom controls                        |

## Why maps stay flat

`WiredMapController` mirrors MapLibre's center and zoom in the same 512-pixel Web Mercator coordinate plane. Flutter overlays use that camera to calculate their screen positions.

`WiredMap` disables map pitch and rotation because a native perspective transform would make those screen-space overlays drift. Applications that need tilt, rotation, terrain, or 3D content should render their data as MapLibre style layers instead.

## Large point collections

Use `WiredMapMarkerLayer` for selected places, active check-ins, search results, and other small interactive sets. Flutter widgets are expensive when a map contains hundreds or thousands of points.

For a large collection, add a GeoJSON source and clustered symbol layers through the native controller returned by `onMapCreated`. MapLibre then culls, clusters, and renders those points on the map engine. A selected symbol can still gain a `WiredMapPin` overlay.

```dart
// Static example: external-asset
WiredMap(
  onMapCreated: (controller) async {
    await controller.addGeoJsonSource('places', placesGeoJson);
  },
  onStyleLoaded: addPlaceLayers,
)
```

Use the [MapLibre Flutter guides](https://maplibre.org/flutter-maplibre-gl/) for GeoJSON, symbols, clusters, PMTiles, and offline regions.

## Global and offline data

The style's tile provider determines geographic coverage and update frequency. A global style requests only the tiles needed for the current viewport.

Android and iOS support MapLibre offline regions for a chosen bounding box and zoom range. The consuming app owns the download, expiry, and refresh policy. Web uses the browser cache and has no mobile offline-region API.

OpenStreetMap-derived data still requires attribution. Open data avoids a proprietary map-data license, but production tile hosting, storage, and bandwidth are separate costs.

See the [mapping library research](https://github.com/openbudgetfun/skribble/blob/main/docs/mapping-libraries-research.md) for the renderer and provider comparison.

## Deliberate limits

The package does not provide place search, geocoding, routing, turn-by-turn navigation, satellite imagery, or tile hosting. Those services have different data and operating requirements and stay outside the visual map package.
