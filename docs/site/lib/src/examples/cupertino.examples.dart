part of 'catalog.dart';

/// @docs-example cupertino-list-tile
Widget _cupertinoListTile(ExampleSettings settings) => WiredCupertinoListTile(
  title: Text(settings.label),
  subtitle: const Text('Saved for a rainy day'),
  backgroundColor: const Color(0xffdde4c9),
  onTap: () {},
);

/// @docs-example cupertino-list-section
Widget _cupertinoListSection(ExampleSettings settings) =>
    WiredCupertinoListSection(
      header: Text(settings.label),
      children: const [
        WiredCupertinoListTile(title: Text('Sketches')),
        WiredCupertinoListTile(title: Text('Little notes')),
      ],
    );

/// @docs-example cupertino-activity-indicator
Widget _cupertinoActivity(ExampleSettings settings) => HookBuilder(
  builder: (context) {
    final running = useState(false);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WiredCupertinoActivityIndicator(animating: running.value, radius: 18),
        const SizedBox(height: 12),
        WiredTextButton(
          onPressed: () => running.value = !running.value,
          child: Text(running.value ? 'Pause' : 'Animate'),
        ),
      ],
    );
  },
);

/// @docs-example cupertino-search-text-field
Widget _cupertinoSearch(ExampleSettings settings) =>
    WiredCupertinoSearchTextField(
      placeholder: settings.label,
      enabled: settings.enabled,
      borderRadius: BorderRadius.circular(settings.radius),
    );

/// @docs-example cupertino-timer-picker
Widget _timerPicker(ExampleSettings settings) => WiredCupertinoTimerPicker(
  initialTimerDuration: const Duration(hours: 1, minutes: 15),
  onTimerDurationChanged: (duration) {},
);

/// @docs-example cupertino-form-section
Widget _cupertinoForm(ExampleSettings settings) => WiredCupertinoFormSection(
  header: Text(settings.label),
  children: const [
    WiredCupertinoTextField(placeholder: 'Your name'),
    WiredCupertinoTextField(placeholder: 'Your next idea'),
  ],
);
