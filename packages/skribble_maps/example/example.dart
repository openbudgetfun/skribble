import 'package:flutter/widgets.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_icons_material/skribble_icons_material.dart';
import 'package:skribble_maps/skribble_maps.dart';

/// Shows a London basemap with a hand-drawn pin, a walking route, and the
/// provider attribution the OpenFreeMap tiles require.
void main() {
  // Pin category glyphs come from the rough Material icon catalog.
  registerSkribbleMaterialIcons();
  runApp(
    SkribbleApp(
      wiredTheme: WiredThemeData(),
      home: const MapExample(),
    ),
  );
}

/// A full-screen map with one tappable place.
class MapExample extends StatelessWidget {
  /// Creates the example screen.
  const MapExample({super.key});

  static const _cafe = LatLng(51.5136, -0.0984);

  @override
  Widget build(BuildContext context) {
    return WiredMap(
      initialCenter: _cafe,
      initialZoom: 14,
      semanticLabel: 'Map of the City of London',
      children: [
        const WiredMapFeatureLayer(
          features: [
            WiredMapPolyline(
              points: [
                LatLng(51.5155, -0.1040),
                LatLng(51.5136, -0.0984),
                LatLng(51.5101, -0.0938),
              ],
              semanticLabel: 'Walking route',
            ),
          ],
        ),
        WiredMapMarkerLayer(
          markers: [
            WiredMapMarker(
              point: _cafe,
              semanticLabel: 'Café',
              onTap: () {},
              child: const WiredMapPin(icon: WiredMapPinIcon.coffee),
            ),
          ],
        ),
        const Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: WiredMapAttribution(
              text: '© OpenStreetMap contributors · OpenFreeMap',
            ),
          ),
        ),
      ],
    );
  }
}
