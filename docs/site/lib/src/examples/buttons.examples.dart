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

/// @docs-example floating-button-sizes
Widget _floatingSizes(ExampleSettings settings) => Wrap(
  spacing: 16,
  runSpacing: 16,
  crossAxisAlignment: WrapCrossAlignment.center,
  children: [
    WiredFloatingActionButton.small(
      icon: const IconData(0xe047, fontFamily: 'MaterialIcons'),
      tooltip: 'Add',
      onPressed: settings.enabled ? () {} : null,
    ),
    WiredFloatingActionButton(
      icon: const IconData(0xe047, fontFamily: 'MaterialIcons'),
      tooltip: 'Add',
      onPressed: settings.enabled ? () {} : null,
    ),
    WiredFloatingActionButton.large(
      icon: const IconData(0xe047, fontFamily: 'MaterialIcons'),
      tooltip: 'Add',
      onPressed: settings.enabled ? () {} : null,
    ),
  ],
);

/// @docs-example floating-button-extended
Widget _floatingExtended(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final extended = useState(true);
    return WiredFloatingActionButton.extended(
      icon: const IconData(0xe21a, fontFamily: 'MaterialIcons'),
      label: Text(settings.label),
      isExtended: extended.value,
      onPressed: settings.enabled
          ? () => extended.value = !extended.value
          : null,
    );
  },
);

/// @docs-example icon-button-variants
Widget _iconVariants(ExampleSettings settings) => Wrap(
  spacing: 12,
  runSpacing: 12,
  children: [
    WiredIconButton(
      icon: const IconData(0xe25b, fontFamily: 'MaterialIcons'),
      tooltip: 'Favourite',
      onPressed: settings.enabled ? () {} : null,
    ),
    WiredIconButton.filled(
      icon: const IconData(0xe571, fontFamily: 'MaterialIcons'),
      tooltip: 'Send',
      onPressed: settings.enabled ? () {} : null,
    ),
    WiredIconButton.filledTonal(
      icon: const IconData(0xe593, fontFamily: 'MaterialIcons'),
      tooltip: 'Share',
      onPressed: settings.enabled ? () {} : null,
    ),
    WiredIconButton.outlined(
      icon: const IconData(0xe21a, fontFamily: 'MaterialIcons'),
      tooltip: 'Edit',
      onPressed: settings.enabled ? () {} : null,
    ),
  ],
);

/// @docs-example icon-button-toggle
Widget _iconToggle(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final saved = useState(false);
    return WiredIconButton(
      icon: const IconData(0xe0f4, fontFamily: 'MaterialIcons'),
      selectedIcon: const IconData(0xe0f1, fontFamily: 'MaterialIcons'),
      isSelected: saved.value,
      tooltip: saved.value ? 'Remove bookmark' : 'Bookmark',
      onPressed: settings.enabled ? () => saved.value = !saved.value : null,
    );
  },
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
