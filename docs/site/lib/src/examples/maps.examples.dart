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
              gestureRecognizers: {
                Factory<OneSequenceGestureRecognizer>(
                  EagerGestureRecognizer.new,
                ),
              },
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
              onLongPress: () => selected.value = 'Selected: Favourite café',
            ),
            WiredMapPin(
              key: const ValueKey('docs-map-pin-market'),
              icon: WiredMapPinIcon.market,
              semanticLabel: 'Weekend market',
              onTap: () => selected.value = 'Selected: Weekend market',
              onLongPress: () => selected.value = 'Selected: Weekend market',
            ),
            WiredMapPin(
              key: const ValueKey('docs-map-pin-gallery'),
              icon: WiredMapPinIcon.gallery,
              semanticLabel: 'Local gallery',
              onTap: () => selected.value = 'Selected: Local gallery',
              onLongPress: () => selected.value = 'Selected: Local gallery',
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
              gestureRecognizers: const {
                Factory<OneSequenceGestureRecognizer>(
                  EagerGestureRecognizer.new,
                ),
              },
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
                      onLongPress: () =>
                          selected.value = 'Selected: Favourite café',
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

/// @docs-example map-location
Widget _mapLocation(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final heading = useState<double?>(35);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Simulated location · compare direction ink'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final style in WiredMapHeadingStyle.values)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 180,
                    child: Text(
                      switch (style) {
                        WiredMapHeadingStyle.wash => 'Blue wash',
                        WiredMapHeadingStyle.hatching => 'Pencil hatching',
                        WiredMapHeadingStyle.washAndHatching => 'Wash + pencil',
                      },
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final dark in [false, true])
                    SizedBox(
                      width: 180,
                      height: 150,
                      child: ColoredBox(
                        color: dark
                            ? const Color(0xFF272E32)
                            : const Color(0xFFF6F2E9),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned.fill(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  for (var i = 0; i < 4; i++)
                                    Container(
                                      height: 5,
                                      color: dark
                                          ? const Color(0xFF42494D)
                                          : const Color(0xFFE2DCCF),
                                    ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 35,
                              right: 12,
                              child: Text(
                                'Park lane',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: dark
                                      ? const Color(0xFFD6DBDC)
                                      : const Color(0xFF666052),
                                ),
                              ),
                            ),
                            WiredMapLocation(
                              heading: heading.value,
                              headingStyle: style,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            WiredButton(
              onPressed: () =>
                  heading.value = ((heading.value ?? 0) + 45) % 360,
              child: const Text('Turn 45°'),
            ),
            WiredButton(
              onPressed: () =>
                  heading.value = heading.value == null ? 35 : null,
              child: Text(
                heading.value == null ? 'Restore heading' : 'Hide heading',
              ),
            ),
          ],
        ),
      ],
    );
  },
);
