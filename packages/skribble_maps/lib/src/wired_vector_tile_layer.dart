import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_maps/src/wired_map_attribution.dart';
import 'package:skribble_maps/src/wired_map_camera.dart';
import 'package:skribble_maps/src/wired_map_provider.dart';
import 'package:skribble_maps/src/wired_map_schema.dart';
import 'package:skribble_maps/src/wired_map_style.dart';

/// Builds content while visible vector tiles load.
typedef WiredMapLoadingBuilder = Widget Function(BuildContext context);

/// Builds content when visible vector tiles cannot be loaded.
typedef WiredMapErrorBuilder = Widget Function(
  BuildContext context,
  Object error,
  StackTrace? stackTrace,
);

/// Describes one source tile's location in the current viewport.
@immutable
class WiredMapTilePlacement {
  /// Creates a tile placement.
  const WiredMapTilePlacement({
    required this.coordinate,
    required this.worldX,
    required this.offset,
    required this.size,
  });

  /// Normalized source coordinate used to load the tile.
  final WiredMapTileCoordinate coordinate;

  /// Unwrapped tile column used to repeat the world.
  final int worldX;

  /// Top-left viewport offset.
  final Offset offset;

  /// Display size after fractional zoom scaling.
  final double size;
}

/// Computes visible tile coverage for a Web Mercator camera.
abstract final class WiredMapTileCoverage {
  /// Returns visible source tiles at [tileZoom], including [buffer] rings.
  static List<WiredMapTilePlacement> visible(
    WiredMapCamera camera,
    int tileZoom, {
    int buffer = 1,
  }) {
    assert(buffer >= 0, 'buffer cannot be negative');
    if (camera.viewportSize.isEmpty) return const [];
    final count = 1 << tileZoom;
    final scale = math.pow(2, camera.zoom - tileZoom).toDouble();
    final center = WiredMapCamera.projectToWorld(
      camera.center,
      tileZoom.toDouble(),
    );
    final halfWidth = camera.viewportSize.width / (2 * scale);
    final halfHeight = camera.viewportSize.height / (2 * scale);
    final minX = ((center.dx - halfWidth) / wiredMapTileSize).floor() - buffer;
    final maxX = ((center.dx + halfWidth) / wiredMapTileSize).floor() + buffer;
    final minY = math.max(
      0,
      ((center.dy - halfHeight) / wiredMapTileSize).floor() - buffer,
    );
    final maxY = math.min(
      count - 1,
      ((center.dy + halfHeight) / wiredMapTileSize).floor() + buffer,
    );
    final displaySize = wiredMapTileSize * scale;
    return [
      for (var worldX = minX; worldX <= maxX; worldX++)
        for (var y = minY; y <= maxY; y++)
          WiredMapTilePlacement(
            coordinate: WiredMapTileCoordinate(
              tileZoom,
              ((worldX % count) + count) % count,
              y,
            ),
            worldX: worldX,
            offset: Offset(
              (worldX * wiredMapTileSize - center.dx) * scale +
                  camera.viewportSize.width / 2,
              (y * wiredMapTileSize - center.dy) * scale +
                  camera.viewportSize.height / 2,
            ),
            size: displaySize,
          ),
    ];
  }
}

/// Loads MVT data and paints every supported basemap feature with Skribble.
class WiredVectorTileLayer extends HookWidget {
  /// Creates a semantic vector-tile layer.
  const WiredVectorTileLayer({
    required this.provider,
    super.key,
    this.schema = const WiredOpenMapTilesSchema(),
    this.style,
    this.maximumPreparedTiles = 96,
    this.maximumConcurrentLoads = 4,
    this.tileBuffer = 1,
    this.showLabels = true,
    this.showAttribution = true,
    this.onAttributionTap,
    this.attributionAlignment = Alignment.bottomCenter,
    this.attributionPadding = const EdgeInsets.all(8),
    this.loadingBuilder,
    this.errorBuilder,
    this.onTileError,
    this.disposeProvider = false,
  }) : assert(
         maximumPreparedTiles > 0,
         'maximumPreparedTiles must be positive',
       ),
       assert(
         maximumConcurrentLoads > 0,
         'maximumConcurrentLoads must be positive',
       ),
       assert(tileBuffer >= 0, 'tileBuffer cannot be negative');

