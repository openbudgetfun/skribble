import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

/// Lazy-rendered gallery of the hand-drawn OpenMoji emoji set.
///
/// Renders only the visible rows of the grid via `GridView.builder`, with a
/// search bar filtering by emoji name and tappable cells that open a preview
/// dialog showing the emoji at 24/48/96 px.
class EmojiPage extends HookWidget {
  const EmojiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final searchQuery = useState('');

    final sortedNames = useMemoized(
      () => kSkribbleEmojiCodePoints.keys.toList()..sort(),
    );

    final filteredNames = useMemoized(
      () {
        final query = searchQuery.value.trim().toLowerCase();
        if (query.isEmpty) {
          return sortedNames;
        }
        return sortedNames
            .where((name) => name.toLowerCase().contains(query))
            .toList(growable: false);
      },
      [searchQuery.value, sortedNames],
    );

    return WiredScaffold(
      appBar: WiredAppBar(
        leading: const BackButton(),
        title: const Text('Emoji'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hand-drawn emoji set',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${sortedNames.length} emoji from OpenMoji',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                WiredInput(
                  hintText: 'Search emoji by name…',
                  semanticLabel: 'Search hand-drawn emoji',
                  hintStyle: TextStyle(color: theme.disabledTextColor),
                  onChanged: (value) => searchQuery.value = value,
                ),
              ],
            ),
          ),
          Expanded(
            child: sortedNames.isEmpty
                ? _EmptyCatalogMessage(theme: theme)
                : filteredNames.isEmpty
                ? Center(
                    child: Text(
                      'No emoji match "${searchQuery.value.trim()}"',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: theme.disabledTextColor,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 64,
                          childAspectRatio: 0.72,
                        ),
                    itemCount: filteredNames.length,
                    itemBuilder: (context, index) {
                      final name = filteredNames[index];
                      return InkWell(
                        onTap: () => _showPopup(context, name),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            WiredEmoji.fromName(name, size: 32),
                            const SizedBox(height: 4),
                            Text(
                              name,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontSize: 9),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Opens a hand-drawn preview dialog showing the emoji at 24/48/96 px.
  void _showPopup(BuildContext context, String name) {
    final theme = WiredTheme.of(context);
    final codePoint = kSkribbleEmojiCodePoints[name];

    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: RoughBoxDecoration(
                // Per-icon fixed seed: the wobble is deterministic for the
                // same emoji across rebuilds and app runs. Names without a
                // catalogued codepoint (placeholders) share the default seed.
                seed: codePoint ?? 1,
                borderStyle: RoughDrawingStyle(
                  width: 2,
                  color: theme.borderColor,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    name,
                    style: Theme.of(dialogContext).textTheme.titleMedium
                        ?.copyWith(color: theme.textColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final size in const [24.0, 48.0, 96.0])
                        Column(
                          children: [
                            WiredEmoji.fromName(name, size: size),
                            const SizedBox(height: 6),
                            Text(
                              '${size.round()}px',
                              style: Theme.of(dialogContext).textTheme.bodySmall
                                  ?.copyWith(color: theme.textColor),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyCatalogMessage extends HookWidget {
  const _EmptyCatalogMessage({required this.theme});

  final WiredThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const WiredEmoji(size: 48),
            const SizedBox(height: 12),
            Text(
              'No emoji generated yet.\n'
              'Run the rough icon pipeline against the emoji '
              'manifest to populate this gallery.',
              style: TextStyle(color: theme.textColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
