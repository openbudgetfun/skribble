import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_storybook/pages/buttons_page.dart';
import 'package:skribble_storybook/pages/data_display_page.dart';
import 'package:skribble_storybook/pages/emoji_page.dart';
import 'package:skribble_storybook/pages/feedback_page.dart';
import 'package:skribble_storybook/pages/home_page.dart';
import 'package:skribble_storybook/pages/inputs_page.dart';
import 'package:skribble_storybook/pages/layout_page.dart';
import 'package:skribble_storybook/pages/navigation_page.dart';
import 'package:skribble_storybook/pages/rough_icons_page.dart';
import 'package:skribble_storybook/pages/selection_page.dart';
import 'package:skribble_storybook/pages/skribble_icons_page.dart';

class SkribbleStorybookApp extends HookWidget {
  const SkribbleStorybookApp({super.key});

  @override
  Widget build(BuildContext context) {
    final wiredTheme = WiredThemeData(
      borderColor: const Color(0xFF4A3470),
      textColor: const Color(0xFF2A2238),
      disabledTextColor: const Color(0xFFA39AAD),
      fillColor: const Color(0xFFFFFCF1),
      roughness: 1.15,
    );

    return WiredMaterialApp(
      wiredTheme: wiredTheme,
      title: 'Skribble Storybook',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/buttons': (context) => const ButtonsPage(),
        '/inputs': (context) => const InputsPage(),
        '/navigation': (context) => const NavigationPage(),
        '/selection': (context) => const SelectionPage(),
        '/feedback': (context) => const FeedbackPage(),
        '/layout': (context) => const LayoutPage(),
        '/data-display': (context) => const DataDisplayPage(),
        '/rough-icons': (context) => const RoughIconsPage(),
        '/skribble-icons': (context) => const SkribbleIconsPage(),
        '/emoji': (context) => const EmojiPage(),
      },
    );
  }
}
