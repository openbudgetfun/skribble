import 'package:flutter/material.dart';
import 'package:skribble_example/app.dart';
import 'package:skribble_icons/skribble_icons.dart';

void main() {
  // Hand-drawn versions of every Material icon, such as the settings page's
  // palette and text-size icons.
  registerSkribbleIcons();
  runApp(const SketchNotesApp());
}
