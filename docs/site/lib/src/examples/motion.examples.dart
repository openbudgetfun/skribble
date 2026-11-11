part of 'catalog.dart';

/// @docs-example ink-reveal
Widget _inkReveal(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final replay = useState(0);
    return Column(
      children: [
        WiredDraw(
          key: ValueKey(replay.value),
          child: WiredCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(settings.label),
            ),
          ),
        ),
        const SizedBox(height: 16),
        WiredOutlinedButton(
          onPressed: () => replay.value++,
          child: const Text('Draw again'),
        ),
      ],
    );
  },
);

/// @docs-example ink-progress
Widget _inkProgress(ExampleSettings settings) => WiredDrawTransition(
  progress: AlwaysStoppedAnimation(settings.amount),
  child: WiredCard(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(settings.label),
    ),
  ),
);

/// @docs-example ink-basic
Widget _inkBasic(ExampleSettings settings) => WiredDraw(
  child: WiredCard(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(settings.label),
    ),
  ),
);

/// @docs-example redraw-button
Widget _redrawButton(ExampleSettings settings) => WiredFilledButton(
  inkInteraction: WiredInkInteraction.redraw,
  fillColor: settings.color,
  borderRadius: BorderRadius.circular(settings.radius),
  onPressed: () {},
  child: Text(settings.label),
);

/// @docs-example entrance-cascade
Widget _entranceCascade(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final replay = useState(0);
    final theme = WiredTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WiredCascade(
          key: ValueKey(replay.value),
          spacing: 12,
          children: [
            for (final (i, plant) in const ['Fern', 'Cactus', 'Basil'].indexed)
              WiredCard(
                height: null,
                color: theme.accentAt(i),
                child: Text(plant),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: WiredOutlinedButton(
            onPressed: () => replay.value++,
            child: const Text('Again!'),
          ),
        ),
      ],
    );
  },
);

/// @docs-example boil-doodle
Widget _boilDoodle(ExampleSettings settings) => const WiredBoil(
  child: Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 16,
    children: [
      WiredDoodle(
        kind: WiredDoodleKind.sun,
        size: 72,
        fillColor: WiredPalette.sunshine,
      ),
      WiredDoodle(
        kind: WiredDoodleKind.heart,
        size: 72,
        fillColor: WiredPalette.bubblegum,
      ),
      WiredDoodle(
        kind: WiredDoodleKind.sparkle,
        size: 72,
        fillColor: WiredPalette.sky,
      ),
    ],
  ),
);

/// @docs-example highlight-marker
Widget _highlightMarker(ExampleSettings settings) => Builder(
  builder: (context) {
    final theme = WiredTheme.of(context);
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: 'Ink that '),
          const WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: WiredHighlight(child: Text('pops')),
          ),
          const TextSpan(text: ' off the '),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: WiredHighlight(
              style: WiredHighlightStyle.underline,
              color: theme.accentAt(1),
              delay: const Duration(milliseconds: 400),
              child: const Text('page'),
            ),
          ),
        ],
      ),
      style: const TextStyle(fontSize: 24),
    );
  },
);
