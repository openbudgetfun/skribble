---
skribble: patch
---

# Icons reuse prepared ink, so scrolling lists of them stop dropping frames

Every `WiredSvgIcon` that appeared — including a list item scrolling back into view seconds after it was first drawn — re-parsed its SVG paths, re-wavered every contour, and re-inked every pen outline before it could paint. The benchmark app measured a 200-item icon list at 34 ms per frame, more than twice the frame budget and 3.6 times the cost of drawing precomputed paths.

Icons with the same geometry, size, colour, weight, fill style, and draw config now share one painter through a bounded cache (256 entries, least-recently-used evicted), so a revisited icon paints at precomputed-path cost and no visible detail changes: the shared painter holds exactly the ink the fresh one would have rebuilt from the same seed. Each path primitive's SVG data is also parsed once per primitive instead of once per appearance, which helps beyond the cache's horizon in the large Material and Simple Icons catalogs. A probe of the 200-item scroll found all 51 distinct icons prepared exactly once, and zero preparations on the return scroll.

`RoughDrawing` and the icon painter also stopped allocating `Paint` objects on every frame while animating progress or pressure; every constant paint is prepared once with the ink it belongs to.
