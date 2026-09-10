part of 'catalog.dart';

/// @docs-example map-online
Widget _mapOnline(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final online = useState(false);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WiredButton(
          key: const ValueKey('docs-map-online-toggle'),
          onPressed: () => online.value = !online.value,
          child: Text(online.value ? 'Close the map' : 'Load OpenFreeMap'),
        ),
        if (online.value) ...[
          const SizedBox(height: 16),
          const SizedBox(
            height: 300,
            child: WiredMap(
              key: ValueKey('docs-online-map'),
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
    final selected = useState('Choose a pin, then explore the walking route.');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 24,
          runSpacing: 12,
          children: [
            WiredMapPin(
              key: const ValueKey('docs-map-pin-coffee'),
              icon: WiredMapPinIcon.coffee,
              semanticLabel: 'Favourite café',
              onTap: () => selected.value = 'Selected: Favourite café',
            ),
            WiredMapPin(
              key: const ValueKey('docs-map-pin-market'),
              icon: WiredMapPinIcon.market,
              semanticLabel: 'Weekend market',
              onTap: () => selected.value = 'Selected: Weekend market',
            ),
            WiredMapPin(
              key: const ValueKey('docs-map-pin-gallery'),
              icon: WiredMapPinIcon.gallery,
              semanticLabel: 'Local gallery',
              onTap: () => selected.value = 'Selected: Local gallery',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Semantics(
          liveRegion: true,
          child: Text(
            selected.value,
            key: const ValueKey('docs-map-selection'),
          ),
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
          SizedBox(
            height: 300,
            child: WiredMap(
              initialCenter: const LatLng(51.5242, -0.0778),
              initialZoom: 14,
              scrollGesturesEnabled: false,
              semanticLabel: 'Shoreditch walking route',
              children: [
                const WiredMapFeatureLayer(
                  semanticLabel: 'Walking route',
                  features: [
                    WiredMapPolygon(
                      points: [
                        LatLng(51.5256, -0.0798),
                        LatLng(51.5258, -0.0769),
                        LatLng(51.5245, -0.0765),
                        LatLng(51.5242, -0.0792),
                      ],
                    ),
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
                      point: const LatLng(51.5242, -0.0778),
                      semanticLabel: 'Favourite café',
                      onTap: () => selected.value = 'Selected: Favourite café',
                      child: const WiredMapPin(icon: WiredMapPinIcon.coffee),
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
