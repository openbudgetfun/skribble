---
title: Your First Widget
description: Add WiredButton, WiredInput, and WiredCard to your app step by step. Learn how widgets read from the theme and handle events.
order: 3
---

# Your First Widget

This guide walks through adding individual skribble widgets to your app, one at a time. You will learn how each widget reads its appearance from `WiredTheme.of(context)`, how to handle user events, and how to compose widgets into a form layout.

## Before you start

Make sure you have a working `SkribbleApp`. If not, follow the [Quick Start](/getting-started/quick-start) first. The examples use `HookBuilder`, so add [flutter_hooks](https://pub.dev/packages/flutter_hooks) if you have not yet:

```bash
flutter pub add flutter_hooks
```

Each example below is a widget expression. Paste it in place of the `WiredButton` in this page, which is a complete `lib/main.dart`:

```dart
// Static example: setup
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

void main() {
  runApp(
    SkribbleApp(
      title: 'My first widgets',
      builder: (context, child) => WiredMaterialTheme(child: child!),
      home: const ExamplePage(),
    ),
  );
}

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return WiredScaffold(
      appBar: WiredAppBar(title: Text('My first widgets')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          // Replace this button with any example below.
          child: WiredButton(onPressed: () {}, child: Text('Hello')),
        ),
      ),
    );
  }
}
```

## Step 1: WiredButton

<!-- {=docsFirstWidgetButton} -->

```dart
// Live example: button
WiredButton(
  borderRadius: BorderRadius.circular(8),
  onPressed: () {},
  inkInteraction: WiredInkInteraction.pressure,
  child: Text('Make something lovely'),
)
```

<!-- {/docsFirstWidgetButton} -->

## Step 2: WiredInput

<!-- {=docsFirstWidgetInput} -->

```dart
// Live example: input
WiredInput(
  labelText: 'Make something lovely',
  hintText: 'A tiny spark of an idea…',
)
```

<!-- {/docsFirstWidgetInput} -->

## Step 3: WiredCard

<!-- {=docsFirstWidgetCard} -->

```dart
// Live example: card
WiredCard(
  color: const Color(0xffff6b4a),
  fill: true,
  child: Center(child: Text('Make something lovely')),
)
```

<!-- {/docsFirstWidgetCard} -->

## Step 4: WiredCheckbox

<!-- {=docsFirstWidgetCheckbox} -->

```dart
// Live example: checkbox
HookBuilder(
  builder: (context) {
    final checked = useState(false);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        WiredCheckbox(
          value: checked.value,
          onChanged: (value) => checked.value = value ?? false,
          semanticLabel: 'Keep this idea',
        ),
        const SizedBox(width: 12),
        Flexible(child: Text('Make something lovely')),
      ],
    );
  },
)
```

<!-- {/docsFirstWidgetCheckbox} -->

## Combining widgets: a complete form

Here is a complete example that combines all four widgets into a sign-up form:

```dart
// Live example: signup-pattern
HookBuilder(
  builder: (context) {
    final name = useTextEditingController();
    final email = useTextEditingController();
    final agreed = useState(false);
    final status = useState<String?>(null);
    return WiredCard(
      height: null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WiredInput(controller: name, labelText: 'Name'),
            const SizedBox(height: 16),
            WiredInput(controller: email, labelText: 'Email'),
            const SizedBox(height: 16),
            WiredCheckboxListTile(
              value: agreed.value,
              onChanged: (value) => agreed.value = value ?? false,
              title: const Text('I agree to the sample terms'),
              showDivider: false,
            ),
            const SizedBox(height: 16),
            WiredButton(
              onPressed: () {
                status.value =
                    name.text.trim().isEmpty || !email.text.contains('@')
                    ? 'Enter your name and email.'
                    : !agreed.value
                    ? 'Please agree to the sample terms.'
                    : 'Your sample is ready. Nothing was sent.';
              },
              child: const Text('Check the details'),
            ),
            if (status.value case final String message)
              Semantics(liveRegion: true, child: Text(message)),
          ],
        ),
      ),
    );
  },
)
```

Every widget in this form reads colors and stroke styles from `WiredTheme.of(context)`. Change the theme once and the entire form updates -- no per-widget color props needed.

## The pattern behind every Wired widget

All Wired widgets follow the same three-layer structure:

1. **Theme lookup** -- `final theme = WiredTheme.of(context);` pulls the active `WiredThemeData` from the widget tree.
2. **Rough rendering** -- the widget uses `RoughBoxDecoration`, `WiredCanvas`, or `WiredPainterBase` to paint hand-drawn shapes using `theme.borderColor`, `theme.fillColor`, and `theme.strokeWidth`.
3. **Flutter interaction** -- the widget wraps a standard Flutter widget (`TextButton`, `TextField`, `Checkbox`, `Card`) for gestures, focus management, and accessibility.

When you build your own custom Wired widgets later, you will follow this same pattern. See the [Custom Widgets](/guides/custom-widgets) guide for details.

## Next steps

- [Theming](/getting-started/theming) -- customize colors, stroke width, roughness, and dark mode support
- [Widget Reference](/widgets/buttons) -- browse the full catalog with API details
- [Custom Widgets](/guides/custom-widgets) -- build your own hand-drawn widgets
