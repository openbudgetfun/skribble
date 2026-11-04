import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_example/models/sketch_settings.dart';
import 'package:skribble_example/widgets/sketch_notes_about.dart';

/// The settings page for the Sketch Notes app.
///
/// Demonstrates [WiredSwitchListTile], [WiredSlider],
/// [WiredSegmentedButton], [WiredDivider], and [showWiredAboutDialog] in a
/// settings layout. Every control writes through [SketchSettingsScope], so
/// the whole app redraws as you change it.
class SettingsPage extends HookWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SketchSettingsScope.of(context);
    final current = useValueListenable(settings);
    final theme = WiredTheme.of(context);

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
          const _SectionHeader('Appearance'),
          WiredSwitchListTile(
            value: current.night,
            onChanged: (value) =>
                settings.value = current.copyWith(night: value),
            title: const Text('Dark Mode'),
            subtitle: Text(
              current.night ? 'Night parchment' : 'Warm parchment',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Roughness: ${current.roughness.toStringAsFixed(1)}',
                  style: TextStyle(color: theme.textColor, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Adjust the sketchiness of drawn elements',
                  style: TextStyle(
                    color: theme.disabledTextColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                WiredSlider(
                  value: current.roughness,
                  min: 0.5,
                  max: 2.5,
                  semanticLabel: 'Roughness',
                  // Returning true lets the slider move to the new value.
                  onChanged: (value) {
                    settings.value = current.copyWith(roughness: value);
                    return true;
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Text Size',
                  style: TextStyle(color: theme.textColor, fontSize: 16),
                ),
                const SizedBox(height: 8),
                WiredSegmentedButton<NoteTextSize>(
                  segments: [
                    for (final size in NoteTextSize.values)
                      WiredButtonSegment(value: size, label: Text(size.label)),
                  ],
                  selected: {current.textSize},
                  onSelectionChanged: (selection) => settings.value = current
                      .copyWith(textSize: selection.single),
                ),
              ],
            ),
          ),
          const WiredDivider(),
          const _SectionHeader('Information'),
          WiredListTile(
            leading: const WiredIcon(icon: Icons.info_outline, size: 22),
            title: const Text('About'),
            subtitle: const Text('Version $sketchNotesVersion'),
            showDivider: false,
            onTap: () => showSketchNotesAbout(context),
          ),
        ],
      ),
    );
  }
}

/// A small heading in the ink colour above a group of settings.
class _SectionHeader extends HookWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Semantics(
        header: true,
        child: Text(
          label,
          style: TextStyle(
            color: WiredTheme.of(context).borderColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
