import 'package:flutter/widgets.dart';
import 'package:skribble_example/app.dart';
import 'package:skribble_icons/skribble_icons.dart';

void main() {
  // Activate the hand-drawn Material catalog before the first frame, so
  // `WiredIcon(icon: Icons.menu)` draws with the pen instead of falling back
  // to the Material font glyph.
  registerSkribbleIcons();
  runApp(const SketchNotesApp());
}
