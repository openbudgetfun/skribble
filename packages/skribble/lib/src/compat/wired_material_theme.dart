// COMPATIBILITY LAYER -- transitional, sanctioned Material/Cupertino import.
//
// See `wired_theme_interop.dart` and docs/site/content/core/material-bridge.md
// for why this directory is the one place allowed to import Material.

import 'package:flutter/material.dart';

import '../skribble_localizations.dart';
import '../wired_theme.dart';
import '../wired_theme_scope.dart';
import 'wired_theme_interop.dart';

/// Installs the Material theme and localizations that Material widgets need
/// inside a widgets-only `SkribbleApp`.
///
/// A `SkribbleApp` deliberately has no `MaterialApp` ancestor, so Material
/// widgets placed in its tree (a `Scaffold`, a `TextField`, a third-party
/// package widget) would otherwise fall back to `ThemeData.fallback()` and,
/// for widgets that assert on localizations, fail outright.
///
/// `WiredMaterialTheme` bridges that gap:
///
/// * it installs a Material `Theme` built from the active
///   [WiredThemeData] with [WiredThemeData.toThemeData];
/// * it installs `DefaultMaterialLocalizations` when no Material
///   localizations are present yet, so widgets such as `Scaffold` render;
/// * it does not touch the Wired theme itself -- the surrounding
///   `SkribbleApp` already installed it, and [data] can override it for this
///   subtree.
///
/// Use it as the `SkribbleApp.builder` for an app-wide effect:
///
/// ```dart
/// SkribbleApp(
///   builder: (context, child) => WiredMaterialTheme(child: child!),
///   home: const MyMaterialScreen(),
/// )
/// ```
///
/// Do not use it inside an existing `MaterialApp`: the app's own `ThemeData`
/// is already there, and this widget would replace it for the subtree. Use
/// `WiredThemeFromMaterial` instead.
class WiredMaterialTheme extends StatelessWidget {
  /// Creates a Material theme boundary derived from [data].
  const WiredMaterialTheme({
    super.key,
    this.data,
    this.brightness,
    required this.child,
  });

  /// Wired tokens to convert. Defaults to the nearest [WiredThemeScope], then
  /// to tokens derived from the ambient Material theme.
  final WiredThemeData? data;

  /// Overrides the brightness used for the Material color scheme. Defaults to
  /// the brightness implied by the resolved theme's fill color.
  final Brightness? brightness;

  /// The subtree that receives the Material theme.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final wiredTheme =
        data ??
        WiredThemeScope.maybeOf(context) ??
        WiredThemeInterop.fromThemeData(Theme.of(context));
    final resolvedBrightness =
        brightness ??
        ThemeData.estimateBrightnessForColor(wiredTheme.fillColor);

    Widget result = Theme(
      data: wiredTheme.toThemeData(brightness: resolvedBrightness),
      child: child,
    );
    if (Localizations.of<MaterialLocalizations>(
          context,
          MaterialLocalizations,
        ) ==
        null) {
      result = Localizations(
        locale:
            Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US'),
        delegates: const <LocalizationsDelegate<dynamic>>[
          DefaultMaterialLocalizations.delegate,
          SkribbleLocalizationsDelegate(),
        ],
        child: result,
      );
    }
    return result;
  }
}
