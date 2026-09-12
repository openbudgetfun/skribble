part of 'catalog.dart';

/// @docs-example chip
Widget _chip(ExampleSettings settings) =>
    WiredChip(label: Text(settings.label));

/// @docs-example choice-chip
Widget _choiceChip(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final selected = useState(false);
    return WiredChoiceChip(
      label: Text(settings.label),
      selected: selected.value,
      onSelected: (value) => selected.value = value,
    );
  },
);

/// @docs-example filter-chip
Widget _filterChip(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final selected = useState(true);
    return WiredFilterChip(
      label: Text(settings.label),
      selected: selected.value,
      onSelected: (value) => selected.value = value,
    );
  },
);

/// @docs-example input-chip
Widget _inputChip(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final visible = useState(true);
    return visible.value
        ? WiredInputChip(
            label: Text(settings.label),
            onDeleted: () => visible.value = false,
          )
        : WiredTextButton(
            onPressed: () => visible.value = true,
            child: const Text('Restore tag'),
          );
  },
);

/// @docs-example action-chip
Widget _actionChip(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final count = useState(0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WiredActionChip(
          label: Text(settings.label),
          onPressed: () => count.value++,
        ),
        Text('Pressed ${count.value} times'),
      ],
    );
  },
);

/// @docs-example date-picker
Widget _datePicker(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final selected = useState<DateTime?>(null);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WiredButton(
          onPressed: () async {
            selected.value = await showWiredDatePicker(
              context: context,
              initialDate: DateTime(2026, 9, 9),
            );
          },
          child: Text(settings.label),
        ),
        if (selected.value case final DateTime date)
          Text('${date.day}/${date.month}/${date.year}'),
      ],
    );
  },
);

/// @docs-example date-range-picker
Widget _dateRangePicker(ExampleSettings settings) => Builder(
  builder: (context) => WiredButton(
    onPressed: () => showWiredDateRangePicker(
      context: context,
      firstDate: DateTime(2026),
      lastDate: DateTime(2027),
    ),
    child: Text(settings.label),
  ),
);

/// @docs-example time-picker
Widget _timePicker(ExampleSettings settings) => Builder(
  builder: (context) => WiredButton(
    onPressed: () => showWiredTimePicker(context: context),
    child: Text(settings.label),
  ),
);

/// @docs-example calendar-date-picker
Widget _calendarDatePicker(ExampleSettings settings) => WiredCalendarDatePicker(
  initialDate: DateTime(2026, 9, 9),
  firstDate: DateTime(2026),
  lastDate: DateTime(2027),
  onDateChanged: (date) {},
);

/// @docs-example color-picker
Widget _colorPicker(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final selected = useState(const Color(0xffe8957d));
    return WiredColorPicker(
      selectedColor: selected.value,
      onColorChanged: (color) => selected.value = color,
    );
  },
);

/// @docs-example cupertino-picker
Widget _cupertinoPicker(ExampleSettings settings) => SizedBox(
  height: 160,
  child: WiredCupertinoPicker(
    onSelectedItemChanged: (index) {},
    children: const [Text('Paper'), Text('Ink'), Text('Possibility')],
  ),
);

/// @docs-example cupertino-date-picker
Widget _cupertinoDatePicker(ExampleSettings settings) => SizedBox(
  height: 180,
  child: WiredCupertinoDatePicker(
    initialDateTime: DateTime(2026, 9, 9, 12),
    onDateTimeChanged: (date) {},
  ),
);

/// @docs-example cupertino-segmented-control
Widget _cupertinoSegmentedControl(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final selected = useState('paper');
    return WiredCupertinoSegmentedControl<String>(
      children: const {'paper': Text('Paper'), 'ink': Text('Ink')},
      groupValue: selected.value,
      onValueChanged: (value) => selected.value = value,
    );
  },
);

/// @docs-example combo
Widget _combo(ExampleSettings settings) => SizedBox(
  width: 320,
  child: WiredCombo<String>.options(
    options: const {
      'paper': Text('Paper'),
      'ink': Text('Ink'),
      'ideas': Text('Ideas'),
    },
    value: 'paper',
  ),
);
