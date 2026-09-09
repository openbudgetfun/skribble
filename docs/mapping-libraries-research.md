# Hand-drawn maps for Skribble

Research snapshot: 9 September 2026.

This document evaluates open-source Flutter map clients, vector-tile renderers, and data delivery options for a new `skribble_maps` package. It uses package documentation, source repositories, licenses, and official data-provider policies. Package versions and platform support are a point-in-time snapshot, not a promise about future releases.

## Updated recommendation for a global product

Use a MapLibre renderer for the production basemap. Keep the custom `skribble_maps` renderer as an optional illustrated-map mode and as a useful prototype, not as the only map engine for a worldwide application.

For Android, iOS, and web, the current first choice is the official [`maplibre_gl`](https://pub.dev/packages/maplibre_gl) package. Version 0.27.0 is actively maintained by the MapLibre organization, supports vector and raster sources, PMTiles, style layers, and mobile offline regions, and leaves the difficult map rendering work in MapLibre Native or MapLibre GL JS ([project README](https://github.com/maplibre/flutter-maplibre-gl)). The newer [`maplibre`](https://pub.dev/packages/maplibre) rewrite is promising and adds desktop support, but has a shorter production history. Evaluate it separately if desktop support becomes a requirement.

Apply the Skribble design through one restrained MapLibre style, hand-drawn sprites and glyphs, and Flutter overlays above the map. The style can make the basemap feel illustrated without changing road geometry. Keep stronger roughness for pins, selected areas, routes, and other app-owned features. This gives up true basemap vertex wobble, but it removes most of the cartographic, label, cache, and cross-platform renderer code from the application's maintenance burden.

OpenFreeMap is the lowest-work online source for development and an early product: its public instance is keyless, has no published request limit, and currently updates the full planet weekly ([OpenFreeMap README](https://github.com/hyperknot/openfreemap/blob/main/README.md)). Its terms provide no warranty and allow the service to change or stop ([terms](https://openfreemap.org/tos/)), so keep the source URL configurable. For more control without a tile server, copy a Protomaps build or regional extract to object storage and serve it as versioned PMTiles. Protomaps publishes daily builds, but storage and bandwidth still cost money ([download documentation](https://docs.protomaps.com/basemaps/downloads)).

This recommendation supersedes the original prototype decision below. The prototype proved that custom rough geometry is possible. It also made the cost clear: Skribble would own projection, tile selection, provider behavior, schema changes, geometry ordering, label placement, seams, caching, offline updates, and rendering performance.

### Relative engineering cost

These are planning estimates for one experienced Flutter engineer. They assume a flat interactive basemap on Android, iOS, and web, with custom markers and routes. They exclude search, routing, navigation, satellite imagery, and terrain.

| Approach                           | Initial usable result | Production hardening | Ongoing responsibility                                                  |
| ---------------------------------- | --------------------- | -------------------- | ----------------------------------------------------------------------- |
| Custom `skribble_maps` renderer    | 1–3 days to tune      | 8–16 engineer-weeks  | High: rendering, labels, schemas, seams, caches, offline updates        |
| MapLibre plus a Skribble style     | 1–2 weeks             | 3–6 weeks            | Low to moderate: style, provider configuration, overlays, platform bugs |
| `flutter_map` plus raster tiles    | 2–5 days              | 1–3 weeks            | Low in the client, but custom raster generation and hosting are extra   |
| `flutter_map` plus a vector plugin | 2–4 weeks             | 1–2 months           | Moderate: plugin behavior, performance, styling, and version alignment  |

Matching MapLibre's robustness with a custom renderer would be a six-to-twelve month project, and it would still need ongoing map-specific maintenance. That is not justified when the product only needs a distinctive visual treatment.

### How worldwide data reaches the map

The renderer and the data source are separate. A camera centered in Dubai follows the same path as one centered in London:

```text
camera and viewport
  -> visible z/x/y tile addresses
  -> vector tiles from OpenFreeMap or hosted PMTiles
  -> geometry decoded by the renderer
  -> one style applied at runtime
  -> application markers and routes drawn above the basemap
```

The application does not pre-render or roughen a separate map for each city. It downloads only the tiles needed for the current viewport. With MapLibre, MapLibre decodes and draws those tiles. With the custom renderer, Skribble decodes them and applies its roughness while recording the visible tile pictures.

Online freshness follows the provider's publication schedule and HTTP cache headers. OpenFreeMap currently publishes a weekly planet build. Protomaps publishes daily builds; its full zoom 0–15 planet archive is roughly 120 GB, so applications should use HTTP range requests or extract a bounded region rather than make a device download the world ([Protomaps downloads](https://docs.protomaps.com/basemaps/downloads)).

For offline use, MapLibre can download a bounding box and zoom range, including the tiles, fonts, and sprites, on Android and iOS. Web has no offline-region API. An offline pack is a cache with its own refresh policy; it does not update merely because the online provider published new data ([offline-region guide](https://maplibre.org/flutter-maplibre-gl/advanced/offline-regions/)).

## Original prototype recommendation

Build `skribble_maps` as a small, pure-Flutter Web Mercator viewport with its own semantic vector-tile renderer. Decode Mapbox Vector Tiles (MVT) directly with [`vector_tile`](https://pub.dev/packages/vector_tile), read local or hosted PMTiles archives with [`pmtiles`](https://pub.dev/packages/pmtiles), and draw the prepared geometry through Skribble painters using only `flutter/widgets.dart`, `flutter/painting.dart`, and `dart:ui`.

Use two data paths:

1. Use a regional Protomaps PMTiles archive for the offline and production path. A PMTiles archive is a single file that can be bundled, copied to application storage, or hosted on ordinary object storage with HTTP Range support. The format specification is CC0 and the reference implementations are BSD-3-Clause licensed ([PMTiles repository and license](https://github.com/protomaps/PMTiles)). Protomaps publishes daily basemap builds and regional extraction guidance, but discourages hotlinking its downloads; applications should copy the data they need to their own storage ([download documentation](https://docs.protomaps.com/basemaps/downloads)).
2. Offer OpenFreeMap as an explicit online example and development source, with visible attribution. Its public instance currently requires no key and publishes no request or view limit ([OpenFreeMap README](https://github.com/hyperknot/openfreemap/blob/main/README.md)), but its terms provide no warranty and allow the service to be changed or discontinued without notice ([terms of service](https://openfreemap.org/tos/)). It is not a contractual production backend and must not be used as an offline-download source.

Do not make an OpenStreetMap Foundation tile endpoint the package default. OpenStreetMap data is open, but the Foundation's public raster and vector tile services are capacity-limited, best-effort services. Their policies prohibit bulk downloading and offline prefetching, require attribution and caching, and permit blocking without notice ([raster tile policy](https://operations.osmfoundation.org/policies/tiles/), [vector tile policy](https://operations.osmfoundation.org/policies/vector/)).

This is more work than wrapping an existing map widget, but it is the only reviewed option that meets all three defining requirements at once:

- Skribble owns the road, boundary, water, and building painting algorithms.
- The public package remains aligned with Skribble's `flutter/widgets`-and-below direction.
- Map data can be bundled or self-hosted without a paid map API.

## What the earlier survey got right, and what needs correction

The supplied survey identified the important families of projects: `flutter_map`, MapLibre bindings, pure-Dart vector rendering, PMTiles, OpenFreeMap, and historical sketch-map styles. Its central observation is also sound: a map whose geometry is actually drawn with Skribble's rough engine is more distinctive than a conventional map with sketch icons and paper textures.

Several implementation claims need qualification:

- A renderer that accepts a `Canvas` does not necessarily let an application replace its geometry painter. `vector_tile_renderer` 6.1.0 exposes `Renderer.render(Canvas, TileSource, ...)`, but its supported constructor hooks concern themes, text, and logging. The line, fill, and symbol renderers are internal implementation types rather than exported extension points ([public `Renderer` API](https://pub.dev/documentation/vector_tile_renderer/latest/vector_tile_renderer/Renderer-class.html), [library source](https://github.com/greensopinion/dart-vector-tile-renderer/blob/main/lib/vector_tile_renderer.dart)). Replacing every road stroke would require a fork or imports from `src`, neither of which is a stable package API.
- `flutter_map_vector_tiles` has a modern pure-Flutter pipeline, but it rasterizes geometry through its own private `TileRasterizer`; its public layer accepts themes, providers, and cache configuration, not a feature-painter callback ([architecture](https://github.com/JonasGrunau/flutter-map-vector-tiles/blob/main/doc/ARCHITECTURE.md), [public exports](https://github.com/JonasGrunau/flutter-map-vector-tiles/blob/40d30333e8fa0fae8306147d03becb4fef0f84a6/lib/flutter_map_vector_tiles.dart), [rasterizer source](https://github.com/JonasGrunau/flutter-map-vector-tiles/blob/40d30333e8fa0fae8306147d03becb4fef0f84a6/lib/src/render/tile_rasterizer.dart)). It is a useful reference implementation, not a supported injection point for Skribble geometry.
- `vector_map_tiles` is not the best current starting point. Its latest stable release is 8.0.0 and depends on `flutter_map ^7.0.2`, while current `flutter_map` is 8.3.2 ([package page](https://pub.dev/packages/vector_map_tiles), [`flutter_map` package page](https://pub.dev/packages/flutter_map)). A 10.0.0 beta exists, but selecting an old stable stack or a beta does not solve the missing painter hook.
- `flutter_map` is "pure Flutter" in the sense that it does not embed a proprietary native map SDK. Version 8.3.2 nevertheless imports `package:flutter/material.dart` in core source, including the tile layer ([tagged tile-layer source](https://github.com/fleaflet/flutter_map/blob/v8.3.2/lib/src/layer/tile_layer/tile_layer.dart)). Depending on it would introduce transitive Material coupling into a package whose design target is `flutter/widgets` and below.
- OpenFreeMap's public instance says "no limits," but that is not a service-level guarantee. Its terms explicitly reserve the right to discontinue service and restrict automated data collection ([README](https://github.com/hyperknot/openfreemap/blob/main/README.md), [terms](https://openfreemap.org/tos/)).
- OpenMapTiles Pencil is prior art, not a current renderer. Its repository was archived on 7 May 2024 and contains an old Mapbox Studio Classic/CartoCSS project ([repository](https://github.com/openmaptiles/mapbox-studio-pencil.tm2)). Its style uses scanned pattern images and standard line/polygon geometry rather than a rough-geometry algorithm ([style source](https://github.com/openmaptiles/mapbox-studio-pencil.tm2/blob/master/style.mss)).

## Decision criteria

The renderer needs to satisfy requirements that ordinary map clients do not optimize for:

- **Geometry ownership:** roads, paths, boundaries, coastlines, and building outlines must be available before drawing so Skribble can resample, perturb, hatch, and stroke them.
- **Stable hand-drawn output:** panning, zooming, tile eviction, and rebuilds must not cause a road to change shape or shimmer.
- **Offline and self-hosted data:** the map must work from a local archive and must not require a metered proprietary map service.
- **Skribble compatibility:** new code cannot import Material or Cupertino, and markers should be normal Wired widgets.
- **Cross-platform operation:** mobile, desktop, and web should share the same public model even when storage and worker implementations differ.
- **Bounded scope:** version 1 should render the map needed by check-ins, not attempt to reproduce every MapLibre style expression or layer type.

## Current open-source Flutter options

### Comparison

| Project                                                                         | Snapshot                                       | Rendering model                                                                                                                                                                                                                                        | Can Skribble replace basemap geometry painting through a supported API?                                                                                       | Decision                                                                                                                                                                                                                                        |
| ------------------------------------------------------------------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`flutter_map`](https://pub.dev/packages/flutter_map)                           | 8.3.2, BSD-3-Clause, all six Flutter platforms | Pure-Flutter slippy-map viewport. Custom layers are widgets, and markers are arbitrary widgets ([custom-layer guide](https://docs.fleaflet.dev/plugins/create/layers), [marker guide](https://docs.fleaflet.dev/layers/marker-layer)).                 | **Only if Skribble supplies an entire custom layer.** Built-in polylines and polygons expose styles, not a replacement painter. It also has Material imports. | Good camera and gesture reference. Do not depend on it in the core package.                                                                                                                                                                     |
| [`flutter_map_vector_tiles`](https://pub.dev/packages/flutter_map_vector_tiles) | 2.8.1, BSD-3-Clause, all six platforms         | MVT decode and preparation off the UI thread on native, cooperative yielding on web, then cached raster images plus a screen-space label pass ([architecture](https://github.com/JonasGrunau/flutter-map-vector-tiles/blob/main/doc/ARCHITECTURE.md)). | **No.** Geometry rasterization is internal.                                                                                                                   | Best reference for cache, scheduling, and label architecture. Not the renderer base.                                                                                                                                                            |
| [`vector_tile_renderer`](https://pub.dev/packages/vector_tile_renderer)         | 6.1.0 stable, BSD-3-Clause, all six platforms  | Pure-Dart/Flutter MapLibre-style renderer that writes to a supplied Canvas. Version 7 is a Flutter GPU beta; the repository directs production users to version 6 ([repository](https://github.com/greensopinion/dart-vector-tile-renderer)).          | **No stable public hook.** Supplying the destination Canvas is not the same as supplying feature painters.                                                    | Useful behavior and style-expression reference. Forking its internals would create a maintenance burden.                                                                                                                                        |
| [`vector_map_tiles`](https://pub.dev/packages/vector_map_tiles)                 | 8.0.0 stable, BSD-3-Clause                     | `flutter_map` plugin over `vector_tile_renderer`.                                                                                                                                                                                                      | **No.** It inherits the renderer's fixed geometry pipeline.                                                                                                   | Do not select for new work; the stable dependency line targets `flutter_map` 7.                                                                                                                                                                 |
| [`maplibre_gl`](https://pub.dev/packages/maplibre_gl)                           | 0.27.0, BSD-3-Clause, Android/iOS/web          | Native MapLibre through platform views on mobile and MapLibre GL JS on web ([architecture](https://github.com/maplibre/flutter-maplibre-gl/blob/main/website/docs/concepts/architecture.md)).                                                          | **No.** Applications configure MapLibre styles and sources; Flutter widgets can sit above the map, not replace native feature drawing.                        | Mature option for a conventionally styled map, but it cannot produce Skribble-painted basemap geometry and has no desktop implementation.                                                                                                       |
| [`maplibre`](https://pub.dev/packages/maplibre)                                 | 0.3.6, BSD-3-Clause                            | Modern bindings: MapLibre Native on Android/iOS, MapLibre GL JS on web, with experimental WebView-backed Windows/macOS support recorded in the changelog ([package changelog](https://pub.dev/packages/maplibre/changelog)).                           | **No.** It exposes style-layer configuration, not decoded feature painting.                                                                                   | Better long-term binding than `maplibre_gl`, but the same geometry limitation applies. Desktop support is still described as experimental.                                                                                                      |
| [`flutter_map_maplibre`](https://pub.dev/packages/flutter_map_maplibre)         | 0.0.5, MIT                                     | Embeds a MapLibre-rendered basemap as a `flutter_map` layer.                                                                                                                                                                                           | **No.** The adapter joins two renderers; it does not expose MapLibre geometry.                                                                                | Adds integration cost without solving the defining requirement.                                                                                                                                                                                 |
| [`maplibre_flutter_gpu`](https://pub.dev/packages/maplibre_flutter_gpu)         | 0.0.6, BSD-2-Clause, beta                      | Experimental MapLibre renderer in Flutter GPU. Symbols can be built as Flutter widgets, and callbacks can record additional geographic GPU geometry.                                                                                                   | **Not for decoded basemap features.** Custom geometry callbacks add application geometry; they do not replace the package's MVT renderer.                     | Watch closely, but do not make it the 1.0 foundation. Flutter GPU itself remains an early preview without API or runtime guarantees ([Flutter GPU status](https://github.com/flutter/flutter/blob/master/docs/engine/impeller/Flutter-GPU.md)). |
| [`mapsforge_flutter`](https://pub.dev/packages/mapsforge_flutter)               | 4.0.0, LGPL-3.0, mobile and desktop            | Pure-Flutter offline renderer for Mapsforge `.map` files. It has explicit shape-painter classes ([shape-painter API](https://pub.dev/documentation/mapsforge_flutter_renderer/latest/shape_painter/)).                                                 | **Closer, but tied to a different format and renderer.** Custom work would still couple Skribble to Mapsforge internals and LGPL obligations.                 | Valuable architectural reference. Not a fit for an MVT/PMTiles package or web.                                                                                                                                                                  |

Other wrappers do not change the conclusion. [`flutter_osm_plugin`](https://pub.dev/packages/flutter_osm_plugin) delegates to platform/web map engines; [`goodmap`](https://pub.dev/packages/goodmap) builds components over `maplibre_gl`; [`generic_map`](https://pub.dev/packages/generic_map) abstracts several provider SDKs; and [`free_map`](https://pub.dev/packages/free_map) wraps `flutter_map` and warns that production applications need an appropriate tile provider. None gives a consumer ownership of decoded basemap geometry.

Platform badges also need careful reading. `maplibre_gl` currently requires Flutter 3.29 or later, Dart 3.7 or later, Android API 21 or later, iOS 13 or later, and WebGL 2 on web. It supports PMTiles across its three platforms, while its offline-region manager is limited to Android and iOS ([project README](https://github.com/maplibre/flutter-maplibre-gl/blob/main/README.md)). The newer `maplibre` package records Windows and macOS WebView support as experimental rather than equivalent to its Android, iOS, and web backends ([changelog](https://pub.dev/packages/maplibre/changelog)). The pure-Flutter renderers cover more targets, but web still changes the execution model: `flutter_map_vector_tiles` uses cooperative queue yielding rather than native isolate parallelism, has no persistent disk cache on web, and requires suitable CORS headers from network sources ([architecture](https://github.com/JonasGrunau/flutter-map-vector-tiles/blob/main/doc/ARCHITECTURE.md)).

### The actual extension boundary

There are three different meanings of “customizable,” and they should not be conflated:

1. **Style customization** changes colors, widths, joins, dashes, symbols, and patterns. The MapLibre style specification supports these properties but does not define an arbitrary geometry-processing callback ([layer specification](https://maplibre.org/maplibre-style-spec/layers/), [sprite specification](https://maplibre.org/maplibre-style-spec/sprite/)). This can create a pencil-themed map, but roads remain mathematically clean paths.
2. **Overlay customization** draws Flutter widgets or application-owned shapes above a basemap. `flutter_map` markers and `maplibre_flutter_gpu` symbol builders are good examples. This is enough for Wired pins and clusters, but it does not make the basemap hand-drawn.
3. **Geometry customization** hands decoded points, lines, and polygon rings to Skribble before rasterization. None of the reviewed maintained Flutter renderers exposes that as a supported, stable callback for all basemap features. A custom MVT renderer is therefore required for the intended visual result.

## Vector tile architecture

### What MVT provides

The MVT 2.1 specification stores named layers of features with point, line, or polygon command streams in tile-local integer coordinates. Feature identifiers are optional, and each layer declares its coordinate extent ([MVT 2.1 specification](https://github.com/mapbox/vector-tile-spec/blob/master/2.1/README.md)). The specification is royalty-free for implementations; its text is separately licensed under CC BY 3.0 ([specification license](https://github.com/mapbox/vector-tile-spec/blob/master/README.md)).

[`vector_tile`](https://pub.dev/packages/vector_tile) 4.0.0 is an MIT-licensed Dart MVT 2.1 decoder and encoder with on-demand geometry decoding. It is the appropriate low-level dependency because it yields the geometry without choosing how that geometry is drawn.

### Chosen package boundary

The public API should describe map concepts, not a particular host or schema:

```text
WiredMap
  WiredMapController / WiredMapCamera
  WiredVectorTileLayer
    WiredMapTileProvider
      WiredNetworkVectorTileProvider
      WiredPmTilesVectorTileProvider
      WiredMemoryVectorTileProvider
    WiredMapStyle
    WiredMapSchemaAdapter
  WiredMapMarkerLayer
    WiredMapMarker (ordinary Flutter/Wired widget)
  WiredMapAttribution
```

`WiredMapTileProvider` should return bytes and metadata for a tile coordinate. Provider metadata should include a stable cache namespace, minimum and maximum zoom, and attribution. Cancellation and stale-result suppression belong at this boundary because network, archive, and decode work finish asynchronously.

`WiredMapSchemaAdapter` should convert source-specific layer names and attributes into a small set of semantic roles such as water, land, park, building, boundary, road class, rail, path, and place label. Ship adapters for the OpenMapTiles schema and the Protomaps basemap schema. The OpenMapTiles schema defines named layers such as `building`, `water`, `landuse`, `transportation`, and `place` ([schema](https://openmaptiles.org/schema/)). A semantic layer prevents source schema details from leaking into every painter.

`WiredMapStyle` should be a typed Skribble style rather than a complete MapLibre JSON interpreter. A full style engine includes expressions, filters, symbol placement, sprites, fonts, and many layer types. Even mature Flutter renderers support only subsets; for example, `vector_tile_renderer` documents unsupported raster, circle, fill-extrusion, heatmap, hillshade, and sky layers ([package documentation](https://pub.dev/packages/vector_tile_renderer)). Version 1 needs a recognizable check-in basemap, not arbitrary third-party style compatibility.

### Rendering pipeline

The recommended pipeline is:

```text
camera -> visible integer tile coordinates -> provider bytes
       -> MVT decode/filter/simplify -> prepared semantic geometry
       -> deterministic rough paths -> per-tile picture cache
       -> composited basemap
       -> screen-space labels
       -> widget markers and controls
```

On native platforms, MVT decoding and feature filtering should run through worker isolates. `dart:ui` objects such as `Path`, `Picture`, and `Image` should be created and disposed on the UI/render side. On web, use a bounded, yielding decode queue so large tiles do not monopolize the event loop. This split follows the measured design used by `flutter_map_vector_tiles`, which performs decoding and preparation in isolates on native, yields on web, raster-caches geometry, and places labels in screen space ([architecture](https://github.com/JonasGrunau/flutter-map-vector-tiles/blob/main/doc/ARCHITECTURE.md)).

Cache keys should include source namespace, z/x/y coordinate, schema version, style fingerprint, sketch seed, and device-pixel-ratio bucket. Keep byte, prepared-geometry, and picture caches separate so a style change does not force a network read. Every resource with native memory must have explicit disposal and a bounded budget.

## Making rough geometry stable

The following points are design conclusions from the MVT format and Flutter rendering model, not claims made by the cited libraries.

### Deterministic strokes

Randomness must be spatial and deterministic. A line that changes whenever a widget rebuilds will shimmer, and a seed based only on a feature ID is insufficient because MVT feature IDs are optional. Derive the noise field from world coordinates, a style seed, the semantic layer, and stable source attributes when present.

For lines, resample in world space at a stable interval, then offset samples along the local normal with coherent noise. For polygon fills, keep the fill boundary stable and apply roughness to the visible outline or hatch pass. Perturbing neighboring polygon fills independently can reveal cracks.

### Tile boundaries

Convert tile-local coordinates to one global world-coordinate space before sampling the noise field. Prepare strokes with an overscan buffer and clip only for final painting. The same world point should therefore receive the same displacement in adjacent tiles.

This reduces seams but cannot guarantee that unrelated source tiles contain identical boundary vertices: MVT generation may simplify and clip geometry per tile. The MapLibre source specification also notes that vector features render only in the tile from which they originate and that wide effects can show tile-edge artifacts unless the source is generated with a sufficient buffer ([source specification](https://maplibre.org/maplibre-style-spec/sources/)).

### Zoom behavior

Use integer source tiles while the camera scales and translates the cached picture between zoom levels. Rebuild at a zoom threshold rather than continuously. Quantize sketch amplitude in screen or zoom bands so a road does not visibly re-roll during a pinch gesture. Simplify before producing doubled strokes or hatching because rough rendering multiplies segment and draw counts.

### Labels and markers

Render labels in a separate screen-space pass after basemap geometry. Keep text upright, perform collision detection across tile boundaries, and use the Skribble font rather than perturbing individual glyph outlines. `flutter_map_vector_tiles` uses the same broad separation to avoid per-tile label collisions ([architecture](https://github.com/JonasGrunau/flutter-map-vector-tiles/blob/main/doc/ARCHITECTURE.md)).

Markers should remain a widget layer. This permits `WiredMapMarker` content to be any Wired widget and lets check-in selection, semantics, focus, animation, and clustering evolve independently of the rasterized basemap. [`supercluster`](https://pub.dev/packages/supercluster) is an ISC-licensed, pure-Dart option if point counts later justify built-in clustering.

## Performance and platform risks

### Memory and rasterization

A 256 logical-pixel RGBA tile costs approximately `(256 × DPR)² × 4` bytes before overhead: 1 MiB at DPR 2 and 2.25 MiB at DPR 3. One large DPR 3 screenful plus overdraw can approach 80 MiB of GPU image memory. `flutter_map_vector_tiles` documents the same per-tile estimates and defaults to bounded decoded, disk, and GPU caches ([performance documentation](https://pub.dev/packages/flutter_map_vector_tiles)).

Start with cached prepared geometry and `ui.Picture` objects. Add per-tile `ui.Image` raster caching only after profiling representative phones and dense urban tiles. If images are used, cap by bytes rather than item count, dispose on eviction, and test application background/foreground transitions on iOS.

### UI-thread work

Rough double-strokes and hatching increase the number of path segments and paint passes. The renderer should:

- discard non-visible source layers and attributes before geometry decoding where possible;
- simplify for the current zoom before rough-path generation;
- prepare geometry outside the UI isolate;
- cap concurrent fetch/decode work and discard results from an obsolete camera generation;
- keep basemap painting in a repaint boundary separate from interactive markers;
- leave room for future debug counters covering queued tiles, decode time, cache bytes, and frame raster time.

### Web

Hosted PMTiles requires servers and CDNs to support byte-range requests and CORS. Protomaps documents HTTP Range as the basis of static hosting and provides cloud-storage configuration guidance ([PMTiles repository](https://github.com/protomaps/PMTiles), [cloud-storage documentation](https://docs.protomaps.com/pmtiles/cloud-storage)). Browser persistent storage should be an optional adapter rather than assumed by core. Local file and SQLite-backed MBTiles APIs do not transfer directly to web.

### Flutter GPU

`maplibre_flutter_gpu` is attractive because it shares Flutter's rendering context and can build symbols as widgets, but both it and Flutter GPU are still explicitly experimental. Flutter GPU requires Impeller and Native Assets and currently offers no API or runtime stability guarantee ([Flutter GPU documentation](https://github.com/flutter/flutter/blob/master/docs/engine/impeller/Flutter-GPU.md)). Its package documentation also records incomplete platform qualification and no web support ([package page](https://pub.dev/packages/maplibre_flutter_gpu)). Keep the renderer interface narrow enough that a future GPU backend can be added without changing the map, style, or provider models.

## Open data, offline use, and operating terms

“No paid mapping data” does not mean “no operating cost.” Hosting a PMTiles file still incurs object storage, egress, and HTTP request costs. Self-hosting tile generation also consumes significant storage and compute.

### OpenStreetMap data

OpenStreetMap data is licensed under ODbL 1.0. The OpenStreetMap Foundation's legal FAQ permits commercial and non-commercial use without a license fee, subject to attribution and database share-alike obligations; Produced Works may use separate terms, while the underlying OSM-derived database must remain available under ODbL when distributed ([legal FAQ](https://osmfoundation.org/wiki/Licence_and_Legal_FAQ), [attribution guidelines](https://osmfoundation.org/wiki/Licence/Attribution_Guidelines)). Product counsel should review obligations for any combined or modified database.

The data license does not grant unrestricted use of `tile.openstreetmap.org` or the Foundation's vector service. Those servers have separate operational policies, no SLA, mandatory identification and attribution rules, cache requirements, and prohibitions on bulk/offline downloading ([raster policy](https://operations.osmfoundation.org/policies/tiles/), [vector policy](https://operations.osmfoundation.org/policies/vector/)).

### OpenFreeMap

OpenFreeMap builds vector tiles from OpenStreetMap and other open sources and publishes its stack under open-source licenses. Its public service has no key or registration and advertises no request or view limit ([README](https://github.com/hyperknot/openfreemap/blob/main/README.md)). It also publishes weekly full-planet artifacts and self-hosting scripts.

Operational limits still matter:

- Service is provided as-is and can be suspended or discontinued without notice; automated data collection requires permission ([terms](https://openfreemap.org/tos/)).
- A full self-hosted instance needs substantial resources. The official guide currently calls for roughly 300 GB for hosting and recommends at least 500 GB SSD and 64 GB RAM for planet generation ([self-hosting guide](https://github.com/hyperknot/openfreemap/blob/main/docs/self_hosting.md)).
- The service does not supply search, geocoding, routing, satellite imagery, or custom datasets ([README](https://github.com/hyperknot/openfreemap/blob/main/README.md)). These are separate product concerns, not map-renderer features.
- Attribution depends on data, schema, style, fonts, and icons. The OpenFreeMap repository documents MIT code alongside OpenMapTiles, style, font, and icon licenses ([license inventory](https://github.com/hyperknot/openfreemap/blob/main/LICENSE.md)).

OpenFreeMap is therefore a good zero-sign-up interactive source for examples and development. Keep the URL injectable, show source-supplied attribution, honor caching, and provide a documented switch to a self-hosted endpoint.

### Protomaps and PMTiles

PMTiles packages tiled data into one archive addressed with HTTP Range requests. It removes the need for a custom tile API server and works equally well from a local file or static object storage ([format repository](https://github.com/protomaps/PMTiles)). The Dart [`pmtiles`](https://pub.dev/packages/pmtiles) package 2.2.0 reads vector or raster archives from files on Dart VM platforms and over HTTP on VM and browser platforms.

Protomaps basemap builds are a practical default dataset:

- Daily planet builds and regional extraction tools are available; the documentation estimates a full z0-z15 planet at about 120 GB ([downloads](https://docs.protomaps.com/basemaps/downloads)).
- Local city or country builds can complete in minutes, while a planet build is documented as an approximately two-hour job on a high-end machine with 64 GB RAM and 1 TB NVMe storage ([build documentation](https://docs.protomaps.com/basemaps/build)).
- Basemap code is BSD-3-Clause, its visual design is CC0, and generated tiles based on OSM are ODbL with visible OpenStreetMap attribution required ([basemaps repository](https://github.com/protomaps/basemaps)).

For true offline use, ship or download a deliberately bounded regional archive through an application-controlled workflow. Do not silently package a large geography in `skribble_maps`; the library should supply readers and examples, while the consuming application chooses and distributes data.

### OpenMapTiles schema

OpenFreeMap uses the OpenMapTiles schema. The schema is well documented and useful as an adapter target, but attribution is required when its schema or generated products are used. Its license file distinguishes BSD-3-Clause code, CC BY 4.0 design/schema attribution, and ODbL source-data obligations ([OpenMapTiles license](https://github.com/openmaptiles/openmaptiles/blob/master/LICENSE.md)). The package should generate a visible attribution widget from provider metadata rather than leaving attribution as an example-only concern.

### MBTiles and tile caches

[`mbtiles`](https://pub.dev/packages/mbtiles) 0.5.1 is a BSD-3-Clause SQLite reader for vector and raster MBTiles on native platforms. It does not support web, and asset databases must be copied to writable/local storage before opening. Add it later as an optional provider if users need existing MBTiles archives; PMTiles is the cleaner first cross-platform archive.

Avoid `flutter_map_tile_caching` in the core package. Its current release is GPL-3.0 licensed and its region-download features are not permission to prefetch from servers whose policies prohibit it ([package page](https://pub.dev/packages/flutter_map_tile_caching)). Also note that [`flutter_map_pmtiles`](https://pub.dev/documentation/flutter_map_pmtiles/latest/flutter_map_pmtiles/PmTilesTileProvider-class.html), despite its name, currently exposes a raster `TileProvider`; it is not a vector-renderer foundation.

## Hand-drawn map precedents

OpenMapTiles Pencil demonstrates that scanned paper textures, line patterns, handwritten labels, and sketch sprites can produce a coherent map. It is an archived Mapbox Studio Classic project, so it should be treated as a visual reference and source of licensing lessons, not imported as a style/runtime ([repository](https://github.com/openmaptiles/mapbox-studio-pencil.tm2), [style source](https://github.com/openmaptiles/mapbox-studio-pencil.tm2/blob/master/style.mss)).

Stamen Watercolor is another useful visual reference. Its open repository describes a 2013-era Mapnik/TileStache/PostGIS raster pipeline and is ISC licensed ([repository](https://github.com/stamen/watercolor)). It does not provide a current Flutter or vector-tile renderer.

MapLibre styles can use hand-drawn sprites and repeating line/fill patterns, so a MapLibre backend could approximate the theme quickly ([sprite specification](https://maplibre.org/maplibre-style-spec/sprite/), [layer specification](https://maplibre.org/maplibre-style-spec/layers/)). That approach stylizes assets around clean source geometry. Skribble's opportunity is to make the geometry itself feel drawn while preserving geographic continuity and legibility.

## Proposed delivery scope

### Version 1

Ship a focused, useful map rather than an incomplete general GIS engine:

- Web Mercator camera, viewport projection, tile coverage, pan, pinch zoom, double-tap zoom, and mouse-wheel/trackpad zoom.
- Vector MVT sources over HTTP and PMTiles sources from a local file or HTTP.
- Semantic OpenMapTiles and Protomaps adapters.
- Land/background, water, parks/landuse, buildings, boundaries, roads, rail, paths, and place labels.
- Deterministic rough linework, polygon outlines, optional hatching, and a typed light/dark Skribble map style.
- Widget markers, selection callbacks, coordinate projection helpers, attribution, loading/error hooks, cache limits, and accessibility semantics.
- Tests for projection round trips, tile coverage, antimeridian wrapping, latitude limits, MVT command decoding, deterministic feature seeds, cache eviction/disposal, stale async results, gestures, markers, attribution, and semantics.
- A storybook example that uses an explicitly labeled OpenFreeMap online source and demonstrates paper and night styles, routes, areas, and widget markers.

Do not include routing, geocoding, turn-by-turn navigation, arbitrary MapLibre style JSON, terrain, satellite imagery, 3D extrusion, heatmaps, or global offline data in version 1. These are separate products or materially larger rendering systems.

### Follow-up work

- Profile dense-city tiles on representative low- and high-end mobile devices, desktop, and web before enabling image raster caching by default.
- Add optional point clustering when measured marker counts need it.
- Add MBTiles as a native-only provider if real consumers request it.
- Evaluate a Flutter GPU backend after Flutter GPU and `maplibre_flutter_gpu` publish stable APIs and adequate platform support.
- Consider a MapLibre style export that uses Skribble sprites and fonts for applications that prefer native renderer performance over rough geometry.

## Fallback if schedule dominates architecture

If the first milestone must be delivered before a custom viewport is viable, the least-wrong temporary path is `flutter_map` for camera and gestures plus a wholly custom MVT layer that Skribble owns. `flutter_map` explicitly supports custom widget layers ([custom-layer guide](https://docs.fleaflet.dev/plugins/create/layers)). This would validate the rough renderer and data providers sooner.

That fallback must be recorded as temporary Material debt because `flutter_map` 8.3.2 imports Material in its library. It should not use `vector_tile_renderer` or `flutter_map_vector_tiles` for basemap drawing, because doing so would again hide the geometry behind internal painters. Keep the renderer, provider, semantic style, and cache types independent so the custom viewport can replace `flutter_map` without an API rewrite.

## Revised decision

Do not use the custom viewport plus direct MVT renderer as the default engine for a global product whose team does not want to maintain mapping internals. Keep it available as an experimental illustrated renderer, with a restrained basemap and more expressive app overlays.

Use `maplibre_gl` behind a small application-facing adapter for the production path on Android, iOS, and web. MapLibre should own basemap rendering, labels, tile seams, zoom behavior, and offline-region mechanics. Skribble should own the style assets and the product overlays. If the application later proves that rough basemap geometry materially improves the product, the custom renderer can remain an opt-in mode with a clear maintenance budget.

The default operational posture should be:

- no hidden or mandatory map service;
- no API key in the package;
- no default traffic to OSM Foundation tile servers;
- visible, provider-driven attribution;
- OpenFreeMap for explicit online examples;
- MapLibre offline regions for bounded mobile downloads;
- optional versioned Protomaps PMTiles when the application needs controlled hosting;
- user-controlled source URLs, attribution, and cache policy.

This avoids paid map-data licensing and proprietary renderer lock-in. It does not pretend that reliable delivery, storage, bandwidth, or ODbL compliance are free.

## Implementation outcome

The accompanying `skribble_maps` package records the prototype result. It includes the widgets-only camera, direct MVT rendering, OpenMapTiles and Protomaps adapters, HTTP and PMTiles providers, deterministic world-coordinate roughness, picture and byte caches, screen-space labels, widget markers, app-owned routes and polygons, accessible controls, and visible attribution. It is not presented as a substitute for MapLibre's full production renderer.

The storybook uses OpenFreeMap only through an explicit `WiredOpenFreeMapLayer`. The core `WiredMap` has no basemap and performs no network traffic by default. Built-in schemas prepare MVT content through Flutter's background compute path on native platforms; the web path bounds concurrent work and yields between tile preparations. Provider replacement, camera changes, and unmount all suppress stale asynchronous results.

Browser verification used a live OpenFreeMap view of London at 1440 by 1000 logical pixels. The implementation caches prepared vector pictures, gates dense detail by zoom, and completed a settled full-page capture in about 0.2 seconds in the measured debug session. That number is a development observation, not a platform benchmark; representative mobile and release-mode profiling remains follow-up work.
