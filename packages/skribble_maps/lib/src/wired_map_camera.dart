import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as maplibre;

/// Maximum latitude representable by the Web Mercator projection.
const double wiredMapMaximumLatitude = 85.05112878;

/// MapLibre's logical world size at zoom zero.
///
/// MapLibre vector sources use 512-pixel tiles. Matching that coordinate plane
/// keeps Flutter overlays aligned with the native basemap.
const double wiredMapTileSize = 512;

/// Immutable flat Web Mercator camera state for a [WiredMapController].
@immutable
class WiredMapCamera {
  /// Creates camera state.
  const WiredMapCamera({
    required this.center,
    required this.zoom,
    required this.viewportSize,
    required this.minimumZoom,
    required this.maximumZoom,
  });

  /// Geographic coordinate at the viewport center.
  final LatLng center;

  /// Continuous MapLibre zoom level.
  final double zoom;

  /// Current logical viewport size.
  final Size viewportSize;

  /// Smallest permitted zoom level.
  final double minimumZoom;

  /// Largest permitted zoom level.
  final double maximumZoom;

  /// World width in logical pixels at [zoom].
  double get worldSize => wiredMapTileSize * math.pow(2, zoom);

  /// Converts [coordinate] to a viewport offset.
  ///
  /// This projection is exact while `WiredMap` keeps pitch and bearing at
  /// zero, which is why those MapLibre gestures are deliberately disabled.
  Offset project(LatLng coordinate) {
    final point = projectToWorld(coordinate, zoom);
    final centerPoint = projectToWorld(center, zoom);
    final width = worldSize;
    var deltaX = point.dx - centerPoint.dx;

    if (width > 0) {
      while (deltaX > width / 2) {
        deltaX -= width;
      }

      while (deltaX < -width / 2) {
        deltaX += width;
      }
    }

    return viewportSize.center(Offset.zero) +
        Offset(deltaX, point.dy - centerPoint.dy);
  }

  /// Converts a viewport [offset] to a geographic coordinate.
  LatLng unproject(Offset offset) {
    final centerPoint = projectToWorld(center, zoom);
    final worldPoint = centerPoint + offset - viewportSize.center(Offset.zero);

    return unprojectFromWorld(worldPoint, zoom);
  }

  /// Returns camera state with selected values replaced.
  WiredMapCamera copyWith({
    LatLng? center,
    double? zoom,
    Size? viewportSize,
    double? minimumZoom,
    double? maximumZoom,
  }) {
    return WiredMapCamera(
      center: center ?? this.center,
      zoom: zoom ?? this.zoom,
      viewportSize: viewportSize ?? this.viewportSize,
      minimumZoom: minimumZoom ?? this.minimumZoom,
      maximumZoom: maximumZoom ?? this.maximumZoom,
    );
  }

  /// Projects [coordinate] into MapLibre's global Web Mercator pixel plane.
  static Offset projectToWorld(LatLng coordinate, double zoom) {
    final latitude = coordinate.latitude.clamp(
      -wiredMapMaximumLatitude,
      wiredMapMaximumLatitude,
    );
    final longitude = _wrapLongitude(coordinate.longitude);
    final scale = wiredMapTileSize * math.pow(2, zoom);
    final sinLatitude = math.sin(latitude * math.pi / 180);
    final x = (longitude + 180) / 360;
    final y =
        0.5 - math.log((1 + sinLatitude) / (1 - sinLatitude)) / (4 * math.pi);

    return Offset(x * scale, y * scale);
  }

