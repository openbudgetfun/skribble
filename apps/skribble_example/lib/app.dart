import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_example/models/sketch_settings.dart';
import 'package:skribble_example/pages/edit_page.dart';
import 'package:skribble_example/pages/home_page.dart';
import 'package:skribble_example/pages/settings_page.dart';

/// The pages of Sketch Notes by route name.
///
/// The edit page takes the note to edit as its route argument, or nothing
/// for a new note, and pops with the saved note.
final Map<String, WidgetBuilder> sketchNotesRoutes = {
  '/': (context) => const HomePage(),
  '/edit': (context) => const EditPage(),
  '/settings': (context) => const SettingsPage(),
};

/// Warm day parchment: brown ink on cream paper.
///
/// A [WiredThemeData] is the whole look of a skribble app: the ink, the
/// paper, the marker behind selections, and how rough every line is.
WiredThemeData dayParchment({required double roughness}) => WiredThemeData(
  borderColor: const Color(0xFF5C3D2E),
  textColor: const Color(0xFF2E2E2E),
  disabledTextColor: const Color(0xFFA89888),
  fillColor: const Color(0xFFF5ECD7),
  markerColor: const Color(0xFFE8D3AE),
  roughness: roughness,
);

/// Night parchment: cream ink on dark brown paper.
WiredThemeData nightParchment({required double roughness}) => WiredThemeData(
  borderColor: const Color(0xFFEBDDC4),
  textColor: const Color(0xFFF5ECD7),
  disabledTextColor: const Color(0xFFA89888),
  fillColor: const Color(0xFF2A221C),
  markerColor: const Color(0xFF5C4636),
  roughness: roughness,
);

/// The root widget for the Sketch Notes app.
///
/// Holds the [SketchSettings] in a notifier that the settings page writes
/// through [SketchSettingsScope], and redraws the whole app when they
/// change: day or night parchment, the roughness of the ink, and the text
/// size.
class SketchNotesApp extends HookWidget {
  const SketchNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = useValueNotifier(const SketchSettings());
    final current = useValueListenable(settings);

    return SketchSettingsScope(
      notifier: settings,
      // WiredMaterialApp is the bridge for apps that still sit on
      // MaterialApp: the notes app uses WiredInput, which wraps a Material
      // text field. New apps without Material widgets use SkribbleApp, which
      // takes the same themes and routes; test/skribble_app_test.dart tracks
      // what this app still needs before it can switch.
      child: WiredMaterialApp(
        title: 'Sketch Notes',
        wiredTheme: dayParchment(roughness: current.roughness),
        darkWiredTheme: nightParchment(roughness: current.roughness),
        // The app's own switch decides, rather than the system brightness.
        themeMode: current.night ? ThemeMode.dark : ThemeMode.light,
        builder: (context, child) =>
            NoteTextSizeScope(size: current.textSize, child: child!),
        routes: sketchNotesRoutes,
      ),
    );
  }
}

/// Applies a [NoteTextSize] on top of the reader's system text size.
///
/// skribble controls take their heights as minimums, so every button, field,
/// and tile grows with the text instead of clipping it.
class NoteTextSizeScope extends HookWidget {
  /// Scales the text below [child] by [size].
  const NoteTextSizeScope({required this.size, required this.child, super.key});

  /// How much larger or smaller to write.
  final NoteTextSize size;

  /// The app below this scope.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (size == NoteTextSize.medium) return child;
    final system = MediaQuery.textScalerOf(context);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        // Multiply the reader's own text size rather than replacing it, so
        // the setting never undoes an accessibility preference. Body text
        // (14 pixels) sets the factor when the system scales nonlinearly.
        textScaler: TextScaler.linear(system.scale(14) / 14 * size.scale),
      ),
      child: child,
    );
  }
}
