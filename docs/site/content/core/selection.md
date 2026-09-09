---
title: Text selection
description: Select and copy rich prose using Flutter's native selection system and Wired controls.
---

# Text selection

`WiredSelectionArea` makes participating `Text` and `Text.rich` descendants selectable together. It uses Flutter's selection system, Wired touch handles, and localized Copy and Select all controls. The documentation you are reading uses this widget.

```dart
WiredSelectionArea(
  child: Column(
    children: [
      Text('A small beginning.\n'),
      Text.rich(TextSpan(children: [
        TextSpan(text: 'Make something '),
        TextSpan(text: 'delightful.', style: TextStyle(fontWeight: FontWeight.bold)),
      ])),
    ],
  ),
)
```

Flutter concatenates selected text widgets verbatim. Include paragraph separators in the text when line breaks belong in both layout and copied text. For document rendering, a `SelectionContainer` with a `StaticSelectionContainerDelegate` can join selected blocks with newlines in `getSelectedContent()` without adding blank lines to the layout. This docs app uses that approach. When using `RichText` directly, supply its `selectionRegistrar` from `SelectionContainer.maybeOf(context)`; `Text.rich` handles that registration for you.

Wrap interactive examples in `SelectionContainer.disabled` to keep their labels out of a document selection. An optional `focusNode` stays owned by the caller. `onSelectionChanged` reports the current `SelectedContent`, or null after clearing the selection.

For long documents, remember that unmounted text cannot participate in selection. This docs app caches its Markdown syntax trees, keeps the current article mounted, and isolates blocks with repaint boundaries. The explicit Copy code and Copy page actions complement ordinary selection.
