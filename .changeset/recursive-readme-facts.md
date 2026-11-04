---
skribble_font_recursive: patch
---

# The Recursive README names the right licence file and version

The install snippet asked for `skribble_font_recursive: ^0.1.1`, which never resolves to a current release, and the licence row named a `RECURSIVE-OFL.txt` that the package does not ship. It now asks for `^0.3.1` and points at `assets/fonts/OFL.txt`.
