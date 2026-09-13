/// Test support for implementation-neutral Skribble widget tests.
///
/// Import this single file in converted tests:
///
/// ```dart
/// import 'package:flutter_test/flutter_test.dart';
/// import 'package:skribble/skribble.dart';
///
/// import '../helpers/skribble_test_support.dart';
/// ```
///
/// See `README.md` in this directory for the conventions these helpers
/// enforce and the migration pattern for converting a Material-coupled test.
library;

export 'finders.dart';
export 'interactions.dart';
export 'pump_app.dart';
export 'rendering.dart';
export 'semantics.dart';
