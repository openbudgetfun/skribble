---
skribble: minor
---

# Add the hand-drawn emoji package with the complete OpenMoji set

The `skribble_emoji` package ships 1,827 emoji generated from OpenMoji artwork — early scaffolds served 50 — with lookup by name and Unicode codepoint, a generation pipeline and download helper, complete OpenMoji 17 sequences, and source colour palettes preserved through the rough pipeline. `PrecomputedEmoji` draws the same API (fromName, fromUnicode, placeholder fallback) directly via `canvas.drawPath` for performance-critical screens, and the `skribble_emoji_gen` package hosts the asset generation in the workspace.
