---
title: Beyond Flutter
description: Using Skribble's hand-drawn aesthetic outside of Flutter applications.
---

# Beyond Flutter

Skribble's hand-drawn aesthetic isn't limited to Flutter apps. This page describes how to use Skribble's fonts, icons, and design principles in other contexts.

## Standalone Fonts

The Skribble font family (roughened from Recursive) can be used in any application that supports custom fonts:

### Web (CSS)

```css
@font-face {
  font-family: 'Skribble';
  src: url('Skribble-Regular.ttf') format('truetype');
  font-weight: 400;
  font-style: normal;
}

@font-face {
  font-family: 'Skribble';
  src: url('Skribble-Bold.ttf') format('truetype');
  font-weight: 700;
  font-style: normal;
}

@font-face {
  font-family: 'Skribble';
  src: url('Skribble-Italic.ttf') format('truetype');
  font-weight: 400;
  font-style: italic;
}

body {
  font-family: 'Skribble', sans-serif;
}
```

### iOS (Swift)

```swift
// Add Skribble-Regular.ttf to your project
// Info.plist: UIAppFonts = ["Skribble-Regular.ttf", "Skribble-Bold.ttf"]

let label = UILabel()
label.font = UIFont(name: "Skribble", size: 16)
```

### Android (Kotlin)

```xml
<!-- res/font/skribble_regular.ttf -->
<TextView
    android:fontFamily="@font/skribble_regular"
    android:text="Hello World" />
```

### React Native

```javascript
// react-native.config.js
module.exports = {
  assets: ['./assets/fonts'],
};

// Usage
<Text style={{ fontFamily: 'Skribble', fontSize: 16 }}>
  Hello World
</Text>
```

## SVG Icons

Skribble's hand-drawn icons can be exported as SVG files for use in any web or native application:

### Exporting Icons

Use the `skribble_font_roughen` CLI to generate SVG files:

```bash
# Generate roughened SVGs for Material icons
dart run skribble_font_roughen --input material_icons --output ./svg_output
```

### Using SVGs in HTML

```html
<img src="icons/home.svg" alt="Home" width="24" height="24">

<!-- Or inline SVG -->
<svg width="24" height="24" viewBox="0 0 24 24">
  <path d="M12 2L2 22h20L12 2z" stroke="#1A2B3C" fill="none" stroke-width="2"/>
</svg>
```

### Using SVGs in React

```jsx
import React from 'react';

const SkribbleIcon = ({ name, size = 24, color = '#1A2B3C' }) => {
  // Load SVG path data from your icon library
  const pathData = require(`./icons/${name}.svg`);
  
  return (
    <svg width={size} height={size} viewBox="0 0 24 24">
      <path d={pathData} stroke={color} fill="none" strokeWidth="2"/>
    </svg>
  );
};

// Usage
<SkribbleIcon name="home" size={32} color="#333" />
```

## Design Principles

When applying Skribble's hand-drawn aesthetic to other platforms, follow these principles:

### 1. Roughness

- **Low roughness (0.5-1.0):** Subtle hand-drawn feel, professional look
- **Medium roughness (1.0-1.5):** Noticeable sketchy quality, playful
- **High roughness (1.5-2.0):** Very sketchy, artistic, child-like

### 2. Stroke Width

- **Thin (1-2px):** Delicate, refined hand-drawn look
- **Medium (2-3px):** Standard hand-drawn appearance
- **Thick (3-4px):** Bold, marker-like feel

### 3. Colors

Skribble uses a simple palette:
- **Border color:** The primary color for outlines and strokes
- **Fill color:** Background color for shapes
- **Text color:** Color for text content

### 4. Imperfection

The key to hand-drawn aesthetics is controlled imperfection:
- Lines aren't perfectly straight
- Circles aren't perfectly round
- Corners aren't perfectly square
- But the overall shape is still recognizable

## Generating Custom Roughened Fonts

Use the `skribble_font_roughen` CLI to create hand-drawn versions of any font:

```bash
# Basic usage
dart run skribble_font_roughen input.ttf output.ttf

# With custom jitter amount
dart run skribble_font_roughen input.ttf output.ttf --jitter 15

# With specific variant
dart run skribble_font_roughen input.ttf output.ttf --variant bold
```

### Supported Variants

- `regular` - Normal weight, upright style
- `bold` - Bold weight, upright style
- `italic` - Normal weight, italic style
- `boldItalic` - Bold weight, italic style

### Jitter Amounts

- **5-8:** Very subtle, almost imperceptible
- **8-12:** Standard hand-drawn feel
- **12-15:** Noticeable sketchy quality
- **15-20:** Very sketchy, artistic
- **20-25:** Extreme, experimental

## Icon Generation Pipeline

To generate hand-drawn versions of custom icons:

1. **Prepare SVG icons** in a standard format (24x24 viewBox)
2. **Run the rough engine** to apply hand-drawn effects
3. **Export as SVG** for web use or **generate TTF** for font-based icons

```bash
# Generate roughened icons
dart run skribble_font_roughen \
  --input ./icons \
  --output ./rough_icons \
  --format svg
```

## Future Directions

### React Native Package

A React Native package for Skribble is planned:
- `skribble-react-native` - Native bridge to Skribble's rough engine
- Pre-computed icons for React Native
- Hand-drawn font support

### SwiftUI Package

A SwiftUI package for Skribble is planned:
- `SkribbleUI` - SwiftUI views with hand-drawn aesthetics
- Custom shapes and paths
- Integration with SF Symbols

### Jetpack Compose Package

A Jetpack Compose package for Skribble is planned:
- `skribble-compose` - Compose components with hand-drawn aesthetics
- Custom painters and shapes
- Material Design integration

### Web Component Library

A web component library is planned:
- `<skribble-button>` - Hand-drawn button
- `<skribble-card>` - Hand-drawn card
- `<skribble-input>` - Hand-drawn input
- Custom elements for any framework

## Contributing

If you're interested in helping build Skribble for other platforms:

1. Check the [GitHub repository](https://github.com/openbudgetfun/skribble) for issues
2. Join the discussion in the `#skribble` channel
3. Submit a PR with your implementation

## License

All Skribble assets (fonts, icons, emoji) are available under the MIT license, same as the Flutter package.
