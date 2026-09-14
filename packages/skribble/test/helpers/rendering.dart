import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart' show WiredIcon;
import 'package:skribble/src/wired_icon.dart' show WiredIcon;

import 'finders.dart';

/// Render-level assertions for Skribble widget tests.
///
/// These helpers answer "did the widget actually lay out and paint?" without
/// naming the painter class that did the drawing and without comparing
/// pixels. That is the level of claim a widget test can make durably: exact
/// ink output is verified by the screenshot harnesses, and painter identity
/// changes with every rough-engine rewrite.
///
/// Use them alongside behavioural assertions; a widget that responds to taps
/// but lays out at zero size, or that never reaches a painter, is still
/// broken.

/// Asserts that [finder] resolves to a laid-out box of non-zero size.
///
/// Fails with the tester's usual "finder returned no widget" message when the
/// subject did not render at all. Pass [size] to pin an exact contract (for
/// example a fixed 48×48 icon button) and [minSize] to require at least a
/// sensible touch target without freezing the design.
///
/// Use [minSize] rather than [size] when the point is only "the hand-drawn
/// border did not collapse to nothing".
void expectRenders(
  WidgetTester tester,
  Finder finder, {
  Size? size,
  Size? minSize,
  String? reason,
}) {
  final rect = tester.getRect(finder);
  final because = reason == null ? '' : ' ($reason)';
  expect(
    rect.width,
    greaterThan(0),
    reason: 'Expected a non-zero width$because; got ${rect.size}.',
  );
  expect(
    rect.height,
    greaterThan(0),
    reason: 'Expected a non-zero height$because; got ${rect.size}.',
  );
  if (size != null) {
    expect(rect.size, size, reason: 'Unexpected rendered size$because.');
  }
  if (minSize != null) {
    expect(
      rect.width >= minSize.width && rect.height >= minSize.height,
      isTrue,
      reason:
          'Expected at least $minSize$because; got ${rect.size}. A control '
          'below this size is hard to hit and usually means the ink or hit '
          'area collapsed.',
    );
  }
}

/// Asserts that [finder]'s subtree reaches rough paint.
///
/// This is the implementation-neutral proof that the widget painted: it does
/// not care whether the ink came from a `WiredCanvas` or a
/// `RoughBoxDecoration`, nor which painter class drew. Deliberately does not
/// inspect the painter's properties or output — those belong to the
/// screenshot harnesses, and pinning them here would make the test break on
/// every rough-engine change.
void expectPaints(Finder finder, {String? reason}) {
  final because = reason == null ? '' : ' ($reason)';
  expect(
    findWiredPainterIn(finder),
    findsWidgets,
    reason:
        'Expected rough paint beneath the subject$because. The widget laid '
        'out but produced no CustomPaint painter and no RoughBoxDecoration.',
  );
}

/// Asserts that [finder]'s subtree contains a [RepaintBoundary].
///
/// Skribble widgets isolate their painting so rough redraws do not repaint
/// surrounding content. A missing boundary is a performance regression, not a
/// visual one, which is why it needs its own assertion.
void expectRepaintIsolation(Finder finder, {String? reason}) {
  final because = reason == null ? '' : ' ($reason)';
  expect(
    findRepaintBoundaryIn(finder),
    findsWidgets,
    reason:
        'Expected a RepaintBoundary beneath the subject$because. Without it '
        'every rough redraw repaints the surrounding subtree.',
  );
}


/// A Material [IconData] for tests that need an icon but do not care which.
///
/// [WiredIcon] resolves this through the registered catalog, falling back to
/// the Material font when a catalog is absent — which is the behaviour these
/// tests cover. The codepoints mirror `Icons`; they are written out rather than
/// imported so core stays free of a Material dependency, matching the
/// decoupling direction in AGENTS.md.
IconData roughIconFor(String name) {
  const icons = <String, IconData>{
    'add': IconData(0xe047, fontFamily: 'MaterialIcons'),
    'check': IconData(0xe156, fontFamily: 'MaterialIcons'),
    'settings': IconData(0xe57f, fontFamily: 'MaterialIcons'),
    'star': IconData(0xe5f9, fontFamily: 'MaterialIcons'),
  };
  final icon = icons[name];
  if (icon == null) {
    throw ArgumentError.value(name, 'name', 'Unknown test icon');
  }
  return icon;
}
