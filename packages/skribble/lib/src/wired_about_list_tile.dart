import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'wired_about_dialog.dart';
import 'wired_list_tile.dart';

/// A list tile that opens a hand-drawn about dialog when tapped.
///
/// Mirrors Material's `AboutListTile`: the tile shows an [icon] and a
/// tile title (or the default `About <name>` label) and opens a
/// [WiredAboutDialog] with the supplied application metadata on tap.
///
/// ```dart
/// WiredAboutListTile(
///   icon: const Icon(Icons.info_outline),
///   applicationName: 'Sketchbook',
///   applicationVersion: '1.2.3',
///   applicationLegalese: 'Made with pencil and paper.',
/// )
/// ```
class WiredAboutListTile extends HookWidget {
  /// Widget shown at the start of the tile.
  final Widget? icon;

  /// Primary content of the tile. Falls back to
  /// `Text('About <applicationName>')` (or simply `Text('About')`).
  final Widget? child;

  /// The name of the application.
  final String? applicationName;

  /// The version string.
  final String? applicationVersion;

  /// The application icon widget.
  final Widget? applicationIcon;

  /// Legal text shown at the bottom of the dialog.
  final String? applicationLegalese;

  /// Additional children shown below the about information.
  final List<Widget>? aboutBoxChildren;

  /// Optional semantic label for accessibility.
  final String? semanticLabel;

  const WiredAboutListTile({
    super.key,
    this.icon,
    this.child,
    this.applicationName,
    this.applicationVersion,
    this.applicationIcon,
    this.applicationLegalese,
    this.aboutBoxChildren,
    this.semanticLabel,
  });

  Future<void> _showAbout(BuildContext context) {
    return showWiredAboutDialog(
      context: context,
      applicationName: applicationName,
      applicationVersion: applicationVersion,
      applicationIcon: applicationIcon,
      applicationLegalese: applicationLegalese,
      children: aboutBoxChildren,
    );
  }

  @override
  Widget build(BuildContext context) {
    final label =
        'About'
        '${applicationName == null || applicationName!.isEmpty ? '' : ' $applicationName'}';

    return Semantics(
      label: semanticLabel,
      button: true,
      onTap: () => _showAbout(context),
      child: WiredListTile(
        leading: icon,
        title: child ?? Text(label),
        onTap: () => _showAbout(context),
      ),
    );
  }
}
