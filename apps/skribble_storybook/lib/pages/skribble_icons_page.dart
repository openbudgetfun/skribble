import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_icons/skribble_icons.dart';

/// Searchable gallery of every bundled icon set, with size and ink comparisons.
///
/// Renders only the visible rows of the grid via `SliverGrid.builder`, with a
/// search bar filtering by identifier and tappable cells that open a preview
/// dialog showing each roughness level at 24/48/96 px.
class SkribbleIconsPage extends HookWidget {
  const SkribbleIconsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final searchQuery = useState('');
    final selectedSet = useState(SkribbleIconSet.curated);
    final catalog = _catalogs[selectedSet.value]!;

    final sortedEntries = useMemoized(() {
      final entries =
          catalog.names.entries
              .where((entry) => catalog.icons.containsKey(entry.value))
              .toList()
            ..sort((a, b) => a.key.compareTo(b.key));
      return entries;
    }, [selectedSet.value]);

    final filteredEntries = useMemoized(() {
      final query = searchQuery.value.trim().toLowerCase();
      if (query.isEmpty) {
        return sortedEntries;
      }
      return sortedEntries
          .where((entry) => entry.key.toLowerCase().contains(query))
          .toList(growable: false);
    }, [searchQuery.value, sortedEntries]);

    return WiredScaffold(
      appBar: WiredAppBar(
        leading: const BackButton(),
        title: const Text('Skribble Icons'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${catalog.label} hand-drawn icons',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${sortedEntries.length} icons',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final entry in _catalogs.entries)
                        WiredChoiceChip(
                          label: Text(entry.value.label),
                          selected: selectedSet.value == entry.key,
                          onSelected: (_) => selectedSet.value = entry.key,
                        ),
                    ],
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
          ),
          if (filteredEntries.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No icons match "${searchQuery.value.trim()}"',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: theme.disabledTextColor),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 64,
                  mainAxisExtent:
                      56 + MediaQuery.textScalerOf(context).scale(9) * 3,
                ),
                itemCount: filteredEntries.length,
                itemBuilder: (context, index) {
                  final entry = filteredEntries[index];
                  return InkWell(
                    onTap: () => _showPopup(
                      context,
                      entry.key,
                      entry.value,
                      catalog.icons[entry.value]!,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        WiredSvgIcon(
                          data: catalog.icons[entry.value]!,
                          size: 32,
                          semanticLabel: '${catalog.label}: ${entry.key}',
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

  /// Compares all three ink levels at 24/48/96 px in a scrollable dialog.
  void _showPopup(
    BuildContext context,
    String identifier,
    int codePoint,
    WiredSvgIconData data,
  ) {
    final theme = WiredTheme.of(context);

    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
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
              child: SingleChildScrollView(
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
                    for (final level in WiredRoughness.values) ...[
                      const SizedBox(height: 12),
                      Text(switch (level) {
                        WiredRoughness.gentle => 'Gentle',
                        WiredRoughness.playful => 'Playful',
                        WiredRoughness.expressive => 'Expressive',
                      }),
                      const SizedBox(height: 8),
                      WiredThemeScope(
                        data: theme.copyWith(roughnessLevel: level),
                        child: Wrap(
                          alignment: WrapAlignment.spaceEvenly,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            for (final size in const [24.0, 48.0, 96.0])
                              Column(
                                children: [
                                  WiredSvgIcon(
                                    data: data,
                                    size: size,
                                    semanticLabel:
                                        '$identifier, ${level.name}, ${size.round()} pixels',
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${size.round()}px',
                                    style: Theme.of(dialogContext)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: theme.textColor),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

const _catalogs =
    <
      SkribbleIconSet,
      ({String label, Map<String, int> names, Map<int, WiredSvgIconData> icons})
    >{
      SkribbleIconSet.curated: (
        label: 'Curated',
        names: kSkribbleCuratedIconCodePoints,
        icons: kSkribbleCuratedIcons,
      ),
      SkribbleIconSet.material: (
        label: 'Material',
        names: kMaterialRoughIconsCodePoints,
        icons: kMaterialRoughIcons,
      ),
      SkribbleIconSet.lucide: (
        label: 'Lucide',
        names: kLucideIconCodePoints,
        icons: kLucideIcons,
      ),
      SkribbleIconSet.simple: (
        label: 'Simple Icons',
        names: kSimpleIconCodePoints,
        icons: kSimpleIcons,
      ),
      SkribbleIconSet.bxs: (
        label: 'Boxicons',
        names: kBxsIconCodePoints,
        icons: kBxsIcons,
      ),
      SkribbleIconSet.cib: (
        label: 'CoreUI Brands',
        names: kCibIconCodePoints,
        icons: kCibIcons,
      ),
    };
