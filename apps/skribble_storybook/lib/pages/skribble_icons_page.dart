import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_icons/skribble_icons.dart';

/// Lazy-rendered gallery of the 30 curated hand-drawn Skribble icons.
///
/// Renders only the visible rows of the grid via `GridView.builder`, with a
/// search bar filtering by identifier and tappable cells that open a preview
/// dialog showing the icon at 24/48/96 px.
class SkribbleIconsPage extends HookWidget {
  const SkribbleIconsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final searchQuery = useState('');

    final sortedEntries = useMemoized(() {
      final entries = kSkribbleCustomIconsCodePoints.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      return entries;
    });

    final filteredEntries = useMemoized(
      () {
        final query = searchQuery.value.trim().toLowerCase();
        if (query.isEmpty) {
          return sortedEntries;
        }
        return sortedEntries
            .where((entry) => entry.key.toLowerCase().contains(query))
            .toList(growable: false);
      },
      [searchQuery.value, sortedEntries],
    );

    return WiredScaffold(
      appBar: WiredAppBar(
        leading: const BackButton(),
        title: const Text('Skribble Icons'),
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
                  'Curated hand-drawn icon set',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${sortedEntries.length} custom icons',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                WiredInput(
                  hintText: 'Search icons by name…',
                  semanticLabel: 'Search Skribble icons',
                  hintStyle: TextStyle(color: theme.disabledTextColor),
                  onChanged: (value) => searchQuery.value = value,
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredEntries.isEmpty
                ? Center(
                    child: Text(
                      'No icons match "${searchQuery.value.trim()}"',
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
                    itemCount: filteredEntries.length,
                    itemBuilder: (context, index) {
                      final entry = filteredEntries[index];
                      return InkWell(
                        onTap: () =>
                            _showPopup(context, entry.key, entry.value),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SkribbleIcon(
                              data: lookupSkribbleIconByIdentifier(
                                entry.key,
                              )!,
                              size: 32,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry.key,
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

  /// Opens a hand-drawn preview dialog showing the icon at 24/48/96 px.
  void _showPopup(BuildContext context, String identifier, int codePoint) {
    final theme = WiredTheme.of(context);
    final data = lookupSkribbleIconByIdentifier(identifier);

    if (data == null) {
      return;
    }

    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: RoughBoxDecoration(
                // Per-icon fixed seed: the wobble is deterministic for the
                // same icon across rebuilds and app runs.
                seed: codePoint,
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
                    identifier,
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
                            SkribbleIcon(
                              data: data,
                              size: size,
                              semanticLabel: identifier,
                            ),
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
