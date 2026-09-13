// COMPATIBILITY LAYER -- transitional, sanctioned Material/Cupertino import.
//
// Skribble's core is a standalone design system: it imports only
// `package:flutter/widgets.dart` and below, so it can be a peer of Material
// and Cupertino rather than a skin over them. This directory is the single
// quarantined exception. It exists so that migrating between Material,
// Cupertino, and Skribble is a small diff, and it may import
// `package:flutter/material.dart` and `package:flutter/cupertino.dart`.
//
// Nothing in `lib/src` outside `lib/src/compat` may depend on these files.
// See docs/site/content/core/material-bridge.md.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../skribble_app.dart';
import '../wired_theme.dart';

/// Converts between Material/Cupertino theme objects and [WiredThemeData].
///
/// All members are static or instance members of an extension on
/// [WiredThemeData], so importing the compatibility layer adds
/// `WiredThemeInterop.fromThemeData(...)` and `wiredTheme.toCupertinoThemeData()`
/// without changing the core class.
///
/// The other direction already exists on the core type:
/// [WiredThemeData.toThemeData] and [WiredThemeData.toColorScheme]. This layer
/// reuses them rather than re-implementing a Material conversion.
///
/// See also:
///
/// * `WiredMaterialTheme`, which installs the derived Material theme for a
///   subtree so Material widgets render inside a `SkribbleApp`.
/// * `WiredThemeFromMaterial` and `WiredThemeFromCupertino`, which install
///   Wired tokens derived from an existing Material or Cupertino app.
extension WiredThemeInterop on WiredThemeData {
  /// Derives Skribble tokens from a Material [ThemeData].
  ///
  /// Maps:
  ///
  /// * `borderColor` from `colorScheme.primary`
  /// * `textColor` from `colorScheme.onSurface`
  /// * `fillColor` from `colorScheme.surface`
  /// * `disabledTextColor` from [ThemeData.disabledColor]
  /// * `strokeWidth` from the first non-zero border width found in the
  ///   card, dialog, bottom-sheet, input, or divider themes
  /// * `fontFamily` from `textTheme.bodyMedium`
  ///
  /// Roughness and motion are not expressed by [ThemeData], so they keep the
  /// Skribble defaults; pass a `copyWith` to override them.
  static WiredThemeData fromThemeData(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return WiredThemeData(
      borderColor: colorScheme.primary,
      textColor: colorScheme.onSurface,
      fillColor: colorScheme.surface,
      disabledTextColor: theme.disabledColor,
      strokeWidth: _strokeWidthOf(theme),
      fontFamily: theme.textTheme.bodyMedium?.fontFamily,
    );
  }

  /// Derives Skribble tokens directly from a Material [ColorScheme].
  ///
  /// Use this when the app owns a color scheme rather than a full
  /// [ThemeData]; the border width then keeps the Skribble default.
  static WiredThemeData fromColorScheme(ColorScheme colorScheme) {
    return WiredThemeData(
      borderColor: colorScheme.primary,
      textColor: colorScheme.onSurface,
      fillColor: colorScheme.surface,
      disabledTextColor: colorScheme.onSurface.withValues(alpha: 0.38),
    );
  }

  /// Derives Skribble tokens from a [CupertinoThemeData].
  ///
  /// Maps `primaryColor`, the text style color, and
  /// `scaffoldBackgroundColor` into the border, text, and fill tokens.
  /// Cupertino does not expose a stroke width, so the Skribble default is
  /// kept.
  static WiredThemeData fromCupertinoTheme(CupertinoThemeData theme) {
    final brightness = theme.brightness ?? Brightness.light;
    final textColor =
        theme.textTheme.textStyle.color ??
        (brightness == Brightness.dark
            ? const Color(0xFFFFFFFF)
            : const Color(0xFF000000));
    return WiredThemeData(
      borderColor: theme.primaryColor,
      textColor: textColor,
      fillColor: theme.scaffoldBackgroundColor,
      disabledTextColor: textColor.withValues(alpha: 0.35),
      fontFamily: theme.textTheme.textStyle.fontFamily,
    );
  }

  /// Builds a [CupertinoThemeData] aligned with these Skribble tokens.
  ///
  /// Use it to keep Cupertino widgets on-palette inside a `SkribbleApp`.
  /// Dynamic Cupertino colors are not resolved; resolve them against a
  /// [BuildContext] if the surrounding app depends on `CupertinoDynamicColor`.
  CupertinoThemeData toCupertinoThemeData({
    Brightness brightness = Brightness.light,
  }) {
    return CupertinoThemeData(
      brightness: brightness,
      primaryColor: borderColor,
      scaffoldBackgroundColor: paperBackgroundColor,
      barBackgroundColor: fillColor,
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          color: textColor,
          fontFamily: fontFamily,
          package: fontPackage,
        ),
      ),
    );
  }
}

/// Converts between [SkribbleThemeMode] and Material's `ThemeMode`.
///
/// Lets an app move a `themeMode: ThemeMode.dark` value between
/// `WiredMaterialApp` and `SkribbleApp` without hand-written switches.
extension WiredThemeModeInterop on SkribbleThemeMode {
  /// The Material `ThemeMode` equivalent of this mode.
  ThemeMode get toThemeMode => switch (this) {
    SkribbleThemeMode.system => ThemeMode.system,
    SkribbleThemeMode.light => ThemeMode.light,
    SkribbleThemeMode.dark => ThemeMode.dark,
  };

  /// Converts a Material `ThemeMode` into a [SkribbleThemeMode].
  static SkribbleThemeMode fromThemeMode(ThemeMode mode) => switch (mode) {
    ThemeMode.system => SkribbleThemeMode.system,
    ThemeMode.light => SkribbleThemeMode.light,
    ThemeMode.dark => SkribbleThemeMode.dark,
  };
}

/// Finds the border width a Material theme uses for its outlined surfaces.
double _strokeWidthOf(ThemeData theme) {
  final shapes = <ShapeBorder?>[
    theme.cardTheme.shape,
    theme.dialogTheme.shape,
    theme.bottomSheetTheme.shape,
    theme.appBarTheme.shape,
  ];
  for (final shape in shapes) {
    if (shape is OutlinedBorder && shape.side.width > 0) {
      return shape.side.width;
    }
  }
  final inputBorder =
      theme.inputDecorationTheme.enabledBorder ??
      theme.inputDecorationTheme.border;
  if (inputBorder is OutlineInputBorder && inputBorder.borderSide.width > 0) {
    return inputBorder.borderSide.width;
  }
  final dividerThickness = theme.dividerTheme.thickness;
  if (dividerThickness != null && dividerThickness > 0) {
    return dividerThickness;
  }
  return WiredThemeData.defaultTheme.strokeWidth;
}
