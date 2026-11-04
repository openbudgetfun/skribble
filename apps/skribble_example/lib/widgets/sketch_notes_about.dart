import 'package:flutter/material.dart';
import 'package:skribble/skribble.dart';

/// The version shown in the about dialog and on the settings page.
const sketchNotesVersion = '1.0.0';

/// Shows the hand-drawn about dialog for Sketch Notes. The drawer and the
/// settings page both open it.
Future<void> showSketchNotesAbout(BuildContext context) => showWiredAboutDialog(
  context: context,
  applicationName: 'Sketch Notes',
  applicationVersion: sketchNotesVersion,
  applicationIcon: const WiredIcon(icon: Icons.edit, size: 32),
  applicationLegalese:
      'A hand-drawn notes app built with the skribble design system.',
);
