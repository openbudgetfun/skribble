import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

/// Common finders for Skribble widget tests.
///
/// Usage:
/// ```dart
/// import '../helpers/finders.dart';
///
/// expect(findWiredCanvas, findsOneWidget);
/// expect(findRepaintBoundary, findsOneWidget);
/// ```

/// Finds all [WiredCanvas] widgets in the tree.
Finder get findWiredCanvas => find.byType(WiredCanvas);

/// Finds all [RepaintBoundary] widgets in the tree.
Finder get findRepaintBoundary => find.byType(RepaintBoundary);

/// Finds all [CustomPaint] widgets in the tree.
Finder get findCustomPaint => find.byType(CustomPaint);

/// Finds [WiredCanvas] widgets that are descendants of [ancestor].
Finder findWiredCanvasIn(Finder ancestor) => find.descendant(
  of: ancestor,
  matching: find.byType(WiredCanvas),
);

/// Finds [RepaintBoundary] widgets that are descendants of [ancestor].
Finder findRepaintBoundaryIn(Finder ancestor) => find.descendant(
  of: ancestor,
  matching: find.byType(RepaintBoundary),
);

/// Finds [GestureDetector] widgets that are descendants of [ancestor].
Finder findGestureDetectorIn(Finder ancestor) => find.descendant(
  of: ancestor,
  matching: find.byType(GestureDetector),
);
