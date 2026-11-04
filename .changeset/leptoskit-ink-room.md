---
skribble_site: fix
---

# leptoskit boxes, buttons, and fields keep content clear of their ink

`skribble_leptoskit` measured its padding from the component's edge, but the hand-drawn outline sits a few pixels inside that edge and moves further in as the ink stretches. Text in a `WiredBox`, a `WiredButton`, or a `WiredInput` could end up 4 or 5 pixels from the line. These components now pad far enough that content keeps at least 12 pixels from the ink at the sides and 8 above and below, as skribble's Flutter widgets and Jaspr components do. `WiredBox` pads 20 at the sides and 12 above and below, buttons pad 12 above and below, and fields pad 16 at the sides and 12 above and below. Cards, circles, badges, and toggles already had the room.
