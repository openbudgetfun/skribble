import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_maps/skribble_maps.dart';

enum _MapInk { paper, night }

enum _MapCity { london, dubai, tokyo }

/// Interactive showcase for the hand-drawn map package.
class MapsPage extends HookWidget {
  const MapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ink = useState(_MapInk.paper);
    final city = useState(_MapCity.london);
    final selectedPlace = useState('Tap a pin to choose the next stop');
    final mapController = useMemoized(
      () => WiredMapController(
        initialCenter: _places[_MapCity.london]!.center,
        initialZoom: _places[_MapCity.london]!.zoom,
        minimumZoom: 2,
        maximumZoom: 18,
      ),
    );
    final style = switch (ink.value) {
      _MapInk.paper => WiredMapStyle.paper,
      _MapInk.night => WiredMapStyle.night,
    };
    final overlayPalette = switch (ink.value) {
      _MapInk.paper => const _MapOverlayPalette(
        areaFill: Color(0x286A7568),
        areaInk: Color(0xFF657064),
        routeInk: Color(0xFF66584B),
      ),
      _MapInk.night => const _MapOverlayPalette(
        areaFill: Color(0x3D9EAA9A),
        areaInk: Color(0xFFBCC6B7),
        routeInk: Color(0xFFD8BE9B),
      ),
    };
    final places = _places[city.value]!;

    useEffect(() => mapController.dispose, [mapController]);

    useEffect(() {
      unawaited(
        mapController.animateTo(places.center, zoom: places.zoom),
      );
      selectedPlace.value = 'Tap a pin to choose the next stop';

      return null;
    }, [mapController, places]);

