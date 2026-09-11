---
skribble: patch
---

# Add a hand-drawn corner radius to the button widgets

Give `WiredButton`, `WiredElevatedButton`, `WiredFilledButton`, and `WiredOutlinedButton` a small, hand-drawn 6 px corner radius. Set `borderRadius: BorderRadius.zero` for square corners or use `BorderRadius.only` for different corners. Both straight edges and corner arcs inherit the theme's roughness.
