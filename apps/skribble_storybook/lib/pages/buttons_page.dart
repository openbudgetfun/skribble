import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_storybook/components/component_showcase.dart';
import 'package:skribble_storybook/widgets/storybook_back_button.dart';

/// Gallery of the button family, from [WiredButton] to [WiredSegmentedButton].
class ButtonsPage extends HookWidget {
  /// Creates the page.
  const ButtonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final segmentSelected = useState<Set<String>>({'day'});
    final toggleSelected = useState([true, false, false]);
    final bookmarked = useState(false);
    final fabExtended = useState(true);

    return WiredScaffold(
      appBar: WiredAppBar(
        leading: const StorybookBackButton(),
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
              for (final (fill, label) in [
                (WiredIconFillStyle.marker, 'coloured in with marker'),
                (WiredIconFillStyle.solid, 'solid ink'),
                (WiredIconFillStyle.hachure, 'pencil shading'),
              ])
                ComponentShowcase(
                  title: 'Material Icons · $label',
                  description: 'Smoothly wandering contours at everyday sizes.',
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 16,
                    children: [
                      WiredIcon(
                        icon: Icons.search,
                        size: 28,
                        fillStyle: fill,
                        semanticLabel: 'Search',
                      ),
                      WiredIcon(
                        icon: Icons.favorite,
                        size: 28,
                        fillStyle: fill,
                        semanticLabel: 'Favourite',
                      ),
                      WiredIcon(
                        icon: Icons.share,
                        size: 28,
                        fillStyle: fill,
                        semanticLabel: 'Share',
                      ),
                      WiredIcon(
                        icon: Icons.delete,
                        size: 28,
                        fillStyle: fill,
                        semanticLabel: 'Delete',
                      ),
                    ],
                  ),
                ),
              ComponentShowcase(
                title: 'Simple Icons · brand marks',
                description:
                    'GitHub, Dart, Flutter, and Figma coloured in with marker, '
                    'in solid ink, and in pencil shading.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final fill in [
                      WiredIconFillStyle.marker,
                      WiredIconFillStyle.solid,
                      WiredIconFillStyle.hachure,
                    ])
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Wrap(
                          spacing: 24,
                          runSpacing: 16,
                          children: [
                            for (final brand in WiredBrandIcon.values)
                              WiredSvgIcon(
                                data: brand.data,
                                size: 40,
                                fillStyle: fill,
                                semanticLabel: brand.name,
                              ),
                          ],
                        ),
                      ),
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
              ComponentShowcase(
                title: 'Filled, tonal, and outlined',
                description:
                    'Accent and marker washes, a colour-coded fill, and a '
                    'disabled filled button.',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    WiredIconButton.filled(
                      icon: Icons.send,
                      tooltip: 'Send',
                      onPressed: () {},
                    ),
                    WiredIconButton.filledTonal(
                      icon: Icons.share,
                      tooltip: 'Share',
                      onPressed: () {},
                    ),
                    WiredIconButton.outlined(
                      icon: Icons.edit,
                      tooltip: 'Edit',
                      onPressed: () {},
                    ),
                    WiredIconButton.filled(
                      icon: Icons.palette,
                      fillColor: WiredTheme.of(context).accentAt(3),
                      tooltip: 'Colour',
                      onPressed: () {},
                    ),
                    const WiredIconButton.filled(
                      icon: Icons.delete,
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ),
              ComponentShowcase(
                title: 'Toggle',
                description: 'isSelected swaps the icon and adds a wash.',
                child: WiredIconButton(
                  icon: Icons.bookmark_border,
                  selectedIcon: Icons.bookmark,
                  isSelected: bookmarked.value,
                  tooltip: bookmarked.value ? 'Remove bookmark' : 'Bookmark',
                  onPressed: () => bookmarked.value = !bookmarked.value,
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
              ComponentShowcase(
                title: 'Small, regular, and large',
                description: '40, 56, and 96 pixels, as in Material.',
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    WiredFloatingActionButton.small(
                      icon: Icons.add,
                      tooltip: 'Add',
                      onPressed: () {},
                    ),
                    WiredFloatingActionButton(
                      icon: Icons.add,
                      tooltip: 'Add',
                      onPressed: () {},
                    ),
                    WiredFloatingActionButton.large(
                      icon: Icons.add,
                      tooltip: 'Add',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              ComponentShowcase(
                title: 'Extended',
                description:
                    'A pill with an icon and label. Tap it to spring back '
                    'to a circle.',
                child: WiredFloatingActionButton.extended(
                  icon: Icons.edit,
                  label: const Text('Compose'),
                  isExtended: fabExtended.value,
                  onPressed: () => fabExtended.value = !fabExtended.value,
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
                    WiredIcon(icon: Icons.format_bold),
                    WiredIcon(icon: Icons.format_italic),
                    WiredIcon(icon: Icons.format_underline),
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
        ],
      ),
    );
  }
}
