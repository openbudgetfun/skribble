import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

/// A live sketch sheet for comparing loading rhythms and placeholders.
class LoadingPlayground extends HookWidget {
  /// Creates the loading catalog's interactive examples.
  const LoadingPlayground({super.key});

  @override
  Widget build(BuildContext context) {
    final moving = useState(true);
    final loading = useState(true);
    final speed = useState<double>(1800);
    final color = WiredTheme.of(context).textColor;
    const descriptions = {
      WiredLoaderStyle.orbit: (
        'Ink orbit',
        'A pen tip taking the long way round.',
      ),
      WiredLoaderStyle.dots: ('Hop, hop, hop', 'A small pause for a reply.'),
      WiredLoaderStyle.bars: ('Pencil bars', 'Five strokes keeping time.'),
      WiredLoaderStyle.ripple: (
        'Paper ripples',
        'Soft rings, spreading slowly.',
      ),
      WiredLoaderStyle.flower: (
        'Turning flower',
        'A familiar flourish, set in motion.',
      ),
      WiredLoaderStyle.scribble: (
        'Endless scribble',
        'Draw a loop. Follow it back.',
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'A little ink while you wait.',
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        const Text(
          'Six hand-drawn rhythms. Quiet pencil placeholders. Try them at your own pace.',
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            WiredButton(
              onPressed: () => moving.value = !moving.value,
              child: Text(moving.value ? 'Settle motion' : 'Play motion'),
            ),
            WiredButton(
              onPressed: () => loading.value = !loading.value,
              child: Text(
                loading.value ? 'Show loaded content' : 'Show skeletons',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('One loop · ${(speed.value / 1000).toStringAsFixed(1)} seconds'),
        WiredSlider(
          value: speed.value,
          min: 800,
          max: 3600,
          semanticLabel: 'Loop duration in milliseconds',
          onChanged: (value) {
            speed.value = value;
            return true;
          },
        ),
        const SizedBox(height: 24),
        WiredMotion(
          enabled: moving.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 640
                      ? 3
                      : constraints.maxWidth >= 420
                      ? 2
                      : 1;
                  final width =
                      (constraints.maxWidth - (columns - 1) * 16) / columns;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (final style in WiredLoaderStyle.values)
                        SizedBox(
                          width: width,
                          child: WiredCard(
                            height: null,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  const SizedBox(height: 12),
                                  WiredLoader(
                                    style: style,
                                    size: 72,
                                    color: color,
                                    duration: Duration(
                                      milliseconds: speed.value.round(),
                                    ),
                                    semanticLabel: null,
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    descriptions[style]!.$1,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    descriptions[style]!.$2,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'WiredLoaderStyle.${style.name}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'Keep a place for what is coming.',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              const Text(
                'The same card keeps its size and state while its content loads. The pencil marks stay still; only their ink gently pulses.',
              ),
              const SizedBox(height: 20),
              WiredCard(
                height: null,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: WiredSkeletonOverlay(
                    loading: loading.value,
                    semanticLabel: 'Loading your next sketch',
                    skeleton: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            WiredSkeleton(
                              width: 48,
                              height: 48,
                              borderRadius: BorderRadius.all(
                                Radius.circular(24),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FractionallySizedBox(
                                    widthFactor: .65,
                                    child: WiredSkeleton(height: 20),
                                  ),
                                  SizedBox(height: 10),
                                  FractionallySizedBox(
                                    widthFactor: .4,
                                    child: WiredSkeleton(height: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        WiredSkeleton(height: 14),
                        SizedBox(height: 10),
                        FractionallySizedBox(
                          widthFactor: .8,
                          child: WiredSkeleton(height: 14),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            WiredDoodle(kind: WiredDoodleKind.sun, size: 48),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'A small sunny sketch',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text('Saved just for you'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Take your notebook outside. There is a whole afternoon to draw.',
                        ),
                        const SizedBox(height: 16),
                        WiredButton(
                          onPressed: () => loading.value = true,
                          child: const Text('Load another sketch'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  WiredLoader(
                    style: WiredLoaderStyle.dots,
                    size: 28,
                    semanticLabel: null,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Small enough to sit beside a status message.'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
