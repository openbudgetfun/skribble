import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

/// Font specimen page — every renderable character of the bundled Skribble
/// font family, across weights and sizes.
///
/// Covers Latin letters, digits, punctuation, currency, math, and assorted
/// symbols. Characters are rendered with the `Skribble` family and fall back
/// to the platform font for anything the roughened font does not contain.
class FontSpecimenPage extends HookWidget {
  const FontSpecimenPage({super.key});

  /// Latin alphabet, digits, punctuation, currency, math, and common symbols.
  static const characterBlocks = <String, String>{
    'Uppercase': 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    'Lowercase': 'abcdefghijklmnopqrstuvwxyz',
    'Digits': '0123456789',
    'Punctuation': r""".,;:!?'"-–—()[]{}/\&@#*†‡§¶•¡¿’“”„""",
    'Currency': r'''$¢£¤¥€₿₽₹₺₩₴₸''',
    'Math': '+−×÷=≠<≤>≥±~≈%‰^|',
    'Symbols': '©®™°µ¶¼½¾¹²³⁴←↑→↓↔↕↖↗↘↙⌘⌥⇧⌃⏎⌫␣',
  };

  static const sizes = <double>[12, 16, 24, 36, 48];

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final selectedWeight = useState<double>(400);
    final weights = <double, String>{
      400: 'Regular',
      700: 'Bold',
    };
    final italic = useState<bool>(false);
    final size = useState<double>(24);

    return WiredScaffold(
      appBar: WiredAppBar(title: const Text('Font Specimen')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Skribble typeface',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Every glyph of the bundled hand-drawn font, roughened from '
              'Recursive (Casual axis).',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Weight / style / size controls.
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final entry in weights.entries)
                  ChoiceChip(
                    label: Text(entry.value),
                    selected: selectedWeight.value == entry.key,
                    onSelected: (_) => selectedWeight.value = entry.key,
                  ),
                ChoiceChip(
                  label: const Text('Italic'),
                  selected: italic.value,
                  onSelected: (v) => italic.value = v,
                ),
                for (final s in sizes)
                  ChoiceChip(
                    label: Text('${s.round()} px'),
                    selected: size.value == s,
                    onSelected: (_) => size.value = s,
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Sample sentence.
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The quick brown fox jumps over the lazy dog.',
                    style: TextStyle(
                      fontFamily: skribbleFontFamily,
                      fontSize: size.value,
                      fontWeight: selectedWeight.value == 700
                          ? FontWeight.bold
                          : null,
                      fontStyle: italic.value ? FontStyle.italic : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pack my box with five dozen liquor jugs. 0123456789',
                    style: TextStyle(
                      fontFamily: skribbleFontFamily,
                      fontSize: size.value * 0.75,
                      fontWeight: selectedWeight.value == 700
                          ? FontWeight.bold
                          : null,
                      fontStyle: italic.value ? FontStyle.italic : null,
                      color: theme.textColor.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Full character tables, grouped by block.
            for (final block in characterBlocks.entries) ...[
              Text(
                block.key,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final rune in block.value.runes)
                    _GlyphCard(
                      character: String.fromCharCode(rune),
                      codePoint: rune,
                      fontSize: size.value,
                      bold: selectedWeight.value == 700,
                      italic: italic.value,
                      textColor: theme.textColor,
                    ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class _GlyphCard extends StatelessWidget {
  const _GlyphCard({
    required this.character,
    required this.codePoint,
    required this.fontSize,
    required this.bold,
    required this.italic,
    required this.textColor,
  });

  final String character;
  final int codePoint;
  final double fontSize;
  final bool bold;
  final bool italic;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    // Visible placeholder for whitespace glyphs.
    final glyph = codePoint == 0x20 ? '·' : character;
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              glyph,
              style: TextStyle(
                fontFamily: skribbleFontFamily,
                fontSize: fontSize,
                fontWeight: bold ? FontWeight.bold : null,
                fontStyle: italic ? FontStyle.italic : null,
                color: textColor,
                height: 1.2,
              ),
            ),
          ),
          Text(
            'U+${codePoint.toRadixString(16).toUpperCase().padLeft(4, '0')}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 9,
              color: textColor.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
