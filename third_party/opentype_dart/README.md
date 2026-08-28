# opentype_dart (vendored)

Vendored copy of [`opentype_dart` 0.0.1](https://github.com/wasabia/opentype)
([pub.dev](https://pub.dev/packages/opentype_dart)), used by
`packages/skribble_font_roughen`.

## Why vendored?

Upstream 0.0.1 declares a hard Flutter SDK dependency and carries an **unused**
`import 'package:flutter/services.dart';` in `lib/opentype.dart`. Because the
import is unused but the library is loaded by pure-Dart VM code (the font
roughening CLI and its `dart test` suite), the stray import makes every load
fail with `Dart library 'dart:ui' is not available on this platform`.

This copy:

- removes the unused Flutter import,
- drops the `flutter` SDK / `flutter_test` constraints from `pubspec.yaml`,
- is pinned via `dependency_overrides` in the workspace root `pubspec.yaml`.

Note on licensing: upstream ships **no license** (see warning above) — the
[LICENSE](LICENSE) here is upstream's unfilled placeholder and grants no rights.
The upstream package ships **no license** (the LICENSE file is an unfilled
placeholder: "Add your license here."). All rights are reserved by default,
which makes redistribution legally unclear. This vendored copy is a
stopgap; before publishing `skribble_font_roughen` to pub.dev, either
obtain permission from the upstream author or replace the dependency
(e.g. with a licensed OpenType reader or a minimal in-repo TTF writer).

## Upgrade path

If a future upstream release ships as pure Dart, delete this directory and the
`dependency_overrides` entry, then depend on the published package again.
