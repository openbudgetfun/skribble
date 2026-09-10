import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:latlong2/latlong.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_maps/src/wired_map_camera.dart';

/// A Flutter widget anchored to a geographic point on a [WiredMapMarkerLayer].
@immutable
class WiredMapMarker {
  /// Creates a map marker.
  const WiredMapMarker({
    required this.point,
    required this.child,
    this.key,
    this.width = 52,
    this.height = 64,
    this.alignment = Alignment.bottomCenter,
    this.semanticLabel,
    this.onTap,
    this.onLongPress,
  }) : assert(width > 0, 'width must be positive'),
       assert(height > 0, 'height must be positive');

  /// The geographic anchor.
  final LatLng point;

  /// The marker content.
  final Widget child;

  /// An optional identity used while rebuilding the marker stack.
  final Key? key;

  /// The marker width.
  final double width;

  /// The marker height.
  final double height;

  /// The marker alignment around [point].
  final Alignment alignment;

  /// An accessibility label for the marker.
  final String? semanticLabel;

  /// Called when the marker is activated.
  final VoidCallback? onTap;

  /// Called when the marker is held, independently of [onTap].
  ///
  /// Keep the selected place in application state and update the marker's
  /// child to show that selection. A long press does not also trigger a tap.
  final VoidCallback? onLongPress;
}

/// Positions interactive Wired widgets over the map geometry.
class WiredMapMarkerLayer extends HookWidget {
  /// Creates a marker layer.
  const WiredMapMarkerLayer({required this.markers, super.key});

  /// Markers displayed by this layer.
  final List<WiredMapMarker> markers;

  @override
  Widget build(BuildContext context) {
    final camera = wiredMapCameraOf(context);
    return buildWiredElement(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final marker in markers) _positionedMarker(camera, marker),
        ],
      ),
    );
  }

  Widget _positionedMarker(WiredMapCamera camera, WiredMapMarker marker) {
    final point = camera.project(marker.point);
    final left = point.dx - marker.width * (marker.alignment.x + 1) / 2;
    final top = point.dy - marker.height * (marker.alignment.y + 1) / 2;
    return Positioned(
      key: marker.key,
      left: left,
      top: top,
      width: marker.width,
      height: marker.height,
      child: Semantics(
        label: marker.semanticLabel,
        button: marker.onTap != null || marker.onLongPress != null,
        onTap: marker.onTap,
        onLongPress: marker.onLongPress,
        excludeSemantics: marker.semanticLabel != null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: marker.onTap,
          onLongPress: marker.onLongPress,
          child: marker.child,
        ),
      ),
    );
  }
}
