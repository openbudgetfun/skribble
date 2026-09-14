/// Hand-drawn Material icon catalog for skribble.
///
/// Ships precomputed rough geometry for the full Flutter Material icon set
///
/// Importing this library does not activate the catalog. Call
/// [registerSkribbleMaterialIcons] once during startup so that [WiredIcon]
/// renders hand-drawn shapes instead of falling back to Material's font
/// glyphs. The `skribble_icons` umbrella package does this for you.
///
/// ```dart
/// import 'package:skribble_icons_material/skribble_icons_material.dart';
///
/// void main() {
///   registerSkribbleMaterialIcons();
///   runApp(const MyApp());
/// }
/// ```
library;

import 'package:flutter/cupertino.dart' show IconData;
import 'package:flutter/material.dart' show IconData;
import 'package:flutter/widgets.dart' show IconData;
import 'package:skribble/skribble.dart';
import 'package:skribble_icons_material/src/generated/material_rough_icon_font.g.dart';
import 'package:skribble_icons_material/src/generated/material_rough_icons.g.dart';

export 'package:skribble_icons_material/src/generated/material_rough_icon_font.g.dart'
    show
        kMaterialRoughIconsCodePoints,
        kMaterialRoughIconsFontFamily,
        lookupMaterialRoughIconsIconData;
export 'package:skribble_icons_material/src/generated/material_rough_icons.g.dart'
    show kMaterialRoughIcons;

/// Activates the Material catalog for [WiredIcon] and similar core widgets.
///
/// Safe to call more than once, and safe to call before `runApp`. Without it,
/// [WiredIcon] falls back to Flutter's regular `Icon` widget.
void registerSkribbleMaterialIcons() {
  registerWiredIconCatalog(
    WiredIconCatalog(
      name: 'material',
      resolve: _resolveIcon,
      resolveByIdentifier: _resolveByIdentifier,
      fontFamily: kMaterialRoughIconsFontFamily,
      identifierCodePoints: kMaterialRoughIconsCodePoints,
      codePoints: kMaterialRoughIcons.keys.toList(growable: false),
      resolveFontIcon: lookupMaterialRoughIconsIconData,
    ),
  );
}

WiredSvgIconData? _resolveByIdentifier(String identifier) {
  final codePoint = kMaterialRoughIconsCodePoints[identifier];
  if (codePoint == null) {
    return null;
  }
  return kMaterialRoughIcons[codePoint];
}

WiredSvgIconData? _resolveIcon(IconData icon) {
  if (icon.fontFamily != 'MaterialIcons') {
    return null;
  }
  return kMaterialRoughIcons[icon.codePoint];
}

/// Font family backing the catalog's plain-font fallback glyphs.
String get materialRoughFontFamily => kMaterialRoughIconsFontFamily;

/// Identifier-to-codepoint map, including legacy alias identifiers that share
/// a codepoint with their canonical name.
Map<String, int> get materialRoughFontCodePoints =>
    kMaterialRoughIconsCodePoints;

/// Every identifier the catalog ships.
List<String> get materialRoughIconIdentifiers =>
    kMaterialRoughIconsCodePoints.keys.toList(growable: false);

/// Every codepoint the catalog ships.
List<int> get materialRoughIconCodePoints =>
    kMaterialRoughIcons.keys.toList(growable: false);

// `lookupMaterialRoughFontIcon` is not defined here: core owns it, building an
// IconData from whichever catalog is registered. Defining it in both places
// made every import of this library and `package:skribble/skribble.dart`
// together an ambiguous reference.
