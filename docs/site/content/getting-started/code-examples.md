---
title: Code Examples
description: Common patterns and code examples for building apps with Skribble's hand-drawn design system.
---

# Code Examples

This page provides code examples for common patterns when building apps with Skribble. Each example runs the Flutter expression shown below it. Place the expression inside a `WiredMaterialApp` widget tree. Import `package:flutter/widgets.dart`, `package:flutter_hooks/flutter_hooks.dart`, and `package:skribble/skribble.dart`. These examples use local sample data; forms do not submit information and loading does not contact a service.

## Basic App Structure

```dart
// Live example: app-pattern
HookBuilder(
  builder: (context) {
    final tab = useState(0);
    return SizedBox(
      height: 320,
      child: WiredScaffold(
        appBar: const WiredAppBar(title: Text('My sketchbook')),
        body: Center(
          child: Text(tab.value == 0 ? 'A fresh page' : 'Your saved ideas'),
        ),
        bottomNavigationBar: WiredBottomNavigationBar(
          currentIndex: tab.value,
          onTap: (value) => tab.value = value,
          items: const [
            WiredBottomNavItem(
              icon: IconData(0xe318, fontFamily: 'MaterialIcons'),
              label: 'Home',
            ),
            WiredBottomNavItem(
              icon: IconData(0xe25b, fontFamily: 'MaterialIcons'),
              label: 'Saved',
            ),
          ],
        ),
      ),
    );
  },
)
```

## Forms with Validation

```dart
// Live example: validated-form
HookBuilder(
  builder: (context) {
    final key = useMemoized(GlobalKey<FormState>.new);
    final accepted = useState(false);
    return WiredForm(
      formKey: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormField<String>(
            validator: (value) => value != null && value.contains('@')
                ? null
                : 'Enter an email address.',
            builder: (field) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WiredInput(labelText: 'Email', onChanged: field.didChange),
                if (field.errorText case final String error)
                  Semantics(liveRegion: true, child: Text(error)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          WiredFilledButton(
            onPressed: () => accepted.value = key.currentState!.validate(),
            child: const Text('Check the form'),
          ),
          if (accepted.value)
            const Text('The sample form is valid. Nothing was sent.'),
        ],
      ),
    );
  },
)
```

## Lists with Swipe Actions

```dart
// Live example: task-list-pattern
HookBuilder(
  builder: (context) {
    const initial = [
      (title: 'Buy paper', done: false),
      (title: 'Walk the dog', done: true),
      (title: 'Sketch an idea', done: false),
    ];
    final tasks = useState(initial);
    return Column(
      children: [
        for (final task in tasks.value)
          WiredDismissible(
            dismissKey: ValueKey(task.title),
            onDismissed: (_) => tasks.value = tasks.value
                .where((item) => item.title != task.title)
                .toList(),
            child: WiredCheckboxListTile(
              title: Text(task.title),
              value: task.done,
              showDivider: false,
              onChanged: (value) => tasks.value = [
                for (final item in tasks.value)
                  if (item.title == task.title)
                    (title: item.title, done: value ?? false)
                  else
                    item,
              ],
            ),
          ),
        WiredOutlinedButton(
          onPressed: () => tasks.value = initial,
          child: const Text('Reset the sample list'),
        ),
      ],
    );
  },
)
```

## Settings Screen

```dart
// Live example: settings-pattern
HookBuilder(
  builder: (context) {
    final notifications = useState(true);
    final language = useState('English');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WiredSwitchListTile(
          title: const Text('Notifications'),
          value: notifications.value,
          onChanged: (value) => notifications.value = value,
          showDivider: false,
        ),
        const SizedBox(height: 16),
        const Text('Language'),
        for (final option in ['English', 'Spanish', 'French'])
          WiredRadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: language.value,
            onChanged: (value) {
              language.value = value!;
              return true;
            },
            showDivider: false,
          ),
        Text(
          'Sample preferences: ${language.value}, notifications ${notifications.value ? 'on' : 'off'}.',
        ),
      ],
    );
  },
)
```

## Loading States

```dart
// Live example: loading-pattern
HookBuilder(
  builder: (context) {
    final request = useState<Future<List<String>>?>(null);
    final result = useFuture(request.value);
    return Column(
      children: [
        WiredOutlinedButton(
          onPressed: result.connectionState == ConnectionState.waiting
              ? null
              : () {
                  request.value = Future.delayed(
                    const Duration(milliseconds: 350),
                    () => ['Paper', 'Ink', 'Possibility'],
                  );
                },
          child: const Text('Load sample notes'),
        ),
        const SizedBox(height: 16),
        if (result.connectionState == ConnectionState.waiting)
          const WiredCircularProgress()
        else if (result.hasError)
          const Text('The sample could not load. Try again.')
        else if (result.data case final List<String> notes)
          for (final note in notes)
            WiredListTile(title: Text(note), showDivider: false),
      ],
    );
  },
)
```

## Search with Filtering

```dart
// Live example: search-pattern
HookBuilder(
  builder: (context) {
    final query = useState('');
    final category = useState('All');
    const items = [
      (title: 'Write a proposal', category: 'Work'),
      (title: 'Buy sketchbooks', category: 'Shopping'),
      (title: 'Draw with friends', category: 'Personal'),
    ];
    final filtered = items
        .where(
          (item) =>
              item.title.toLowerCase().contains(query.value.toLowerCase()) &&
              (category.value == 'All' || item.category == category.value),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WiredInput(
          labelText: 'Search sample tasks',
          onChanged: (value) => query.value = value,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in ['All', 'Work', 'Shopping', 'Personal'])
              WiredChoiceChip(
                label: Text(option),
                selected: category.value == option,
                onSelected: (selected) {
                  if (selected) category.value = option;
                },
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty) const Text('No matching sample tasks.'),
        for (final item in filtered)
          WiredListTile(
            title: Text(item.title),
            subtitle: Text(item.category),
            showDivider: false,
          ),
      ],
    );
  },
)
```

## Animations

```dart
// Live example: ink-reveal
HookBuilder(
  builder: (context) {
    final replay = useState(0);
    return Column(
      children: [
        WiredDraw(
          key: ValueKey(replay.value),
          child: WiredCard(child: Text('Make something lovely')),
        ),
        const SizedBox(height: 16),
        WiredOutlinedButton(
          onPressed: () => replay.value++,
          child: const Text('Draw again'),
        ),
      ],
    );
  },
)
```

## Error Handling with Snackbars

```dart
// Live example: snackbar-pattern
Builder(
  builder: (context) => WiredOutlinedButton(
    onPressed: () => showWiredSnackBar(
      context,
      content: const WiredSnackBarContent(
        child: Text('The sample could not save. Please try again.'),
      ),
      duration: const Duration(seconds: 3),
    ),
    child: const Text('Show a sample error'),
  ),
)
```

## Responsive Layout

```dart
// Live example: responsive-pattern
LayoutBuilder(
  builder: (context, constraints) {
    final cards = [
      for (final title in ['Ideas', 'In progress', 'Finished'])
        WiredCard(
          child: Padding(padding: const EdgeInsets.all(16), child: Text(title)),
        ),
    ];
    return constraints.maxWidth < 600
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: cards,
          )
        : Row(children: [for (final card in cards) Expanded(child: card)]);
  },
)
```

## Next Steps

- [Theming Guide](/getting-started/theming) - Customize the hand-drawn palette
- [Widget Catalog](/widgets/buttons) - Browse all available Wired widgets
- [Core Concepts](/core/architecture) - Understand the rough engine and painting system
- [Migration Guide](/getting-started/migration) - Migrate from Material to Skribble
