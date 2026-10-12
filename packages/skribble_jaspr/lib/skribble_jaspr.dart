/// Hand-drawn Jaspr components from the skribble design system.
///
/// Every component draws its rough ink on the server into an inline,
/// decorative SVG, so static and server-rendered sites get the hand-drawn
/// look with zero client JavaScript. The same `seed` always renders the
/// same markup, which keeps static builds byte-stable.
///
/// Add `skribbleCss` to each page, then use the components:
///
/// - `WiredBox`, `WiredCard`, and `WiredCircle` wrap content in a rough
///   rectangle or ellipse, optionally filled with a sketched pattern.
/// - `WiredButton` renders a rough `<button>` or link.
/// - `WiredHighlight` underlines, circles, boxes, strikes, or marks text.
/// - `WiredDivider` separates sections with a rough rule.
/// - `WiredSketch` draws standalone doodles such as arrows.
///
/// Fill patterns come from `RoughFillStyle`, re-exported from
/// `package:skribble_rough`.
library;

export 'package:skribble_rough/skribble_rough.dart' show RoughFillStyle;

export 'src/skribble_css.dart';
export 'src/wired_box.dart';
export 'src/wired_button.dart';
export 'src/wired_divider.dart';
export 'src/wired_highlight.dart';
export 'src/wired_sketch.dart';
