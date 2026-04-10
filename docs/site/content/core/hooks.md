---
title: Hooks & State Management
description: Why Skribble uses HookWidget exclusively, common hook patterns, Riverpod integration with HookConsumerWidget, and state management recipes.
---

# Hooks & State Management

Every widget in Skribble uses `HookWidget` from the [flutter_hooks](https://pub.dev/packages/flutter_hooks) package. This is not a suggestion -- it is a hard rule. No `StatefulWidget` or `StatelessWidget` exists anywhere in the codebase.

## Why HookWidget

### Problem with StatefulWidget

`StatefulWidget` separates widget configuration from mutable state across two classes. This creates boilerplate (`createState`, `initState`, `dispose`, `didUpdateWidget`) and makes it harder to extract and reuse stateful logic.

```dart
// Standard Flutter -- lots of ceremony
class AnimatedBox extends StatefulWidget {
  @override
  State<AnimatedBox> createState() => _AnimatedBoxState();
}

class _AnimatedBoxState extends State<AnimatedBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { ... }
}
```

### Solution with HookWidget

Hooks compress all of this into the `build` method. State, side effects, and disposal are declared inline and automatically cleaned up:

```dart
// Skribble way -- clean and composable
class AnimatedBox extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: Duration(milliseconds: 300),
    );
    // controller is created, managed, and disposed automatically
    return ...;
  }
}
```

### Benefits

- **Composable** -- extract a hook into a function and reuse it across widgets without mixins or inheritance.
- **Colocated** -- state declaration, initialization, and disposal live in one place.
- **No lifecycle boilerplate** -- no `initState`, `dispose`, `didUpdateWidget`, or `createState`.
- **Testable** -- hooks follow the same patterns as the widget tree, so widget tests work unchanged.

## Common Hooks in Skribble

### useState

Manages a single piece of mutable state. Calling `.value =` triggers a rebuild.

```dart
class WiredToggle extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final isOn = useState(false);

    return GestureDetector(
      onTap: () => isOn.value = !isOn.value,
      child: Container(
        color: isOn.value ? Colors.green : Colors.grey,
        child: Text(isOn.value ? 'ON' : 'OFF'),
      ),
    );
  }
}
```

### useAnimationController

Creates an `AnimationController` that is automatically disposed. Replaces the `SingleTickerProviderStateMixin` pattern entirely.

```dart
class WiredProgress extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: Duration(seconds: 2),
    )..repeat();

    final animation = useAnimation(controller);

    return CustomPaint(
      painter: ProgressPainter(progress: animation),
    );
  }
}
```

### useAnimation

Subscribes to an `Animation` and returns its current value. The widget rebuilds whenever the animation ticks.

```dart
final controller = useAnimationController(duration: Duration(milliseconds: 500));
final value = useAnimation(controller); // double, rebuilds every frame
```

### useMemoized

Caches an expensive computation across rebuilds. Only recomputes when the keys change.

```dart
class WiredCard extends HookWidget {
  final double roughness;

  const WiredCard({required this.roughness});

  @override
  Widget build(BuildContext context) {
    // Only recreated when roughness changes
    final drawConfig = useMemoized(
      () => DrawConfig.build(roughness: roughness),
      [roughness],
    );

    return WiredCanvas(
      painter: WiredRectangleBase(),
      fillerType: RoughFilter.noFiller,
      drawConfig: drawConfig,
    );
  }
}
```

### useEffect

Runs a side effect when the widget mounts (or when keys change) and optionally returns a cleanup function. Replaces `initState` and `dispose`.

```dart
class WiredLiveData extends HookWidget {
  final Stream<int> dataStream;

  const WiredLiveData({required this.dataStream});

  @override
  Widget build(BuildContext context) {
    final latestValue = useState(0);

    useEffect(() {
      final subscription = dataStream.listen((value) {
        latestValue.value = value;
      });
      return subscription.cancel; // cleanup on dispose
    }, [dataStream]);

    return Text('Value: ${latestValue.value}');
  }
}
```

### useValueChanged

Calls a callback whenever a watched value changes. Useful for triggering animations on prop changes:

```dart
class WiredBadge extends HookWidget {
  final int count;

  const WiredBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: Duration(milliseconds: 200),
    );

    useValueChanged(count, (_, __) {
      controller.forward(from: 0);
    });

    return ScaleTransition(
      scale: controller,
      child: Text('$count'),
    );
  }
}
```

### useTextEditingController

Creates a `TextEditingController` that is automatically disposed:

```dart
class WiredInput extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();

    return TextField(
      controller: controller,
    );
  }
}
```

### useFocusNode

Creates a `FocusNode` that is automatically disposed:

```dart
class WiredSearchBar extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final focusNode = useFocusNode();

    return TextField(
      focusNode: focusNode,
    );
  }
}
```

## HookWidget vs HookConsumerWidget

Use `HookWidget` for widgets that only need hooks. Use `HookConsumerWidget` (from [hooks_riverpod](https://pub.dev/packages/hooks_riverpod)) when you also need to read Riverpod providers.

### HookWidget (default)

```dart
class WiredButton extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    // ... hooks and build logic
  }
}
```

### HookConsumerWidget (when Riverpod is needed)

```dart
class WiredUserProfile extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = WiredTheme.of(context);
    final user = ref.watch(userProvider);
    final isEditing = useState(false);

    return WiredCard(
      child: Text(user.name),
    );
  }
}
```

The rule is simple: if you need `WidgetRef`, use `HookConsumerWidget`. Otherwise, use `HookWidget`.

## Pattern: Reading Theme in build()

Every Wired widget reads the theme at the top of its `build` method:

<!-- {=docsThemeReadPattern} -->

```dart
final theme = WiredTheme.of(context);
// Use theme.borderColor, theme.fillColor, theme.textColor, etc.
```

<!-- {/docsThemeReadPattern} -->

This establishes a dependency on the `WiredTheme` `InheritedWidget`, so the widget rebuilds automatically when the theme changes.

### Complete Widget Example

```dart
class WiredButton extends HookWidget {
  final Widget child;
  final VoidCallback onPressed;

  const WiredButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);

    return buildWiredElement(
      child: Container(
        height: kWiredButtonHeight,
        decoration: RoughBoxDecoration(
          shape: RoughBoxShape.rectangle,
          borderStyle: RoughDrawingStyle(
            width: 1,
            color: theme.borderColor,
          ),
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: theme.textColor,
          ),
          onPressed: onPressed,
          child: child,
        ),
      ),
    );
  }
}
```

## Pattern: Local Animation State

Combine `useAnimationController` with `useAnimation` for animated Wired widgets:

```dart
class WiredCheckbox extends HookWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const WiredCheckbox({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final controller = useAnimationController(
      duration: Duration(milliseconds: 150),
    );

    // Drive animation based on value changes
    useEffect(() {
      if (value) {
        controller.forward();
      } else {
        controller.reverse();
      }
      return null;
    }, [value]);

    final progress = useAnimation(controller);

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: CustomPaint(
        size: Size(24, 24),
        painter: CheckboxPainter(
          progress: progress,
          borderColor: theme.borderColor,
          fillColor: theme.fillColor,
          drawConfig: theme.drawConfig,
        ),
      ),
    );
  }
}
```

## Pattern: Memoized Generators

When creating a `Generator` or `DrawConfig` is expensive or you want to avoid unnecessary object allocation, use `useMemoized`:

```dart
class WiredShape extends HookWidget {
  final double roughness;
  final RoughFilter fillerType;

  const WiredShape({
    required this.roughness,
    required this.fillerType,
  });

  @override
  Widget build(BuildContext context) {
    final drawConfig = useMemoized(
      () => DrawConfig.build(roughness: roughness),
      [roughness],
    );

    return WiredCanvas(
      painter: WiredRectangleBase(),
      fillerType: fillerType,
      drawConfig: drawConfig,
    );
  }
}
```

## Rules

1. **Always use `HookWidget`** -- never `StatefulWidget` or `StatelessWidget`.
2. **Use `HookConsumerWidget` only when Riverpod is needed** -- do not import `hooks_riverpod` unless you need `WidgetRef`.
3. **Read the theme first** -- `WiredTheme.of(context)` should be one of the first lines in `build`.
4. **Wrap painted content with RepaintBoundary** -- use `WiredBaseWidget` or `buildWiredElement()`.
5. **Memoize expensive objects** -- use `useMemoized` for `DrawConfig`, `Generator`, or any computation that does not need to run every build.
6. **Never store hooks in variables outside build** -- all `use*` calls must happen inside the `build` method, unconditionally, in the same order on every build.
