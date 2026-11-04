// COMPATIBILITY LAYER -- transitional, sanctioned Material/Cupertino import.
//
// See `wired_theme_interop.dart` and docs/site/content/core/material-bridge.md
// for why this directory is the one place allowed to import Material.

import 'package:flutter/cupertino.dart'
    show CupertinoLocalizations, DefaultCupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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
/// * it installs `DefaultMaterialLocalizations` and
///   `DefaultCupertinoLocalizations` when none are present yet, so widgets
///   such as `Scaffold`, `TextField`, and `CupertinoDatePicker` render;
/// * it adds a transparent `Material` when there is none above it, so
///   Material-backed skribble widgets (`WiredInput`, `WiredCheckbox`,
///   `WiredListTile`, and the others still built on Material) find the
///   ancestor they assert on, on every page of the app;
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
class WiredMaterialTheme extends HookWidget {
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

    // The conversion runs ColorScheme.fromSeed and builds a whole ThemeData.
    // As a SkribbleApp builder this widget rebuilds with the app, so keep
    // the result for as long as its inputs are equal.
    final material = useMemoized(
      () => wiredTheme.toThemeData(brightness: resolvedBrightness),
      <Object?>[wiredTheme, resolvedBrightness],
    );
    Widget result = Theme(data: material, child: child);
    // A transparent Material above the app's Navigator is an ancestor of
    // every route, which is all `debugCheckHasMaterial` looks for.
    if (context.findAncestorWidgetOfExactType<Material>() == null) {
      result = Material(type: MaterialType.transparency, child: result);
    }
    final needsMaterial =
        Localizations.of<MaterialLocalizations>(
          context,
          MaterialLocalizations,
        ) ==
        null;
    final needsCupertino =
        Localizations.of<CupertinoLocalizations>(
          context,
          CupertinoLocalizations,
        ) ==
        null;
    if (needsMaterial || needsCupertino) {
      final missing = <LocalizationsDelegate<dynamic>>[
        if (needsMaterial) DefaultMaterialLocalizations.delegate,
        if (needsCupertino) DefaultCupertinoLocalizations.delegate,
      ];
      // Inside an app, Localizations.override keeps the app's own delegates
      // (skribble's included) and adds only the missing defaults. Outside
      // one, a fresh scope supplies everything.
      result = Localizations.maybeLocaleOf(context) == null
          ? Localizations(
              locale: const Locale('en', 'US'),
              delegates: <LocalizationsDelegate<dynamic>>[
                DefaultWidgetsLocalizations.delegate,
                ...missing,
                const SkribbleLocalizationsDelegate(),
              ],
              child: result,
            )
          : Localizations.override(
              context: context,
              delegates: missing,
              child: result,
            );
    }

    return result;
  }
}
