<!-- {@docsQuickInstallSection} -->

```bash
dart pub add skribble
```

Then import it in your application code:

```dart
import 'package:skribble/skribble.dart';
```

<!-- {/docsQuickInstallSection} -->

<!-- {@docsInstallSection} -->

## Install in an app

Add the `skribble` package to your Flutter project:

```bash
dart pub add skribble
```

Then import it:

```dart
import 'package:skribble/skribble.dart';
```

<!-- {/docsInstallSection} -->

<!-- {@docsWorkspaceSetupSection} -->

```bash
# Clone the repository
git clone https://github.com/openbudgetfun/skribble.git
cd skribble

# If using devenv
direnv allow

# If not using devenv
fvm install
fvm use --force

# Install dependencies
flutter pub get
```

<!-- {/docsWorkspaceSetupSection} -->

<!-- {@docsWorkspaceDevCommandsSection} -->

```bash
# Run all lint checks (format + analyze)
lint:all

# Run dart analyze across all packages
melos run analyze

# Run Flutter widget tests
melos run flutter-test

# Format all Dart code
dart format .

# Fix all fixable lint and format issues
fix:all

# Capture component screenshots
melos run screenshot

# Generate rough Material icon SVGs
melos run rough-icons

# Generate rough icon font (TTF + Dart helpers)
melos run rough-icons-font

# Generate custom icon artifacts from SVG manifest
melos run rough-icons-custom

# Run CI-equivalent rough icon checks
melos run rough-icons-ci-check
```

<!-- {/docsWorkspaceDevCommandsSection} -->

<!-- {@docsMinimalAppSection} -->

```dart
import 'package:flutter/material.dart';
import 'package:skribble/skribble.dart';

void main() {
  runApp(
    WiredMaterialApp(
      wiredTheme: WiredThemeData(),
      home: Scaffold(
        appBar: WiredAppBar(title: Text('My Sketchy App')),
        body: Center(
          child: WiredButton(
            onPressed: () {},
            child: Text('Press Me'),
          ),
        ),
      ),
    ),
  );
}
```

<!-- {/docsMinimalAppSection} -->

<!-- {@docsThemeSetupSection} -->

```dart
import 'package:flutter/material.dart';
import 'package:skribble/skribble.dart';

void main() {
  final wiredTheme = WiredThemeData(
    borderColor: Color(0xFF4A3470),
    textColor: Color(0xFF2A2238),
    disabledTextColor: Color(0xFFA39AAD),
    fillColor: Color(0xFFFFFCF1),
    roughness: 1.15,
  );

  runApp(
    WiredMaterialApp(
      wiredTheme: wiredTheme,
      darkWiredTheme: WiredThemeData(
        borderColor: Color(0xFFB09BDC),
        textColor: Color(0xFFF0EBF5),
        fillColor: Color(0xFF1E1A26),
        roughness: 1.15,
      ),
      themeMode: ThemeMode.system,
      title: 'My Sketchy App',
      home: MyHomePage(),
    ),
  );
}
```

<!-- {/docsThemeSetupSection} -->

<!-- {@docsThemeReadPattern} -->

```dart
@override
Widget build(BuildContext context) {
  final theme = WiredTheme.of(context);

  // Use theme values for all visual properties
  final borderColor = theme.borderColor;
  final fillColor = theme.fillColor;
  final textColor = theme.textColor;
  final strokeWidth = theme.strokeWidth;
  final roughness = theme.roughness;
  // ...
}
```

<!-- {/docsThemeReadPattern} -->

<!-- {@docsAgentWidgetTemplate} -->

```dart
import 'package:flutter/material.dart';
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
import 'package:flutter/material.dart';
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

<!-- {@docsAgentCommandsSection} -->

```bash
# Install dependencies
flutter pub get

# Run all lint checks
lint:all

# Run dart analyze
melos run analyze

# Run widget tests
melos run flutter-test

# Format code
dart format .

# Fix lint issues
melos exec -- dart fix --apply

# Capture screenshots
melos run screenshot

# Generate rough Material icons
melos run rough-icons

# Generate rough icon font
melos run rough-icons-font

# Generate custom icon set
melos run rough-icons-custom

# CI-equivalent checks
melos run rough-icons-ci-check
```

<!-- {/docsAgentCommandsSection} -->

<!-- {@docsPumpAppHelper} -->

```dart
import '../helpers/pump_app.dart';

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

<!-- {/docsPumpAppHelper} -->

<!-- {@docsRoughBoxDecorationPattern} -->

```dart
Container(
  decoration: RoughBoxDecoration(
    shape: RoughBoxShape.rectangle,
    borderStyle: RoughDrawingStyle(
      width: theme.strokeWidth,
      color: theme.borderColor,
    ),
    fillStyle: RoughDrawingStyle(
      color: theme.fillColor,
    ),
  ),
  child: child,
)
```

<!-- {/docsRoughBoxDecorationPattern} -->

<!-- {@docsContribSetupSection} -->

```bash
# Clone the repository
git clone https://github.com/openbudgetfun/skribble.git
cd skribble

# If using devenv
direnv allow

# If not using devenv
fvm install
fvm use --force
flutter pub get
```

<!-- {/docsContribSetupSection} -->

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

<!-- {@docsFirstWidgetButton} -->

```dart
WiredButton(
  onPressed: () {
    print('Tapped!');
  },
  child: Text('Click Me'),
)
```

<!-- {/docsFirstWidgetButton} -->

<!-- {@docsFirstWidgetInput} -->

```dart
WiredInput(
  hintText: 'Enter your name',
  onChanged: (value) {
    print('Name: $value');
  },
)
```

<!-- {/docsFirstWidgetInput} -->

<!-- {@docsFirstWidgetCard} -->

```dart
WiredCard(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        Text('Card Title', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('This is a hand-drawn card with sketchy borders.'),
      ],
    ),
  ),
)
```

<!-- {/docsFirstWidgetCard} -->

<!-- {@docsFirstWidgetCheckbox} -->

```dart
WiredCheckbox(
  value: isChecked,
  onChanged: (value) {
    setState(() => isChecked = value!);
  },
)
```

<!-- {/docsFirstWidgetCheckbox} -->

<!-- {@docsButtonBasicUsage} -->

```dart
WiredButton(
  onPressed: () {
    // Handle tap
  },
  child: Text('Press Me'),
)
```

<!-- {/docsButtonBasicUsage} -->

<!-- {@docsDocsSiteCommandsSection} -->

```bash
# Serve docs site locally at http://localhost:9080
docs:site:serve

# Build static docs output for GitHub Pages
docs:site:build

# Build with custom base path
docs:site:build --dart-define=DOCS_BASE_PATH=/skribble/
```

<!-- {/docsDocsSiteCommandsSection} -->
