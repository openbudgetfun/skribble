import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_emoji/skribble_emoji.dart';

class EmojiPage extends HookWidget {
  const EmojiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sortedNames = useMemoized(() {
      final names = kSkribbleEmojiCodePoints.keys.toList()..sort();
      return names;
    });

    final emojiCount = kSkribbleEmoji.length;

    return WiredScaffold(
      appBar: WiredAppBar(
        leading: const BackButton(),
        title: const Text('Emoji'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hand-drawn emoji set',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '$emojiCount emoji from OpenMoji',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Emoji are rendered as hand-drawn SVG icons using the '
              'WiredEmoji widget. Look up emoji by name with '
              'lookupSkribbleEmojiByName() or by Unicode codepoint '
              'with lookupSkribbleEmojiByUnicode().',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            if (sortedNames.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      const WiredEmoji(size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'No emoji generated yet.\n'
                        'Run the rough icon pipeline against the emoji '
                        'manifest to populate this gallery.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 16,
                children: [
                  for (final name in sortedNames)
                    SizedBox(
                      width: 72,
                      child: Column(
                        children: [
                          WiredEmoji.fromName(name, size: 32),
                          const SizedBox(height: 4),
                          Text(
                            name,
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
