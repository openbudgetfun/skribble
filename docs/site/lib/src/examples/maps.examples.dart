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
          child: Text(online.value ? 'Close the map' : 'Load OpenFreeMap'),
        ),
        if (online.value) ...[
          const SizedBox(height: 16),
          const SizedBox(
            height: 300,
            child: WiredMap(
              initialCenter: LatLng(51.5074, -0.1278),
              initialZoom: 13,
              scrollGesturesEnabled: false,
            ),
          ),
        ],
      ],
    );
  },
);

/// @docs-example map-features
Widget _mapFeatures(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final online = useState(false);
    return Column(
      children: [
        const WiredMapPin(
          icon: WiredMapPinIcon.coffee,
          semanticLabel: 'Favourite café',
        ),
        const SizedBox(height: 16),
        WiredButton(
          onPressed: () => online.value = !online.value,
          child: Text(
            online.value ? 'Close the route' : 'Show the route on a map',
          ),
        ),
        if (online.value) ...[
          const SizedBox(height: 16),
          const SizedBox(
            height: 300,
            child: WiredMap(
              initialCenter: LatLng(51.5242, -0.0778),
              initialZoom: 14,
              scrollGesturesEnabled: false,
              children: [
                WiredMapFeatureLayer(
                  semanticLabel: 'Walking route',
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
                      child: WiredMapPin(icon: WiredMapPinIcon.coffee),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  },
);
