# skribble_maps

MapLibre maps with hand-drawn overlays for the [Skribble](https://pub.dev/packages/skribble) Flutter design system.

MapLibre renders the basemap. It loads vector tiles, places labels, draws roads and buildings, and handles map gestures. `skribble_maps` adds interactive Flutter pins, routes, areas, controls, and callouts above that map.

This split keeps the map readable and keeps cartography out of the application code. The application does not decode map polygons or roughen each downloaded tile.

## What it includes

- Official `maplibre_gl` renderer on Android, iOS, and web
- MapLibre style URLs, local styles, or raw style JSON
- Keyless OpenFreeMap Positron, Liberty, and Dark presets
- Flat Web Mercator camera synchronization for Flutter overlays
- Rounded sketch pins with pastel category fills, readable icons, and cream sticker edges
- Precise, round-capped routes and lightly hatched area annotations
- Hand-drawn zoom controls and optional attribution badges
- Direct access to the MapLibre controller for clustering, GeoJSON layers, PMTiles, and offline regions
- No Material or Cupertino imports in `skribble_maps`

## Install

```bash
dart pub add skribble skribble_maps
```

```dart
import 'package:skribble/skribble.dart';
import 'package:skribble_maps/skribble_maps.dart';
```

Place the map below a `WiredTheme` or `WiredMaterialApp`.

## Start with a global online map

`WiredMapStyle.paper` uses OpenFreeMap's keyless Positron style.

```dart
const WiredMap(
  initialCenter: LatLng(25.2048, 55.2708),
  initialZoom: 13,
)
```

MapLibre requests the visible tiles for Dubai in this example. Moving the map to another country requests that area's tiles. The app does not need a city extract or a separate polygon conversion step.

OpenFreeMap is useful for development and early products, but its public service has no availability guarantee. A production app can supply any compatible hosted or self-hosted style:

```dart
const WiredMap(
  style: WiredMapStyle(
    styleString: 'https://maps.example.com/style.json',
  ),
)
```

Changing the style does not change the overlay API.

## Add hand-drawn overlays

```dart
WiredMap(
  initialCenter: const LatLng(51.5242, -0.0778),
  initialZoom: 14,
  children: [
    WiredMapFeatureLayer(
      features: [
        WiredMapPolyline(
          points: const [
            LatLng(51.5228, -0.0810),
            LatLng(51.5242, -0.0778),
            LatLng(51.5260, -0.0740),
          ],
          color: const Color(0xFF66584B),
          strokeWidth: 4,
        ),
      ],
    ),
    WiredMapMarkerLayer(
      markers: [
        WiredMapMarker(
          point: const LatLng(51.5242, -0.0778),
          semanticLabel: 'Favourite cafe',
          onTap: selectCafe,
          child: const WiredMapPin(
            icon: WiredMapPinIcon.coffee,
            fillColor: Color(0xFFF1E9DB),
            inkColor: Color(0xFF37342F),
          ),
        ),
      ],
    ),
  ],
)
```

`WiredMapPin` uses a large hand-drawn place icon by default. Its typed icon set covers check-ins, cafes, markets, galleries, favourite places, and people. Pass `child` when the product needs a custom widget.

Pins default to category-specific pastel fills and dark brown ink on both light and dark maps. Seeded wobble in the icons and border, including a short retraced shoulder, keeps the ink hand-drawn without moving the anchor or flickering on rebuild. Explicit color overrides still take precedence. Routes follow the supplied coordinates exactly, independent of theme roughness; the polyline `seed` remains accepted for compatibility. Area annotations keep their rough outline with a lighter default hatch opacity of 22 percent.

## Camera and overlay alignment

Dragging to pan and pinching to zoom are enabled by default. `scrollGesturesEnabled` controls panning; `zoomGesturesEnabled` controls pinch, double-tap, and web wheel zoom. Use `onCameraChanged` to observe the camera and `onTap` to receive an unclaimed map coordinate.

Both `WiredMapMarker` and standalone `WiredMapPin` accept `onTap` and `onLongPress`. Set either callback to update your app's selected place ID. A completed hold fires the long-press callback without also firing a tap, and movement before recognition cancels the hold. Both actions are exposed to accessibility services. Configure these actions on the marker or its interactive child, rather than both.

Inside a mobile scroll view, use `gestureRecognizers: {Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new)}` when touches starting inside the map should pan or zoom it rather than scroll the parent. Import the recognizer types from `flutter/gestures.dart` and `Factory` from `flutter/foundation.dart`. The docs demos enable interaction after you choose to load a map.

Decorative features and empty space in `WiredMapFeatureLayer` pass touches through to the map. Only features with `onTap` claim their hit area.

`WiredMapController` mirrors MapLibre's center and zoom. `WiredMapMarkerLayer` and `WiredMapFeatureLayer` read that camera to position their Flutter content.

`WiredMap` disables pitch and rotation. Flat maps let the package use the same 512-pixel Web Mercator coordinate plane as MapLibre, which keeps overlays aligned while the user pans and zooms. Use MapLibre style layers instead of Flutter overlays when a product requires a tilted or rotating map.

```dart
final controller = WiredMapController(
  initialCenter: const LatLng(35.6595, 139.7005),
  initialZoom: 15,
);

await controller.animateTo(
  const LatLng(25.2048, 55.2708),
  zoom: 13,
);
```

## Large datasets and advanced MapLibre work

The default OpenFreeMap style already supplies real OpenStreetMap-derived cartography. To add your own API's places or check-ins, validate its JSON, build `LatLng(latitude, longitude)` values, and rebuild a `WiredMapMarkerLayer` with stable place keys. Pass decoded routing-service points to `WiredMapPolyline`; the library does not calculate directions. GeoJSON coordinates use the opposite order, `[longitude, latitude]`.

See the [real map data guide](../../docs/site/content/widgets/maps.md#connect-your-own-places-and-routes) for an HTTP loader, selected-marker rendering, coordinate conversion, loading and error handling, provider setup, and native GeoJSON updates.

Flutter widget markers work best for the small set of visible places that need custom interaction or animation. Put hundreds or thousands of points in a MapLibre GeoJSON symbol layer and enable MapLibre clustering. Reserve `WiredMapMarkerLayer` for selected items, search results, and active check-ins.

`onMapCreated` gives the app the official `MapLibreMapController`. Store it in persistent widget state and add sources and layers only after `onStyleLoaded`:

```dart
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

Declare `late MapLibreMapController nativeController` in persistent state and import it and `CircleLayerProperties` from `maplibre_gl`. Add that package to the consuming app if using its native APIs. Recreate sources and layers after a style change; update initialized sources with `setGeoJsonSource` rather than adding duplicate source IDs. Surface asynchronous errors in your app.

Use the [MapLibre Flutter documentation](https://maplibre.org/flutter-maplibre-gl/) for sources, style layers, clustering, PMTiles, and mobile offline regions. The map package does not copy those APIs.

## Current data and offline regions

Online freshness follows the tile provider's update schedule and HTTP cache headers. The map requests tiles for the current viewport, so a global app can move anywhere its provider covers.

Offline data is different. Android and iOS apps can use MapLibre offline regions for a chosen bounding box and zoom range. The app must decide when to download, expire, and refresh each region. Web browsers use their normal cache and do not have MapLibre's mobile offline-region API.

Open map data can avoid per-view license fees, but tile hosting, storage, and bandwidth still cost money at scale. OpenStreetMap attribution and the chosen provider's terms still apply.

Read the repository's [mapping research](../../docs/mapping-libraries-research.md) for the provider and maintenance tradeoffs.

## Scope

`skribble_maps` renders a MapLibre basemap and app-owned overlays. It does not provide geocoding, place search, routing, turn-by-turn navigation, or a tile-hosting service.

### Current location

Add `WiredMapLocationLayer(point: location, heading: trueNorthDegrees)` to `WiredMap.children`. The blue dot stays centered on the supplied coordinate. Choose `WiredMapHeadingStyle.wash`, `.hatching`, or `.washAndHatching` for the translucent direction fan. Null heading hides the fan. `WiredMapLocation` also works as a standalone preview. These widgets do not acquire device location; your app owns permissions and sensor subscriptions.
