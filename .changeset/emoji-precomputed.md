---
skribble: patch
---

# Add `PrecomputedEmoji` widget for fast emoji rendering ...

Same API as `WiredEmoji` (fromName, fromUnicode, placeholder fallback) but draws
SVG paths directly via canvas.drawPath for performance-critical screens.