  /// Raw vector-tile source.
  final WiredMapTileProvider provider;

  /// Source-schema adapter.
  final WiredMapSchemaAdapter schema;

  /// Typed rendering style, or one derived from the active Wired theme.
  final WiredMapStyle? style;

  /// Maximum decoded tiles retained by this layer.
  final int maximumPreparedTiles;

  /// Maximum tile requests and preparations allowed at once.
  final int maximumConcurrentLoads;

  /// Extra source-tile rings loaded outside the viewport.
  final int tileBuffer;

  /// Whether screen-space labels are displayed.
  final bool showLabels;

  /// Whether provider attribution is displayed.
  final bool showAttribution;

  /// Called when the attribution badge is activated.
  final VoidCallback? onAttributionTap;

  /// Attribution placement.
  final AlignmentGeometry attributionAlignment;

  /// Inset around the attribution badge.
  final EdgeInsetsGeometry attributionPadding;

  /// Builds content until the first visible tile is prepared.
  final WiredMapLoadingBuilder? loadingBuilder;

  /// Builds content after a visible tile fails.
  final WiredMapErrorBuilder? errorBuilder;

  /// Receives tile failures without replacing the map surface.
  final void Function(WiredMapTileCoordinate coordinate, Object error)?
  onTileError;

  /// Whether this layer disposes [provider] when unmounted.
  final bool disposeProvider;

