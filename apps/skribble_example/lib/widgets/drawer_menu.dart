import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_example/widgets/sketch_notes_about.dart';

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
          // A drawer header fills the height it is given, and a list gives
          // none, so the header sets one. It leaves room for larger text.
          SizedBox(
            height: 170,
            child: WiredDrawerHeader(
              child: Row(
                children: [
                  const WiredAvatar(
                    radius: 28,
                    child: WiredIcon(icon: Icons.edit, size: 24),
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
            leading: const WiredIcon(icon: Icons.notes, size: 22),
            title: const Text('All Notes'),
            // The drawer opens over the notes list, so closing it is enough.
            // Replacing the route would build a fresh list and lose the notes.
            onTap: () => Navigator.pop(context),
          ),
          const WiredDivider(),
          WiredListTile(
            leading: const WiredIcon(icon: Icons.settings, size: 22),
            title: const Text('Settings'),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.pushNamed(context, '/settings');
            },
          ),
          WiredListTile(
            leading: const WiredIcon(icon: Icons.info_outline, size: 22),
            title: const Text('About'),
            showDivider: false,
            onTap: () async {
              Navigator.pop(context);
              await showSketchNotesAbout(context);
            },
          ),
        ],
      ),
    );
  }
}
