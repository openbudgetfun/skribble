import 'package:flutter/widgets.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_icons/skribble_icons.dart';

/// Draws icons from several bundled sets through one lookup.
void main() {
  // Lets WiredIcon(icon: Icons.search) draw hand-drawn Material geometry.
  registerSkribbleIcons();
  runApp(
    SkribbleApp(
      wiredTheme: WiredThemeData(),
      home: const IconsExample(),
    ),
  );
}

/// A row of icons resolved by name from different sets.
class IconsExample extends StatelessWidget {
  /// Creates the example screen.
  const IconsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      // Icons follow the ambient IconTheme size and colour.
      child: IconTheme(
        data: const IconThemeData(size: 40),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            for (final (name, label) in const [
              ('home', 'Home'),
              ('github', 'GitHub'),
              ('a-arrow-down', 'Decrease text size'),
            ])
              if (lookupSkribbleIconByIdentifier(name) case final data?)
                WiredSvgIcon(data: data, semanticLabel: label),
          ],
        ),
      ),
    );
  }
}
