---
main:
  bump: major
  version: "0.1.0"
---

# Publish the full Skribble package family

Make all seven workspace packages publicly publishable through a grouped Monochange release PR. Releases now use the shared `publisher` trusted-publishing environment, verify readiness, and run package dry-runs before publishing the complete package group.

```text
monochange step tag-release --from HEAD --push=true
monochange step publish-packages --all
```
