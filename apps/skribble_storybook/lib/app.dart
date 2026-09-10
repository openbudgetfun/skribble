import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_storybook/pages/buttons_page.dart';
import 'package:skribble_storybook/pages/charts_page.dart';
import 'package:skribble_storybook/pages/data_display_page.dart';
import 'package:skribble_storybook/pages/emoji_page.dart';
import 'package:skribble_storybook/pages/feedback_page.dart';
import 'package:skribble_storybook/pages/font_specimen_page.dart';
import 'package:skribble_storybook/pages/home_page.dart';
import 'package:skribble_storybook/pages/inputs_page.dart';
import 'package:skribble_storybook/pages/layout_page.dart';
import 'package:skribble_storybook/pages/maps_page.dart';
import 'package:skribble_storybook/pages/motion_page.dart';
import 'package:skribble_storybook/pages/navigation_page.dart';
import 'package:skribble_storybook/pages/rough_icons_page.dart';
import 'package:skribble_storybook/pages/selection_page.dart';
import 'package:skribble_storybook/pages/skribble_icons_page.dart';
import 'package:skribble_storybook/pages/studio_page.dart';
import 'package:skribble_storybook/widgets/roughness_picker.dart';

class SkribbleStorybookApp extends HookWidget {
  const SkribbleStorybookApp({super.key});

  @override
  Widget build(BuildContext context) {
    final roughness = useState(WiredRoughness.playful);
    final wiredTheme = WiredThemeData(
      roughnessLevel: roughness.value,
      borderColor: const Color(0xFF4A3470),
      textColor: const Color(0xFF2A2238),
      disabledTextColor: const Color(0xFFA39AAD),
      fillColor: const Color(0xFFFFFCF1),
    );

    return WiredMaterialApp(
      wiredTheme: wiredTheme,
      title: 'Skribble Storybook',
      initialRoute: const String.fromEnvironment(
        'STORYBOOK_ROUTE',
        defaultValue: '/',
      ),
      builder: (context, child) => DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!,
        child: Column(
          // Paint the toolbar after the navigator so its route semantics do
          // not hide these app-wide controls from assistive technology.
          verticalDirection: VerticalDirection.up,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: child ?? const SizedBox.shrink()),
            WiredRoughnessPicker(
              value: roughness.value,
              onChanged: (value) => roughness.value = value,
            ),
          ],
        ),
      ),
      routes: {
        '/': (context) => const HomePage(),
        '/motion': (context) => const WiredMotionPage(),
        '/studio': (context) => const WiredStudioPage(),
        '/buttons': (context) => const ButtonsPage(),
        '/inputs': (context) => const InputsPage(),
        '/navigation': (context) => const NavigationPage(),
        '/selection': (context) => const SelectionPage(),
        '/feedback': (context) => const FeedbackPage(),
        '/layout': (context) => const LayoutPage(),
        '/maps': (context) => const MapsPage(),
        '/charts': (context) => const ChartsPage(),
        '/data-display': (context) => const DataDisplayPage(),
        '/rough-icons': (context) => const RoughIconsPage(),
        '/skribble-icons': (context) => const SkribbleIconsPage(),
        '/emoji': (context) => const EmojiPage(),
        '/font-specimen': (context) => const FontSpecimenPage(),
      },
    );
  }
}