  @override
  Widget build(BuildContext context) {
    final camera = wiredMapCameraOf(context);
    final wiredTheme = WiredTheme.of(context);
    final resolvedStyle = style ?? WiredMapStyle.fromTheme(wiredTheme);
    final sourceZoom = camera.zoom.floor().clamp(
      provider.minimumZoom,
      provider.maximumZoom,
    );
    final placements = WiredMapTileCoverage.visible(
      camera,
      sourceZoom,
      buffer: tileBuffer,
    );
    final prepared = useState(
      LinkedHashMap<WiredMapTileCoordinate, WiredPreparedMapTile>(),
    );
    final inFlight = useRef(<WiredMapTileCoordinate, int>{});
    final providerGeneration = useRef(0);
    final coverageGeneration = useRef(0);
    final lastError = useState<(Object, StackTrace?)?>(null);
    final pictureCache = useMemoized(_WiredMapPictureCache.new);

    useEffect(() => pictureCache.dispose, [pictureCache]);
    useEffect(() {
      pictureCache.clear();
      return null;
    }, [provider, schema.cacheKey, resolvedStyle, pictureCache]);

    useEffect(() {
      providerGeneration.value++;
      inFlight.value.clear();
      prepared.value = LinkedHashMap();
      lastError.value = null;
      return null;
    }, [provider, schema.cacheKey]);

    final visibleCoordinates = placements
        .map((placement) => placement.coordinate)
        .toSet()
        .toList(growable: false);
    final coverageKey = visibleCoordinates.map((tile) => '$tile').join('|');
    useEffect(
      () {
        final providerVersion = providerGeneration.value;
        final generation = ++coverageGeneration.value;
        var cancelled = false;
        inFlight.value.clear();
        lastError.value = null;
        final pending = Queue<WiredMapTileCoordinate>.of(
          visibleCoordinates.where(
            (coordinate) => !prepared.value.containsKey(coordinate),
          ),
        );
        late void Function() startMore;

        Future<void> load(WiredMapTileCoordinate coordinate) async {
          try {
            final bytes = await provider.load(coordinate);
            if (cancelled ||
                providerVersion != providerGeneration.value ||
                generation != coverageGeneration.value) {
              return;
            }
            if (kIsWeb && bytes != null) {
              await Future<void>.delayed(Duration.zero);
            }
            final tile = bytes == null
                ? WiredPreparedMapTile(
                    coordinate: coordinate,
                    features: const [],
                  )
                : await schema.prepareAsync(bytes, coordinate);
            if (cancelled ||
                providerVersion != providerGeneration.value ||
                generation != coverageGeneration.value) {
              return;
            }
            final next =
                LinkedHashMap<
                    WiredMapTileCoordinate,
                    WiredPreparedMapTile
                  >.from(
                    prepared.value,
                  )
                  ..remove(coordinate)
                  ..[coordinate] = tile;
            while (next.length > maximumPreparedTiles) {
              next.remove(next.keys.first);
            }
            prepared.value = next;
          } on Object catch (error, stackTrace) {
            if (cancelled ||
                providerVersion != providerGeneration.value ||
                generation != coverageGeneration.value) {
              return;
            }
            lastError.value = (error, stackTrace);
            onTileError?.call(coordinate, error);
          } finally {
            if (inFlight.value[coordinate] == generation) {
              inFlight.value.remove(coordinate);
            }
            startMore();
          }
        }

        startMore = () {
          if (cancelled ||
              providerVersion != providerGeneration.value ||
              generation != coverageGeneration.value) {
            return;
          }
          final activeCount = inFlight.value.values
              .where((value) => value == generation)
              .length;
          var available = maximumConcurrentLoads - activeCount;
          while (available > 0 && pending.isNotEmpty) {
            final coordinate = pending.removeFirst();
            if (prepared.value.containsKey(coordinate) ||
                inFlight.value[coordinate] == generation) {
              continue;
            }
            inFlight.value[coordinate] = generation;
            unawaited(load(coordinate));
            available--;
          }
        };
        startMore();
        return () {
          cancelled = true;
          if (coverageGeneration.value == generation) {
            coverageGeneration.value++;
          }
        };
      },
      [
        coverageKey,
        provider,
        schema.cacheKey,
        maximumPreparedTiles,
        maximumConcurrentLoads,
      ],
    );

    useEffect(() {
      if (!disposeProvider) return null;
      return () {
        final result = provider.dispose();
        if (result is Future<void>) unawaited(result);
      };
    }, [provider, disposeProvider]);

    final hasVisibleTile = placements.any(
      (placement) => prepared.value.containsKey(placement.coordinate),
    );
    final error = lastError.value;
    final labels = showLabels
        ? _buildLabels(
            camera,
            placements,
            prepared.value,
            resolvedStyle,
            wiredTheme,
          )
        : const <Widget>[];

    return buildWiredElement(
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _WiredVectorTilePainter(
              camera: camera,
              placements: placements,
              tiles: prepared.value,
              style: resolvedStyle,
              pictureCache: pictureCache,
              maximumPictures: maximumPreparedTiles,
            ),
            isComplex: true,
          ),
          ...labels,
          if (!hasVisibleTile && error == null)
            loadingBuilder?.call(context) ??
                const _MapMessage(
                  semanticLabel: 'Map loading',
                  text: 'Drawing the map…',
                ),
          if (!hasVisibleTile && error != null)
            errorBuilder?.call(context, error.$1, error.$2) ??
                const _MapMessage(
                  semanticLabel: 'Map failed to load',
                  text: 'Could not draw this map.',
                ),
          if (showAttribution && provider.attribution.text.isNotEmpty)
            Align(
              alignment: attributionAlignment,
              child: Padding(
                padding: attributionPadding,
                child: WiredMapAttribution(
                  text: provider.attribution.text,
                  onTap: onAttributionTap,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Explicit keyless online example backed by OpenFreeMap.
class WiredOpenFreeMapLayer extends HookWidget {
  /// Creates an OpenFreeMap layer.
  const WiredOpenFreeMapLayer({
    super.key,
    this.style,
    this.showLabels = true,
    this.showAttribution = true,
    this.onAttributionTap,
    this.loadingBuilder,
    this.errorBuilder,
    this.headers = const {},
    this.maximumCachedBytes = 24 * 1024 * 1024,
    this.maximumConcurrentLoads = 3,
    this.tileBuffer = 0,
  }) : assert(
         maximumConcurrentLoads > 0,
         'maximumConcurrentLoads must be positive',
       ),
       assert(tileBuffer >= 0, 'tileBuffer cannot be negative');

  /// Typed map style.
  final WiredMapStyle? style;

  /// Whether labels are displayed.
  final bool showLabels;

  /// Whether source attribution is displayed.
  final bool showAttribution;

  /// Called when attribution is activated.
  final VoidCallback? onAttributionTap;

  /// Builds content while tiles load.
  final WiredMapLoadingBuilder? loadingBuilder;

  /// Builds content when loading fails.
  final WiredMapErrorBuilder? errorBuilder;

  /// HTTP headers sent by the OpenFreeMap provider.
  final Map<String, String> headers;

  /// Maximum raw tile bytes retained in memory.
  final int maximumCachedBytes;

  /// Maximum OpenFreeMap requests and tile preparations allowed at once.
  final int maximumConcurrentLoads;

  /// Extra source-tile rings loaded outside the viewport.
  final int tileBuffer;

  @override
  Widget build(BuildContext context) {
    final provider = useMemoized(
      () => WiredCachingTileProvider(
        source: WiredOpenFreeMapProvider(headers: headers),
        maximumBytes: maximumCachedBytes,
        disposeSource: true,
      ),
      [headers, maximumCachedBytes],
    );
    return WiredVectorTileLayer(
      provider: provider,
      style: style,
      showLabels: showLabels,
      showAttribution: showAttribution,
      onAttributionTap: onAttributionTap,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      maximumConcurrentLoads: maximumConcurrentLoads,
      tileBuffer: tileBuffer,
      disposeProvider: true,
    );
  }
}

class _WiredVectorTilePainter extends CustomPainter {
  const _WiredVectorTilePainter({
    required this.camera,
    required this.placements,
    required this.tiles,
    required this.style,
    required this.pictureCache,
    required this.maximumPictures,
  });

  final WiredMapCamera camera;
  final List<WiredMapTilePlacement> placements;
  final Map<WiredMapTileCoordinate, WiredPreparedMapTile> tiles;
  final WiredMapStyle style;
  final _WiredMapPictureCache pictureCache;
  final int maximumPictures;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(style.paperColor, BlendMode.srcOver);
    for (final placement in placements) {
      final tile = tiles[placement.coordinate];
      if (tile == null) continue;
      final picture = pictureCache.obtain(
        tile,
        style,
        camera.zoom,
        maximumPictures,
        () => _recordTile(tile),
      );
      canvas
        ..save()
        ..translate(placement.offset.dx, placement.offset.dy)
        ..clipRect(Rect.fromLTWH(0, 0, placement.size, placement.size))
        ..scale(placement.size / wiredMapTileSize)
        ..drawPicture(picture)
        ..restore();
    }
  }

  ui.Picture _recordTile(WiredPreparedMapTile tile) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      const Rect.fromLTWH(0, 0, wiredMapTileSize, wiredMapTileSize),
    );
    final placement = WiredMapTilePlacement(
      coordinate: tile.coordinate,
      worldX: tile.coordinate.x,
      offset: Offset.zero,
      size: wiredMapTileSize,
    );
    for (final feature in tile.features) {
      if (feature.kind == WiredMapFeatureKind.label) continue;
      _paintFeature(canvas, placement, feature);
    }
    return recorder.endRecording();
  }

  void _paintFeature(
    Canvas canvas,
    WiredMapTilePlacement placement,
    WiredMapSemanticFeature feature,
  ) {
    if (feature.kind == WiredMapFeatureKind.building &&
        camera.zoom < style.minimumBuildingZoom) {
      return;
    }
    if (feature.kind == WiredMapFeatureKind.path &&
        camera.zoom < style.minimumPathZoom) {
      return;
    }
    final featurePaint = _paintFor(feature);
    final parts = [
      for (final part in feature.parts)
        [
          for (final point in part)
            placement.offset + Offset(point.dx, point.dy) * placement.size,
        ],
    ];
    if (feature.geometryType == WiredMapGeometryType.polygon) {
      _paintPolygon(canvas, placement, feature, parts, featurePaint);
    } else if (feature.geometryType == WiredMapGeometryType.line) {
      for (final part in parts) {
        _paintLine(canvas, placement, feature, part, featurePaint);
      }
    }
  }

  WiredMapFeaturePaint _paintFor(WiredMapSemanticFeature feature) {
    final paint = style.paintFor(feature.kind);
    if (feature.kind != WiredMapFeatureKind.road) return paint;
    final widthScale = switch (feature.properties['class']) {
      'motorway' || 'trunk' || 'primary' => 1.15,
      'secondary' || 'tertiary' => 0.82,
      'service' => 0.34,
      _ => 0.52,
    };
    return WiredMapFeaturePaint(
      fill: paint.fill,
      ink: paint.ink,
      secondaryInk: paint.secondaryInk,
      width: paint.width * widthScale,
      dashed: paint.dashed,
      hachure: paint.hachure,
    );
  }

  void _paintPolygon(
    Canvas canvas,
    WiredMapTilePlacement placement,
    WiredMapSemanticFeature feature,
    List<List<Offset>> parts,
    WiredMapFeaturePaint featurePaint,
  ) {
    final cleanPath = ui.Path()..fillType = ui.PathFillType.evenOdd;
    for (final part in parts.where((part) => part.length >= 3)) {
      cleanPath.moveTo(part.first.dx, part.first.dy);
      for (final point in part.skip(1)) {
        cleanPath.lineTo(point.dx, point.dy);
      }
      cleanPath.close();
    }
    final fill = featurePaint.fill;
    if (fill != null) {
      canvas.drawPath(cleanPath, Paint()..color = fill);
    }
    if (featurePaint.hachure) {
      _paintHachure(canvas, cleanPath, cleanPath.getBounds(), featurePaint);
    }
    if (featurePaint.ink != null) {
      for (final part in parts.where((part) => part.length >= 3)) {
        _drawRoughLine(
          canvas,
          placement,
          feature,
          [...part, part.first],
          featurePaint.ink!,
          featurePaint.width,
          echo: feature.kind != WiredMapFeatureKind.building,
        );
      }
    }
  }

  void _paintLine(
    Canvas canvas,
    WiredMapTilePlacement placement,
    WiredMapSemanticFeature feature,
    List<Offset> points,
    WiredMapFeaturePaint featurePaint,
  ) {
    final ink = featurePaint.ink;
    if (ink == null || points.length < 2) return;
    _drawRoughLine(
      canvas,
      placement,
      feature,
      points,
      ink,
      featurePaint.width,
      dashed: featurePaint.dashed,
    );
    final secondary = featurePaint.secondaryInk;
    if (secondary != null) {
      _drawRoughLine(
        canvas,
        placement,
        feature,
        points,
        secondary,
        featurePaint.width * 0.58,
        pass: 1,
      );
    }
  }

  void _drawRoughLine(
    Canvas canvas,
    WiredMapTilePlacement placement,
    WiredMapSemanticFeature feature,
    List<Offset> points,
    Color color,
    double width, {
    bool dashed = false,
    bool echo = true,
    int pass = 0,
  }) {
    final path = ui.Path();
    for (var index = 0; index < points.length; index++) {
      final screenPoint = points[index];
      final local = Offset(
        (screenPoint.dx - placement.offset.dx) / placement.size,
        (screenPoint.dy - placement.offset.dy) / placement.size,
      );
      final point = _jittered(placement, local, feature.kind, pass);
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = width;
    if (dashed) {
      _drawDashedPath(canvas, path, paint, 5 + width, 4 + width);
    } else {
      canvas.drawPath(path, paint);
      if (echo && pass == 0 && style.roughness > 0) {
        final echo = ui.Path();
        for (var index = 0; index < points.length; index++) {
          final screenPoint = points[index];
          final local = Offset(
            (screenPoint.dx - placement.offset.dx) / placement.size,
            (screenPoint.dy - placement.offset.dy) / placement.size,
          );
          final point = _jittered(placement, local, feature.kind, 2);
          if (index == 0) {
            echo.moveTo(point.dx, point.dy);
          } else {
            echo.lineTo(point.dx, point.dy);
          }
        }
        canvas.drawPath(
          echo,
          Paint.from(paint)..color = color.withValues(alpha: color.a * 0.55),
        );
      }
    }
  }

  Offset _jittered(
    WiredMapTilePlacement placement,
    Offset local,
    WiredMapFeatureKind kind,
    int pass,
  ) {
    final globalX = (placement.worldX + local.dx) * 4096;
    final globalY = (placement.coordinate.y + local.dy) * 4096;
    final base = style.seed + kind.index * 7919 + pass * 104729;
    final xNoise = _noise(base, globalX.round(), globalY.round());
    final yNoise = _noise(base + 1543, globalX.round(), globalY.round());
    final point =
        placement.offset + Offset(local.dx, local.dy) * placement.size;
    return point + Offset(xNoise, yNoise) * style.roughness;
  }

  void _paintHachure(
    Canvas canvas,
    ui.Path clip,
    Rect bounds,
    WiredMapFeaturePaint featurePaint,
  ) {
    final ink = featurePaint.ink;
    if (ink == null || bounds.isEmpty) return;
    canvas
      ..save()
      ..clipPath(clip);
    final gap = style.hachureGap;
    final start = ((bounds.left - bounds.height) / gap).floor() * gap;
    final end = bounds.right + bounds.height;
    final paint = Paint()
      ..color = ink.withValues(alpha: ink.a * 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.7, featurePaint.width * 0.45);
    for (var x = start; x <= end; x += gap) {
      canvas.drawLine(
        Offset(x, bounds.bottom),
        Offset(x + bounds.height, bounds.top),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_WiredVectorTilePainter oldDelegate) =>
      oldDelegate.camera != camera ||
      oldDelegate.placements != placements ||
      oldDelegate.tiles != tiles ||
      oldDelegate.style != style ||
      oldDelegate.pictureCache != pictureCache ||
      oldDelegate.maximumPictures != maximumPictures;
}

class _WiredMapPictureCache {
  final LinkedHashMap<(WiredMapTileCoordinate, bool, bool), ui.Picture>
  _pictures = LinkedHashMap();

  ui.Picture obtain(
    WiredPreparedMapTile tile,
    WiredMapStyle style,
    double zoom,
    int maximumPictures,
    ui.Picture Function() build,
  ) {
    final key = (
      tile.coordinate,
      zoom >= style.minimumBuildingZoom,
      zoom >= style.minimumPathZoom,
    );
    final cached = _pictures.remove(key);
    if (cached != null) {
      _pictures[key] = cached;
      return cached;
    }
    final picture = build();
    _pictures[key] = picture;
    while (_pictures.length > maximumPictures) {
      _pictures.remove(_pictures.keys.first)?.dispose();
    }
    return picture;
  }

  void clear() {
    for (final picture in _pictures.values) {
      picture.dispose();
    }
    _pictures.clear();
  }

  void dispose() => clear();
}

List<Widget> _buildLabels(
  WiredMapCamera camera,
  List<WiredMapTilePlacement> placements,
  Map<WiredMapTileCoordinate, WiredPreparedMapTile> tiles,
  WiredMapStyle style,
  WiredThemeData wiredTheme,
) {
  final candidates = <_LabelCandidate>[];
  final seen = <String>{};
  for (final placement in placements) {
    final tile = tiles[placement.coordinate];
    if (tile == null) continue;
    for (final feature in tile.features) {
      final label = feature.label;
      if (feature.kind != WiredMapFeatureKind.label || label == null) continue;
      if (feature.sourceLayer == 'transportation_name' &&
          camera.zoom < style.minimumRoadLabelZoom) {
        continue;
      }
      final point = _labelPoint(feature.parts);
      if (point == null) continue;
      final screen = placement.offset + point * placement.size;
      if (!(Offset.zero & camera.viewportSize).inflate(40).contains(screen)) {
        continue;
      }
      final identity = '${feature.sourceLayer}:$label';
      if (!seen.add(identity)) continue;
      final rank = feature.properties['rank'];
      candidates.add(
        _LabelCandidate(
          text: label,
          center: screen,
          rank: rank is num ? rank.toDouble() : 999,
        ),
      );
    }
  }
  candidates.sort((a, b) => a.rank.compareTo(b.rank));
  final occupied = <Rect>[];
  final widgets = <Widget>[];
  for (final candidate in candidates) {
    final width = (candidate.text.length * 7.2 + 10).clamp(34.0, 180.0);
    const height = 22.0;
    final rect = Rect.fromCenter(
      center: candidate.center,
      width: width,
      height: height,
    );
    if (occupied.any((other) => other.overlaps(rect))) continue;
    occupied.add(rect.inflate(3));
    widgets.add(
      Positioned(
        left: rect.left,
        top: rect.top,
        width: rect.width,
        height: rect.height,
        child: IgnorePointer(
          child: Semantics(
            label: candidate.text,
            excludeSemantics: true,
            child: Center(
              child: Text(
                candidate.text,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  color: style.labelColor,
                  fontFamily: wiredTheme.fontFamily,
                  package: wiredTheme.fontPackage,
                  fontSize: 11,
                  height: 1,
                  shadows: [
                    for (final offset in const [
                      Offset(-1, 0),
                      Offset(1, 0),
                      Offset(0, -1),
                      Offset(0, 1),
                    ])
                      Shadow(
                        color: style.labelHaloColor,
                        offset: offset,
                        blurRadius: 1,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  return widgets;
}

Offset? _labelPoint(List<List<Offset>> parts) {
  final part = parts.firstWhere(
    (candidate) => candidate.isNotEmpty,
    orElse: () => const [],
  );
  if (part.isEmpty) return null;
  return part[part.length ~/ 2];
}

double _noise(int seed, int x, int y) {
  var value = seed ^ (x * 374761393) ^ (y * 668265263);
  value = (value ^ (value >> 13)) * 1274126177;
  value ^= value >> 16;
  return ((value & 0xFFFF) / 32767.5) - 1;
}

void _drawDashedPath(
  Canvas canvas,
  ui.Path path,
  Paint paint,
  double dash,
  double gap,
) {
  for (final metric in path.computeMetrics()) {
    var distance = 0.0;
    while (distance < metric.length) {
      canvas.drawPath(
        metric.extractPath(distance, math.min(distance + dash, metric.length)),
        paint,
      );
      distance += dash + gap;
    }
  }
}

class _LabelCandidate {
  const _LabelCandidate({
    required this.text,
    required this.center,
    required this.rank,
  });

  final String text;
  final Offset center;
  final double rank;
}

class _MapMessage extends StatelessWidget {
  const _MapMessage({required this.semanticLabel, required this.text});

  final String semanticLabel;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: semanticLabel,
        excludeSemantics: true,
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}
