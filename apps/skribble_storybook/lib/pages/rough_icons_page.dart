import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

class RoughIconsPage extends HookWidget {
  const RoughIconsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final codePoints = useMemoized(() {
      final sorted = [...materialRoughIconCodePoints]..sort();
      return sorted;
    });

    return WiredScaffold(
      appBar: WiredAppBar(
        leading: const BackButton(),
        title: const Text('Rough Icons'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generated rough Material icon catalog',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${codePoints.length} icons',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 60,
                mainAxisSpacing: 12,
                crossAxisSpacing: 8,
              ),
              itemCount: codePoints.length,
              itemBuilder: (context, index) {
                final codePoint = codePoints[index];
                return SizedBox(
                  width: 44,
                  child: Column(
                    children: [
                      WiredIcon(
                        icon: IconData(
                          // Renders every catalogued codepoint at runtime;
                          // const evaluation (and the icon tree-shaking it
                          // enables) does not apply in the storybook.
                          // ignore: non_const_argument_for_const_parameter
                          codePoint,
                          fontFamily: 'MaterialIcons',
                        ),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCodePoint(codePoint),
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontSize: 8),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }
}

String _formatCodePoint(int codePoint) {
  final hex = codePoint.toRadixString(16);
  return '0x${hex.toUpperCase()}';
}
