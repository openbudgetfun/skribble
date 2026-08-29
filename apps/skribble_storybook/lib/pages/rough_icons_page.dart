import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

/// Lazy-rendered gallery of every precomputed roughened Material icon.
///
/// Renders only the visible rows of the grid via `GridView.builder`, so the
/// full 8.6k-icon catalog stays scrollable on low-end devices. Cells are
/// tappable and open a hand-drawn preview dialog with the icon drawn at
/// 24/48/96 px alongside its identifier.
class RoughIconsPage extends HookWidget {
  const RoughIconsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final searchQuery = useState('');

    final sortedEntries = useMemoized(() {
      final entries = materialRoughFontCodePoints.entries.toList()
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
            .where(
              (entry) => _matchesQuery(entry.key, entry.value, query),
            )
            .toList(growable: false);
      },
      [searchQuery.value, sortedEntries],
    );

    final totalCount = sortedEntries.length;

    return WiredScaffold(
      appBar: WiredAppBar(
        leading: const BackButton(),
        title: const Text('Rough Icons'),
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
                  'Generated rough Material icon catalog',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalCount icons',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                WiredInput(
                  hintText: 'Search icons by name or codepoint…',
                  semanticLabel: 'Search rough Material icons',
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
                            WiredIcon(
                              // Storybook gallery: renders every catalogued
                              // codepoint at runtime; const evaluation (and
                              // the icon tree-shaking it enables) does not
                              // apply.
                              icon: IconData(
                                // Renders every catalogued codepoint at
                                // runtime; const evaluation (and the icon
                                // tree-shaking it enables) does not apply in
                                // the storybook. This ignore suppresses the
                                // linter since runtime codepoints cannot be
                                // const-evaluated by the shaker.
                                // ignore: non_const_argument_for_const_parameter
                                entry.value,
                                fontFamily: 'MaterialIcons',
                              ),
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry.key,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontSize: 8),
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
                  const SizedBox(height: 4),
                  Text(
                    _formatCodePoint(codePoint),
                    style: Theme.of(dialogContext).textTheme.bodySmall
                        ?.copyWith(color: theme.disabledTextColor),
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
                            WiredIcon(
                              icon: IconData(
                                // Storybook gallery: renders every catalogued
                                // codepoint at runtime; const evaluation
                                // (and the icon tree-shaking it enables)
                                // does not apply.
                                // ignore: non_const_argument_for_const_parameter
                                codePoint,
                                fontFamily: 'MaterialIcons',
                              ),
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

/// Returns whether [query] matches the icon [identifier] or its raw
/// [codePoint] (with or without the `0x` prefix).
bool _matchesQuery(String identifier, int codePoint, String query) {
  if (identifier.toLowerCase().contains(query)) {
    return true;
  }
  final hexQuery = query.replaceFirst('0x', '');
  return hexQuery.isNotEmpty && codePoint.toRadixString(16).contains(hexQuery);
}

String _formatCodePoint(int codePoint) {
  final hex = codePoint.toRadixString(16);
  return '0x${hex.toUpperCase()}';
}
