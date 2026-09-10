---
skribble: none
---

# Enforce changeset and manifest lint rules on every check

`monochange check` now fails when a changeset or package manifest violates the configured policy, and the CI `lint` job runs it on every pull request instead of the weaker `monochange step validate`. The enabled rules come from the `changesets/recommended` and `dart/recommended` presets layered with explicit policy: every changeset needs a single H1 summary heading of 8–90 characters with no trailing period and no Conventional Commit prefix, a description that adds information beyond the heading, at least an 80-character body (120 plus a code block for `major` bumps), inline `target: type` entries, and no duplicate targets or change-type section headings. Dart manifests must keep dependencies and assets sorted, keep internal dependency versions consistent with the workspace, declare required package fields and an SDK constraint, avoid git dependencies and unexpected `dependency_overrides` in publishable packages, and declare `publish_to: none` when unmanaged. Locally, `monochange check --fix` auto-fixes the fixable rules (entry and ordering style).
