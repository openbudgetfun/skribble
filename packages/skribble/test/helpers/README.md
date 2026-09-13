# Skribble test support

Helpers for writing widget tests that assert against **Skribble's public API**, not against the Material/Cupertino widgets the implementation currently wraps.

Skribble's endgame is a standalone design system (`AGENTS.md`, "Material decoupling direction"). Every `find.byType(Checkbox)` or `tester.widget<TextButton>(...)` in a test encodes the transitional implementation as the contract: it breaks on the rewrite and, worse, it gives false confidence today. A test that reads `Checkbox.value` proves a value was forwarded into Material; it says nothing about what `WiredCheckbox` paints, how big its hit area is, or whether a screen reader can use it.

## The rules

1. **Never name a Flutter Material or Cupertino type in a test assertion.** That includes `find.byType`, `find.descendant(matching: ...)`, `find.byWidgetPredicate`, `tester.widget<T>`, and `tester.widgetList<T>`. The guard test in `test/tool/no_material_test_coupling_test.dart` enforces this with a shrinking allowlist of not-yet-migrated files.
2. **Import `package:flutter/material.dart` only when a test genuinely needs a Material-only value** (for example driving a Material dialog route). If you need it, that is a finding: report it instead of reaching through Material. Converted tests import `package:flutter/widgets.dart` at most — usually nothing, because the helper barrel covers what they need.
3. **Assert behaviour, not plumbing.** "When tapped, `onChanged` receives `true`" and "the semantics node is a disabled button with label Save" are behaviour. "A `Checkbox` exists with `value: true`" is plumbing.
4. **Add the dimension tests Material was masking.** Disabled state, RTL, text scaling, semantics, and large/zero/small constraints. These are where the inherited Material behaviour currently papers over gaps.
5. **Do not assert pixels or painter classes.** Use `expectRenders`, `expectPaints`, and `expectRepaintIsolation` for "it laid out and painted". Exact ink output belongs to the screenshot harnesses in `apps/skribble_storybook`.

## Helpers

| Helper                                           | Purpose                                                                                                    |
| ------------------------------------------------ | ---------------------------------------------------------------------------------------------------------- |
| `pumpWired(tester, widget, {...})`               | Minimal correct host: `WiredTheme`, `Directionality`, `MediaQuery` text scale, bounded surface, alignment. |
| `pumpWiredRtl(tester, widget, {...})`            | Same host with `TextDirection.rtl`.                                                                        |
| `pumpWiredScaled(tester, widget, {scale})`       | Same host with a scaled `TextScaler`.                                                                      |
| `findWired<T>()`                                 | Finder for a public Skribble type.                                                                         |
| `findWiredIn<T>(ancestor)`                       | Public Skribble type below an ancestor.                                                                    |
| `findWiredRoughPaint()`                          | Every `CustomPaint` painter or `RoughBoxDecoration` in the tree.                                           |
| `findWiredPainterIn(ancestor)`                   | The same rough-paint leaves below an ancestor.                                                             |
| `findWiredBySemanticsLabel(label)`               | Finder by accessibility label.                                                                             |
| `semanticsOf(tester, finder)`                    | Raw `SemanticsData` for a widget.                                                                          |
| `expectSemantics(tester, finder, {...})`         | Assert label/role/enabled/checked/selected/toggled/actions.                                                |
| `expectRenders(tester, finder, {size, minSize})` | Laid out with non-zero (or exact/minimum) size.                                                            |
| `expectPaints(finder)`                           | Reaches rough paint (a painter or a `RoughBoxDecoration`).                                                 |
| `expectRepaintIsolation(finder)`                 | Subtree contains a `RepaintBoundary`.                                                                      |
| `tapWired(tester, finder)`                       | Pointer tap plus pump.                                                                                     |
| `semanticTapWired(tester, finder)`               | Performs the semantics tap action (accessibility path).                                                    |
| `enterWiredText(tester, finder, text)`           | Types into the text field at a public finder.                                                              |
| `dragWired(tester, finder, offset)`              | Drag plus pump.                                                                                            |

`pumpApp` remains for the unconverted files. It exposes Material slots (`asAppBar`, `asDrawer`, ...) and a `ThemeData`; new tests should use `pumpWired`.

## Migration pattern

Before — asserts the wrapper, not the widget:

```dart
testWidgets('displays checked state when value is true', (tester) async {
  await pumpApp(tester, WiredCheckbox(value: true, onChanged: (_) {}));

  final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
  expect(checkbox.value, isTrue);
});
```

After — asserts what the design system promises, including the dimensions the old test never touched:

```dart
testWidgets('reports checked state to assistive technology', (tester) async {
  await pumpWired(tester, WiredCheckbox(value: true, onChanged: (_) {}));

  expectSemantics(tester, findWired<WiredCheckbox>(), isChecked: true);
});

testWidgets('lays out and paints a touch-sized box in RTL', (tester) async {
  await pumpWiredRtl(tester, WiredCheckbox(value: false, onChanged: (_) {}));

  expectRenders(tester, findWired<WiredCheckbox>(), minSize: const Size(24, 24));
  expectPaints(findWired<WiredCheckbox>());
});

testWidgets('scales its label without clipping at 2x text', (tester) async {
  await pumpWiredScaled(
    tester,
    WiredCheckboxListTile(value: false, onChanged: (_) {}, title: const Text('Notifications')),
  );

  expectRenders(tester, findWired<WiredCheckboxListTile>());
  expect(tester.takeException(), isNull);
});
```

Note what the converted test does _not_ do: it never mentions `Checkbox`, never builds its own `MaterialApp`, and gets an RTL or scaled host from one named argument.

## Reading a conversion

A converted test file should satisfy all of these:

- no import of `package:flutter/material.dart` or `cupertino.dart`;
- no `find.byType` on a Flutter widget type (Skribble types are fine);
- every `testWidgets` starts with `pumpWired`, `pumpWiredRtl`, or `pumpWiredScaled`;
- at least one assertion per widget file is about semantics or rendering, so the file cannot pass while the widget is invisible or unusable;
- disabled, RTL, and text-scale cases exist where the widget supports them.

If a test cannot be expressed without naming a Material type, do not keep the Material coupling: report it as a finding. There is one known legitimate case, `test/widgets/wired_material_app_test.dart` (Skribble's Material bridge), plus tests that drive Material's own routes/dialogs.
