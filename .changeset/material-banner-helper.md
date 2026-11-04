---
skribble: patch
---

# showWiredMaterialBanner shows your banner

`showWiredMaterialBanner` ignored its arguments and showed an empty strip with a Material divider. It now shows a `WiredMaterialBanner` with the given `content`, `leading`, `actions`, and `backgroundColor`, and calls `onVisible` once the banner has slid in.
