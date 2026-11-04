---
skribble: patch
---

# Dialogs hug their content

`WiredDialog` drew its border as a sizing child, and a canvas takes all the room it is offered, so every dialog stretched to the full height of the screen. The border now follows the content, and the dialog also lays out inside unbounded height.
