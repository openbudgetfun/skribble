import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:latlong2/latlong.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_maps/src/wired_map_camera.dart';

/// A widgets-only Web Mercator map with hand-drawn layers and controls.
class WiredMap extends HookWidget {
  /// Creates a map viewport.
  const WiredMap({
    super.key,
    this.controller,
    this.initialCenter = const LatLng(0, 0),
    this.initialZoom = 2,
    this.minimumZoom = 0,
    this.maximumZoom = 20,
    this.basemap,
    this.children = const [],
    this.backgroundColor,
    this.showZoomControls = true,
    this.zoomControlsAlignment = Alignment.topRight,
    this.zoomControlsPadding = const EdgeInsets.all(12),
    this.semanticLabel = 'Interactive map',
    this.clipBehavior = Clip.hardEdge,
    this.scrollZoomSensitivity = 0.005,
  }) : assert(
         minimumZoom <= maximumZoom,
         'minimumZoom must not exceed maximumZoom',
       ),
       assert(
         scrollZoomSensitivity > 0,
         'scrollZoomSensitivity must be positive',
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

  /// Optional basemap layer placed below [children].
  ///
  /// There is intentionally no network-backed default. Choose a provider
  /// explicitly so opening a map never creates hidden traffic.
  final Widget? basemap;

  /// Overlay layers painted above [basemap].
  final List<Widget> children;

  /// Paper color behind all layers.
  final Color? backgroundColor;

  /// Whether hand-drawn zoom controls are displayed.
  final bool showZoomControls;

  /// Placement of the zoom controls.
  final AlignmentGeometry zoomControlsAlignment;

  /// Inset around the zoom controls.
  final EdgeInsetsGeometry zoomControlsPadding;

  /// Accessibility label for the map surface.
  final String semanticLabel;

  /// How map content is clipped at the viewport bounds.
  final Clip clipBehavior;

  /// Zoom units applied per mouse-wheel logical pixel.
  final double scrollZoomSensitivity;

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
    useEffect(() {
      if (controller != null) return null;
      return mapController.dispose;
    }, [controller, mapController]);

    final scaleStartZoom = useRef(mapController.camera.zoom);
    final activeTapPointer = useRef<int?>(null);
    final activeTapOrigin = useRef<Offset?>(null);
    final activeTapMoved = useRef(false);
    final previousTapTimestamp = useRef<Duration?>(null);
    final previousTapPosition = useRef<Offset?>(null);
    final theme = WiredTheme.of(context);

    void handlePointerDown(PointerDownEvent event) {
      if (activeTapPointer.value != null) return;
      activeTapPointer.value = event.pointer;
      activeTapOrigin.value = event.localPosition;
      activeTapMoved.value = false;
    }

    void handlePointerMove(PointerMoveEvent event) {
      if (event.pointer != activeTapPointer.value) return;
      final origin = activeTapOrigin.value;
      if (origin == null) return;
      const tapSlop = 18.0;
      if ((event.localPosition - origin).distanceSquared > tapSlop * tapSlop) {
        activeTapMoved.value = true;
      }
    }

    void handlePointerUp(PointerUpEvent event) {
      if (event.pointer != activeTapPointer.value) return;
      if (!activeTapMoved.value) {
        final timestamp = event.timeStamp;
        final previousTimestamp = previousTapTimestamp.value;
        final previousPosition = previousTapPosition.value;
        const doubleTapTimeout = Duration(milliseconds: 300);
        const doubleTapSlop = 48.0;
        final isDoubleTap =
            previousTimestamp != null &&
            previousPosition != null &&
            timestamp - previousTimestamp <= doubleTapTimeout &&
            (event.localPosition - previousPosition).distanceSquared <=
                doubleTapSlop * doubleTapSlop;
        if (isDoubleTap) {
          mapController.zoomBy(1, focalPoint: event.localPosition);
          previousTapTimestamp.value = null;
          previousTapPosition.value = null;
        } else {
          previousTapTimestamp.value = timestamp;
          previousTapPosition.value = event.localPosition;
        }
      }
      activeTapPointer.value = null;
      activeTapOrigin.value = null;
      activeTapMoved.value = false;
    }

    void handlePointerCancel(PointerCancelEvent event) {
      if (event.pointer != activeTapPointer.value) return;
      activeTapPointer.value = null;
      activeTapOrigin.value = null;
      activeTapMoved.value = false;
    }

    return buildWiredElement(
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: semanticLabel,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            final finiteSize = Size(
              size.width.isFinite ? size.width : 0,
              size.height.isFinite ? size.height : 0,
            );
            mapController.updateViewport(finiteSize);
            return AnimatedBuilder(
              animation: mapController,
              builder: (context, _) {
                final camera = mapController.camera.copyWith(
                  viewportSize: finiteSize,
                );
                return ClipRect(
                  clipBehavior: clipBehavior,
                  child: ColoredBox(
                    color: backgroundColor ?? theme.fillColor,
                    child: WiredMapCameraScope(
                      camera: camera,
                      controller: mapController,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Listener(
                            onPointerDown: handlePointerDown,
                            onPointerMove: handlePointerMove,
                            onPointerUp: handlePointerUp,
                            onPointerCancel: handlePointerCancel,
                            onPointerSignal: (event) {
                              if (event is! PointerScrollEvent) return;
                              mapController.zoomBy(
                                -event.scrollDelta.dy *
                                    scrollZoomSensitivity,
                                focalPoint: event.localPosition,
                              );
                            },
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onScaleStart: (_) {
                                scaleStartZoom.value =
                                    mapController.camera.zoom;
                              },
                              onScaleUpdate: (details) {
                                mapController.panBy(details.focalPointDelta);
                                if (details.scale > 0) {
                                  mapController.zoomTo(
                                    scaleStartZoom.value +
                                        math.log(details.scale) / math.ln2,
                                    focalPoint: details.localFocalPoint,
                                  );
                                }
                              },
                              child: Stack(
                                fit: StackFit.expand,
                                children: [?basemap, ...children],
                              ),
                            ),
                          ),
                          if (showZoomControls)
                            WiredMapZoomControls(
                              controller: mapController,
                              alignment: zoomControlsAlignment,
                              padding: zoomControlsPadding,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
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
      mapController.zoomBy(delta);
      onZoomChanged?.call(mapController.camera.zoom);
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
              child: const Text('+', style: TextStyle(fontSize: 24, height: 1)),
            ),
            const SizedBox(height: 8),
            _WiredMapControlButton(
              semanticLabel: 'Zoom out',
              onTap: canZoomOut ? () => zoomBy(-zoomStep) : null,
              child: const Text('−', style: TextStyle(fontSize: 24, height: 1)),
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
    required this.child,
  });

  final String semanticLabel;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final pressed = useState(false);
    final enabled = onTap != null;
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: enabled,
      excludeSemantics: true,
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
                    fillColor: theme.fillColor.withValues(alpha: 0.92),
                    borderColor: enabled
                        ? theme.borderColor
                        : theme.disabledTextColor,
                    strokeWidth: theme.strokeWidth,
                  ),
                ),
                Center(
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      color: enabled
                          ? theme.textColor
                          : theme.disabledTextColor,
                      fontFamily: theme.fontFamily,
                      package: theme.fontPackage,
                    ),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
