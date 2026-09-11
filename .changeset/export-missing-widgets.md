---
skribble: patch
---

# Export the widgets the API reference already documents

`WiredLoadingIndicator` and `WiredCircularProgressIndicator` were documented in the API reference but missing from `skribble.dart`, so the only way to reach them was a `package:skribble/src/...` import. `WiredExpansionPanelList`, `WiredExpansionPanel`, and `WiredPaginatedDataTable` had widget tests that imported them the same way. All five are now exported, and the tests import the public library. The unused `wired_transitions.dart` and the `utils/` icon helpers, which nothing imported or documented, are gone.
