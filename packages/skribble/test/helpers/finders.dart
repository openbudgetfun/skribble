import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

/// Common finders for skribble widget tests.
///
/// Prefer the named helpers over calling `find.byType` directly: they make
/// the intent explicit and keep a single place to change if the underlying
/// lookup strategy ever needs to (for example, if a widget renders through a
/// wrapper). The type argument must always be a *public Skribble type*; a
/// Flutter Material or Cupertino type here means the test is asserting
/// against the implementation, not against the design system.
///
/// Usage:
/// ```dart
/// import '../helpers/skribble_test_support.dart';
///
/// expect(findWired<WiredCheckbox>(), findsOneWidget);
/// expect(findWiredIn<WiredCanvas>(findWired<WiredSwitch>()), findsWidgets);
/// ```

/// Finds every widget of the public Skribble type [T].
///
/// Use instead of `find.byType(T)` so the test's reliance on the public API
/// is visible and searchable. [T] must be exported by `package:skribble`,
/// never a Material or Cupertino class.
Finder findWired<T extends Widget>({bool skipOffstage = true}) =>
    find.byType(T, skipOffstage: skipOffstage);

/// Finds every widget of the public Skribble type [T] below [ancestor].
///
/// Use for composed widgets, e.g. the checkbox inside a checkbox list tile,
/// or the canvas inside a switch.
Finder findWiredIn<T extends Widget>(
  Finder ancestor, {
  bool skipOffstage = true,
}) => find.descendant(
  of: ancestor,
  matching: find.byType(T, skipOffstage: skipOffstage),
);

/// Finds the semantics node carrying [label].
///
/// Use to assert that a control is reachable by assistive technology with the
/// label the caller supplied. This is stronger than checking a widget
/// property, because it proves the label reaches the semantics tree.
///
/// [label] may be a [String] or [RegExp].
Finder findWiredBySemanticsLabel(Pattern label, {bool skipOffstage = true}) =>
    find.bySemanticsLabel(label, skipOffstage: skipOffstage);

/// Finds all [WiredCanvas] widgets in the tree.
Finder get findWiredCanvas => find.byType(WiredCanvas);

/// Finds all [RepaintBoundary] widgets in the tree.
Finder get findRepaintBoundary => find.byType(RepaintBoundary);

/// Finds all [CustomPaint] widgets in the tree.
Finder get findCustomPaint => find.byType(CustomPaint);

/// Finds [WiredCanvas] widgets that are descendants of [ancestor].
Finder findWiredCanvasIn(Finder ancestor) => find.descendant(
  of: ancestor,
  matching: find.byType(WiredCanvas),
);

/// Finds [RepaintBoundary] widgets that are descendants of [ancestor].
Finder findRepaintBoundaryIn(Finder ancestor) => find.descendant(
  of: ancestor,
  matching: find.byType(RepaintBoundary),
);

/// Finds [GestureDetector] widgets that are descendants of [ancestor].
Finder findGestureDetectorIn(Finder ancestor) => find.descendant(
  of: ancestor,
  matching: find.byType(GestureDetector),
);

/// Finds every widget that produces rough paint.
///
/// Matches both ways Skribble paints: a [CustomPaint] carrying a painter (the
/// [WiredCanvas] path) and a [DecoratedBox] using a [RoughBoxDecoration] (the
/// box-decoration path, including widget-drawn overlays such as
/// `WiredTooltip`). Matching both keeps `expectPaints` truthful no matter
/// which strategy a widget uses.
///
/// A bare [CustomPaint] or a plain decoration does not count: the former can
/// be structural, and the latter would not be rough ink.
Finder findWiredRoughPaint() => find.byWidgetPredicate(
  (widget) =>
      (widget is CustomPaint && widget.painter != null) ||
      (widget is DecoratedBox && widget.decoration is RoughBoxDecoration),
  description: 'a painter-backed CustomPaint or a RoughBoxDecoration',
);

/// Finds the paint-producing leaves beneath [ancestor].
///
/// Use through `expectPaints` rather than inspecting the painter class: tests
/// must not depend on which painter drew.
Finder findWiredPainterIn(Finder ancestor) =>
    find.descendant(of: ancestor, matching: findWiredRoughPaint());
