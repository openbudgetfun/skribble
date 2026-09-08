import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_emoji/skribble_emoji.dart';
import 'package:skribble_icons/skribble_icons.dart';
import 'package:skribble_storybook/testing/quality_keys.dart';

/// A working notebook for checking typography, controls, and artwork together.
class WiredStudioPage extends HookWidget {
  const WiredStudioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final parentNavigator = Navigator.maybeOf(context);
    final dark = useState(false);
    final done = useState(false);
    final reminder = useState(true);
    final note = useState('');
    final saved = useState('Pick something small. Make it yours.');
    final controller = useTextEditingController();
    final theme = WiredThemeData(
      roughnessLevel: WiredTheme.of(context).roughnessLevel,
      borderColor: dark.value
          ? const Color(0xffdfc4ff)
          : const Color(0xff624079),
      textColor: dark.value ? const Color(0xfffff7e5) : const Color(0xff382d40),
      fillColor: dark.value ? const Color(0xff29232f) : const Color(0xfffffbef),
      disabledTextColor: dark.value
          ? const Color(0xffbdb0c8)
          : const Color(0xff716579),
    );

    return WiredMaterialApp(
      initialRoute: '/',
      onNavigationNotification: (_) => true,
      wiredTheme: theme,
      darkWiredTheme: theme,
      home: Builder(
        builder: (context) => DefaultTextStyle(
          style: TextStyle(
            fontFamily: theme.fontFamily,
            package: theme.fontPackage,
            color: theme.textColor,
            fontSize: 16,
          ),
          child: ColoredBox(
            color: theme.fillColor,
            child: SafeArea(
              child: SingleChildScrollView(
                key: QualityKeys.scroll,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (parentNavigator?.canPop() ?? false)
                          WiredTextButton(
                            onPressed: () => parentNavigator!.pop(),
                            child: const Text('All components'),
                          ),
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          spacing: 24,
                          runSpacing: 16,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Your everyday sketchbook',
                              style: TextStyle(
                                fontSize: 18,
                                color: theme.disabledTextColor,
                              ),
                            ),
                            WiredOutlinedButton(
                              key: QualityKeys.dark,
                              onPressed: () => dark.value = !dark.value,
                              child: Text(
                                dark.value ? 'Morning paper' : 'Evening ink',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Little plans,\nbig days.',
                          key: QualityKeys.title,
                          style: TextStyle(
                            fontSize: 52,
                            height: 1.12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'A little room for ideas, daydreams, and getting things done.',
                          style: TextStyle(fontSize: 18, height: 1.5),
                        ),
                        const SizedBox(height: 28),
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          children: [
                            for (final name in [
                              'sun_with_face',
                              'seedling',
                              'hot_beverage',
                              'sparkles',
                              'rainbow',
                            ])
                              PrecomputedEmoji.fromName(
                                name,
                                size: 44,
                                semanticLabel: name.replaceAll('_', ' '),
                              ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        WiredCard(
                          height: null,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'One good thing today',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    WiredCheckbox(
                                      key: QualityKeys.checkbox,
                                      value: done.value,
                                      semanticLabel:
                                          'Make time to make something',
                                      onChanged: (value) =>
                                          done.value = value ?? false,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        'Make time to make something',
                                        style: TextStyle(
                                          fontSize: 18,
                                          height: 1.5,
                                          decoration: done.value
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  key: QualityKeys.status,
                                  done.value
                                      ? 'A small win. Nicely done!'
                                      : 'Small steps count.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: theme.disabledTextColor,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                WiredInput(
                                  key: QualityKeys.input,
                                  controller: controller,
                                  hintText: 'An idea worth keeping…',
                                  semanticLabel: 'Your next idea',
                                  onChanged: (value) => note.value = value,
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 12,
                                  children: [
                                    WiredElevatedButton(
                                      key: QualityKeys.add,
                                      onPressed: note.value.trim().isEmpty
                                          ? null
                                          : () =>
                                                saved.value = note.value.trim(),
                                      child: const Text('Keep this idea'),
                                    ),
                                    WiredTextButton(
                                      key: QualityKeys.reset,
                                      onPressed: () {
                                        controller.clear();
                                        note.value = '';
                                        done.value = false;
                                        saved.value = 'Pick something small. Make it yours.';
                                      },
                                      child: const Text('Start fresh'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  key: QualityKeys.inputResult,
                                  saved.value,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            WiredSwitch(
                              key: QualityKeys.switchControl,
                              value: reminder.value,
                              semanticLabel: 'A gentle reminder',
                              onChanged: (value) => reminder.value = value,
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                key: QualityKeys.reminderStatus,
                                reminder.value
                                    ? 'A gentle reminder, now and then.'
                                    : 'Quiet time. Reminders are off.',
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Wrap(
                          spacing: 24,
                          runSpacing: 16,
                          children: [
                            for (final name in [
                              'heart',
                              'star',
                              'edit',
                              'mail',
                              'calendar',
                            ])
                              WiredSvgIcon(
                                data: lookupSkribbleCustomIconByIdentifier(
                                  name,
                                )!,
                                size: 28,
                              ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Made of imperfect lines and good intentions.',
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
