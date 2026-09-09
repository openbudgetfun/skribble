part of 'catalog.dart';

/// @docs-example checkbox
Widget _checkbox(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final checked = useState(false);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        WiredCheckbox(
          value: checked.value,
          onChanged: (value) => checked.value = value ?? false,
          semanticLabel: 'Keep this idea',
        ),
        const SizedBox(width: 12),
        Flexible(child: Text(settings.label)),
      ],
    );
  },
);

/// @docs-example switch
Widget _switch(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final enabled = useState(true);
    return WiredSwitch(
      value: enabled.value,
      onChanged: (value) {
        enabled.value = value;
      },
    );
  },
);

/// @docs-example slider
Widget _slider(ExampleSettings settings) => WiredSlider(
  value: settings.amount,
  divisions: 10,
  semanticLabel: 'Amount',
  onChanged: settings.enabled ? (value) => true : null,
);

/// @docs-example input
Widget _input(ExampleSettings settings) => WiredInput(
  labelText: settings.label,
  hintText: 'A tiny spark of an idea…',
);

/// @docs-example text-area
Widget _textArea(ExampleSettings settings) => WiredTextArea(
  hintText: settings.label,
);

/// @docs-example search-bar
Widget _searchBar(ExampleSettings settings) =>
    WiredSearchBar(hintText: settings.label);

/// @docs-example checkbox-list-tile
Widget _checkboxListTile(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final checked = useState(true);
    return WiredCheckboxListTile(
      value: checked.value,
      onChanged: (value) => checked.value = value ?? false,
      title: Text(settings.label),
      showDivider: false,
    );
  },
);

/// @docs-example radio
Widget _radio(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final selected = useState('paper');
    return Wrap(
      children: [
        for (final value in ['paper', 'ink'])
          WiredRadio<String>(
            value: value,
            groupValue: selected.value,
            semanticLabel: value,
            onChanged: settings.enabled
                ? (value) {
                    selected.value = value!;
                    return true;
                  }
                : null,
          ),
      ],
    );
  },
);

/// @docs-example radio-list-tile
Widget _radioListTile(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final selected = useState('paper');
    return Column(
      children: [
        for (final value in ['paper', 'ink'])
          WiredRadioListTile<String>(
            title: Text(value),
            value: value,
            groupValue: selected.value,
            showDivider: false,
            onChanged: settings.enabled
                ? (value) {
                    selected.value = value!;
                    return true;
                  }
                : null,
          ),
      ],
    );
  },
);

/// @docs-example switch-list-tile
Widget _switchListTile(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final enabled = useState(true);
    return WiredSwitchListTile(
      value: enabled.value,
      onChanged: (value) => enabled.value = value,
      title: Text(settings.label),
      showDivider: false,
    );
  },
);

/// @docs-example toggle
Widget _toggle(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final enabled = useState(false);
    return WiredToggle(
      value: enabled.value,
      semanticLabel: 'Ink enabled',
      onChange: (value) {
        enabled.value = value;
        return true;
      },
    );
  },
);

/// @docs-example autocomplete
Widget _autocomplete(ExampleSettings settings) => WiredAutocomplete<String>(
  options: const ['Apple', 'Apricot', 'Banana', 'Cherry'],
  displayStringForOption: (value) => value,
  hintText: settings.label,
  optionsWidth: 260,
);

/// @docs-example cupertino-text-field
Widget _cupertinoTextField(ExampleSettings settings) => WiredCupertinoTextField(
  placeholder: settings.label,
  enabled: settings.enabled,
  borderRadius: BorderRadius.circular(settings.radius),
);

/// @docs-example cupertino-slider
Widget _cupertinoSlider(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final value = useState(.6);
    return WiredCupertinoSlider(
      value: value.value,
      onChanged: settings.enabled ? (next) => value.value = next : null,
    );
  },
);

/// @docs-example cupertino-switch
Widget _cupertinoSwitch(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final value = useState(true);
    return WiredCupertinoSwitch(
      value: value.value,
      onChanged: settings.enabled ? (next) => value.value = next : null,
    );
  },
);

/// @docs-example form
Widget _form(ExampleSettings settings) => WiredForm(
  borderRadius: BorderRadius.circular(settings.radius),
  child: WiredInput(labelText: settings.label, hintText: 'Your next idea'),
);

/// @docs-example range-slider
Widget _rangeSlider(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final range = useState((start: .2, end: .8));
    return WiredRangeSlider.between(
      start: range.value.start,
      end: range.value.end,
      divisions: 10,
      onChanged: settings.enabled
          ? (start, end) {
              range.value = (start: start, end: end);
              return true;
            }
          : null,
    );
  },
);

/// @docs-example search-anchor
Widget _searchAnchor(ExampleSettings settings) => WiredSearchAnchor(
  builder: (context, controller) => WiredSearchBar(
    controller: controller,
    hintText: settings.label,
    onTap: controller.openView,
  ),
  suggestionsBuilder: (context, controller) => [
    for (final option in ['Paper', 'Ink', 'Possibility'].where(
      (option) => option.toLowerCase().contains(controller.text.toLowerCase()),
    ))
      WiredListTile(
        title: Text(option),
        showDivider: false,
        onTap: () => controller.closeView(option),
      ),
  ],
);
