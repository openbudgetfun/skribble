# Changelog

All notable changes to this vendored package are documented in this file.

## 0.0.1+skribble.1

- Vendored from `opentype_dart` 0.0.1 (https://github.com/wasabia/opentype).
- Removed the unused `package:flutter/services.dart` import and the Flutter
  SDK dependency so the library runs as pure Dart on the VM.
- Removed unreferenced unported JavaScript sources (`bidi.dart`,
  `tokenizer.dart`, `hintingtt.dart`, `substitution.dart`, `util.dart`,
  `index.dart`, `features/`, `tables/sfnt.dart`).
- See README.md for licensing caveats and the upgrade path.