  /// Unprojects a global Web Mercator [point] at [zoom].
  static LatLng unprojectFromWorld(Offset point, double zoom) {
    final scale = wiredMapTileSize * math.pow(2, zoom);
    final longitude = _wrapLongitude(point.dx / scale * 360 - 180);
    final mercatorY = math.pi - 2 * math.pi * point.dy / scale;
    final hyperbolicSine = (math.exp(mercatorY) - math.exp(-mercatorY)) / 2;
    final latitude = 180 / math.pi * math.atan(hyperbolicSine);

    return LatLng(
      latitude.clamp(-wiredMapMaximumLatitude, wiredMapMaximumLatitude),
      longitude,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WiredMapCamera &&
        other.center == center &&
        other.zoom == zoom &&
        other.viewportSize == viewportSize &&
        other.minimumZoom == minimumZoom &&
        other.maximumZoom == maximumZoom;
  }

  @override
  int get hashCode => Object.hash(
    center,
    zoom,
    viewportSize,
    minimumZoom,
    maximumZoom,
  );
}

/// Controls a MapLibre-backed `WiredMap` and exposes flat projection helpers.
class WiredMapController extends ChangeNotifier {
  /// Creates a map controller.
  WiredMapController({
    LatLng initialCenter = const LatLng(0, 0),
    double initialZoom = 2,
    this.minimumZoom = 0,
    this.maximumZoom = 20,
  }) : assert(
         minimumZoom <= maximumZoom,
         'minimumZoom must not exceed maximumZoom',
       ),
       _camera = WiredMapCamera(
         center: _clampCoordinate(initialCenter),
         zoom: initialZoom.clamp(minimumZoom, maximumZoom),
         viewportSize: Size.zero,
         minimumZoom: minimumZoom,
         maximumZoom: maximumZoom,
       );

  /// Smallest permitted zoom level.
  final double minimumZoom;

  /// Largest permitted zoom level.
  final double maximumZoom;

  WiredMapCamera _camera;
  maplibre.MapLibreMapController? _engineController;

  /// Current camera state.
  WiredMapCamera get camera => _camera;

  /// Moves immediately to [center] and optionally [zoom].
  Future<void> move(LatLng center, {double? zoom}) async {
    final next = _camera.copyWith(
      center: _clampCoordinate(center),
      zoom: zoom?.clamp(minimumZoom, maximumZoom),
    );

    _setCamera(next);

    final engineController = _engineController;
    if (engineController == null) return;

    await engineController.moveCamera(
      maplibre.CameraUpdate.newLatLngZoom(
        _toMapLibreLatLng(next.center),
        next.zoom,
      ),
    );
  }

  /// Animates to [center] and optionally [zoom].
  Future<void> animateTo(
    LatLng center, {
    double? zoom,
    Duration duration = const Duration(milliseconds: 320),
  }) async {
    final next = _camera.copyWith(
      center: _clampCoordinate(center),
      zoom: zoom?.clamp(minimumZoom, maximumZoom),
    );

    _setCamera(next);

    final engineController = _engineController;
    if (engineController == null) return;

    await engineController.animateCamera(
      maplibre.CameraUpdate.newLatLngZoom(
        _toMapLibreLatLng(next.center),
        next.zoom,
      ),
      duration: duration,
    );
  }

  /// Pans the camera by a viewport-pixel [delta].
  Future<void> panBy(Offset delta) async {
    if (delta == Offset.zero) return;

    final centerWorld = WiredMapCamera.projectToWorld(
      _camera.center,
      _camera.zoom,
    );
    final next = WiredMapCamera.unprojectFromWorld(
      centerWorld - delta,
      _camera.zoom,
    );

    await move(next);
  }

  /// Changes zoom by [delta], keeping [focalPoint] geographically stable.
  Future<void> zoomBy(
    double delta, {
    Offset? focalPoint,
    Duration duration = const Duration(milliseconds: 180),
  }) async {
    await zoomTo(
      _camera.zoom + delta,
      focalPoint: focalPoint,
      duration: duration,
    );
  }

