// COMPATIBILITY LAYER -- transitional, sanctioned Material/Cupertino import.
//
// See `wired_theme_interop.dart` and docs/site/content/core/material-bridge.md
// for why this directory is the one place allowed to import Material.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../wired_theme.dart';
import '../wired_theme_scope.dart';
import 'wired_material_theme.dart';
import 'wired_theme_interop.dart';

/// Gives `Wired*` widgets the palette of an existing Material app.
///
/// `Wired*` widgets already work under a plain `MaterialApp`: with no
/// [WiredThemeScope] ancestor they fall back to [WiredThemeData.defaultTheme],
/// so they render a consistent Skribble look. Wrap a subtree in
/// `WiredThemeFromMaterial` when the Wired widgets should instead inherit the
/// host app's colors, for example while migrating a screen at a time:
///
/// ```dart
/// MaterialApp(
///   theme: myTheme,
///   home: WiredThemeFromMaterial(
///     child: WiredScaffold(
///       appBar: WiredAppBar(title: const Text('Migrated screen')),
///       body: const WiredButton(child: Text('Save')),
///     ),
///   ),
/// )
/// ```
///
/// Because it installs [WiredTheme], Material text styles inside the subtree
/// also pick up the Skribble font. Pass [data] to use explicit tokens instead
/// of deriving them from the ambient Material theme, and [WiredMaterialTheme]
/// for the opposite direction.
class WiredThemeFromMaterial extends StatelessWidget {
  /// Creates a Wired theme boundary derived from the ambient Material theme.
  const WiredThemeFromMaterial({super.key, this.data, required this.child});

  /// Explicit tokens to install. Defaults to the nearest [WiredThemeScope],
  /// then to tokens derived from the ambient Material theme.
  final WiredThemeData? data;

  /// The subtree that inherits the derived Wired theme.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WiredTheme(
      data:
          data ??
          WiredThemeScope.maybeOf(context) ??
          WiredThemeInterop.fromThemeData(Theme.of(context)),
      child: child,
    );
  }
}

/// Gives `Wired*` widgets the palette of an existing Cupertino app.
///
/// The Cupertino counterpart of [WiredThemeFromMaterial]: it derives
/// [WiredThemeData] from [CupertinoThemeData] and installs it with the
/// widgets-only [WiredThemeScope], so no Material theme is introduced into a
/// Cupertino app.
///
/// ```dart
/// CupertinoApp(
///   theme: CupertinoThemeData(primaryColor: CupertinoColors.systemPink),
///   home: WiredThemeFromCupertino(
///     child: WiredCupertinoScaffold(child: WiredCupertinoButton(...)),
///   ),
/// )
/// ```
class WiredThemeFromCupertino extends StatelessWidget {
  /// Creates a Wired theme boundary derived from the ambient Cupertino theme.
  const WiredThemeFromCupertino({super.key, this.data, required this.child});

  /// Explicit tokens to install. Defaults to the nearest [WiredThemeScope],
  /// then to tokens derived from the ambient Cupertino theme.
  final WiredThemeData? data;

  /// The subtree that inherits the derived Wired theme.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WiredThemeScope(
      data:
          data ??
          WiredThemeScope.maybeOf(context) ??
          WiredThemeInterop.fromCupertinoTheme(CupertinoTheme.of(context)),
      child: child,
    );
  }
}
