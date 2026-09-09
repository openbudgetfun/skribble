import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_maps/skribble_maps.dart';

enum _MapInk { paper, night }

/// Interactive showcase for the hand-drawn map package.
class MapsPage extends HookWidget {
  const MapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ink = useState(_MapInk.paper);
    final selectedPlace = useState('Tap a pin to choose the next stop');
    final style = switch (ink.value) {
      _MapInk.paper => WiredMapStyle.paper,
      _MapInk.night => WiredMapStyle.night,
    };

    return WiredScaffold(
      appBar: WiredAppBar(
        leading: const _MapBackButton(),
        title: const Text('Hand-drawn maps'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'A real vector map, redrawn in ink',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pan, pinch, scroll, or double-tap. Roads and buildings are '
              'decoded from open vector tiles, then painted by Skribble.',
              style: TextStyle(fontSize: 14, height: 1.25),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: WiredSegmentedButton<_MapInk>(
                segments: const [
                  WiredButtonSegment(
                    value: _MapInk.paper,
                    label: Text('Morning paper'),
                  ),
                  WiredButtonSegment(
                    value: _MapInk.night,
                    label: Text('Evening ink'),
                  ),
                ],
                selected: {ink.value},
                onSelectionChanged: (selection) {
                  ink.value = selection.single;
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(18)),
                child: WiredMap(
                  initialCenter: const LatLng(51.5242, -0.0778),
                  initialZoom: 14.2,
                  minimumZoom: 2,
                  maximumZoom: 18,
                  backgroundColor: style.paperColor,
                  basemap: WiredOpenFreeMapLayer(
                    style: style,
                    errorBuilder: (_, _, _) => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'The online tiles are unavailable. The route and '
                          'pins remain interactive.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  children: [
                    WiredMapFeatureLayer(
                      semanticLabel: 'A walking route through Shoreditch',
                      features: [
                        WiredMapPolygon(
                          points: const [
                            LatLng(51.5256, -0.0798),
                            LatLng(51.5258, -0.0769),
                            LatLng(51.5245, -0.0765),
                            LatLng(51.5242, -0.0792),
                          ],
                          fillColor: const Color(0x33F19C79),
                          inkColor: const Color(0xFFC66A4A),
                        ),
                        WiredMapPolyline(
                          points: const [
                            LatLng(51.5228, -0.0810),
                            LatLng(51.5235, -0.0790),
                            LatLng(51.5242, -0.0778),
                            LatLng(51.5251, -0.0758),
                            LatLng(51.5260, -0.0740),
                          ],
                          color: const Color(0xFFD95C45),
                          strokeWidth: 4,
                          seed: 91,
                        ),
                      ],
                    ),
                    WiredMapMarkerLayer(
                      markers: [
                        WiredMapMarker(
                          point: const LatLng(51.5228, -0.0810),
                          semanticLabel: 'Coffee stop',
                          onTap: () => selectedPlace.value = 'Coffee stop',
                          child: const WiredMapPin(child: Text('☕')),
                        ),
                        WiredMapMarker(
                          point: const LatLng(51.5242, -0.0778),
                          semanticLabel: 'Brick Lane market',
                          onTap: () =>
                              selectedPlace.value = 'Brick Lane market',
                          child: const WiredMapPin(
                            fillColor: Color(0xFFFFD58A),
                            child: Text('★'),
                          ),
                        ),
                        WiredMapMarker(
                          point: const LatLng(51.5260, -0.0740),
                          semanticLabel: 'Gallery stop',
                          onTap: () => selectedPlace.value = 'Gallery stop',
                          child: const WiredMapPin(
                            fillColor: Color(0xFFCDE7DB),
                            child: Text('✎'),
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
