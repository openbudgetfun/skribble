---
skribble_site: user_fix
---

# skribble.dev and its docs load much faster

The landing page now downloads about a fifth of what it did on a first visit: 182 KB instead of 850 KB, in 8 requests instead of 13. Fonts arrive as small WOFF2 slices that hold only the characters the page shows, the stylesheet is part of the page, the sketches are written more compactly, and drawings and fonts further down the page wait until you scroll near them. On a mid-range phone the page appears in about 1.4 seconds instead of 4.8.

The docs load less up front as well. They no longer fetch a 380 KB symbols font for the arrows in their links, ship only the icons they use, load the gentle and expressive pens' code fonts only when you pick one, trim every font to the scripts the docs show, and read only the page you open. The first page now appears in about 24 seconds instead of 41 on a slow phone connection, and the first load transfers about 3.9 MB instead of 7.8 MB.
