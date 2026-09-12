import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

/// An interactive sketch sheet for choosing a flourish and a stable seed.
class DoodlePlayground extends HookWidget {
  /// Creates the sketch sheet used by the flourish documentation.
  const DoodlePlayground({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = useState(WiredDoodleKind.butterfly);
    final seed = useState(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Draw a little happiness.',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final kind in WiredDoodleKind.values)
              WiredChoiceChip(
                label: Text(kind.name),
                selected: selected.value == kind,
                onSelected: (_) => selected.value = kind,
              ),
          ],
        ),
        const SizedBox(height: 24),
        Center(
          child: WiredDraw(
            key: ValueKey((selected.value, seed.value)),
            child: WiredDoodle(
              kind: selected.value,
              seed: seed.value,
              size: 180,
              strokeWidth: 3,
              fillColor: WiredPalette.peach,
              semanticLabel: '${selected.value.name}, drawing ${seed.value}',
            ),
          ),
        ),
        const SizedBox(height: 16),
        WiredButton(
          onPressed: () => seed.value++,
          child: const Text('Draw another'),
        ),
        const SizedBox(height: 16),
        Text(
          'WiredDoodle(\n  kind: WiredDoodleKind.${selected.value.name},\n  seed: ${seed.value},\n)',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
