import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

/// Loading rhythms, progress, and placeholders with live motion controls.
class WiredLoadingPage extends HookWidget {
  /// Creates the loading gallery.
  const WiredLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final moving = useState(true);
    final loading = useState(true);
    final progress = useState(0.6);
    return WiredScaffold(
      appBar: WiredAppBar(title: const Text('Loading and skeletons')),
      body: WiredMotion(
        enabled: moving.value,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                WiredButton(
                  onPressed: () => moving.value = !moving.value,
                  child: Text(moving.value ? 'Pause motion' : 'Play motion'),
                ),
                WiredButton(
                  onPressed: () => loading.value = !loading.value,
                  child: Text(loading.value ? 'Show content' : 'Show skeleton'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                for (final style in WiredLoaderStyle.values)
                  SizedBox(
                    width: 120,
                    child: Column(
                      children: [
                        WiredLoader(style: style, size: 64),
                        const SizedBox(height: 12),
                        Text(style.name),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Progress'),
            WiredSlider(
              value: progress.value,
              semanticLabel: 'Loading progress',
              onChanged: (value) {
                progress.value = value;
                return true;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const WiredLoadingIndicator(size: 48),
                WiredCircularProgressIndicator(value: progress.value),
              ],
            ),
            const SizedBox(height: 24),
            WiredSkeletonOverlay(
              loading: loading.value,
              child: const WiredCard(
                height: null,
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: WiredSelectionArea(
                    child: Text(
                      'Your notebook is ready. Select this text to try the hand-drawn selection controls.',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const WiredSkeleton(width: 180),
            const SizedBox(height: 12),
            const WiredSkeleton(width: 120, height: 12),
            const SizedBox(height: 24),
            const SizedBox(
              height: 240,
              child: WiredLoadingScreen(message: 'Getting the pens ready…'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