    return WiredScaffold(
      appBar: WiredAppBar(
        leading: const _MapBackButton(),
        title: const Text('MapLibre maps'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Clear maps, drawn interactions',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'MapLibre renders the streets and labels. Skribble draws the '
              'route, area, pins, and controls above it.',
              style: TextStyle(fontSize: 14, height: 1.25),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                WiredSegmentedButton<_MapCity>(
                  segments: const [
                    WiredButtonSegment(
                      value: _MapCity.london,
                      label: Text('London'),
                    ),
                    WiredButtonSegment(
                      value: _MapCity.dubai,
                      label: Text('Dubai'),
                    ),
                    WiredButtonSegment(
                      value: _MapCity.tokyo,
                      label: Text('Tokyo'),
                    ),
                  ],
                  selected: {city.value},
                  onSelectionChanged: (selection) {
                    city.value = selection.single;
                  },
                ),
                WiredSegmentedButton<_MapInk>(
                  segments: const [
                    WiredButtonSegment(
                      value: _MapInk.paper,
                      label: Text('Paper'),
                    ),
                    WiredButtonSegment(
                      value: _MapInk.night,
                      label: Text('Night'),
                    ),
                  ],
                  selected: {ink.value},
                  onSelectionChanged: (selection) {
                    ink.value = selection.single;
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(18)),
                child: WiredMap(
                  controller: mapController,
                  minimumZoom: 2,
                  maximumZoom: 18,
                  style: style,
                  children: [
                    WiredMapFeatureLayer(
                      semanticLabel: places.routeLabel,
                      features: [
                        WiredMapPolygon(
                          points: places.area,
                          fillColor: overlayPalette.areaFill,
                          inkColor: overlayPalette.areaInk,
                        ),
                        WiredMapPolyline(
                          points: places.route,
                          color: overlayPalette.routeInk,
                          strokeWidth: 4,
                          seed: 91,
                        ),
                      ],
                    ),
                    WiredMapMarkerLayer(
                      markers: [
                        for (final place in places.markers)
                          WiredMapMarker(
                            point: place.point,
                            semanticLabel: place.label,
                            onTap: () => selectedPlace.value = place.label,
                            child: WiredMapPin(
                              icon: place.icon,
                              fillColor: place.fillColor,
                              inkColor: const Color(0xFF37342F),
                            ),
                          ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: _MapStatus(text: selectedPlace.value),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapOverlayPalette {
  const _MapOverlayPalette({
    required this.areaFill,
    required this.areaInk,
    required this.routeInk,
  });

  final Color areaFill;
  final Color areaInk;
  final Color routeInk;
}

class _MapPlaces {
  const _MapPlaces({
    required this.center,
    required this.zoom,
    required this.routeLabel,
    required this.route,
    required this.area,
    required this.markers,
  });

  final LatLng center;
  final double zoom;
  final String routeLabel;
  final List<LatLng> route;
  final List<LatLng> area;
  final List<_MapPlace> markers;
}

class _MapPlace {
  const _MapPlace({
    required this.point,
    required this.label,
    required this.icon,
    required this.fillColor,
  });

  final LatLng point;
  final String label;
  final WiredMapPinIcon icon;
  final Color fillColor;
}

const _places = <_MapCity, _MapPlaces>{
  _MapCity.london: _MapPlaces(
    center: LatLng(51.5242, -0.0778),
    zoom: 14.2,
    routeLabel: 'A walking route through Shoreditch',
    route: [
      LatLng(51.5228, -0.0810),
      LatLng(51.5235, -0.0790),
      LatLng(51.5242, -0.0778),
      LatLng(51.5251, -0.0758),
      LatLng(51.5260, -0.0740),
    ],
    area: [
      LatLng(51.5256, -0.0798),
      LatLng(51.5258, -0.0769),
      LatLng(51.5245, -0.0765),
      LatLng(51.5242, -0.0792),
    ],
    markers: [
      _MapPlace(
        point: LatLng(51.5228, -0.0810),
        label: 'Coffee stop',
        icon: WiredMapPinIcon.coffee,
        fillColor: Color(0xFFF1E9DB),
      ),
      _MapPlace(
        point: LatLng(51.5242, -0.0778),
        label: 'Brick Lane market',
        icon: WiredMapPinIcon.market,
        fillColor: Color(0xFFE6EBE2),
      ),
      _MapPlace(
        point: LatLng(51.5260, -0.0740),
        label: 'Gallery stop',
        icon: WiredMapPinIcon.gallery,
        fillColor: Color(0xFFECE5E2),
      ),
    ],
  ),
  _MapCity.dubai: _MapPlaces(
    center: LatLng(25.1972, 55.2744),
    zoom: 14.4,
    routeLabel: 'A walking route through Downtown Dubai',
    route: [
      LatLng(25.1949, 55.2782),
      LatLng(25.1961, 55.2764),
      LatLng(25.1972, 55.2744),
      LatLng(25.1984, 55.2729),
      LatLng(25.1995, 55.2715),
    ],
    area: [
      LatLng(25.1989, 55.2730),
      LatLng(25.1982, 55.2760),
      LatLng(25.1963, 55.2757),
      LatLng(25.1967, 55.2728),
    ],
    markers: [
      _MapPlace(
        point: LatLng(25.1949, 55.2782),
        label: 'Coffee by the boulevard',
        icon: WiredMapPinIcon.coffee,
        fillColor: Color(0xFFF1E9DB),
      ),
      _MapPlace(
        point: LatLng(25.1972, 55.2744),
        label: 'Dubai Mall',
        icon: WiredMapPinIcon.market,
        fillColor: Color(0xFFE6EBE2),
      ),
      _MapPlace(
        point: LatLng(25.1995, 55.2715),
        label: 'Burj Park',
        icon: WiredMapPinIcon.favorite,
        fillColor: Color(0xFFECE5E2),
      ),
    ],
  ),
  _MapCity.tokyo: _MapPlaces(
    center: LatLng(35.6595, 139.7005),
    zoom: 15,
    routeLabel: 'A walking route through Shibuya',
    route: [
      LatLng(35.6575, 139.6990),
      LatLng(35.6584, 139.6998),
      LatLng(35.6595, 139.7005),
      LatLng(35.6603, 139.7016),
      LatLng(35.6612, 139.7025),
    ],
    area: [
      LatLng(35.6606, 139.6992),
      LatLng(35.6608, 139.7017),
      LatLng(35.6592, 139.7019),
      LatLng(35.6590, 139.6994),
    ],
    markers: [
      _MapPlace(
        point: LatLng(35.6575, 139.6990),
        label: 'Coffee stop',
        icon: WiredMapPinIcon.coffee,
        fillColor: Color(0xFFF1E9DB),
      ),
      _MapPlace(
        point: LatLng(35.6595, 139.7005),
        label: 'Shibuya crossing',
        icon: WiredMapPinIcon.person,
        fillColor: Color(0xFFE6EBE2),
      ),
      _MapPlace(
        point: LatLng(35.6612, 139.7025),
        label: 'Gallery stop',
        icon: WiredMapPinIcon.gallery,
        fillColor: Color(0xFFECE5E2),
      ),
    ],
  ),
};

class _MapBackButton extends HookWidget {
  const _MapBackButton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Back',
      button: true,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.maybePop(context),
        child: const SizedBox.square(
          dimension: 44,
          child: Center(
            child: Text('‹', style: TextStyle(fontSize: 34, height: 1)),
          ),
        ),
      ),
    );
  }
}

class _MapStatus extends HookWidget {
  const _MapStatus({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return buildWiredElement(
      child: DecoratedBox(
        decoration: RoughBoxDecoration(
          drawConfig: theme.drawConfig.copyWith(seed: 19),
          shape: RoughBoxShape.roundedRectangle,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderStyle: RoughDrawingStyle(
            width: theme.strokeWidth,
            color: theme.borderColor,
          ),
          fillStyle: RoughDrawingStyle(
            color: theme.fillColor.withValues(alpha: 0.92),
          ),
          filler: SolidFiller(),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Text(text, style: const TextStyle(fontSize: 12)),
        ),
      ),
    );
  }
}
