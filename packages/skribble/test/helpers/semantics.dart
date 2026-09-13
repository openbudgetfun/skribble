import 'dart:ui' as ui;

import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// Semantic assertions for Skribble widget tests.
///
/// Accessibility is part of a design system's contract, so semantics should
/// be asserted as a behavioural claim ("this is a disabled button labelled
/// Save") rather than assumed. These helpers read the semantics tree through
/// [WidgetTester.getSemantics], so they never name the widget or painter that
/// produced the node. A test written with them keeps passing when the
/// internal implementation is rewritten, and fails when accessibility
/// regresses.

/// Returns the semantics data exposed by the nearest node for [finder].
///
/// Use when a test needs to inspect several flags together, or when the
/// assertion does not fit [expectSemantics]. Prefer [expectSemantics] for the
/// common cases because its failure output explains what was expected.
///
/// Throws a [StateError] when [finder] matches no element or more than one;
/// keep the finder specific (use `findWired` or `find.descendant`).
SemanticsData semanticsOf(WidgetTester tester, Finder finder) =>
    tester.getSemantics(finder).getSemanticsData();

/// Asserts that the widget at [finder] exposes the given semantics.
///
/// Only pass the arguments the test is actually about: each supplied argument
/// is asserted, and every omitted one is ignored. That keeps assertions
/// durable — a widget may add incidental flags (focusability, hints) without
/// breaking unrelated tests.
///
/// * [label] — the exact accessibility label; [hasLabel] asserts a non-empty
///   label without pinning its text.
/// * [isButton], [isSlider], [isTextField] — role flags.
/// * [isEnabled] — pass `true` for enabled controls, `false` for disabled
///   ones. The control must expose an enabled state at all, so a widget that
///   never marks itself enabled fails this assertion instead of silently
///   passing.
/// * [isChecked], [isSelected], [isToggled] — state flags. Pass `null` (the
///   default) to ignore, `true`/`false` to require that state.
/// * [hasTapAction], [hasIncreaseAction], [hasDecreaseAction] — pass `true`
///   or `false` to assert an action is exposed or absent.
///
/// ```dart
/// expectSemantics(
///   tester,
///   findWired<WiredButton>(),
///   label: 'Submit',
///   isButton: true,
///   isEnabled: false,
///   hasTapAction: false,
/// );
/// ```
void expectSemantics(
  WidgetTester tester,
  Finder finder, {
  String? label,
  bool hasLabel = false,
  bool? isButton,
  bool? isSlider,
  bool? isTextField,
  bool? isEnabled,
  bool? isChecked,
  bool? isSelected,
  bool? isToggled,
  bool? hasTapAction,
  bool? hasIncreaseAction,
  bool? hasDecreaseAction,
  String? reason,
}) {
  final data = semanticsOf(tester, finder);
  final actual = _describe(data);
  String because(String clause) =>
      reason == null ? clause : '$clause ($reason)';

  if (label != null) {
    expect(
      data.label,
      label,
      reason: because('Semantics label mismatch. $actual'),
    );
  }
  if (hasLabel) {
    expect(
      data.label.trim(),
      isNotEmpty,
      reason: because('Expected a non-empty semantics label. $actual'),
    );
  }
  if (isButton != null) {
    expect(
      data.flagsCollection.isButton,
      isButton,
      reason: because('Semantics button flag mismatch. $actual'),
    );
  }
  if (isSlider != null) {
    expect(
      data.flagsCollection.isSlider,
      isSlider,
      reason: because('Semantics slider flag mismatch. $actual'),
    );
  }
  if (isTextField != null) {
    expect(
      data.flagsCollection.isTextField,
      isTextField,
      reason: because('Semantics text field flag mismatch. $actual'),
    );
  }
  if (isEnabled != null) {
    expect(
      data.flagsCollection.isEnabled.toBoolOrNull(),
      isEnabled,
      reason: because(
        'Semantics enabled state mismatch; the widget must set '
        'Semantics.enabled for this to pass. $actual',
      ),
    );
  }
  if (isChecked != null) {
    expect(
      _checkedToBool(data.flagsCollection.isChecked),
      isChecked,
      reason: because('Semantics checked state mismatch. $actual'),
    );
  }
  if (isSelected != null) {
    expect(
      data.flagsCollection.isSelected.toBoolOrNull(),
      isSelected,
      reason: because('Semantics selected state mismatch. $actual'),
    );
  }
  if (isToggled != null) {
    expect(
      data.flagsCollection.isToggled.toBoolOrNull(),
      isToggled,
      reason: because('Semantics toggled state mismatch. $actual'),
    );
  }
  if (hasTapAction != null) {
    expect(
      data.hasAction(SemanticsAction.tap),
      hasTapAction,
      reason: because(
        'Semantics tap action mismatch; expected '
        '${hasTapAction ? 'a tap action' : 'no tap action'}. $actual',
      ),
    );
  }
  if (hasIncreaseAction != null) {
    expect(
      data.hasAction(SemanticsAction.increase),
      hasIncreaseAction,
      reason: because('Semantics increase action mismatch. $actual'),
    );
  }
  if (hasDecreaseAction != null) {
    expect(
      data.hasAction(SemanticsAction.decrease),
      hasDecreaseAction,
      reason: because('Semantics decrease action mismatch. $actual'),
    );
  }
}

/// Renders the interesting parts of [data] for failure messages.
String _describe(SemanticsData data) {
  final flags = data.flagsCollection;
  final actions =
      SemanticsAction.values.where(data.hasAction).map((a) => a.name).toList()
        ..sort();
  return 'Actual semantics -> label: ${data.label.isEmpty ? '<empty>' : '"${data.label}"'}, '
      'value: ${data.value.isEmpty ? '<empty>' : '"${data.value}"'}, '
      'button: ${flags.isButton}, '
      'slider: ${flags.isSlider}, '
      'textField: ${flags.isTextField}, '
      'enabled: ${flags.isEnabled.toBoolOrNull()}, '
      'checked: ${_checkedToBool(flags.isChecked)}, '
      'selected: ${flags.isSelected.toBoolOrNull()}, '
      'toggled: ${flags.isToggled.toBoolOrNull()}, '
      'actions: $actions.';
}

/// Converts a [ui.CheckedState] to the tristate bool used by the public API.
bool? _checkedToBool(ui.CheckedState state) => switch (state) {
  ui.CheckedState.none => null,
  ui.CheckedState.isTrue => true,
  ui.CheckedState.isFalse => false,
  ui.CheckedState.mixed => null,
};