  /// Sets [zoom], keeping [focalPoint] geographically stable.
  Future<void> zoomTo(
    double zoom, {
    Offset? focalPoint,
    Duration duration = const Duration(milliseconds: 180),
  }) async {
    final nextZoom = zoom.clamp(minimumZoom, maximumZoom);
    final currentZoom = _camera.zoom;
    if (nextZoom == currentZoom) return;

    final focal = focalPoint ?? _camera.viewportSize.center(Offset.zero);
    final anchoredCoordinate = _camera.unproject(focal);
    final anchoredWorld = WiredMapCamera.projectToWorld(
      anchoredCoordinate,
      nextZoom,
    );
    final nextCenterWorld =
        anchoredWorld - focal + _camera.viewportSize.center(Offset.zero);

    _setCamera(
      _camera.copyWith(
        center: WiredMapCamera.unprojectFromWorld(nextCenterWorld, nextZoom),
        zoom: nextZoom,
      ),
    );

    final engineController = _engineController;
    if (engineController == null) return;

    await engineController.animateCamera(
      maplibre.CameraUpdate.zoomBy(nextZoom - currentZoom, focalPoint),
      duration: duration,
    );
  }

  /// Updates the viewport used by projection helpers.
  ///
  /// `WiredMap` calls this during layout. Applications normally do not need to
  /// call it directly.
  void updateViewport(Size size) {
    if (size == _camera.viewportSize) return;

    _camera = _camera.copyWith(viewportSize: size);
  }

  /// Connects this controller to the MapLibre view owned by `WiredMap` and
  /// returns a matching disconnect callback.
  @internal
  VoidCallback bindEngine(maplibre.MapLibreMapController controller) {
    _engineController = controller;

    return () {
      if (identical(_engineController, controller)) {
        _engineController = null;
      }
    };
  }

  /// Mirrors camera movement reported by MapLibre into Flutter overlay state.
  @internal
  void synchronizeFromEngine(maplibre.CameraPosition position) {
    _setCamera(
      _camera.copyWith(
        center: LatLng(
          position.target.latitude,
          position.target.longitude,
        ),
        zoom: position.zoom.clamp(minimumZoom, maximumZoom),
      ),
    );
  }

  void _setCamera(WiredMapCamera next) {
    if (next == _camera) return;

    _camera = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _engineController = null;
    super.dispose();
  }
}

/// Returns the camera inherited from the nearest `WiredMap`.
WiredMapCamera wiredMapCameraOf(BuildContext context) {
  final scope = context
      .dependOnInheritedWidgetOfExactType<WiredMapCameraScope>();

  if (scope == null) {
    throw StateError('A Wired map layer must be placed inside WiredMap');
  }

  return scope.camera;
}

/// Internal camera boundary used by map layers.
class WiredMapCameraScope extends InheritedWidget {
  /// Creates a camera boundary.
  const WiredMapCameraScope({
    required this.camera,
    required this.controller,
    required super.child,
    super.key,
  });

  /// Current camera state.
  final WiredMapCamera camera;

  /// Controller that owns [camera].
  final WiredMapController controller;

  /// Returns the nearest controller.
  static WiredMapController controllerOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<WiredMapCameraScope>();

    if (scope == null) {
      throw StateError('A Wired map layer must be placed inside WiredMap');
    }

    return scope.controller;
  }

  @override
  bool updateShouldNotify(WiredMapCameraScope oldWidget) {
    return oldWidget.camera != camera || oldWidget.controller != controller;
  }
}

LatLng _clampCoordinate(LatLng value) {
  return LatLng(
    value.latitude.clamp(-wiredMapMaximumLatitude, wiredMapMaximumLatitude),
    _wrapLongitude(value.longitude),
  );
}

double _wrapLongitude(double value) {
  var longitude = value;

  while (longitude < -180) {
    longitude += 360;
  }

  while (longitude >= 180) {
    longitude -= 360;
  }

  return longitude;
}

maplibre.LatLng _toMapLibreLatLng(LatLng coordinate) {
  return maplibre.LatLng(coordinate.latitude, coordinate.longitude);
}
