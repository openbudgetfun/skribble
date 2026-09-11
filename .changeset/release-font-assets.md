---
skribble: none
---

# Harden release and CI infrastructure

Release automation attaches versioned font zips to every GitHub release: the release tag job creates a draft release, the publish workflow packages each font family (`SkribbleRecursive`, `SkribbleGentle`, `SkribblePlayful`, `ArchitectsDaughter`) via `scripts/release/package_fonts.sh`, and the release publishes only after the packages exist on pub.dev and the assets are attached. CI gains `publish-check` and `publish-check-release` jobs that dry-run pub.dev publishing for every package as-is and on the would-be release commit, and the devenv git-hooks inputs were fixed so the lint, test, and coverage jobs run. Changeset and manifest lint rules are enforced by `monochange check` on every pull request, and the release PR branch prefix stays at `chore/release` — renaming it while a release PR is open orphans the long-running request, and recreating it exceeds GitHub's 65536-character body limit.
