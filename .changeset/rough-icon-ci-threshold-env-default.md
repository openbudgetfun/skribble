---
skribble: patch
---

Wire rough icon CI checks to the new threshold-based regression env option.

- Set `ROUGH_ICONS_MAX_NEW_UNRESOLVED=0` in rough icon regression and generated-sync CI jobs.
- Keeps CI behavior strict (equivalent to `--fail-on-new-unresolved`) while exposing a single threshold knob in workflow config.
- Update rough icon docs/README to document the CI default and override path.
