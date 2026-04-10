---
title: Your First Widget
description: Add WiredButton, WiredInput, and WiredCard to your app step by step. Learn how widgets read from the theme and handle events.
---

# Your First Widget

This guide walks through adding individual Skribble widgets to your app, one at a time. You will learn how each widget reads its appearance from `WiredTheme.of(context)`, how to handle user events, and how to compose widgets into a form layout.

## Before you start

Make sure you have a working `WiredMaterialApp` shell. If not, follow the [Quick Start](/getting-started/quick-start) guide first.

All examples below assume this outer structure:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

void main() {
  runApp(
    WiredMaterialApp(
      wiredTheme: WiredThemeData(),
      home: const ExamplePage(),
    ),
  );
}
```

## Step 1: WiredButton

<!-- {=docsFirstWidgetButton} -->

`WiredButton` is the simplest Wired widget. It draws a hand-sketched rectangle border around a child widget and fires `onPressed` when tapped.

```dart
class ExamplePage extends HookWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WiredAppBar(title: const Text('Button Example')),
      body: Center(
        child: WiredButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Button pressed!')),
            );
          },
          child: const Text('Tap me'),
        ),
      ),
    );
  }
}
```

### How WiredButton reads the theme

Inside its `build` method, `WiredButton` calls:

```dart
final theme = WiredTheme.of(context);
```

It then uses `theme.borderColor` for the sketchy rectangle border and `theme.textColor` for the label. You never pass colors to individual widgets -- they inherit everything from the nearest `WiredTheme` ancestor.

### Accessibility

`WiredButton` wraps its content in a `Semantics` widget. Pass `semanticLabel` when the child widget does not convey meaning to screen readers:

```dart
WiredButton(
  onPressed: handleSave,
  semanticLabel: 'Save document',
  child: Icon(Icons.save),
)
```

<!-- {/docsFirstWidgetButton} -->

## Step 2: WiredInput

<!-- {=docsFirstWidgetInput} -->

`WiredInput` is a text field with a hand-drawn rectangle border. It wraps Flutter's `TextField` internally, so all standard text input behavior (focus, selection, IME) works automatically.

```dart
class ExamplePage extends HookWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();

    return Scaffold(
      appBar: WiredAppBar(title: const Text('Input Example')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            WiredInput(
              controller: controller,
              labelText: 'Email',
              hintText: 'you@example.com',
              onChanged: (value) {
                debugPrint('Current input: $value');
              },
            ),
            const SizedBox(height: 16),
            WiredInput(
              labelText: 'Password',
              hintText: 'Enter your password',
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }
}
```

### WiredInput parameters

| Parameter     | Type                     | Description                                                                          |
| ------------- | ------------------------ | ------------------------------------------------------------------------------------ |
| `controller`  | `TextEditingController?` | Controls the text being edited. Use `useTextEditingController()` from flutter_hooks. |
| `labelText`   | `String?`                | Label displayed to the left of the input.                                            |
| `hintText`    | `String?`                | Placeholder text inside the field.                                                   |
| `onChanged`   | `void Function(String)?` | Called every time the text changes.                                                  |
| `obscureText` | `bool`                   | Hides the input text (for passwords). Defaults to `false`.                           |
| `style`       | `TextStyle?`             | Custom text style for the input content.                                             |
| `labelStyle`  | `TextStyle?`             | Custom text style for the label.                                                     |
| `hintStyle`   | `TextStyle?`             | Custom text style for the hint text.                                                 |

### How WiredInput reads the theme

`WiredInput` calls `WiredTheme.of(context)` and uses:

- `theme.fillColor` for the rectangle background
- `theme.borderColor` for the sketchy rectangle stroke

The underlying `TextField` uses Flutter's default text styling, which `WiredMaterialApp` has already synced with the Wired theme's text color.

<!-- {/docsFirstWidgetInput} -->

## Step 3: WiredCard

<!-- {=docsFirstWidgetCard} -->

`WiredCard` draws a hand-sketched rectangle container. Use it to group related content.

```dart
class ExamplePage extends HookWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WiredAppBar(title: const Text('Card Example')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Fixed-height card (default 130px)
            WiredCard(
              child: Center(
                child: Text('Default card'),
              ),
            ),
            const SizedBox(height: 16),

            // Auto-sized card
            WiredCard(
              height: null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('This card sizes to its content.'),
              ),
            ),
            const SizedBox(height: 16),

            // Filled card with hachure pattern
            WiredCard(
              fill: true,
              child: Center(
                child: Text('Hachure-filled card'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### WiredCard parameters

| Parameter | Type      | Default | Description                                                            |
| --------- | --------- | ------- | ---------------------------------------------------------------------- |
| `child`   | `Widget?` | `null`  | The content inside the card.                                           |
| `height`  | `double?` | `130.0` | Fixed height. Pass `null` to auto-size.                                |
| `fill`    | `bool`    | `false` | When `true`, the card background is drawn with a hachure fill pattern. |

### How WiredCard reads the theme

`WiredCard` calls `WiredTheme.of(context)` and passes `theme.fillColor` and `theme.borderColor` to its internal `WiredRectangleBase` painter.

<!-- {/docsFirstWidgetCard} -->

## Step 4: WiredCheckbox

<!-- {=docsFirstWidgetCheckbox} -->

`WiredCheckbox` draws a hand-sketched square with a checkmark inside when checked.

```dart
class ExamplePage extends HookWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isChecked = useState(false);

    return Scaffold(
      appBar: WiredAppBar(title: const Text('Checkbox Example')),
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            WiredCheckbox(
              value: isChecked.value,
              onChanged: (value) {
                isChecked.value = value ?? false;
              },
            ),
            const SizedBox(width: 12),
            Text(isChecked.value ? 'Checked' : 'Unchecked'),
          ],
        ),
      ),
    );
  }
}
```

`WiredCheckbox` supports tristate values. Pass `null` for the indeterminate state.

<!-- {/docsFirstWidgetCheckbox} -->

## Combining widgets: a complete form

<!-- {=docsFirstWidgetForm} -->

Here is a complete example that combines all four widgets into a sign-up form:

```dart
class SignUpForm extends HookWidget {
  const SignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final agreeToTerms = useState(false);
    final subscribeNewsletter = useState(false);

    void handleSubmit() {
      final name = nameController.text;
      final email = emailController.text;
      final password = passwordController.text;

      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')),
        );
        return;
      }

      if (!agreeToTerms.value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please agree to the terms')),
        );
        return;
      }

      debugPrint('Name: $name');
      debugPrint('Email: $email');
      debugPrint('Agreed: ${agreeToTerms.value}');
      debugPrint('Newsletter: ${subscribeNewsletter.value}');
    }

    return Scaffold(
      appBar: WiredAppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: WiredCard(
          height: null,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create an Account',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),

                // Name field
                WiredInput(
                  controller: nameController,
                  labelText: 'Name',
                  hintText: 'Jane Doe',
                ),
                const SizedBox(height: 16),

                // Email field
                WiredInput(
                  controller: emailController,
                  labelText: 'Email',
                  hintText: 'jane@example.com',
                ),
                const SizedBox(height: 16),

                // Password field
                WiredInput(
                  controller: passwordController,
                  labelText: 'Password',
                  hintText: 'At least 8 characters',
                  obscureText: true,
                ),
                const SizedBox(height: 20),

                // Terms checkbox
                Row(
                  children: [
                    WiredCheckbox(
                      value: agreeToTerms.value,
                      onChanged: (value) {
                        agreeToTerms.value = value ?? false;
                      },
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('I agree to the Terms of Service'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Newsletter checkbox
                Row(
                  children: [
                    WiredCheckbox(
                      value: subscribeNewsletter.value,
                      onChanged: (value) {
                        subscribeNewsletter.value = value ?? false;
                      },
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Subscribe to newsletter'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Submit button
                Align(
                  alignment: Alignment.centerRight,
                  child: WiredButton(
                    onPressed: handleSubmit,
                    child: const Text('Create Account'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

Every widget in this form reads colors and stroke styles from `WiredTheme.of(context)`. Change the theme once and the entire form updates -- no per-widget color props needed.

<!-- {/docsFirstWidgetForm} -->

## The pattern behind every Wired widget

All Wired widgets follow the same three-layer structure:

1. **Theme lookup** -- `final theme = WiredTheme.of(context);` pulls the active `WiredThemeData` from the widget tree.
2. **Rough rendering** -- the widget uses `RoughBoxDecoration`, `WiredCanvas`, or `WiredPainterBase` to paint hand-drawn shapes using `theme.borderColor`, `theme.fillColor`, and `theme.strokeWidth`.
3. **Flutter interaction** -- the widget wraps a standard Flutter widget (`TextButton`, `TextField`, `Checkbox`, `Card`) for gestures, focus management, and accessibility.

When you build your own custom Wired widgets later, you will follow this same pattern. See the [Custom Widgets](/guides/custom-widgets) guide for details.

## Next steps

- [Theming](/getting-started/theming) -- customize colors, stroke width, roughness, and dark mode support
- [Widget Reference](/widgets) -- browse the full catalog with API details
- [Custom Widgets](/guides/custom-widgets) -- build your own hand-drawn widgets
