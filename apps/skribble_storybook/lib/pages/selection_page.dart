import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_storybook/components/component_showcase.dart';

class SelectionPage extends HookWidget {
  const SelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final filterSelected = useState(false);
    final choiceSelected = useState(false);

    return Scaffold(
      appBar: WiredAppBar(
        leading: const BackButton(),
        title: const Text('Selection'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ShowcaseSection(
            title: 'WiredChip',
            children: [
              ComponentShowcase(
                title: 'Basic Chip',
                description:
                    'Rounded rectangle with optional avatar and delete.',
                child: Wrap(
                  spacing: 8,
                  children: [
                    const WiredChip(label: Text('Flutter')),
                    const WiredChip(label: Text('Dart')),
                    WiredChip(
                      label: const Text('Deletable'),
                      onDeleted: () {},
                    ),
                    const WiredChip(
                      avatar: Icon(Icons.person, size: 16),
                      label: Text('With Avatar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredFilterChip',
            children: [
              ComponentShowcase(
                title: 'Filter Chip',
                description: 'Chip with checkmark for filtering.',
                child: WiredFilterChip(
                  label: const Text('Vegetarian'),
                  selected: filterSelected.value,
                  onSelected: (v) => filterSelected.value = v,
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredChoiceChip',
            children: [
              ComponentShowcase(
                title: 'Choice Chip',
                description: 'Chip with selection fill.',
                child: WiredChoiceChip(
                  label: const Text('Selected'),
                  selected: choiceSelected.value,
                  onSelected: (v) => choiceSelected.value = v,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
