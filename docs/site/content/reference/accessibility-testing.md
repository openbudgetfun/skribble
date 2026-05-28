---
title: Accessibility Testing
description: Guide for testing Skribble widgets with screen readers and accessibility tools.
---

# Accessibility Testing

This guide covers how to test Skribble widgets for accessibility, including screen reader testing, semantic tree inspection, and keyboard navigation.

## Overview

Skribble widgets are designed to be accessible by default. All interactive widgets include `Semantics` wrappers that provide screen readers with the information they need to describe the UI to users.

## Testing Tools

### 1. Flutter Accessibility Inspector

Flutter DevTools includes an accessibility inspector that shows the semantic tree:

```bash
# Run your app with DevTools
flutter run --debug

# Open DevTools in browser
# Navigate to "Inspector" tab → "Accessibility" section
```

### 2. Screen Readers

#### iOS (VoiceOver)

- **Enable**: Settings → Accessibility → VoiceOver
- **Test**: Swipe left/right to navigate, double-tap to activate
- **Verify**: Widget labels, states, and actions are announced correctly

#### Android (TalkBack)

- **Enable**: Settings → Accessibility → TalkBack
- **Test**: Swipe left/right to navigate, double-tap to activate
- **Verify**: Widget labels, states, and actions are announced correctly

#### Web (Screen Readers)

- **macOS**: VoiceOver (Cmd + F5)
- **Windows**: NVDA or JAWS
- **Linux**: Orca

### 3. Flutter Semantics Debugger

Use the `SemanticsDebugger` widget to visualize semantics:

```dart
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SemanticsDebugger(
      child: MaterialApp(
        home: MyHomePage(),
      ),
    );
  }
}
```

## Testing Checklist

### Interactive Widgets

For each interactive widget, verify:

- [ ] **Label**: Widget has a descriptive label
- [ ] **State**: Current state is announced (checked, selected, expanded, etc.)
- [ ] **Action**: Available actions are announced (tap, swipe, etc.)
- [ ] **Value**: Current value is announced (for sliders, inputs, etc.)

### Example Test Cases

#### WiredCheckbox

```dart
testWidgets('checkbox has correct semantics', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: WiredCheckbox(
          value: true,
          onChanged: (_) {},
          semanticLabel: 'Accept terms',
        ),
      ),
    ),
  );

  final semantics = tester.getSemantics(find.byType(WiredCheckbox));
  expect(semantics.label, 'Accept terms');
  expect(semantics.hasFlag(SemanticsFlag.isChecked), isTrue);
});
```

#### WiredSlider

```dart
testWidgets('slider has correct semantics', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: WiredSlider(
          value: 0.5,
          onChanged: (_) => true,
          semanticLabel: 'Volume',
        ),
      ),
    ),
  );

  final semantics = tester.getSemantics(find.byType(WiredSlider));
  expect(semantics.label, 'Volume');
  expect(semantics.value, '0.5');
});
```

#### WiredInput

```dart
testWidgets('input has correct semantics', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: WiredInput(
          labelText: 'Email',
          semanticLabel: 'Email address',
        ),
      ),
    ),
  );

  final semantics = tester.getSemantics(find.byType(WiredInput));
  expect(semantics.label, 'Email address');
  expect(semantics.hasFlag(SemanticsFlag.isTextField), isTrue);
});
```

## Common Issues

### Missing Labels

If a widget doesn't have a label:

```dart
// Bad - no label
WiredButton(
  onPressed: () {},
  child: Icon(Icons.save),
)

// Good - with label
WiredButton(
  onPressed: () {},
  semanticLabel: 'Save document',
  child: Icon(Icons.save),
)
```

### Missing State Announcements

If state changes aren't announced:

```dart
// Bad - state not announced
WiredCheckbox(
  value: true,
  onChanged: (_) {},
)

// Good - state announced
WiredCheckbox(
  value: true,
  onChanged: (_) {},
  semanticLabel: 'Accept terms and conditions',
)
```

### Missing Action Announcements

If actions aren't announced:

```dart
// Bad - action not clear
WiredIconButton(
  icon: Icons.delete,
  onPressed: () {},
)

// Good - action clear
WiredIconButton(
  icon: Icons.delete,
  onPressed: () {},
  semanticLabel: 'Delete item',
)
```

## Automated Testing

### Semantic Tests

Create semantic tests for all widgets:

```dart
testWidgets('all interactive widgets have semantics', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            WiredButton(
              onPressed: () {},
              semanticLabel: 'Test button',
              child: Text('Click'),
            ),
            WiredCheckbox(
              value: false,
              onChanged: (_) {},
              semanticLabel: 'Test checkbox',
            ),
            WiredSlider(
              value: 0.5,
              onChanged: (_) => true,
              semanticLabel: 'Test slider',
            ),
          ],
        ),
      ),
    ),
  );

  // Verify all widgets have semantics
  expect(
    tester.getSemantics(find.byType(WiredButton)).label,
    'Test button',
  );
  expect(
    tester.getSemantics(find.byType(WiredCheckbox)).label,
    'Test checkbox',
  );
  expect(
    tester.getSemantics(find.byType(WiredSlider)).label,
    'Test slider',
  );
});
```

### Integration Tests

Run accessibility tests in CI:

```yaml
# .github/workflows/accessibility.yml
name: Accessibility Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter test test/accessibility/
```

## Best Practices

1. **Always provide semantic labels** for interactive widgets
2. **Test with real screen readers** periodically
3. **Use the Semantics debugger** during development
4. **Include accessibility tests** in your test suite
5. **Follow Flutter's accessibility guidelines** for custom widgets

## Resources

- [Flutter Accessibility Guide](https://docs.flutter.dev/accessibility-and-localization/accessibility)
- [Semantics Widget Documentation](https://api.flutter.dev/flutter/widgets/Semantics-class.html)
- [Flutter Accessibility Checklist](https://docs.flutter.dev/accessibility-and-localization/accessibility)
