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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: [
                for (final codePoint in codePoints)
                  SizedBox(
                    width: 44,
                    child: Column(
                      children: [
                        WiredIcon(
                          icon: IconData(
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
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _formatCodePoint(int codePoint) {
  final hex = codePoint.toRadixString(16);
  return '0x${hex.toUpperCase()}';
}
