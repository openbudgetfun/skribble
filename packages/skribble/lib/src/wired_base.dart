/// Shared paint factories, repaint isolation, and shape painter bases.
///
/// The implementation lives in three focused libraries:
///
/// - `wired_paint.dart` — `WiredBase` paint factories and shared constants
/// - `wired_element.dart` — `WiredBaseWidget`, `WiredRepaintMixin`, and
///   `buildWiredElement`
/// - `wired_painter_bases.dart` — the concrete rough painter bases
///
/// They are re-exported here so existing imports keep working.
library;

export 'wired_element.dart';
export 'wired_paint.dart' show WiredBase, kWiredButtonHeight;
export 'wired_painter_bases.dart';
