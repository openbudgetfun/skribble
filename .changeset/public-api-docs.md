---
skribble: patch
skribble_rough_dart: patch
skribble_font_roughen: patch
skribble_lints: patch
---

# Every public member is documented

Every public class, member, and parameter in `skribble`, `skribble_rough`, and `skribble_font_roughen` now has a `///` doc comment that says what it does, its default, and its units. Parameters that pass straight through to Flutter, such as the `MaterialApp` options on `WiredMaterialApp`, link to the Flutter member they mirror.

`skribble_lints` now turns on `public_member_api_docs`, so `dart analyze --fatal-infos` fails on any undocumented public member in a package that includes it. It also drops the dead `missing_return` entry; the analyzer reports a missing return as the `body_might_complete_normally` compile error.
