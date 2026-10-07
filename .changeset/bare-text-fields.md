---
skribble: patch
---

# Search bars and text fields draw only their ink border

Under `WiredMaterialApp`, the Material bridge theme gives inputs an outlined, filled decoration. `WiredSearchBar`, `WiredAutocomplete`, `WiredCupertinoTextField`, and `WiredMenuBar`'s field hid only the default border, so the theme's enabled and focused borders and its fill drew a second box inside the hand-drawn one. They now clear every border and the fill, as `WiredInput` and `WiredTextArea` already did.
