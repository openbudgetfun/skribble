# Skribble Accessibility Patterns

This document describes the accessibility patterns used in the Skribble hand-drawn Flutter design system.

## Overview

Skribble widgets follow Flutter's accessibility best practices by wrapping interactive elements with `Semantics` widgets. This ensures that screen readers and other assistive technologies can properly describe the UI to users.

## Core Patterns

### 1. Semantic Labels

All interactive widgets accept an optional `semanticLabel` property that provides a custom label for screen readers.

```dart
WiredCheckbox(
  value: true,
  onChanged: (value) {},
  semanticLabel: 'Accept terms and conditions',
)
```

### 2. State Communication

Widgets communicate their current state to screen readers:

- **Selection state:** `selected`, `checked`, `toggled`, `expanded`
- **Value state:** `value`, `slider`, `textField`
- **Interaction state:** `button`, `onTap`, `onIncrease`, `onDecrease`

```dart
WiredSlider(
  value: 0.5,
  onChanged: (value) => true,
  semanticLabel: 'Volume',
  // Automatically communicates: value, increase/decrease actions
)
```

### 3. Live Regions

Widgets that display temporary notifications use `liveRegion: true` to announce changes:

```dart
WiredSnackBarContent(
  child: Text('Item saved'),
  semanticLabel: 'Success notification',
  // liveRegion: true is set automatically
)
```

## Widget-Specific Patterns

### Buttons (WiredButton, WiredElevatedButton, etc.)
- Use `button: true` in Semantics
- Include `onTap` for tap action
- Support `semanticLabel` for custom labels

### Checkboxes and Radios (WiredCheckbox, WiredRadio)
- Use `checked` or `toggled` for state
- Use `inGroup: true` for radio buttons
- Include `onTap` for toggle action

### Sliders (WiredSlider, WiredRangeSlider)
- Use `slider: true` in Semantics
- Include `value` for current value
- Include `increasedValue` and `decreasedValue` for step actions
- Include `onIncrease` and `onDecrease` for keyboard navigation

### Text Fields (WiredInput, WiredTextArea)
- Use `textField: true` in Semantics
- Include `label` for field description
- Support `semanticLabel` override

### Chips (WiredChip, WiredChoiceChip, etc.)
- Use `button: true` for tappable chips
- Use `selected: true` for selection state
- Include `onTap` for interaction

### List Tiles (WiredListTile, WiredCheckboxListTile, etc.)
- Use `button: true` when tappable
- Include `onTap` for tap action
- Composite widgets pass `semanticLabel` to child components

### Navigation (WiredNavigationBar, WiredTabBar)
- Use descriptive labels for navigation context
- Include selected state for current destination/tab

### Expansion Tiles (WiredExpansionTile)
- Use `expanded: true/false` for collapse state
- Include `onTap` for toggle action

### Pickers (WiredDatePicker, WiredTimePicker)
- Use `button: true` for interaction
- Include descriptive labels for picker type

### Sheets and Dialogs (WiredBottomSheet, WiredSnackBarContent)
- Use descriptive labels for context
- Use `liveRegion: true` for notifications

## Implementation Guidelines

### When to Add Semantics

1. **Always add Semantics to interactive widgets** - buttons, inputs, toggles, etc.
2. **Add Semantics to informational widgets** - status messages, labels, etc.
3. **Use `ExcludeSemantics` for decorative elements** - icons, dividers, etc.

### SemanticLabel Best Practices

1. **Be concise** - Screen readers read labels aloud
2. **Be descriptive** - Include context (e.g., "Delete item" not just "Delete")
3. **Use sentence case** - "Accept terms" not "accept terms"
4. **Avoid redundancy** - Don't repeat the widget type in the label

### Testing Accessibility

1. **Use Flutter's accessibility inspector** in DevTools
2. **Test with screen readers** - TalkBack (Android), VoiceOver (iOS)
3. **Verify keyboard navigation** - Tab order, focus management
4. **Check semantic tree** - Use `SemanticsDebugger` widget

## Widgets with Built-in Semantics

The following widgets inherit semantics from their wrapped Flutter components:

- `WiredDialog` - wraps Flutter's Dialog
- `WiredDrawer` - wraps Flutter's Drawer
- `WiredTooltip` - wraps Flutter's Tooltip
- `WiredSwitch` - wraps Flutter's Switch
- `WiredCupertinoSwitch` - wraps Flutter's CupertinoSwitch

These widgets don't need explicit Semantics wrappers unless custom labels are required.

## Future Work

- [ ] Add accessibility tests to all widget test suites
- [ ] Test with real screen readers (TalkBack, VoiceOver)
- [ ] Add keyboard navigation support where missing
- [ ] Create accessibility demo in storybook app
