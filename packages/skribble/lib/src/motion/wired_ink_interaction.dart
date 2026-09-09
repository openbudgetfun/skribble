/// Decorative feedback for interactive Wired controls.
///
/// The global motion policy and platform reduced-motion preference always win.
enum WiredInkInteraction {
  /// Keeps ink still through hover, focus, and activation.
  none,

  /// Gently reinforces the existing strokes on hover, focus, and press.
  pressure,

  /// Adds a brief redraw of outlines and patterned fills on each press.
  ///
  /// Content, opaque fills, layout, and semantics remain visible throughout.
  redraw,
}
