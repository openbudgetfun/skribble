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
          key: const ValueKey('docs-map-online-toggle'),
          onPressed: () => online.value = !online.value,
          child: Text(online.value ? 'Close the map' : 'Load OpenFreeMap'),
        ),
        if (online.value) ...[
          const SizedBox(height: 16),
          const SizedBox(
            height: 300,
            child: WiredMap(
              key: ValueKey('docs-online-map'),
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

MapLibre requests the tiles visible around London. Panning to another area requests its tiles. There is no city-specific preprocessing step in the application. The embedded examples disable map scrolling so you can continue scrolling the document. Their zoom buttons remain available.

Use `onStyleLoaded` to react when the style and annotation managers are available. Use `onMapIdle` before capturing a screenshot: it waits for requested tiles, camera transitions, and fades to finish. Storybook's **Map ready** status follows this idle event and resets when the map moves or its city or palette changes.

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

Tap the café, market, or gallery pin below to try its selection feedback without loading a basemap. Select Show the route on a map to load a London example with a precise route, a hatched area, and a tappable café marker. The selected place is announced to screen readers.

```dart
// Live example: map-features
HookBuilder(
  builder: (context) {
    final online = useState(false);
    final selected = useState('Choose a pin, then explore the walking route.');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 24,
          runSpacing: 12,
          children: [
            WiredMapPin(
              key: const ValueKey('docs-map-pin-coffee'),
              icon: WiredMapPinIcon.coffee,
              semanticLabel: 'Favourite café',
              onTap: () => selected.value = 'Selected: Favourite café',
            ),
            WiredMapPin(
              key: const ValueKey('docs-map-pin-market'),
              icon: WiredMapPinIcon.market,
              semanticLabel: 'Weekend market',
              onTap: () => selected.value = 'Selected: Weekend market',
            ),
            WiredMapPin(
              key: const ValueKey('docs-map-pin-gallery'),
              icon: WiredMapPinIcon.gallery,
              semanticLabel: 'Local gallery',
              onTap: () => selected.value = 'Selected: Local gallery',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Semantics(
          liveRegion: true,
          child: Text(
            selected.value,
            key: const ValueKey('docs-map-selection'),
          ),
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
          SizedBox(
            height: 300,
            child: WiredMap(
              initialCenter: const LatLng(51.5242, -0.0778),
              initialZoom: 14,
              scrollGesturesEnabled: false,
              semanticLabel: 'Shoreditch walking route',
              children: [
                const WiredMapFeatureLayer(
                  semanticLabel: 'Walking route',
                  features: [
                    WiredMapPolygon(
                      points: [
                        LatLng(51.5256, -0.0798),
                        LatLng(51.5258, -0.0769),
                        LatLng(51.5245, -0.0765),
                        LatLng(51.5242, -0.0792),
                      ],
                    ),
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
                      point: const LatLng(51.5242, -0.0778),
                      semanticLabel: 'Favourite café',
                      onTap: () => selected.value = 'Selected: Favourite café',
                      child: const WiredMapPin(icon: WiredMapPinIcon.coffee),
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

Pins default to 52 by 64 logical pixels with a 28-pixel vector icon. A softly asymmetric ink contour, small pen accent, and cream sticker edge keep them distinct from the map. The built-in icon choices are `place`, `checkIn`, `coffee`, `market`, `gallery`, `favorite`, and `person`. Their icons use very little roughness so small details remain readable.

Each category has a pastel fill and dark brown ink by default, including on dark maps. Override `fillColor`, `inkColor`, or `iconColor` to match your app. Keep the glyph as well as the color so categories remain distinguishable without color vision. A pin's seed varies its shoulders while its bottom-center anchor stays fixed.

Roads and labels retain MapLibre's exact geometry. `WiredMapPolyline` also follows its supplied points exactly, with continuous round joins and caps. Theme roughness does not distort routes, and the existing polyline `seed` parameter is retained for compatibility without affecting the stroke. `WiredMapPolygon` keeps a sketch outline and light hatching for area annotations. Its default hatch opacity is 22 percent to leave underlying labels visible.

## Map widgets

The Storybook Maps page opens the same map package as a full-screen example. Switch between London, Dubai, and Tokyo, choose Paper or Night, and tap a pin to name the next stop. Changing cities clears the selection; changing the map style preserves it. The selection stays above the map so it cannot cover a pin or the zoom buttons. Controls wrap on narrow screens, and the page scrolls in landscape or with larger text to keep the map reachable. Routes are illustrative overlays rather than directions returned by a routing service.

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
