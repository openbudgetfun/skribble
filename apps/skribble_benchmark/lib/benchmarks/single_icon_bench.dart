import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_benchmark/widgets/frame_timer.dart';
import 'package:skribble_benchmark/widgets/precomputed_icon.dart';
import 'package:skribble_icons/skribble_icons.dart';

/// Returns a list of [WiredSvgIconData] from the curated custom icons.
List<WiredSvgIconData> _getIconDataList() {
  return kSkribbleCustomIcons.values.toList(growable: false);
}

/// Benchmark page that renders a single icon with each approach and measures
/// build + paint time over 100 consecutive frames.
class SingleIconBenchPage extends HookWidget {
  const SingleIconBenchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final icons = useMemoized(_getIconDataList);
    final iconData = icons.isNotEmpty ? icons.first : null;

    final runtimeTimer = useFrameTimer(maxFrames: 100);
    final precomputedTimer = useFrameTimer(maxFrames: 100);
    final activeTab = useState(0);

    // Force rebuilds to generate frame timings when collecting.
    final rebuildTicker = useState(0);
    useEffect(
      () {
        if (runtimeTimer.isCollecting || precomputedTimer.isCollecting) {
          void scheduleRebuild() {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (runtimeTimer.isCollecting ||
                  precomputedTimer.isCollecting) {
                rebuildTicker.value++;
                scheduleRebuild();
              }
            });
          }

          scheduleRebuild();
        }
        return null;
      },
      [runtimeTimer.isCollecting, precomputedTimer.isCollecting],
    );

    // Consume the ticker value to ensure rebuilds.
    rebuildTicker.value;

    if (iconData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Single Icon Bench')),
        body: const Center(child: Text('No icon data available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Single Icon Bench')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Renders one icon with each approach and measures frame '
              'timings over 100 frames.',
            ),
            const SizedBox(height: 16),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Runtime')),
                ButtonSegment(value: 1, label: Text('Pre-computed')),
              ],
              selected: {activeTab.value},
              onSelectionChanged: (selected) {
                activeTab.value = selected.first;
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 48,
                height: 48,
                child: activeTab.value == 0
                    ? WiredSvgIcon(data: iconData, size: 48)
                    : PrecomputedIcon(data: iconData, size: 48),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: activeTab.value == 0
                      ? (runtimeTimer.isCollecting
                          ? null
                          : runtimeTimer.startCollecting)
                      : (precomputedTimer.isCollecting
                          ? null
                          : precomputedTimer.startCollecting),
                  child: Text(
                    activeTab.value == 0
                        ? (runtimeTimer.isCollecting
                            ? 'Collecting... '
                                '(${runtimeTimer.timings.length}/100)'
                            : 'Measure Runtime')
                        : (precomputedTimer.isCollecting
                            ? 'Collecting... '
                                '(${precomputedTimer.timings.length}/100)'
                            : 'Measure Pre-computed'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: activeTab.value == 0
                      ? runtimeTimer.reset
                      : precomputedTimer.reset,
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (activeTab.value == 0)
              FrameTimingStatsCard(
                title: 'Runtime Roughening',
                stats: runtimeTimer.stats,
              )
            else
              FrameTimingStatsCard(
                title: 'Pre-computed Paths',
                stats: precomputedTimer.stats,
              ),
          ],
        ),
      ),
    );
  }
}
