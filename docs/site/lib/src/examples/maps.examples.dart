part of 'catalog.dart';

/// @docs-example map-online
Widget _mapOnline(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final online = useState(false);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WiredButton(
          onPressed: () => online.value = !online.value,
          child: Text(
            online.value ? 'Disconnect the online map' : 'Load OpenFreeMap',
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: WiredMap(
            initialCenter: const LatLng(51.5074, -0.1278),
            initialZoom: 13,
            basemap: online.value ? const WiredOpenFreeMapLayer() : null,
          ),
        ),
      ],
    );
  },
);

/// @docs-example map-features
Widget _mapFeatures(ExampleSettings settings) => const SizedBox(
  height: 300,
  child: WiredMap(
    initialCenter: LatLng(51.5242, -0.0778),
    initialZoom: 14,
    children: [
      WiredMapFeatureLayer(
        features: [
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
            point: LatLng(51.5242, -0.0778),
            semanticLabel: 'Favourite café',
            child: WiredMapPin(child: Text('C')),
          ),
        ],
      ),
    ],
  ),
);
