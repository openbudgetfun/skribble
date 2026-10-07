import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_example/models/sketch_settings.dart';
import 'package:skribble_example/pages/edit_page.dart';
import 'package:skribble_example/pages/home_page.dart';
import 'package:skribble_example/pages/settings_page.dart';

/// The root widget for the Sketch Notes app.
///
/// Uses [WiredMaterialApp] with warm parchment themes, by day and by night,
/// to give the whole app a cohesive hand-drawn feel. The settings page
/// changes the paper and the roughness through [SketchSettingsScope].
class SketchNotesApp extends HookWidget {
  const SketchNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = useValueNotifier(const SketchSettings());
    final current = useValueListenable(settings);
    final wiredTheme = current.night
        ? WiredThemeData(
            borderColor: const Color(0xFFEBDDC4),
            textColor: const Color(0xFFF5ECD7),
            disabledTextColor: const Color(0xFFA89888),
            fillColor: const Color(0xFF2A221C),
            markerColor: const Color(0xFF5C4636),
            roughness: current.roughness,
          )
        : WiredThemeData(
            borderColor: const Color(0xFF5C3D2E),
            textColor: const Color(0xFF2E2E2E),
            disabledTextColor: const Color(0xFFA89888),
            fillColor: const Color(0xFFF5ECD7),
            markerColor: const Color(0xFFE8D3AE),
            roughness: current.roughness,
          );

    return SketchSettingsScope(
      notifier: settings,
      child: WiredMaterialApp(
        wiredTheme: wiredTheme,
        darkWiredTheme: wiredTheme,
        title: 'Sketch Notes',
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/edit': (context) => const EditPage(),
          '/settings': (context) => const SettingsPage(),
        },
      ),
    );
  }
}
