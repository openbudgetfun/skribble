import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Interaction helpers for Skribble widget tests.
///
/// Interaction is expressed through public finders (see `finders.dart`) or
/// through the semantics tree. Neither path mentions the Material control
/// that currently handles the gesture, so the tests survive the decoupling
/// rewrite and, in the semantics case, additionally prove that the control
/// is usable by assistive technology rather than only by a mouse.

/// Taps [finder] with a real pointer event and pumps one frame.
///
/// Use for the common case. The pump is included because a tap that fires a
/// callback but is never pumped hides state changes from the rest of the
/// test; add further `pumpAndSettle` calls only when an animation is involved.
Future<void> tapWired(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump();
}

/// Performs the semantics tap action on [finder] and pumps one frame.
///
/// Use when the test is about accessibility specifically: a control can be
/// tappable by pointer while exposing no tap action to screen readers. This
/// helper fails loudly when no tap action exists, then invokes the same path
/// an assistive-technology user would.
Future<void> semanticTapWired(WidgetTester tester, Finder finder) async {
  final node = tester.getSemantics(finder);
  final data = node.getSemanticsData();
  expect(
    data.hasAction(SemanticsAction.tap),
    isTrue,
    reason:
        'The subject exposes no semantics tap action, so assistive technology '
        'cannot activate it. Semantics -> ${data.label.isEmpty ? '<no label>' : '"${data.label}"'}.',
  );
  node.owner!.performAction(node.id, SemanticsAction.tap);
  await tester.pump();
}

/// Types [text] into the text field found at [finder].
///
/// Use with the public text-field widget as [finder]; the helper locates the
/// framework's editable child itself. Typing through the public widget keeps
/// the test from depending on which editable implementation the field uses.
Future<void> enterWiredText(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await tester.enterText(
    find.descendant(of: finder, matching: find.byType(EditableText)).first,
    text,
  );
  await tester.pump();
}

/// Drags [finder] by [offset] and pumps one frame.
///
/// Use for value controls (sliders, dialogs with drag handles). Prefer a
/// small offset that stays inside the widget so the assertion is about the
/// callback firing, not about gesture disambiguation.
Future<void> dragWired(
  WidgetTester tester,
  Finder finder,
  Offset offset,
) async {
  await tester.drag(finder, offset);
  await tester.pump();
}
