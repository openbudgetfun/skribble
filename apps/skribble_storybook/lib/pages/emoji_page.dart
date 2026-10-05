import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

/// The emoji each group tab shows.
const Map<EmojiGroup, String> _groupIcons = {
  EmojiGroup.smileysAndEmotion: '😀',
  EmojiGroup.peopleAndBody: '👋',
  EmojiGroup.animalsAndNature: '🐱',
  EmojiGroup.foodAndDrink: '🍕',
  EmojiGroup.travelAndPlaces: '🚀',
  EmojiGroup.activities: '🎉',
  EmojiGroup.objects: '💡',
  EmojiGroup.symbols: '✅',
  EmojiGroup.flags: '🇯🇵',
};

/// Browses skribble's hand-drawn emoji like a picker: one tab per Unicode
/// group, search by name, and a skin tone for every emoji that has one.
///
/// Tapping an emoji opens a preview at several sizes and pen weights.
class EmojiPage extends HookWidget {
  const EmojiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final group = useState(EmojiGroup.smileysAndEmotion);
    final query = useState('');
    final tone = useState(EmojiSkinTone.none);

    final entries = useMemoized(() {
      final found = query.value.trim().isEmpty
          ? SkribbleEmoji.inGroup(group.value)
          : SkribbleEmoji.search(query.value, limit: 200);
      return [
        for (final entry in found)
          if (entry.hasTones && tone.value != EmojiSkinTone.none)
            SkribbleEmoji.withTone(entry, tone.value) ?? entry
          else
            entry,
      ];
    }, [group.value, query.value, tone.value]);

    final textTheme = Theme.of(context).textTheme;

    return WiredScaffold(
      appBar: WiredAppBar(
        leading: const BackButton(),
        title: const Text('Emoji'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hand-drawn emoji', style: textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  '${SkribbleEmoji.all.length} emoji, every one drawn for '
                  'skribble and inked live with the theme pen.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                WiredInput(
                  hintText: 'Search emoji by name…',
                  semanticLabel: 'Search hand-drawn emoji',
                  hintStyle: TextStyle(color: theme.disabledTextColor),
                  onChanged: (value) => query.value = value,
                ),
                const SizedBox(height: 12),
                _ToneRow(
                  tone: tone.value,
                  onChanged: (value) => tone.value = value,
                ),
              ],
            ),
          ),
          if (query.value.trim().isEmpty) ...[
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final MapEntry(key: value, value: icon)
                      in _groupIcons.entries)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: WiredChoiceChip(
                        selected: group.value == value,
                        onSelected: (_) => group.value = value,
                        semanticLabel: value.label,
                        label: WiredEmoji(icon, semanticLabel: value.label),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Text(group.value.label, style: textTheme.titleMedium),
            ),
          ],
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Text(
                      'No emoji match "${query.value.trim()}"',
                      style: textTheme.bodyMedium?.copyWith(
                        color: theme.disabledTextColor,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 56,
                        ),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return Tooltip(
                        message: entry.name,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => _showPreview(context, entry),
                          child: Center(
                            child: WiredEmoji(entry.emoji, size: 36),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Opens a preview of [entry] at several sizes and pen weights.
  void _showPreview(BuildContext context, EmojiEntry entry) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) => _EmojiPreview(entry: entry),
      ),
    );
  }
}

/// A row of skin-tone swatches, each a waving hand in that tone.
class _ToneRow extends StatelessWidget {
  const _ToneRow({required this.tone, required this.onChanged});

  final EmojiSkinTone tone;
  final ValueChanged<EmojiSkinTone> onChanged;

  @override
  Widget build(BuildContext context) {
    final hand = SkribbleEmoji.lookup('👋')!;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('Skin tone', style: Theme.of(context).textTheme.labelLarge),
        for (final value in EmojiSkinTone.values)
          WiredChoiceChip(
            selected: tone == value,
            onSelected: (_) => onChanged(value),
            semanticLabel: '${value.label} skin tone',
            label: WiredEmoji(
              SkribbleEmoji.withTone(hand, value)!.emoji,
              size: 22,
            ),
          ),
      ],
    );
  }
}

/// The emoji at three sizes and three pen weights, with its name and code.
class _EmojiPreview extends StatelessWidget {
  const _EmojiPreview({required this.entry});

  final EmojiEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final codes = [
      for (final rune in entry.emoji.runes)
        'U+${rune.toRadixString(16).toUpperCase().padLeft(4, '0')}',
    ].join(' ');

    Widget labelled(Widget child, String label) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 6),
        Text(label, style: textTheme.bodySmall),
      ],
    );

    return WiredDialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              entry.name,
              style: textTheme.titleMedium?.copyWith(color: theme.textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '$codes · ${entry.group.label} › ${entry.subgroup}',
              style: textTheme.bodySmall?.copyWith(
                color: theme.disabledTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final size in const [24.0, 48.0, 96.0])
                  labelled(
                    WiredEmoji(entry.emoji, size: size),
                    '${size.round()} px',
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final (weight, label) in const [
                  (200.0, 'Light'),
                  (400.0, 'Regular'),
                  (700.0, 'Bold'),
                ])
                  labelled(
                    WiredEmoji(entry.emoji, size: 56, weight: weight),
                    label,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            WiredButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
