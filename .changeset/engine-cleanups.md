---
skribble: patch
---

# Tighten three rough-engine edge cases

`DrawConfig.copyWith` accepted `fillWeight` and `combineNestedSvgPaths` and dropped both on the floor, so a caller could pass them and silently get nothing; the parameters are gone and passing them is now a compile error. `Filler.buildFillLines` closed the polygon ring by appending to the caller's point list, which corrupted the polygon for the connecting-line pass whenever the hachure angle skipped rotation. `OpSetBuilder.linearPath` copied its accumulated operation list once per edge, making a polygon quadratic in its vertex count; it now appends in place.
