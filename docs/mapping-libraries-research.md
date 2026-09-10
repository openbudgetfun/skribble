# Open-source Flutter maps for Skribble

Research snapshot: 9 September 2026.

This document compares open-source Flutter map clients and open map-data delivery options for `skribble_maps`. Package versions and platform support can change after this date.

## Decision

Use the official [`maplibre_gl`](https://pub.dev/packages/maplibre_gl) package for the basemap on Android, iOS, and web. MapLibre draws the geographic data. Skribble draws app-owned pins, routes, selected areas, callouts, and controls above it.

Do not maintain the custom Skribble vector-tile renderer. The prototype proved that rough roads and buildings were possible, but it also made dense roads harder to read. It required Skribble to own tile decoding, source schemas, label placement, tile seams, cache behavior, offline updates, and render performance. Those responsibilities do not improve the check-in experience enough to justify the maintenance cost.

The production design rule is now simple:

```text
MapLibre: basemap, labels, roads, buildings, tiles, camera, cache
Skribble: pins, active routes, selected areas, callouts, controls
```

## Why the official MapLibre binding

[`maplibre_gl` 0.27.0](https://pub.dev/packages/maplibre_gl) is published by the MapLibre organization under BSD-3-Clause. It uses MapLibre Native on Android and iOS and MapLibre GL JS on web. Its current API includes vector and raster sources, MapLibre style layers, GeoJSON, clustering, PMTiles, and mobile offline regions. The [MapLibre Flutter documentation](https://maplibre.org/flutter-maplibre-gl/) has runnable web examples for the public APIs.

The package supports the three targets needed by the application and storybook. It also has more production history and organization ownership than the newer community rewrite.

The [`maplibre`](https://pub.dev/packages/maplibre) rewrite remains worth watching. Version 0.3.6 supports Android, iOS, web, and desktop targets and includes a Flutter widget marker layer. Its Windows and macOS backends still use WebViews, and the package has a shorter production record. Desktop support does not justify switching the core today.

## Current Flutter options

| Project                                                                         | License and targets                      | Strength                                                                                          | Reason not chosen                                                                      |
| ------------------------------------------------------------------------------- | ---------------------------------------- | ------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| [`maplibre_gl`](https://pub.dev/packages/maplibre_gl)                           | BSD-3-Clause; Android, iOS, web          | Maintained by MapLibre, mature source and layer APIs, PMTiles, clustering, mobile offline regions | Chosen                                                                                 |
| [`maplibre`](https://pub.dev/packages/maplibre)                                 | BSD-3-Clause; Android, iOS, web, desktop | Modern bindings and Flutter widget markers                                                        | Shorter production record; desktop backends are not equal to the mobile engines        |
| [`flutter_map`](https://pub.dev/packages/flutter_map)                           | BSD-3-Clause; all Flutter targets        | Pure Flutter, large plugin set, arbitrary widget markers                                          | Raster tiles are easy, but vector maps need another renderer and plugin stack          |
| [`flutter_map_vector_tiles`](https://pub.dev/packages/flutter_map_vector_tiles) | BSD-3-Clause; all Flutter targets        | Pure Flutter vector tiles and screen-space labels                                                 | Geometry painter is internal; Skribble cannot replace it through a supported API       |
| [`vector_tile_renderer`](https://pub.dev/packages/vector_tile_renderer)         | BSD-3-Clause; all Flutter targets        | MapLibre-style vector rendering to a Flutter canvas                                               | Public API does not accept replacement road or polygon painters                        |
| [`flutter_map_maplibre`](https://pub.dev/packages/flutter_map_maplibre)         | MIT                                      | Places MapLibre inside `flutter_map`                                                              | Adds a second camera and layer system without improving this product's chosen flat map |
| [`maplibre_flutter_gpu`](https://pub.dev/packages/maplibre_flutter_gpu)         | BSD-2-Clause; native desktop and mobile  | Flutter GPU map and widget synchronization                                                        | Beta, no web support, and requires Flutter GPU                                         |

The custom prototype used [`vector_tile`](https://pub.dev/packages/vector_tile) and [`pmtiles`](https://pub.dev/packages/pmtiles) directly. Both packages remain useful for teams building a renderer. `skribble_maps` no longer needs them because MapLibre already implements that work.

## How a global map works

The renderer, style, and tile provider are separate:

```text
user camera in Dubai
  -> MapLibre calculates visible tile addresses
  -> provider returns vector tiles, glyphs, and sprites
  -> MapLibre draws roads, buildings, water, and labels
  -> Skribble places app-owned overlays above the flat camera
```

The app does not generate a rough map for Dubai or any other city. It gives MapLibre a global style URL. MapLibre requests only the tiles needed for the current viewport and zoom level.

Online freshness follows the provider's publishing schedule and HTTP cache headers. The application receives updated map data when the provider publishes new tiles and the cached response expires.

## Open map-data options

### OpenFreeMap

[`OpenFreeMap`](https://openfreemap.org/) provides keyless MapLibre styles and global OpenStreetMap-derived vector tiles. Its repository states that the public service has no request or view limit and publishes a new planet build each week. The [quick-start guide](https://openfreemap.org/quick_start/) currently provides Positron, Bright, Liberty, Dark, Fiord, and 3D styles.

The public service has no service-level agreement. Its [terms](https://openfreemap.org/tos/) allow it to change, suspend, or stop the service. `WiredMapStyle.paper` uses OpenFreeMap Positron for examples and early development, but `WiredMapStyle` keeps the URL configurable.

### Protomaps and PMTiles

[`Protomaps`](https://protomaps.com/) publishes daily OpenStreetMap-derived basemap builds. [`PMTiles`](https://github.com/protomaps/PMTiles) stores a tile pyramid in one archive and serves it through HTTP range requests. This works with static object storage and MapLibre without a custom tile API.

The [Protomaps download guide](https://docs.protomaps.com/basemaps/downloads) estimates a zoom 0 through 15 planet archive at about 120 GB. A phone should download a bounded region, not the planet. Storage, HTTP requests, and bandwidth still cost money even when the map-data license has no per-view fee.

### OpenStreetMap public tile servers

OpenStreetMap data is open under ODbL, but the OpenStreetMap Foundation's public tile servers are not a production CDN. The [raster tile policy](https://operations.osmfoundation.org/policies/tiles/) and [vector tile policy](https://operations.osmfoundation.org/policies/vector/) require attribution and caching, restrict bulk or offline downloading, and permit blocking heavy clients.

`skribble_maps` does not configure those endpoints.

## Online and offline updates

For normal online use, MapLibre follows the style's URLs and cache headers. The app does not manage individual polygons or roads.

Android and iOS can use MapLibre [offline regions](https://maplibre.org/flutter-maplibre-gl/advanced/offline-regions/). An offline region specifies a geographic bounding box and zoom range. MapLibre downloads the required tiles, fonts, and sprites. The application still needs a product policy for download size, expiry, deletion, and refresh.

Web has no mobile offline-region API. Browser builds use the browser's network cache. A web product that promises offline maps needs a separate service-worker and storage design.

An offline region does not update when the provider publishes new data. The application must expire or redownload it.

## Design boundary

Basemap roads, boundaries, coastlines, buildings, and labels stay crisp. A muted MapLibre style can still use the Skribble palette, fonts, and hand-drawn sprite assets, but it should not distort geographic geometry.

Skribble roughness belongs where it communicates application state:

- a check-in pin;
- a selected search result;
- a walking route owned by the app;
- a saved or restricted area;
- a callout, cluster selection, or map control.

Pins use low-saturation fills and one ink color. Their category comes from a large rough vector icon. This is easier to scan than emoji, Unicode symbols, tiny icons, or a different loud color for every category.

## Overlay alignment and scale

MapLibre uses a 512-pixel Web Mercator world at zoom zero. `WiredMapController` mirrors that center and zoom so Flutter overlays can calculate the same flat screen coordinates.

`WiredMap` disables pitch and rotation. A tilted native map uses a perspective transform that a screen-space Flutter layer cannot reproduce with the package's simple projection. Products that need tilt, 3D buildings, or rotation should put the relevant data in MapLibre style layers.

Flutter widget pins are appropriate for a small set of visible, interactive places. Hundreds or thousands of points should use a MapLibre GeoJSON source, symbol layers, and clustering. A selected symbol can gain one `WiredMapPin` overlay.

On Android, `WiredMap` enables MapLibre's texture-backed view so Flutter content can compose above it. This costs more than the direct surface mode, but it is required for reliable native overlays.

## Engineering cost

These estimates assume one experienced Flutter engineer and a flat interactive map on Android, iOS, and web. They exclude search, geocoding, routing, navigation, satellite imagery, and terrain.

| Approach                           | First usable result | Production work                            | Ongoing responsibility                                              |
| ---------------------------------- | ------------------- | ------------------------------------------ | ------------------------------------------------------------------- |
| MapLibre with Skribble overlays    | 1 to 2 weeks        | 3 to 6 weeks                               | Style, provider, overlays, and platform integration                 |
| Custom Flutter vector renderer     | 8 to 16 weeks       | 6 to 12 months to approach mature behavior | Projection, labels, schemas, seams, caches, offline, and rendering  |
| `flutter_map` with raster tiles    | 2 to 5 days         | 1 to 3 weeks                               | Client is simple; custom raster generation and hosting are separate |
| `flutter_map` with a vector plugin | 2 to 4 weeks        | 1 to 2 months                              | Plugin behavior, styling, performance, and version alignment        |

The MapLibre path can still hit plugin or platform bugs. The difference is that those bugs belong to an active mapping project with documented APIs and many users. A custom renderer would make every cartographic defect a Skribble defect.

## Implementation result

`skribble_maps` now wraps `maplibre_gl` and exposes:

- `WiredMap` for the MapLibre view and Flutter overlay stack;
- `WiredMapController` for camera movement and flat projection;
- `WiredMapStyle` for OpenFreeMap presets or a custom MapLibre style;
- `WiredMapMarkerLayer` and `WiredMapPin` for foreground places;
- `WiredMapFeatureLayer` for app-owned routes and areas;
- `WiredMapZoomControls` and `WiredMapAttribution` for map chrome.

The package removed its direct vector-tile provider, PMTiles reader, schema adapters, label engine, and rough basemap painter. Advanced sources, clustering, PMTiles, and offline work use the official MapLibre controller and documentation rather than duplicate wrapper APIs.

## Remaining product decisions

Before launch, the application team still needs to choose:

- a production tile provider or a self-hosted PMTiles plan;
- the expected online update frequency;
- the maximum offline region size and refresh policy;
- a geocoder and place-search source if users search by name;
- a routing service if the product draws calculated routes;
- the MapLibre style and attribution text used in production.

These are application and infrastructure decisions. They do not require changes to the Skribble overlay widgets.
