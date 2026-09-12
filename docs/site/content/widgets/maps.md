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

The default paper style is OpenFreeMap Positron. These are real OpenStreetMap-derived streets, buildings, and labels, not a mock map. It is global and does not need an API key. Select Load OpenFreeMap to start the live map. Once loaded, drag and zoom inside the map; scroll the document outside it or close the map to resume reading.

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
              gestureRecognizers: {
                Factory<OneSequenceGestureRecognizer>(
                  EagerGestureRecognizer.new,
                ),
              },
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
              onLongPress: () => selected.value = 'Selected: Favourite café',
            ),
            WiredMapPin(
              key: const ValueKey('docs-map-pin-market'),
              icon: WiredMapPinIcon.market,
              semanticLabel: 'Weekend market',
              onTap: () => selected.value = 'Selected: Weekend market',
              onLongPress: () => selected.value = 'Selected: Weekend market',
            ),
            WiredMapPin(
              key: const ValueKey('docs-map-pin-gallery'),
              icon: WiredMapPinIcon.gallery,
              semanticLabel: 'Local gallery',
              onTap: () => selected.value = 'Selected: Local gallery',
              onLongPress: () => selected.value = 'Selected: Local gallery',
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
              gestureRecognizers: const {
                Factory<OneSequenceGestureRecognizer>(
                  EagerGestureRecognizer.new,
                ),
              },
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
                      onLongPress: () =>
                          selected.value = 'Selected: Favourite café',
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

Pins default to 52 by 64 logical pixels with a 28-pixel vector icon. Seeded pen wobble, a lightly retraced shoulder, and a cream sticker edge give the border a hand-drawn finish. The built-in icon choices are `place`, `checkIn`, `coffee`, `market`, `gallery`, `favorite`, and `person`. Their icons have a restrained wobble so small details remain readable. Rebuilding a pin with the same seed keeps its ink stable.

Each category has a pastel fill and dark brown ink by default, including on dark maps. Override `fillColor`, `inkColor`, or `iconColor` to match your app. Keep the glyph as well as the color so categories remain distinguishable without color vision. A pin's seed varies its shoulders while its bottom-center anchor stays fixed.

Roads and labels retain MapLibre's exact geometry. `WiredMapPolyline` also follows its supplied points exactly, with continuous round joins and caps. Theme roughness does not distort routes, and the existing polyline `seed` parameter is retained for compatibility without affecting the stroke. `WiredMapPolygon` keeps a sketch outline and light hatching for area annotations. Its default hatch opacity is 22 percent to leave underlying labels visible.

## Gestures and selection

| Interaction                            | Support                              | API                                                       |
| -------------------------------------- | ------------------------------------ | --------------------------------------------------------- |
| Drag to pan                            | Enabled by default on mobile and web | `scrollGesturesEnabled`                                   |
| Pinch to zoom                          | Enabled by default                   | `zoomGesturesEnabled`                                     |
| Double-tap and web wheel/trackpad zoom | Enabled by default                   | `zoomGesturesEnabled`                                     |
| Zoom buttons                           | Shown by default                     | `showZoomControls`                                        |
| Tap an unclaimed map coordinate        | Callback available                   | `WiredMap.onTap(LatLng)`                                  |
| Tap a pin                              | Callback available                   | `WiredMapMarker.onTap` or `WiredMapPin.onTap`             |
| Hold a pin to select it                | Callback available on mobile and web | `WiredMapMarker.onLongPress` or `WiredMapPin.onLongPress` |
| Observe pan or zoom                    | Callback available                   | `onCameraChanged(WiredMapCamera)`                         |

Selection belongs to your app. Both tap and long press can update the same selected place ID; a completed long press does not also fire the tap callback. Moving before the hold is recognized cancels selection. Standalone pins expose the same callbacks, and both actions are available to accessibility services. The live pin demo and Storybook support either tap or hold. Configure callbacks on the marker **or** its interactive child; nesting two gesture handlers makes them compete.

On Android and iOS, a map inside a scroll view competes with the page for drags. The live examples give gestures that start inside the map to its platform view:

```dart
// Static example: setup
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

WiredMap(
  gestureRecognizers: {
    Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
  },
)
```

The rest of the page still scrolls. Omit this recognizer when the parent should participate in gesture arbitration. `WiredMapFeatureLayer` passes touches through decorative features and empty space; only features with `onTap` claim their hit area. Other decorative overlays should use `IgnorePointer` so they do not cover the map's hit area. A press on a Flutter pin selects the pin; it does not move the pin's coordinates. Rotation and pitch remain disabled to keep Flutter overlays aligned.

## Connect your own places and routes

There are two independent data inputs. `WiredMapStyle.styleString` supplies the basemap and its tile sources. Your API supplies places, check-ins, boundaries, or routes to the Flutter overlay layers. Replacing your place data does not require replacing the basemap.

For a small set of interactive places, fetch your API's JSON in a repository or service, validate it, and convert coordinates into `LatLng(latitude, longitude)`. For example, an endpoint could return:

```json
[
  {
    "id": "cafe-1",
    "name": "Corner cafe",
    "latitude": 51.5242,
    "longitude": -0.0778
  }
]
```

Add `http` to your consuming app with `dart pub add http`. This loader accepts that specific schema and reports malformed data instead of placing a pin at an invented location:

```dart
// Static example: external-asset
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skribble_maps/skribble_maps.dart';

typedef MapPlace = ({String id, String name, LatLng point});

Future<List<MapPlace>> loadPlaces(http.Client client, Uri endpoint) async {
  final response = await client.get(endpoint).timeout(const Duration(seconds: 15));
  if (response.statusCode != 200) {
    throw StateError('Place request failed: ${response.statusCode}');
  }
  final Object? decoded = jsonDecode(response.body);
  if (decoded is! List<Object?>) {
    throw const FormatException('Expected a list of places');
  }
  final places = <MapPlace>[];
  for (final item in decoded) {
    if (item case {
      'id': final String id,
      'name': final String name,
      'latitude': final num latitude,
      'longitude': final num longitude,
    } when latitude.isFinite && longitude.isFinite &&
        latitude.abs() <= 90 && longitude.abs() <= 180) {
      places.add((
        id: id,
        name: name,
        point: LatLng(latitude.toDouble(), longitude.toDouble()),
      ));
    } else {
      throw const FormatException('Invalid place or coordinates');
    }
  }
  return places;
}
```

Keep the HTTP client and request outside `build`, close the client when its owner is disposed, and show loading, error/retry, and empty states. Keep stable, unique place IDs from your API. Once your state holds the loaded `places`, render them like this; `selectPlace` updates your application's selected ID:

```dart
// Static example: external-asset
WiredMapMarkerLayer(
  markers: [
    for (final place in places)
      WiredMapMarker(
        key: ValueKey(place.id),
        point: place.point,
        semanticLabel: place.name,
        onTap: () => selectPlace(place.id),
        onLongPress: () => selectPlace(place.id),
        child: WiredMapPin(
          icon: WiredMapPinIcon.place,
          fillColor: selectedId == place.id ? const Color(0xFFF3ABA6) : null,
        ),
      ),
  ],
)
```

Rebuild the marker list when the request or a realtime subscription produces new data. Use `onCameraChanged` to observe the viewport, but debounce requests and discard stale responses so panning does not start a request every frame. `onMapIdle` is another trigger when you only need updates after the map settles.

For routes, pass the routing service's decoded points to `WiredMapPolyline(points: routePoints)`. For boundaries, use `WiredMapPolygon(points: boundaryPoints)`. Skribble draws those supplied coordinates; it does not calculate directions. GeoJSON stores coordinates as **[longitude, latitude]**, the reverse of the `LatLng` constructor. Decode encoded polylines using the precision documented by your routing service before constructing the points.

For hosted basemaps, use a MapLibre **style JSON URL**, not a raster tile template, in `styleString`. Configure vector or raster tile URLs inside that style's `sources`. A custom provider may require an app-scoped public token; keep server credentials on your backend. Web requests for your API, style, tiles, sprites, and fonts must allow your app's origin through CORS. Mobile apps need network access and any provider-specific platform configuration. Location permission is only needed for device location, not for displaying supplied coordinates. Retain provider and OpenStreetMap attribution.

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
  onMapCreated: (controller) => nativeController = controller,
  onStyleLoaded: () async {
    await nativeController.addGeoJsonSource('places', placesGeoJson);
    await nativeController.addCircleLayer(
      'places',
      'place-dots',
      const CircleLayerProperties(circleRadius: 6, circleColor: '#B2533D'),
    );
  },
)
```

Import `MapLibreMapController` and `CircleLayerProperties` from `package:maplibre_gl/maplibre_gl.dart` in the consuming app. Declare `late MapLibreMapController nativeController` in the widget's persistent state; `onMapCreated` assigns it before the style-loaded callback. `placesGeoJson` is a validated GeoJSON FeatureCollection from your service. Create **both the source and its layers after the style loads**, and recreate them on every style reload. Update existing data with `nativeController.setGeoJsonSource('places', nextGeoJson)` after initialization rather than adding the same source again. Await these operations and surface loading failures in your app. Add clustering through MapLibre's source options when the dataset requires it.

Use the [MapLibre Flutter guides](https://maplibre.org/flutter-maplibre-gl/) for GeoJSON, symbols, clusters, PMTiles, and offline regions.

## Global and offline data

The style's tile provider determines geographic coverage and update frequency. A global style requests only the tiles needed for the current viewport.

Android and iOS support MapLibre offline regions for a chosen bounding box and zoom range. The consuming app owns the download, expiry, and refresh policy. Web uses the browser cache and has no mobile offline-region API.

OpenStreetMap-derived data still requires attribution. Open data avoids a proprietary map-data license, but production tile hosting, storage, and bandwidth are separate costs.

See the [mapping library research](https://github.com/openbudgetfun/skribble/blob/main/docs/mapping-libraries-research.md) for the renderer and provider comparison.

## Deliberate limits

The package does not provide place search, geocoding, routing, turn-by-turn navigation, satellite imagery, or tile hosting. Those services have different data and operating requirements and stay outside the visual map package.

## Current location and facing direction

```dart
// Live example: map-location
HookBuilder(
  builder: (context) {
    final heading = useState<double?>(35);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Simulated location · compare direction ink'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final style in WiredMapHeadingStyle.values)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 180,
                    child: Text(
                      switch (style) {
                        WiredMapHeadingStyle.wash => 'Blue wash',
                        WiredMapHeadingStyle.hatching => 'Pencil hatching',
                        WiredMapHeadingStyle.washAndHatching => 'Wash + pencil',
                      },
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final dark in [false, true])
                    SizedBox(
                      width: 180,
                      height: 150,
                      child: ColoredBox(
                        color: dark
                            ? const Color(0xFF272E32)
                            : const Color(0xFFF6F2E9),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned.fill(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  for (var i = 0; i < 4; i++)
                                    Container(
                                      height: 5,
                                      color: dark
                                          ? const Color(0xFF42494D)
                                          : const Color(0xFFE2DCCF),
                                    ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 35,
                              right: 12,
                              child: Text(
                                'Park lane',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: dark
                                      ? const Color(0xFFD6DBDC)
                                      : const Color(0xFF666052),
                                ),
                              ),
                            ),
                            WiredMapLocation(
                              heading: heading.value,
                              headingStyle: style,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            WiredButton(
              onPressed: () =>
                  heading.value = ((heading.value ?? 0) + 45) % 360,
              child: const Text('Turn 45°'),
            ),
            WiredButton(
              onPressed: () =>
                  heading.value = heading.value == null ? 35 : null,
              child: Text(
                heading.value == null ? 'Restore heading' : 'Hide heading',
              ),
            ),
          ],
        ),
      ],
    );
  },
)
```

`WiredMapLocation` draws a blue dot with an irregular outline and a white rim. The fan uses translucent ink so streets and labels remain visible. Compare `wash`, `hatching`, and `washAndHatching` above on light and dark backgrounds. The dot stays fixed while the fan rotates. Its shape stays stable on rebuild.

Place `WiredMapLocationLayer` in `WiredMap.children` to anchor the dot to a coordinate. The indicator stays the same screen size while zooming, and pointer events pass through to the map and any controls underneath.

```dart
// Static example: setup
WiredMap(
  initialCenter: const LatLng(51.5242, -0.0778),
  initialZoom: 15,
  children: const [
    WiredMapLocationLayer(
      point: LatLng(51.5242, -0.0778),
      heading: 35,
      headingStyle: WiredMapHeadingStyle.washAndHatching,
    ),
  ],
)
```

These are simulated coordinates. Your app owns location permission, sensor subscriptions, and unavailable or stale fixes. Remove the layer when there is no usable fix. Pass `heading: null` when orientation is unavailable; this hides the fan without implying north. Heading is clockwise degrees from true north, not direction of travel. The map is north-up, with rotation disabled. The fan is a visual facing cue, not a measured GPS or compass accuracy region.

Both widgets accept a localizable `semanticLabel`, a stable `seed`, an ink `color`, and a square `size` in logical pixels. The default extent is 128, with a dot diameter of approximately 21. Heading updates apply immediately; apps can filter noisy sensor input before rebuilding. No animation or sensor runs inside the component.

Storybook also places a simulated location between the first two route points in each city, using the combined wash and pencil treatment with a 35° heading. It does not read your device location.

The default heading treatment is `WiredMapHeadingStyle.washAndHatching`. The plain wash and pencil-only treatments remain available through `headingStyle` on both the standalone indicator and the geographic layer.
