<!-- Shared templates and snippets for agent workflow documentation
     and contributor docs. -->
<!-- {@docsAgentWidgetTemplate} -->

Use this template for ordinary UI components. For motion lifecycle wrappers, use standard Flutter state and ticker providers as described in the ink motion guide. Borrowed `Animation<double>` values remain owned by the consumer.

```dart
// Static example: pseudocode
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn <description> widget.
///
/// Reads colors from the nearest [WiredTheme] ancestor, falling back
/// to default constants when no theme is provided.
class Wired<Name> extends HookWidget {
  /// The widget content.
  final Widget child;

  /// Called when the widget is tapped.
  final VoidCallback? onPressed;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  const Wired<Name>({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);

    return Semantics(
      label: semanticLabel,
      child: buildWiredElement(
        child: Container(
          decoration: RoughBoxDecoration(
            shape: RoughBoxShape.rectangle,
            borderStyle: RoughDrawingStyle(
              width: theme.strokeWidth,
              color: theme.borderColor,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
```

<!-- {/docsAgentWidgetTemplate} -->

<!-- {@docsAgentTestTemplate} -->

```dart
// Static example: test
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('Wired<Name>', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(
        tester,
        Wired<Name>(child: Text('Test'), onPressed: () {}),
      );
      expect(find.byType(Wired<Name>), findsOneWidget);
    });

    testWidgets('renders child content', (tester) async {
      await pumpApp(
        tester,
        Wired<Name>(child: Text('Hello'), onPressed: () {}),
      );
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('has correct default height', (tester) async {
      await pumpApp(
        tester,
        Wired<Name>(child: Text('Test'), onPressed: () {}),
      );
      final size = tester.getSize(find.byType(Wired<Name>));
      expect(size.height, greaterThan(0));
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await pumpApp(
        tester,
        Wired<Name>(child: Text('Tap'), onPressed: () => tapped = true),
      );
      await tester.tap(find.byType(Wired<Name>));
      expect(tapped, isTrue);
    });

    testWidgets('rebuilds with new child', (tester) async {
      await pumpApp(
        tester,
        Wired<Name>(child: Text('Before'), onPressed: () {}),
      );
      expect(find.text('Before'), findsOneWidget);

      await pumpApp(
        tester,
        Wired<Name>(child: Text('After'), onPressed: () {}),
      );
      expect(find.text('After'), findsOneWidget);
    });

    testWidgets('handles rapid taps', (tester) async {
      var count = 0;
      await pumpApp(
        tester,
        Wired<Name>(child: Text('Rapid'), onPressed: () => count++),
      );
      await tester.tap(find.byType(Wired<Name>));
      await tester.tap(find.byType(Wired<Name>));
      await tester.tap(find.byType(Wired<Name>));
      expect(count, 3);
    });

    testWidgets('applies semantic label', (tester) async {
      await pumpApp(
        tester,
        Wired<Name>(
          child: Text('Label'),
          onPressed: () {},
          semanticLabel: 'My widget',
        ),
      );
      expect(
        tester.getSemantics(find.byType(Wired<Name>)),
        matchesSemantics(label: 'My widget'),
      );
    });
  });
}
```

<!-- {/docsAgentTestTemplate} -->

<!-- Raw pumpApp slot examples; consumers add fences/prefixes. -->
<!-- {@docsPumpAppExample} -->

```dart
// Static example: test
// Body slot (default)
await pumpApp(tester, myWidget);

// AppBar slot
await pumpApp(tester, WiredAppBar(title: Text('T')), asAppBar: true);

// BottomNavigationBar slot
await pumpApp(tester, myNavBar, asBottomNav: true);

// Drawer slot
await pumpApp(tester, WiredDrawer(child: Text('X')), asDrawer: true);

// With custom theme
await pumpApp(
  tester,
  myWidget,
  theme: WiredThemeData(borderColor: Colors.red),
);
```

<!-- {/docsPumpAppExample} -->

<!-- {@docsContribQualityGatesSection} -->

```bash
# Zero issues (including info-level)
dart analyze --fatal-infos .

# Zero format drift
dart format --set-exit-if-changed .

# All tests green
flutter test

# Zero dartdoc warnings
dart doc --dry-run .
```

<!-- {/docsContribQualityGatesSection} -->
