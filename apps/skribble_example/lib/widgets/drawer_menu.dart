import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

/// The drawer menu for the Sketch Notes app.
///
/// Shows a hand-drawn header with the app title and avatar, followed by
/// navigation items for "All Notes", "Settings", and "About".
class DrawerMenu extends HookWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return WiredDrawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 170,
            child: WiredDrawerHeader(
              child: Row(
                children: [
                  const WiredAvatar(
                    radius: 28,
                    child: WiredIcon(
                      icon: Icons.edit,
                      size: 24,
                      strokeWidth: 1.2,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Text(
                      'Sketch Notes',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: WiredTheme.of(context).textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          WiredListTile(
            leading: const WiredIcon(
              icon: Icons.notes,
              size: 22,
              strokeWidth: 1.2,
            ),
            title: const Text('All Notes'),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.pushReplacementNamed(context, '/');
            },
          ),
          const WiredDivider(),
          WiredListTile(
            leading: const WiredIcon(
              icon: Icons.settings,
              size: 22,
              strokeWidth: 1.2,
            ),
            title: const Text('Settings'),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.pushNamed(context, '/settings');
            },
          ),
          WiredListTile(
            leading: const WiredIcon(
              icon: Icons.info_outline,
              size: 22,
              strokeWidth: 1.2,
            ),
            title: const Text('About'),
            showDivider: false,
            onTap: () async {
              Navigator.pop(context);
              await showWiredAboutDialog(
                context: context,
                applicationName: 'Sketch Notes',
                applicationVersion: '1.0.0',
                applicationLegalese:
                    'Built with the Skribble hand-drawn design system.',
              );
            },
          ),
        ],
      ),
    );
  }
}
