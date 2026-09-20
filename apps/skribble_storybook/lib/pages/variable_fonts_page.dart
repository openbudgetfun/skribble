import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

/// Interactive controls for every axis of the bundled variable font.
class WiredVariableFontsPage extends HookWidget {
  /// Creates the variable font specimen.
  const WiredVariableFontsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sample = useTextEditingController(
      text: 'A little ink. A lot of possibility.\nHamburgefontsiv 0123456789',
    );
    final weight = useState<double>(400);
    final casual = useState<double>(1);
    final mono = useState<double>(0);
    final slant = useState<double>(0);
    final cursive = useState(0.5);
    final level = WiredTheme.of(context).roughnessLevel;
    useListenable(sample);
    return WiredScaffold(
      appBar: WiredAppBar(title: const Text('Variable fonts')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          WiredTextArea(
            controller: sample,
            semanticLabel: 'Variable specimen text',
            minLines: 2,
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          Text(
            sample.text,
            key: const ValueKey('variable-specimen'),
            style: TextStyle(
              fontFamily: WiredFont.variableFamilyFor(level),
              package: 'skribble_font_recursive',
              fontSize: 36,
              fontVariations: [
                FontVariation('wght', weight.value),
                FontVariation('CASL', casual.value),
                FontVariation('MONO', mono.value),
                FontVariation('slnt', slant.value),
                FontVariation('CRSV', cursive.value),
              ],
            ),
          ),
          const SizedBox(height: 24),
          for (final axis in [
            (label: 'Weight', state: weight, min: 300.0, max: 900.0),
            (label: 'Casualness', state: casual, min: 0.0, max: 1.0),
            (label: 'Monospace', state: mono, min: 0.0, max: 1.0),
            (label: 'Slant', state: slant, min: -15.0, max: 0.0),
          ]) ...[
            Text('${axis.label}: ${axis.state.value.toStringAsFixed(2)}'),
            WiredSlider(
              value: axis.state.value,
              min: axis.min,
              max: axis.max,
              semanticLabel: axis.label,
              onChanged: (value) {
                axis.state.value = value;
                return true;
              },
            ),
          ],
          const Text('Cursive letterforms'),
          Wrap(
            spacing: 8,
            children: [
              for (final mode in [
                (0.0, 'Roman'),
                (0.5, 'Auto'),
                (1.0, 'Cursive'),
              ])
                WiredChoiceChip(
                  label: Text(mode.$2),
                  selected: cursive.value == mode.$1,
                  onSelected: (_) => cursive.value = mode.$1,
                ),
            ],
          ),
          const SizedBox(height: 16),
          WiredButton(
            onPressed: () {
              weight.value = 400;
              casual.value = 1;
              mono.value = 0;
              slant.value = 0;
              cursive.value = 0.5;
            },
            child: const Text('Reset axes'),
          ),
        ],
      ),
    );
  }
}
