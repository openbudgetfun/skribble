---
skribble: minor
---

# WiredCard keeps its content the ink padding from its outline

`WiredCard` has a new `padding` parameter, `kWiredInkPadding` by default, and no longer adds Material's 4-pixel card margin. Before, `WiredCard(child: Text('Hello'))` put the text 4 pixels from the hand-drawn line; it now sits 12 pixels in from the sides and 8 from the top and bottom. `height` is now a minimum, so taller content grows the card instead of being squeezed into 130 pixels. A card with a `height` still spans the width it is given, and inside a horizontal scroll view it wraps its content.

If your card's child already adds its own padding, pass `padding: EdgeInsets.zero` to keep the old spacing.
