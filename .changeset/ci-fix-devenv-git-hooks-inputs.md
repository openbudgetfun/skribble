---
skribble: patch
---

# CI: fix devenv git-hooks inputs in GitHub Actions

Fix GitHub Actions `devenv shell` evaluation failures by declaring the
required `git-hooks` input and `pre-commit-hooks` alias in `devenv.yaml`.

This unblocks the `lint`, `test`, and `coverage` jobs, which were failing
before any project checks actually ran.
