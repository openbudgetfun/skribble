---
skribble: patch
---

# Reuse displaced icon contours between repaints

`WiredSvgIcon` sampled every contour and rebuilt its displaced path on each repaint. Sampling runs a tangent evaluation roughly every 0.6 logical pixels, so a 96 px icon re-did thousands of them per frame. The contours are now displaced once per painter and reused, which roughly halves the cost of painting a filled icon. Rendering is unchanged: a fresh painter and a cached one produce identical pixels.
