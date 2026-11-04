import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:latlong2/latlong.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as maplibre;
import 'package:skribble/skribble.dart';
import 'package:skribble_maps/src/wired_map_camera.dart';
import 'package:skribble_maps/src/wired_map_style.dart';

/// Builds a replacement for the native map view in widget tests.
typedef WiredMapViewBuilder = Widget Function(BuildContext context);

/// A MapLibre basemap with hand-drawn Flutter overlays and controls.
///
/// MapLibre renders source data, roads, buildings, water, and labels. skribble
/// only draws the widgets in [children]. Pitch and rotation stay disabled so
/// those Flutter overlays remain aligned with geographic coordinates.
class WiredMap extends HookWidget {
  /// Creates a MapLibre-backed map.
  const WiredMap({
    super.key,
    this.controller,
    this.initialCenter = const LatLng(0, 0),
    this.initialZoom = 2,
    this.minimumZoom = 0,
    this.maximumZoom = 20,
    this.style = WiredMapStyle.paper,
    this.children = const [],
    this.backgroundColor,
    this.showZoomControls = true,
    this.zoomControlsAlignment = Alignment.topRight,
    this.zoomControlsPadding = const EdgeInsets.all(12),
    this.semanticLabel = 'Interactive map',
    this.clipBehavior = Clip.hardEdge,
    this.scrollGesturesEnabled = true,
    this.zoomGesturesEnabled = true,
    this.myLocationEnabled = false,
    this.gestureRecognizers,
    this.onMapCreated,
    this.onStyleLoaded,
    this.onMapIdle,
    this.onCameraChanged,
    this.onTap,
    this.mapViewBuilder,
  }) : assert(
         minimumZoom <= maximumZoom,
         'minimumZoom must not exceed maximumZoom',
       );

  /// An external controller. The map creates and owns one when omitted.
  final WiredMapController? controller;

  /// Initial center used by an internally created controller.
  final LatLng initialCenter;

  /// Initial zoom used by an internally created controller.
  final double initialZoom;

  /// Minimum zoom used by an internally created controller.
  final double minimumZoom;

  /// Maximum zoom used by an internally created controller.
  final double maximumZoom;

  /// MapLibre style used for the basemap.
  final WiredMapStyle style;

  /// Flutter overlays placed above the MapLibre view.
  final List<Widget> children;

  /// Color visible while MapLibre loads its style and tiles.
  final Color? backgroundColor;

  /// Whether hand-drawn zoom controls are displayed.
  final bool showZoomControls;

  /// Placement of the zoom controls.
  final AlignmentGeometry zoomControlsAlignment;

  /// Inset around the zoom controls.
  final EdgeInsetsGeometry zoomControlsPadding;

  /// Accessibility label for the map.
  final String semanticLabel;

  /// How map content is clipped at the viewport bounds.
  final Clip clipBehavior;

  /// Whether MapLibre handles dragging to pan across the map.
  final bool scrollGesturesEnabled;

  /// Whether MapLibre handles pinch and double-tap zoom gestures.
  ///
  /// Also controls mouse-wheel and trackpad zoom on the web.
  final bool zoomGesturesEnabled;

  /// Whether MapLibre displays the device-location indicator.
  ///
  /// The consuming application must configure and request each platform's
  /// location permission before enabling this option.
  final bool myLocationEnabled;

  /// Gesture recognizers forwarded to MapLibre's platform view.
  ///
  /// On mobile, a map inside a scrollable can compete with its parent for
  /// drags. Supply an eager recognizer when gestures starting on the map
  /// should belong to the map; the rest of the page remains scrollable.
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  /// Called after MapLibre creates its controller.
  ///
  /// Use the native controller for advanced MapLibre operations such as
  /// clustered style layers, offline regions, or large GeoJSON sources.
  final ValueChanged<maplibre.MapLibreMapController>? onMapCreated;

  /// Called after the MapLibre style and annotation managers load.
  final VoidCallback? onStyleLoaded;

  /// Called after requested tiles load and camera and fade transitions finish.
  ///
  /// Unlike [onStyleLoaded], this callback is suitable for waiting before a
  /// screenshot. Further camera movement or data loading can make the map busy
  /// again.
  final VoidCallback? onMapIdle;

  /// Called while MapLibre moves the camera.
  final ValueChanged<WiredMapCamera>? onCameraChanged;

