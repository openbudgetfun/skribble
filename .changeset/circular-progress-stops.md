---
skribble: patch
---

# Circular progress stops spinning once it has a value

`WiredCircularProgress` and `WiredCircularProgressIndicator` kept their animation controllers repeating after `value` went from null to a number, scheduling a frame every tick for an indicator that no longer moves and making `pumpAndSettle` time out. They now stop when determinate and restart when the value goes back to null. Both take a new `semanticLabel` and announce the percentage, like `WiredProgress`.
