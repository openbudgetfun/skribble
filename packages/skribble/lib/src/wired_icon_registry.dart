import 'package:flutter/widgets.dart';

import 'wired_icon.dart';
import 'wired_svg_icon_data.dart';

/// Resolves a Flutter [IconData] to precomputed hand-drawn geometry.
typedef WiredIconResolver = WiredSvgIconData? Function(IconData icon);

/// Resolves a catalog identifier such as `'search'` to hand-drawn geometry.
typedef WiredIconIdentifierResolver = WiredSvgIconData? Function(
  String identifier,
);

/// A registered icon catalog that [WiredIcon] can draw from.
///
/// Icon-set packages build one of these from their generated maps and register
/// it, so the core library never depends on a particular icon set.
final class WiredIconCatalog {
  /// Creates a catalog description.
  const WiredIconCatalog({
    required this.name,
    required this.resolve,
    required this.resolveByIdentifier,
    required this.fontFamily,
    required this.identifierCodePoints,
    required this.codePoints,
  });

  /// Human-readable catalog name, used in diagnostics.
  final String name;

  /// Resolves a Flutter [IconData] to hand-drawn geometry, or `null`.
  final WiredIconResolver resolve;

  /// Resolves a catalog identifier to hand-drawn geometry, or `null`.
  final WiredIconIdentifierResolver resolveByIdentifier;

  /// Font family backing the catalog's plain-font fallback glyphs.
  final String fontFamily;

  /// Identifier to codepoint, including legacy alias identifiers.
  final Map<String, int> identifierCodePoints;

  /// Every codepoint the catalog ships.
  final List<int> codePoints;
}

WiredIconCatalog? _catalog;

/// The registered catalog, or `null` when none is loaded.
WiredIconCatalog? get wiredIconCatalog => _catalog;

/// Registers [catalog] as the set [WiredIcon] draws from.
///
/// An icon-set package calls this from its own library so that importing the
/// package is enough to activate it. A later registration replaces an earlier
/// one, which lets an app or test swap catalogs.
void registerWiredIconCatalog(WiredIconCatalog catalog) {
  _catalog = catalog;
}

/// Removes the registered catalog, restoring the plain-font fallback.
///
/// Tests use this to assert behaviour without a catalog loaded.
void clearWiredIconCatalog() {
  _catalog = null;
}

/// Font family registered by the active catalog, or `null`.
String? get registeredMaterialRoughFontFamily => _catalog?.fontFamily;

/// Identifier-to-codepoint map from the active catalog, or an empty map.
Map<String, int> get registeredMaterialRoughFontCodePoints =>
    _catalog?.identifierCodePoints ?? const <String, int>{};

/// Codepoints from the active catalog, or an empty list.
List<int> get registeredMaterialRoughCodePoints =>
    _catalog?.codePoints ?? const <int>[];
