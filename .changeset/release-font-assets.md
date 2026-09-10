---
skribble: none
---

# Ship bundled fonts as GitHub release assets

Release automation now attaches versioned font zips to every GitHub release. The release tag job creates a draft release, the publish workflow packages each font family (`SkribbleRecursive`, `SkribbleGentle`, `SkribblePlayful`, `ArchitectsDaughter`) with `scripts/release/package_fonts.sh` and uploads the archives, and the release is published only after the packages exist on pub.dev and the assets are attached.
