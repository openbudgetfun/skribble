/// Transitional compatibility layer for Material and Cupertino interop.
///
/// Skribble's core (`package:skribble/skribble.dart` minus this group) imports
/// only `package:flutter/widgets.dart` and below. That is what lets Skribble be
/// a peer of Material and Cupertino instead of a skin over them.
///
/// This library is the single sanctioned exception. Every file under
/// `lib/src/compat/` may import `package:flutter/material.dart` and
/// `package:flutter/cupertino.dart`, and every file says so in its header. It
/// exists to answer one question well: *how does an existing app switch?*
///
/// * Hosting Material widgets in a Skribble app: `WiredMaterialTheme`.
/// * Hosting Wired widgets in an existing Material app:
///   `WiredThemeFromMaterial`.
/// * Hosting Wired widgets in an existing Cupertino app:
///   `WiredThemeFromCupertino`.
/// * Converting theme objects both ways: `WiredThemeInterop`.
/// * Keeping `MaterialApp` while migrating: `WiredMaterialApp`.
///
/// Nothing in the core may depend on this group, and this group's job is
/// interop and migration -- not Material parity expansion. See
/// `docs/site/content/core/material-bridge.md` for the migration path.
library;

export 'wired_material_app.dart';
export 'wired_material_theme.dart';
export 'wired_theme_adapters.dart';
export 'wired_theme_interop.dart';
