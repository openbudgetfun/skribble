import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

/// Changes the storybook's app-wide ink, typeface, and paper.
class WiredRoughnessPicker extends HookWidget {
  /// Creates a picker that reports a level without owning application state.
  const WiredRoughnessPicker({
    required this.value,
    required this.onChanged,
    this.font = WiredFont.casual,
    this.onFontChanged,
    this.night = false,
    this.onNightChanged,
    super.key,
  });

  /// The currently active level.
  final WiredRoughness value;

  /// Called when a level is selected.
  final ValueChanged<WiredRoughness> onChanged;

  /// The bundled font family used throughout the storybook.
  final WiredFont font;

  /// Called when a different bundled font is selected.
  final ValueChanged<WiredFont>? onFontChanged;

  /// Whether the storybook is drawn on night paper.
  final bool night;

  /// Called when day or night paper is chosen.
  final ValueChanged<bool>? onNightChanged;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: WiredTheme.of(context).fillColor,
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Ink style', style: TextStyle(fontSize: 14)),
            for (final level in WiredRoughness.values)
              WiredChoiceChip(
                key: ValueKey('roughness-${level.name}'),
                selected: level == value,
                semanticLabel: _label(level),
                onSelected: (_) => onChanged(level),
                label: ExcludeSemantics(child: Text(_label(level))),
              ),
            if (onFontChanged != null) ...[
              const Text('Typeface', style: TextStyle(fontSize: 14)),
              for (final family in WiredFont.values)
                WiredChoiceChip(
                  label: Text(switch (family) {
                    WiredFont.casual => 'Casual',
                    WiredFont.linear => 'Linear',
                    WiredFont.mono => 'Mono',
                  }),

                  selected: family == font,
                  onSelected: (_) => onFontChanged!(family),
                ),
            ],
            if (onNightChanged != null) ...[
              const Text('Paper', style: TextStyle(fontSize: 14)),
              for (final (value, label) in const [
                (false, 'Day'),
                (true, 'Night'),
              ])
                WiredChoiceChip(
                  key: ValueKey('paper-$label'),
                  label: Text(label),
                  selected: value == night,
                  onSelected: (_) => onNightChanged!(value),
                ),
            ],
          ],
        ),
      ),
    ),
  );
}

String _label(WiredRoughness level) => switch (level) {
  WiredRoughness.gentle => 'Gentle',
  WiredRoughness.playful => 'Playful',
  WiredRoughness.expressive => 'Expressive',
};