  /// Called when the user taps an unclaimed point on the map.
  final ValueChanged<LatLng>? onTap;

  /// Optional native-view replacement for deterministic widget tests.
  @visibleForTesting
  final WiredMapViewBuilder? mapViewBuilder;

  @override
  Widget build(BuildContext context) {
    final mapController = useMemoized(
      () =>
          controller ??
          WiredMapController(
            initialCenter: initialCenter,
            initialZoom: initialZoom,
            minimumZoom: minimumZoom,
            maximumZoom: maximumZoom,
          ),
      [controller, initialCenter, initialZoom, minimumZoom, maximumZoom],
    );
    final disconnectEngine = useRef<VoidCallback?>(null);
    final theme = WiredTheme.of(context);

    useEffect(() {
      if (controller != null) return null;

      return mapController.dispose;
    }, [controller, mapController]);

    useEffect(() {
      return () {
        disconnectEngine.value?.call();
      };
    }, [mapController]);

    final mapView =
        mapViewBuilder?.call(context) ??
        _buildMapLibreView(
          mapController: mapController,
          disconnectEngine: disconnectEngine,
          loadingColor: backgroundColor ?? theme.fillColor,
        );

    return buildWiredElement(
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: semanticLabel,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            final viewportSize = Size(
              size.width.isFinite ? size.width : 0,
              size.height.isFinite ? size.height : 0,
            );

            mapController.updateViewport(viewportSize);

            return ClipRect(
              clipBehavior: clipBehavior,
              child: ColoredBox(
                color: backgroundColor ?? theme.fillColor,
                child: AnimatedBuilder(
                  animation: mapController,
                  child: mapView,
                  builder: (context, mapView) {
                    final camera = mapController.camera.copyWith(
                      viewportSize: viewportSize,
                    );

                    return WiredMapCameraScope(
                      camera: camera,
                      controller: mapController,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ?mapView,
                          ...children,
                          if (showZoomControls)
                            WiredMapZoomControls(
                              controller: mapController,
                              alignment: zoomControlsAlignment,
                              padding: zoomControlsPadding,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMapLibreView({
    required WiredMapController mapController,
    required ObjectRef<VoidCallback?> disconnectEngine,
    required Color loadingColor,
  }) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      // Android needs the texture-backed view for Flutter overlays to compose
      // above MapLibre reliably.
      maplibre.MapLibreMap.useHybridComposition = true;
    }

    final camera = mapController.camera;

    return maplibre.MapLibreMap(
      initialCameraPosition: maplibre.CameraPosition(
        target: maplibre.LatLng(
          camera.center.latitude,
          camera.center.longitude,
        ),
        zoom: camera.zoom,
      ),
      styleString: style.styleString,
      minMaxZoomPreference: maplibre.MinMaxZoomPreference(
        mapController.minimumZoom,
        mapController.maximumZoom,
      ),
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      scrollGesturesEnabled: scrollGesturesEnabled,
      zoomGesturesEnabled: zoomGesturesEnabled,
      doubleClickZoomEnabled: zoomGesturesEnabled,
      compassEnabled: false,
      trackCameraPosition: true,
      myLocationEnabled: myLocationEnabled,
      attributionButtonColor: style.attributionButtonColor,
      foregroundLoadColor: loadingColor,
      gestureRecognizers: gestureRecognizers,
      onMapCreated: (controller) {
        disconnectEngine.value?.call();
        disconnectEngine.value = mapController.bindEngine(controller);
        onMapCreated?.call(controller);
      },
      onStyleLoadedCallback: onStyleLoaded,
      onMapIdle: onMapIdle,
      onCameraMove: (position) {
        mapController.synchronizeFromEngine(position);
        onCameraChanged?.call(mapController.camera);
      },
      onMapClick: (_, coordinate) {
        onTap?.call(LatLng(coordinate.latitude, coordinate.longitude));
      },
    );
  }
}

/// Hand-drawn zoom controls designed for a [WiredMap].
class WiredMapZoomControls extends HookWidget {
  /// Creates map zoom controls.
  const WiredMapZoomControls({
    super.key,
    this.controller,
    this.alignment = Alignment.topRight,
    this.padding = const EdgeInsets.all(12),
    this.zoomStep = 1,
    this.onZoomChanged,
  }) : assert(zoomStep > 0, 'zoomStep must be positive');

  /// The controlled map, or the nearest map controller when omitted.
  final WiredMapController? controller;

  /// Placement within the map.
  final AlignmentGeometry alignment;

  /// Inset around the controls.
  final EdgeInsetsGeometry padding;

  /// Zoom units applied by each activation.
  final double zoomStep;

  /// Called after a zoom movement is requested.
  final ValueChanged<double>? onZoomChanged;

  @override
  Widget build(BuildContext context) {
    final camera = wiredMapCameraOf(context);
    final mapController =
        controller ?? WiredMapCameraScope.controllerOf(context);
    final canZoomIn = camera.zoom < camera.maximumZoom;
    final canZoomOut = camera.zoom > camera.minimumZoom;

    void zoomBy(double delta) {
      final nextZoom = (camera.zoom + delta).clamp(
        camera.minimumZoom,
        camera.maximumZoom,
      );

      unawaited(mapController.zoomBy(delta));
      onZoomChanged?.call(nextZoom);
    }

    return Align(
      alignment: alignment,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _WiredMapControlButton(
              semanticLabel: 'Zoom in',
              onTap: canZoomIn ? () => zoomBy(zoomStep) : null,
              iconIdentifier: 'add',
            ),
            const SizedBox(height: 8),
            _WiredMapControlButton(
              semanticLabel: 'Zoom out',
              onTap: canZoomOut ? () => zoomBy(-zoomStep) : null,
              iconIdentifier: 'remove',
            ),
          ],
        ),
      ),
    );
  }
}

class _WiredMapControlButton extends HookWidget {
  const _WiredMapControlButton({
    required this.semanticLabel,
    required this.onTap,
    required this.iconIdentifier,
  });

  final String semanticLabel;
  final VoidCallback? onTap;
  final String iconIdentifier;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final pressed = useState(false);
    final focused = useState(false);
    final enabled = onTap != null;
    final icon = lookupMaterialRoughIconByIdentifier(iconIdentifier);
    final ink = enabled ? theme.textColor : theme.disabledTextColor;

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: enabled,
      // The gesture detector's own tap action is excluded with its subtree,
      // so screen readers activate the control through this one.
      onTap: onTap,
      excludeSemantics: true,
      child: FocusableActionDetector(
        enabled: enabled,
        mouseCursor: enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onShowFocusHighlight: (value) => focused.value = value,
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              onTap?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          onTapDown: enabled ? (_) => pressed.value = true : null,
          onTapUp: enabled ? (_) => pressed.value = false : null,
          onTapCancel: enabled ? () => pressed.value = false : null,
          child: AnimatedScale(
            duration: theme.motionEnabled
                ? const Duration(milliseconds: 80)
                : Duration.zero,
            scale: pressed.value ? 0.92 : 1,
            child: SizedBox.square(
              dimension: 44,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  WiredCanvas(
                    fillerType: RoughFilter.solidFiller,
                    painter: WiredRoundedRectangleBase(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      fillColor: theme.fillColor.withValues(alpha: 0.94),
                      borderColor: enabled
                          ? theme.borderColor
                          : theme.disabledTextColor,
                      // A keyboard-focused control draws a heavier line.
                      strokeWidth: focused.value
                          ? theme.strokeWidth * 2 + 1
                          : theme.strokeWidth,
                    ),
                  ),
                  Center(
                    child: icon != null
                        ? WiredSvgIcon(
                            data: icon,
                            size: 22,
                            color: ink,
                            fillStyle: WiredIconFillStyle.none,
                          )
                        // Without a registered icon catalog, or with one that
                        // names these glyphs differently, draw them directly.
                        : CustomPaint(
                            size: const Size.square(22),
                            painter: _ZoomGlyphPainter(
                              plus: iconIdentifier == 'add',
                              color: ink,
                              strokeWidth: theme.strokeWidth + 0.5,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A plus or minus sign for zoom controls when no icon catalog supplies one.
class _ZoomGlyphPainter extends CustomPainter {
  const _ZoomGlyphPainter({
    required this.plus,
    required this.color,
    required this.strokeWidth,
  });

  final bool plus;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final center = size.center(Offset.zero);
    final arm = size.shortestSide * 0.32;

    canvas.drawLine(
      center - Offset(arm, 0),
      center + Offset(arm, 0),
      paint,
    );

    if (plus) {
      canvas.drawLine(
        center - Offset(0, arm),
        center + Offset(0, arm),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ZoomGlyphPainter oldDelegate) =>
      plus != oldDelegate.plus ||
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth;
}
