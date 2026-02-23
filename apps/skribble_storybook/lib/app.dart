import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_storybook/pages/buttons_page.dart';
import 'package:skribble_storybook/pages/data_display_page.dart';
import 'package:skribble_storybook/pages/feedback_page.dart';
import 'package:skribble_storybook/pages/home_page.dart';
import 'package:skribble_storybook/pages/inputs_page.dart';
import 'package:skribble_storybook/pages/layout_page.dart';
import 'package:skribble_storybook/pages/navigation_page.dart';
import 'package:skribble_storybook/pages/selection_page.dart';

class SkribbleStorybookApp extends HookWidget {
  const SkribbleStorybookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WiredTheme(
      data: WiredThemeData(),
      child: MaterialApp(
        title: 'Skribble Storybook',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.brown,
        ),
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
        },
      ),
    );
  }
}
