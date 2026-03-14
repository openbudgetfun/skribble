import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_storybook/components/component_showcase.dart';

class DataDisplayPage extends HookWidget {
  const DataDisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stepperIndex = useState(0);
    final calendarSelected = useState<String?>(null);

    return Scaffold(
      appBar: WiredAppBar(
        leading: const BackButton(),
        title: const Text('Data Display'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ShowcaseSection(
            title: 'WiredCalendar',
            children: [
              ComponentShowcase(
                title: 'Calendar',
                description: 'Month calendar with hand-drawn day cells.',
                child: SizedBox(
                  height: 380,
                  child: WiredCalendar(
                    selected: calendarSelected.value,
                    onSelected: (s) => calendarSelected.value = s,
                  ),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredCalendarDatePicker',
            children: [
              ComponentShowcase(
                title: 'Calendar Date Picker (M3)',
                description:
                    'Flutter CalendarDatePicker with hand-drawn border.',
                child: SizedBox(
                  width: 340,
                  height: 360,
                  child: WiredCalendarDatePicker(
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    onDateChanged: (_) {},
                  ),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredDatePicker',
            children: [
              ComponentShowcase(
                title: 'Date Picker',
                description: 'Date picker dialog extending the calendar.',
                child: WiredButton(
                  onPressed: () async {
                    final date = await showWiredDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                    );
                    if (date != null && context.mounted) {
                      showWiredSnackBar(
                        context,
                        content: Text('Selected: ${date.toLocal()}'),
                      );
                    }
                  },
                  child: const Text('Pick Date'),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredTimePicker',
            children: [
              ComponentShowcase(
                title: 'Time Picker',
                description: 'Clock face with hour/minute hands.',
                child: const SizedBox(
                  height: 340,
                  width: 280,
                  child: WiredTimePicker(),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredStepper',
            children: [
              ComponentShowcase(
                title: 'Stepper',
                description: 'Connected circles with lines.',
                child: WiredStepper(
                  currentStep: stepperIndex.value,
                  onStepTapped: (i) => stepperIndex.value = i,
                  steps: const [
                    WiredStep(
                      title: Text('Step 1'),
                      subtitle: Text('Basic info'),
                      content: Text('Enter your name and email.'),
                    ),
                    WiredStep(
                      title: Text('Step 2'),
                      subtitle: Text('Details'),
                      content: Text('Provide additional details.'),
                    ),
                    WiredStep(
                      title: Text('Step 3'),
                      subtitle: Text('Confirm'),
                      content: Text('Review and submit.'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredDataTable',
            children: [
              ComponentShowcase(
                title: 'Data Table',
                description: 'Table with hand-drawn grid lines.',
                child: WiredDataTable(
                  columns: const [
                    WiredDataColumn(label: Text('Name')),
                    WiredDataColumn(label: Text('Role')),
                    WiredDataColumn(label: Text('Score')),
                  ],
                  rows: const [
                    WiredDataRow(
                      cells: [Text('Alice'), Text('Engineer'), Text('95')],
                    ),
                    WiredDataRow(
                      cells: [Text('Bob'), Text('Designer'), Text('88')],
                    ),
                    WiredDataRow(
                      cells: [Text('Carol'), Text('Manager'), Text('92')],
                    ),
                  ],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredRangeSlider',
            children: [
              ComponentShowcase(
                title: 'Range Slider',
                description: 'Dual-handle slider with hand-drawn track.',
                child: WiredRangeSlider(
                  values: const RangeValues(0.2, 0.8),
                  onChanged: (v) => true,
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredSelectableText',
            children: [
              ComponentShowcase(
                title: 'Selectable Text',
                description: 'Text that can be selected and copied.',
                child: const WiredSelectableText(
                  'Long press to select this text. '
                  'You can copy it to your clipboard.',
                ),
              ),
              ComponentShowcase(
                title: 'Styled',
                child: const WiredSelectableText(
                  'Bold and blue selectable text',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
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
