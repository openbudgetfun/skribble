import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_example/models/sketch_settings.dart';

/// The settings page for the Sketch Notes app.
///
/// Demonstrates [WiredSwitchListTile], [WiredSlider], [WiredDivider],
/// and [showWiredAboutDialog] in a cohesive settings layout. The switch and
/// slider change the whole app through [SketchSettingsScope].
class SettingsPage extends HookWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SketchSettingsScope.of(context);
    final current = useValueListenable(settings);

    return WiredScaffold(
      appBar: WiredAppBar(
        leading: WiredIconButton(
          icon: Icons.arrow_back,
          size: 40,
          onPressed: () => Navigator.pop(context),
          semanticLabel: 'Go back',
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Appearance',
              style: TextStyle(
                color: WiredTheme.of(context).borderColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          WiredSwitchListTile(
            value: current.night,
            onChanged: (value) =>
                settings.value = current.copyWith(night: value),
            title: const Text('Dark Mode'),
            subtitle: const Text('Write on night parchment'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Roughness: ${current.roughness.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: WiredTheme.of(context).textColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Adjust the sketchiness of drawn elements',
                  style: TextStyle(
                    color: WiredTheme.of(context).disabledTextColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                WiredSlider(
                  value: current.roughness,
                  min: 0.5,
                  max: 2.5,
                  semanticLabel: 'Roughness',
                  onChanged: (value) {
                    settings.value = current.copyWith(roughness: value);
                    return true;
                  },
                ),
              ],
            ),
          ),
          const WiredDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'General',
              style: TextStyle(
                color: WiredTheme.of(context).borderColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          WiredListTile(
            leading: const WiredIcon(
              icon: Icons.palette,
              size: 22,
            ),
            title: const Text('Theme'),
            subtitle: Text(
              current.night ? 'Night parchment' : 'Warm parchment',
            ),
          ),
          WiredListTile(
            leading: const WiredIcon(
              icon: Icons.text_fields,
              size: 22,
            ),
            title: const Text('Font Size'),
            subtitle: const Text('Medium'),
          ),
          const WiredDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Information',
              style: TextStyle(
                color: WiredTheme.of(context).borderColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          WiredListTile(
            leading: const WiredIcon(
              icon: Icons.info_outline,
              size: 22,
            ),
            title: const Text('About'),
            subtitle: const Text('Version 1.0.0'),
            showDivider: false,
            onTap: () async {
              await showWiredAboutDialog(
                context: context,
                applicationName: 'Sketch Notes',
                applicationVersion: '1.0.0',
                applicationLegalese:
                    'A hand-drawn notes app built with the Skribble '
                    'design system.\n\nMade with sketchy love.',
              );
            },
          ),
        ],
      ),
    );
  }
}
