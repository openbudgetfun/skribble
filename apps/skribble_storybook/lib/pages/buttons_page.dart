import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_storybook/components/component_showcase.dart';

class ButtonsPage extends HookWidget {
  const ButtonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final segmentSelected = useState<Set<String>>({'day'});
    final toggleSelected = useState([true, false, false]);
    final roundness = useState<double>(0);

    return WiredScaffold(
      appBar: WiredAppBar(
        leading: const BackButton(),
        title: const Text('Buttons'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ShowcaseSection(
            title: 'WiredButton',
            children: [
              ComponentShowcase(
                title: 'Basic',
                description: 'A standard hand-drawn button.',
                child: WiredButton(
                  onPressed: () {},
                  child: const Text('Click Me'),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredElevatedButton',
            children: [
              ComponentShowcase(
                title: 'Elevated',
                description: 'Filled with hachure and offset shadow.',
                child: WiredElevatedButton(
                  onPressed: () {},
                  child: const Text('Elevated'),
                ),
              ),
              ComponentShowcase(
                title: 'Disabled',
                child: const WiredElevatedButton(child: Text('Disabled')),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredOutlinedButton',
            children: [
              ComponentShowcase(
                title: 'Outlined',
                description: 'Thick hand-drawn border, no fill.',
                child: WiredOutlinedButton(
                  onPressed: () {},
                  child: const Text('Outlined'),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredTextButton',
            children: [
              ComponentShowcase(
                title: 'Text',
                description: 'No border, hand-drawn underline.',
                child: WiredTextButton(
                  onPressed: () {},
                  child: const Text('Text Button'),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredIcon',
            children: [
              ComponentShowcase(
                title: 'Material Icons',
                description: 'Standalone rough-rendered Material icons.',
                child: Row(
                  children: const [
                    WiredIcon(icon: Icons.search, size: 28),
                    SizedBox(width: 16),
                    WiredIcon(icon: Icons.favorite, size: 28),
                    SizedBox(width: 16),
                    WiredIcon(icon: Icons.share, size: 28),
                    SizedBox(width: 16),
                    WiredIcon(icon: Icons.delete, size: 28),
                  ],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredIconButton',
            children: [
              ComponentShowcase(
                title: 'Icon Button',
                description: 'Icon in a hand-drawn circle.',
                child: Row(
                  children: [
                    WiredIconButton(icon: Icons.favorite, onPressed: () {}),
                    const SizedBox(width: 16),
                    WiredIconButton(icon: Icons.share, onPressed: () {}),
                    const SizedBox(width: 16),
                    WiredIconButton(icon: Icons.delete, onPressed: () {}),
                  ],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredFloatingActionButton',
            children: [
              ComponentShowcase(
                title: 'FAB',
                description: 'Circle with icon, filled with hachure.',
                child: WiredFloatingActionButton(
                  icon: Icons.add,
                  onPressed: () {},
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredFilledButton',
            children: [
              ComponentShowcase(
                title: 'Filled',
                description: 'Solid hachure-filled button.',
                child: WiredFilledButton(
                  onPressed: () {},
                  child: const Text('Filled Button'),
                ),
              ),
              ComponentShowcase(
                title: 'Custom Color',
                child: WiredFilledButton(
                  onPressed: () {},
                  fillColor: Colors.indigo,
                  child: const Text('Indigo Fill'),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredToggleButtons',
            children: [
              ComponentShowcase(
                title: 'Toggle Buttons',
                description: 'Multi-toggle with hand-drawn borders.',
                child: WiredToggleButtons(
                  isSelected: toggleSelected.value,
                  onPressed: (i) {
                    final next = [...toggleSelected.value];
                    next[i] = !next[i];
                    toggleSelected.value = next;
                  },
                  children: const [
                    Icon(Icons.format_bold),
                    Icon(Icons.format_italic),
                    Icon(Icons.format_underline),
                  ],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredCupertinoButton',
            children: [
              ComponentShowcase(
                title: 'Cupertino Button',
                description: 'iOS-style hand-drawn button with press opacity.',
                child: WiredCupertinoButton(
                  onPressed: () {},
                  child: const Text('Cupertino'),
                ),
              ),
              ComponentShowcase(
                title: 'Filled Variant',
                child: WiredCupertinoButton.filled(
                  onPressed: () {},
                  child: const Text('Filled'),
                ),
              ),
              ComponentShowcase(
                title: 'Disabled',
                child: const WiredCupertinoButton(
                  onPressed: null,
                  child: Text('Disabled'),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredSegmentedButton',
            children: [
              ComponentShowcase(
                title: 'Segmented',
                description: 'Connected rounded rectangles.',
                child: WiredSegmentedButton<String>(
                  segments: const [
                    WiredButtonSegment(value: 'day', label: Text('Day')),
                    WiredButtonSegment(value: 'week', label: Text('Week')),
                    WiredButtonSegment(value: 'month', label: Text('Month')),
                  ],
                  selected: segmentSelected.value,
                  onSelectionChanged: (s) => segmentSelected.value = s,
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'Roundness',
            children: [
              ComponentShowcase(
                title: 'Border radius',
                description: 'Pick a corner radius to round the hand-drawn corners of every button.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    WiredSegmentedButton<double>(
                      segments: const [
                        WiredButtonSegment(value: 0, label: Text('0')),
                        WiredButtonSegment(value: 4, label: Text('4')),
                        WiredButtonSegment(value: 8, label: Text('8')),
                        WiredButtonSegment(value: 12, label: Text('12')),
                        WiredButtonSegment(value: 16, label: Text('16')),
                        WiredButtonSegment(value: 20, label: Text('20')),
                        WiredButtonSegment(value: 24, label: Text('24')),
                      ],
                      selected: {roundness.value},
                      onSelectionChanged: (s) => roundness.value = s.first,
                    ),
                    const SizedBox(height: 16),
                    WiredButton(
                      onPressed: () {},
                      borderRadius: BorderRadius.circular(roundness.value),
                      child: const Text('Rounded'),
                    ),
                    const SizedBox(height: 12),
                    WiredElevatedButton(
                      onPressed: () {},
                      borderRadius: BorderRadius.circular(roundness.value),
                      child: const Text('Elevated'),
                    ),
                    const SizedBox(height: 12),
                    WiredFilledButton(
                      onPressed: () {},
                      borderRadius: BorderRadius.circular(roundness.value),
                      child: const Text('Filled'),
                    ),
                    const SizedBox(height: 12),
                    WiredOutlinedButton(
                      onPressed: () {},
                      borderRadius: BorderRadius.circular(roundness.value),
                      child: const Text('Outlined'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
