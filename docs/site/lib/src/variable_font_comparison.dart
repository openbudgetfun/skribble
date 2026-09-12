import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_docs_site/src/docs_surface.dart';

/// Compares continuous font axes with the nearest dedicated static face.
class VariableFontComparison extends HookWidget {
  /// Creates the variable lettering playground.
  const VariableFontComparison({super.key});

  @override
  Widget build(BuildContext context) {
    final weight = useState<double>(400);
    final casual = useState<double>(1);
    final mono = useState<double>(0);
    final slant = useState<double>(0);
    final cursive = useState(0.5);
    final roughness = useState(WiredRoughness.playful);
    final sample = useState(
      'A little ink, a lot of possibility.\nHamburgefontsiv 0123456789',
    );
    final controller = useTextEditingController(text: sample.value);
    final staticWeight = (weight.value / 100).round().clamp(3, 9);
    final staticFont = mono.value >= 0.5
        ? WiredFont.mono
        : casual.value >= 0.5
        ? WiredFont.casual
        : WiredFont.linear;
    final staticItalic = slant.value <= -7.5;
    final variations = [
      FontVariation('wght', weight.value),
      FontVariation('CASL', casual.value),
      FontVariation('MONO', mono.value),
      FontVariation('slnt', slant.value),
      FontVariation('CRSV', cursive.value),
    ];

    Widget slider(
      String name,
      ValueNotifier<double> state,
      double min,
      double max,
    ) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$name · ${state.value.toStringAsFixed(name == 'Weight' ? 0 : 2)}',
        ),
        SizedBox(
          height: 40,
          child: WiredSlider(
            key: ValueKey('variable-$name'),
            semanticLabel: name,
            value: state.value,
            min: min,
            max: max,
            onChanged: (value) {
              state.value = value;
              return true;
            },
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Lettering in motion',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'Slide between real weights and styles. The variable font moves continuously; the dedicated file beside it changes in steps.',
        ),
        const SizedBox(height: 16),
        WiredTextArea(
          controller: controller,
          semanticLabel: 'Variable specimen text',
          minLines: 2,
          maxLines: 4,
          onChanged: (text) => sample.value = text,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 4,
          children: [
            for (final level in WiredRoughness.values)
              DocsAction(
                selected: roughness.value == level,
                onPressed: () => roughness.value = level,
                child: Text(level.name),
              ),
            DocsAction(
              onPressed: () {
                weight.value = 400;
                casual.value = 1;
                mono.value = 0;
                slant.value = 0;
                cursive.value = 0.5;
                roughness.value = WiredRoughness.playful;
              },
              child: const Text('Reset axes'),
            ),
          ],
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              _Preview(
                title: 'Variable · ${weight.value.round()}',
                text: sample.value,
                specimenKey: const ValueKey('variable-specimen'),
                style: TextStyle(
                  fontFamily: WiredFont.variableFamilyFor(roughness.value),
                  package: 'skribble',
                  fontVariations: variations,
                ),
              ),
              _Preview(
                title:
                    'Static · ${staticFont.name} · ${staticWeight * 100}${staticItalic ? ' italic' : ''}',
                text: sample.value,
                specimenKey: const ValueKey('static-specimen'),
                style: TextStyle(
                  fontFamily: staticFont.familyFor(roughness.value),
                  package: 'skribble',
                  fontWeight: FontWeight.values[staticWeight - 1],
                  fontStyle: staticItalic ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ];
            if (constraints.maxWidth < 650) return Column(children: cards);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (final card in cards) Expanded(child: card)],
            );
          },
        ),
        const SizedBox(height: 12),
        slider('Weight', weight, 300, 900),
        Wrap(
          spacing: 4,
          children: [
            for (final value in [300, 400, 500, 600, 700, 800, 900])
              DocsAction(
                selected: weight.value == value,
                onPressed: () => weight.value = value.toDouble(),
                child: Text('$value'),
              ),
          ],
        ),
        slider('Casualness', casual, 0, 1),
        slider('Monospace', mono, 0, 1),
        slider('Slant', slant, -15, 0),
        const Text('Cursive letterforms'),
        Wrap(
          spacing: 4,
          children: [
            for (final mode in [
              (0.0, 'Roman'),
              (0.5, 'Auto'),
              (1.0, 'Cursive'),
            ])
              DocsAction(
                selected: cursive.value == mode.$1,
                onPressed: () => cursive.value = mode.$1,
                child: Text(mode.$2),
              ),
          ],
        ),
        const Text(
          'Cursive switches letter shapes. Auto follows the slant; it is not a continuous blend.',
        ),
        const SizedBox(height: 20),
        const SizedBox(height: 12),
        const Text(
          'The static preview uses the nearest 100-step weight and Casual, Linear, or Mono Linear family. Italics use a −15° slant and cursive forms. Intermediate style positions and upright cursive forms are available in the variable font.',
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _Preview extends HookWidget {
  const _Preview({
    required this.title,
    required this.text,
    required this.style,
    required this.specimenKey,
  });
  final String title;
  final String text;
  final TextStyle style;
  final Key specimenKey;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 16, bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 12),
        Text(
          text,
          key: specimenKey,
          style: style.copyWith(
            inherit: false,
            color: const Color(0xff34283f),
            fontSize: 28,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}
