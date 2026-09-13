/// The bundled Skribble typefaces, shipped separately from the widget library.
///
/// This package is almost entirely font assets: the hand-drawn Recursive
/// families at three roughness levels, as 126 static faces and 3 variable
/// fonts. Declaring it as a dependency is all an app needs — Flutter picks the
/// families up from this package's pubspec, and `WiredTheme` in the core
/// [`skribble`](https://pub.dev/packages/skribble) package selects them by
/// name.
///
/// Family names are owned by core's `WiredFont` and `WiredRoughness`; use those
/// rather than hard-coding strings.
///
/// Regenerate with
/// `devenv shell dart run packages/skribble_font_roughen/bin/roughen_fonts.dart`.
/// See [the provenance notes](https://github.com/openbudgetfun/skribble/blob/main/docs/asset-provenance.md)
/// for the pinned upstream source and the determinism guarantee.
library;
