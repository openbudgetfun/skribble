---
skribble: patch
---

# Icons centre and label like Icon, and short progress bars stay visible

`WiredSvgIcon`, and so `SkribbleIcon` and `WiredIcon`, drew its glyph in the top-left corner whenever a parent forced a box larger than its size, as an input decoration's prefix and suffix slots and fixed-size badges do. The drawing is now centred, as Flutter's `Icon` centres its glyph.

An icon's `semanticLabel` also carried an image flag. Inside a parent that merges its descendants, such as a card, that flag spread to the whole merged node, so assistive technology announced the card as one image and lost its group and name. The label is now plain, as `Icon`'s is, and joins the parent's label as text.

`WiredProgress` inset its marker by the pen's ink inside a box that had already been inset by the same amount. At a 12- or 14-pixel height the bar became a hairline, and a small value painted nothing. The marker is now laid out against the track's interior, so its painted edge lands exactly on the value, and a bar shorter than its ink plus a 6-pixel band is raised to that height.
