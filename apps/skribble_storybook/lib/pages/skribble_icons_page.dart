import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_icons/skribble_icons.dart';

class SkribbleIconsPage extends HookWidget {
  const SkribbleIconsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sortedIdentifiers = useMemoized(() {
      final identifiers = kSkribbleCustomIconsCodePoints.keys.toList()..sort();
      return identifiers;
    });

    final materialCount = useMemoized(() => materialRoughIconCodePoints.length);
    final customCount = kSkribbleCustomIcons.length;
    final totalCount = customCount + materialCount;

    return WiredScaffold(
      appBar: WiredAppBar(
        leading: const BackButton(),
        title: const Text('Skribble Icons'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Curated hand-drawn icon set',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '$customCount custom icons + $materialCount Material icons = '
              '$totalCount total',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'All icons are accessible through a unified lookup API. '
              'Use lookupSkribbleIconByIdentifier() to find any custom icon '
              'by name, or use WiredIcon for Material icons.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            Text(
              'Custom Icons',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 16,
              children: [
                for (final identifier in sortedIdentifiers)
                  SizedBox(
                    width: 72,
                    child: Column(
                      children: [
                        SkribbleIcon(
                          data: lookupSkribbleIconByIdentifier(identifier)!,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          identifier,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontSize: 9),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
