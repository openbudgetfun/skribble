---
skribble: patch
---

Enable rough icon unresolved regression gating in CI.

- Add a dedicated CI job (`rough-icons-regression`) that runs rough icon
  resolution in `--rough-only` mode against the committed unresolved baseline.
- The job fails pull requests when new unresolved icon regressions are
  introduced (`--fail-on-new-unresolved`).
- Update rough icon docs/README to note the CI enforcement behavior.
