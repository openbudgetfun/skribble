import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

/// Emoji gallery with lazy grid, search, and per-emoji detail popup.
class EmojiPage extends HookWidget {
  const EmojiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final searchQuery = useState('');
    final filtered = useMemoized(() {
      final names = kSkribbleEmojiCodePoints.keys.toList()..sort();
      if (searchQuery.value.isEmpty) return names;
      final q = searchQuery.value.toLowerCase();
      return names.where((n) => n.contains(q)).toList();
    }, [searchQuery.value]);
    final theme = WiredTheme.of(context);

    return WiredScaffold(
      appBar: WiredAppBar(
        leading: const BackButton(),
        title: const Text('Emoji'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: WiredInput(
              labelText: 'Search ${filtered.length} emoji...',
              onChanged: (v) => searchQuery.value = v,
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 64,
                mainAxisSpacing: 12,
                crossAxisSpacing: 8,
                childAspectRatio: 0.72,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final name = filtered[index];
                return InkWell(
                  onTap: () { (() async { await _showEmojiDetail(
                    context,
                    name,
                    WiredTheme.of(context).textColor,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      WiredEmoji.fromName(name, size: 40),
                      const SizedBox(height: 4),
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontFamily: skribbleFontFamily,
                          color: theme.textColor,
                        ),
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

  static void _showEmojiDetail(
    BuildContext context,
    String name,
    Color themeColor,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: RoughBoxDecoration(
            seed: name.hashCode,
            borderStyle: RoughDrawingStyle(
              width: 2,
              color: Theme.of(ctx).colorScheme.onSurface,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name, style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 20),
              for (final size in [24.0, 48.0, 96.0])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        child: Text(
                          '${size.round()}px',
                          textAlign: TextAlign.right,
                          style: Theme.of(ctx).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(width: 28),
                      SizedBox.square(
                        dimension: size,
                        child: WiredEmoji.fromName(name, size: size),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
