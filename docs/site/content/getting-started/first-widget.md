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
