---
skribble: patch
---

# Cupertino slider semantics and search field fixes

`WiredCupertinoSlider` now reports a slider with its value and increase and decrease actions, and accepts `semanticLabel`. It no longer fails to lay out when `min` equals `max`, snaps divisions from `min` rather than from zero (a 1–4 range in two steps lands on 1, 2.5, and 4), and puts the minimum at the right under right-to-left text.

`WiredCupertinoSearchTextField` no longer throws when a `focusNode` is supplied after the first build, keeps its placeholder at the start of the line under right-to-left text, and leaves focus traversal while disabled. `WiredCupertinoTextField` and the section headers of `WiredCupertinoListSection` and `WiredCupertinoFormSection` mirror their start and end spacing under right-to-left text.
