part of 'catalog.dart';

/// @docs-example button
Widget _button(ExampleSettings settings) => WiredButton(
  borderRadius: BorderRadius.circular(settings.radius),
  onPressed: () {},
  inkInteraction: settings.interaction,
  child: Text(settings.label),
);

/// @docs-example elevated-button
Widget _elevated(ExampleSettings settings) => WiredElevatedButton(
  borderRadius: BorderRadius.circular(settings.radius),
  onPressed: settings.enabled ? () {} : null,
  inkInteraction: settings.interaction,
  child: Text(settings.label),
);

/// @docs-example filled-button
Widget _filled(ExampleSettings settings) => WiredFilledButton(
  borderRadius: BorderRadius.circular(settings.radius),
  onPressed: settings.enabled ? () {} : null,
  fillColor: settings.color,
  inkInteraction: settings.interaction,
  child: Text(settings.label),
);

/// @docs-example outlined-button
Widget _outlined(ExampleSettings settings) => WiredOutlinedButton(
  borderRadius: BorderRadius.circular(settings.radius),
  onPressed: settings.enabled ? () {} : null,
  inkInteraction: settings.interaction,
  child: Text(settings.label),
);

/// @docs-example text-button
Widget _text(ExampleSettings settings) => WiredTextButton(
  onPressed: settings.enabled ? () {} : null,
  inkInteraction: settings.interaction,
  child: Text(settings.label),
);

/// @docs-example floating-button
Widget _floating(ExampleSettings settings) => WiredFloatingActionButton(
  icon: const IconData(0xe047, fontFamily: 'MaterialIcons'),
  semanticLabel: 'Add an idea',
  onPressed: settings.enabled ? () {} : null,
);

/// @docs-example icon-button
Widget _icon(ExampleSettings settings) => WiredIconButton(
  icon: const IconData(0xe25b, fontFamily: 'MaterialIcons'),
  semanticLabel: 'Favourite',
  onPressed: settings.enabled ? () {} : null,
);

/// @docs-example cupertino-button
Widget _cupertino(ExampleSettings settings) => WiredCupertinoButton(
  onPressed: settings.enabled ? () {} : null,
  color: const Color(0xffe8957d),
  borderRadius: BorderRadius.circular(settings.radius),
  child: Text(settings.label),
);

/// @docs-example toggle-buttons
Widget _toggles(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final selected = useState([true, false, false]);
    return WiredToggleButtons(
      isSelected: selected.value,
      onPressed: settings.enabled
          ? (index) {
              final next = List<bool>.of(selected.value);
              next[index] = !next[index];
              selected.value = next;
            }
          : null,
      children: const [Text('B'), Text('I'), Text('U')],
    );
  },
);

/// @docs-example segmented-button
Widget _segmented(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final selected = useState({'week'});
    return WiredSegmentedButton<String>(
      segments: const [
        WiredButtonSegment(value: 'day', label: Text('Day')),
        WiredButtonSegment(value: 'week', label: Text('Week')),
        WiredButtonSegment(value: 'month', label: Text('Month')),
      ],
      selected: selected.value,
      onSelectionChanged: settings.enabled
          ? (value) => selected.value = value
          : null,
    );
  },
);
