import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_docs_site/src/docs_keys.dart';
import 'package:skribble_docs_site/src/docs_surface.dart';

/// Matched specimens of original and roughened Recursive Casual and Linear.
class FontComparison extends HookWidget {
  /// Creates the comparison without replacing the app's current font.
  const FontComparison({super.key});

  @override
  Widget build(BuildContext context) {
    final sample = useState(
      'Little things, made with care.\nHamburgefontsiv 0123456789',
    );
    final size = useState<double>(24);
    final bold = useState(false);
    final italic = useState(false);
    final textController = useTextEditingController(text: sample.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Two kinds of handwriting',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'Compare Recursive Casual with Recursive Sans Linear. The original fonts keep their hinting; each roughened pair uses the same outline-warp strength.',
        ),
        const SizedBox(height: 20),
        const Text('Your specimen text'),
        const SizedBox(height: 8),
        WiredTextArea(
          key: DocsKeys.fontSample,
          controller: textController,
          semanticLabel: 'Your specimen text',
          minLines: 2,
          maxLines: 4,
          hintText: 'Little things, made with care.',
          onChanged: (value) => sample.value = value,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 4,
          children: [
            for (final value in [14.0, 16.0, 24.0, 48.0, 72.0])
              DocsAction(
                selected: size.value == value,
                onPressed: () => size.value = value,
                child: Text('${value.toInt()} px'),
              ),
            DocsAction(
              selected: bold.value,
              onPressed: () => bold.value = !bold.value,
              child: const Text('Bold'),
            ),
            DocsAction(
              selected: italic.value,
              onPressed: () => italic.value = !italic.value,
              child: const Text('Italic'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        for (final level in [null, ...WiredRoughness.values]) ...[
          Text(
            level == null
                ? 'Original · unmodified'
                : '${level.name[0].toUpperCase()}${level.name.substring(1)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final specimens = [
                for (final linear in [false, true])
                  _Specimen(
                    linear: linear,
                    level: level,
                    text: sample.value,
                    size: size.value,
                    bold: bold.value,
                    italic: italic.value,
                  ),
              ];

              return constraints.maxWidth < 560
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: specimens,
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final specimen in specimens)
                          Expanded(child: specimen),
                      ],
                    );
            },
          ),
          const SizedBox(height: 24),
        ],
        const Text(
          'Gentle makes small outline changes, especially at 14–16 px. Compare the original row at your actual reading size before deciding which family feels right.',
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _Specimen extends HookWidget {
  const _Specimen({
    required this.linear,
    required this.level,
    required this.text,
    required this.size,
    required this.bold,
    required this.italic,
  });
  final bool linear;
  final WiredRoughness? level;
  final String text;
  final double size;
  final bool bold;
  final bool italic;

  @override
  Widget build(BuildContext context) {
    final family = level == null
        ? linear
              ? 'RecursiveLinearOriginal'
              : 'RecursiveCasualOriginal'
        : linear
        ? 'SkribbleLinear${level!.name[0].toUpperCase()}${level!.name.substring(1)}'
        : level!.fontFamily;

    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            linear ? 'Sans Linear' : 'Sans Casual',
            style: const TextStyle(fontSize: 13, color: Color(0xff716275)),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              inherit: false,
              color: const Color(0xff34283f),
              fontFamily: family,
              package: !linear && level != null ? 'skribble' : null,
              fontSize: size,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
