import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

/// Changes the storybook's app-wide border and lettering level.
class WiredRoughnessPicker extends HookWidget {
  /// Creates a picker that reports a level without owning application state.
  const WiredRoughnessPicker({
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// The currently active level.
  final WiredRoughness value;

  /// Called when a level is selected.
  final ValueChanged<WiredRoughness> onChanged;

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
