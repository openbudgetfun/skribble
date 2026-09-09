<!-- Shared content for the getting-started docs pages.
     Providers here are consumed by installation, quick-start, and
     first-widget pages plus the agents reference commands section. -->
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

<!-- {@docsSetupSection} -->

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

<!-- {/docsSetupSection} -->

<!-- {@docsCommandsSection} -->

```bash
# Install dependencies
flutter pub get

# Run all lint checks (format + analyze + docs)
lint:all

# Run dart analyze across all packages
melos run analyze

# Run Flutter widget tests
melos run flutter-test

# Format all Dart code
dart format .

# Fix all fixable lint, format, and docs issues
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

<!-- {/docsCommandsSection} -->

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
