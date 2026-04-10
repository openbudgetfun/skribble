import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_example/pages/edit_page.dart';
import 'package:skribble_example/pages/home_page.dart';
import 'package:skribble_example/pages/settings_page.dart';

/// The root widget for the Sketch Notes app.
///
/// Uses [WiredMaterialApp] with a warm sepia theme to give the entire
/// app a cohesive hand-drawn, parchment-like feel.
class SketchNotesApp extends HookWidget {
  const SketchNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final wiredTheme = WiredThemeData(
      borderColor: const Color(0xFF5C3D2E),
      textColor: const Color(0xFF2E2E2E),
      disabledTextColor: const Color(0xFFA89888),
      fillColor: const Color(0xFFF5ECD7),
      roughness: 1.2,
    );

    return WiredMaterialApp(
      wiredTheme: wiredTheme,
      title: 'Sketch Notes',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/edit': (context) => const EditPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
