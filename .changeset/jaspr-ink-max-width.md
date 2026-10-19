---
skribble_jaspr: patch
---

# Circle and marker highlights cover their whole word under an `svg` reset

Many sites reset `svg { max-width: 100% }`. That capped the ink of a `WiredHighlight` at the width of its text, so a circle was drawn to the left of its word and a marker stopped short of the last letter. `skribbleCss` now gives every ink overlay `max-width: none`, so highlights keep their margin around the text whatever the page's own resets.
