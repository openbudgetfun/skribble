# Skribble Animation Style Guide

This document defines the animation patterns and style guidelines for the Skribble hand-drawn Flutter design system.

## Design Philosophy

Skribble animations should feel **organic and hand-drawn**, not mechanical. The goal is to enhance the sketchy, informal aesthetic while maintaining usability and performance.

## Core Principles

### 1. Organic Motion
- Use **ease-in-out curves** instead of linear animations
- Add slight **overshoot and bounce** for playful feel
- Keep durations **moderate** (200-400ms) - not too fast, not too slow

### 2. Hand-Drawn Aesthetic
- Animations should feel like **pen strokes** - fluid and slightly imperfect
- Use **irregular timing** where appropriate (e.g., staggered animations)
- Avoid perfectly smooth, mechanical movements

### 3. Purposeful Motion
- Every animation should have a **clear purpose** (feedback, transition, emphasis)
- Don't animate just for decoration
- Ensure animations **don't hinder usability**

## Animation Types

### Transitions

#### Page Transitions
```dart
// Recommended: Slide with slight fade
PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => NextPage(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  },
)
```

#### Element Transitions
- **Expand/Collapse:** Use `AnimatedSize` with `Curves.easeOutCubic`
- **Fade In/Out:** Use `AnimatedOpacity` with 200-300ms duration
- **Slide:** Use `AnimatedSlide` with slight overshoot

### Micro-interactions

#### Button Press
```dart
// Slight scale down on press, bounce back on release
AnimatedScale(
  scale: isPressed ? 0.95 : 1.0,
  duration: Duration(milliseconds: 100),
  curve: Curves.easeOutCubic,
  child: WiredButton(...),
)
```

#### Toggle State
```dart
// Smooth color transition with slight bounce
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  curve: Curves.easeOutBack, // Slight overshoot
  decoration: BoxDecoration(
    color: isSelected ? selectedColor : defaultColor,
  ),
)
```

#### Loading States
```dart
// Organic pulsing animation
AnimatedOpacity(
  opacity: isLoading ? 0.5 : 1.0,
  duration: Duration(milliseconds: 800),
  curve: Curves.easeInOut,
  child: child,
)
```

### Staggered Animations

For lists and grids, use staggered delays to create organic reveal:

```dart
AnimatedSwitcher(
  duration: Duration(milliseconds: 300),
  child: ListView.builder(
    itemBuilder: (context, index) {
      return AnimatedBuilder(
        animation: AlwaysStoppedAnimation(index * 0.1),
        builder: (context, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 0.5),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Interval(
                index * 0.1,
                1.0,
                curve: Curves.easeOutCubic,
              ),
            )),
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Interval(
                  index * 0.1,
                  1.0,
                  curve: Curves.easeOut,
                ),
              ),
              child: child,
            ),
          );
        },
        child: WiredCard(...),
      );
    },
  ),
)
```

## Durations

| Animation Type | Duration | Curve |
|---------------|----------|-------|
| Micro-interactions | 100-200ms | easeOutCubic |
| State changes | 200-300ms | easeOutBack |
| Page transitions | 300-400ms | easeOutCubic |
| Loading indicators | 800-1200ms | easeInOut |
| Staggered reveals | 100-200ms per item | easeOutCubic |

## Curves

### Recommended Curves
- `Curves.easeOutCubic` - Smooth deceleration, organic feel
- `Curves.easeOutBack` - Slight overshoot for playful bounce
- `Curves.easeInOut` - Smooth acceleration/deceleration
- `Curves.easeOutQuart` - Stronger deceleration for emphasis

### Avoid
- `Curves.linear` - Too mechanical
- `Curves.bounceIn/Out` - Too playful for most cases
- `Curves.elasticIn/Out` - Too exaggerated

## Implementation Patterns

### Using Hooks for Animations

```dart
class AnimatedWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: Duration(milliseconds: 300),
    );

    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    );

    useEffect(() {
      controller.forward();
      return null;
    }, []);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: WiredCard(...),
    );
  }
}
```

### Implicit Animations

For simple state changes, use Flutter's implicit animations:

```dart
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  curve: Curves.easeOutCubic,
  padding: EdgeInsets.all(isExpanded ? 16 : 8),
  decoration: BoxDecoration(
    color: isSelected ? selectedColor : defaultColor,
    borderRadius: BorderRadius.circular(isExpanded ? 12 : 8),
  ),
  child: child,
)
```

## Performance Considerations

1. **Use `RepaintBoundary`** for animated widgets to isolate repaints
2. **Prefer implicit animations** over explicit controllers when possible
3. **Avoid animating expensive properties** (e.g., blur, shadows)
4. **Use `AnimatedBuilder`** to rebuild only necessary parts
5. **Dispose controllers** in `useEffect` cleanup

## Accessibility

1. **Respect `MediaQuery.disableAnimations`** - Don't animate when disabled
2. **Provide alternatives** - Ensure functionality works without animation
3. **Use `Semantics`** - Announce state changes to screen readers
4. **Keep durations reasonable** - Don't make users wait for animations

## Future Work

- [ ] Create animation presets library
- [ ] Add hand-drawn ripple/splash effect
- [ ] Implement organic loading spinners
- [ ] Create transition demo in storybook
- [ ] Add animation performance benchmarks
