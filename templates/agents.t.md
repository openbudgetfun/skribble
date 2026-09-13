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

import '../helpers/skribble_test_support.dart';

void main() {
  group('Wired<Name>', () {
    testWidgets('renders and paints', (tester) async {
      await pumpWired(
        tester,
        Wired<Name>(child: const Text('Test'), onPressed: () {}),
      );
      expectRenders(tester, findWired<Wired<Name>>());
      expectPaints(findWired<Wired<Name>>());
    });

    testWidgets('renders child content', (tester) async {
      await pumpWired(
        tester,
        Wired<Name>(child: const Text('Hello'), onPressed: () {}),
      );
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await pumpWired(
        tester,
        Wired<Name>(child: const Text('Tap'), onPressed: () => tapped = true),
      );
      await tapWired(tester, findWired<Wired<Name>>());
      expect(tapped, isTrue);
    });

    testWidgets('exposes a labelled button role', (tester) async {
      await pumpWired(
        tester,
        Wired<Name>(
          child: const Text('Label'),
          onPressed: () {},
          semanticLabel: 'My widget',
        ),
      );
      expectSemantics(
        tester,
        findWired<Wired<Name>>(),
        label: 'My widget',
        isButton: true,
        isEnabled: true,
      );
    });

    testWidgets('disabled widget ignores taps', (tester) async {
      await pumpWired(tester, const Wired<Name>(child: Text('Off')));
      await tapWired(tester, findWired<Wired<Name>>());
      expectSemantics(
        tester,
        findWired<Wired<Name>>(),
        isButton: true,
        isEnabled: false,
      );
    });

    testWidgets('lays out and paints in RTL', (tester) async {
      await pumpWiredRtl(
        tester,
        Wired<Name>(child: const Text('RTL'), onPressed: () {}),
      );
      expectRenders(tester, findWired<Wired<Name>>());
      expectPaints(findWired<Wired<Name>>());
    });

    testWidgets('scales text without clipping', (tester) async {
      await pumpWiredScaled(
        tester,
        Wired<Name>(child: const Text('Scaled'), onPressed: () {}),
      );
      expectRenders(tester, findWired<Wired<Name>>());
      expect(tester.takeException(), isNull);
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
