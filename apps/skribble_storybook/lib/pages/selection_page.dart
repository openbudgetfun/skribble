import 'package:flutter/cupertino.dart';
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
    final inputChipSelected = useState(false);
    final pickerIndex = useState(0);

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
                    WiredChip(label: const Text('Deletable'), onDeleted: () {}),
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
          ShowcaseSection(
            title: 'WiredInputChip',
            children: [
              ComponentShowcase(
                title: 'Input Chip',
                description: 'Selectable chip with delete and avatar.',
                child: Wrap(
                  spacing: 8,
                  children: [
                    WiredInputChip(
                      label: const Text('Flutter'),
                      selected: inputChipSelected.value,
                      onSelected: (v) => inputChipSelected.value = v,
                      onDeleted: () => inputChipSelected.value = false,
                      avatar: const CircleAvatar(
                        radius: 10,
                        child: Text('F', style: TextStyle(fontSize: 10)),
                      ),
                    ),
                    WiredInputChip(
                      label: const Text('Disabled'),
                      enabled: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredActionChip',
            children: [
              ComponentShowcase(
                title: 'Action Chip',
                description: 'Tappable chip with optional icon.',
                child: Wrap(
                  spacing: 8,
                  children: [
                    WiredActionChip(
                      label: const Text('Share'),
                      avatar: const Icon(Icons.share, size: 16),
                      onPressed: () {},
                    ),
                    WiredActionChip(
                      label: const Text('Copy'),
                      avatar: const Icon(Icons.copy, size: 16),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredCupertinoPicker',
            children: [
              ComponentShowcase(
                title: 'Picker Wheel',
                description:
                    'Cupertino-style scroll picker with sketchy border.',
                child: Column(
                  children: [
                    SizedBox(
                      width: 200,
                      child: WiredCupertinoPicker(
                        height: 160,
                        onSelectedItemChanged: (i) => pickerIndex.value = i,
                        children: const [
                          Text('January'),
                          Text('February'),
                          Text('March'),
                          Text('April'),
                          Text('May'),
                          Text('June'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Selected index: ${pickerIndex.value}'),
                  ],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredCupertinoDatePicker',
            children: [
              ComponentShowcase(
                title: 'Date & Time Picker',
                description:
                    'iOS-style date/time picker with sketchy border.',
                child: SizedBox(
                  height: 216,
                  child: WiredCupertinoDatePicker(
                    onDateTimeChanged: (_) {},
                  ),
                ),
              ),
              ComponentShowcase(
                title: 'Date Only',
                child: SizedBox(
                  height: 216,
                  child: WiredCupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    onDateTimeChanged: (_) {},
                  ),
                ),
              ),
              ComponentShowcase(
                title: 'Time Only (24h)',
                child: SizedBox(
                  height: 216,
                  child: WiredCupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    onDateTimeChanged: (_) {},
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
