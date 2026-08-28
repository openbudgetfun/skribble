---
skribble: patch
---

Add optional `borderRadius` support to `WiredButton`, `WiredCard`, `WiredDialog`,
`WiredElevatedButton`, `WiredFilledButton`, and `WiredOutlinedButton`. When a
`BorderRadius` is provided the widgets draw with hand-drawn rounded corners
(straight edges plus four jittered corner arcs); when omitted they keep their
sharp-corner look. Per-corner radii via `BorderRadius.only` are supported.
