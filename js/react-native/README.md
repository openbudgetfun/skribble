# @skribble/react-native

Hand-drawn sketches for React Native, drawn by [`@skribble/rough`](https://github.com/openbudgetfun/skribble/tree/main/js/rough) and painted with [react-native-svg](https://github.com/software-mansion/react-native-svg). The same seed draws the same ink as skribble on the web and in Flutter.

```bash
npm install @skribble/react-native react-native-svg
```

## `<Sketch>`

```jsx
import { Sketch } from "@skribble/react-native";

export function Badge() {
  return (
    <Sketch
      width={120}
      height={60}
      color="#1f1d1a"
      shape={{ type: "roundedRectangle", x: 4, y: 4, width: 112, height: 52, radius: 12 }}
      fill="#ffd43b"
      fillStyle="hachure"
      label="New"
    />
  );
}
```

- `shape`, `width`, `height`, and every [sketch option](https://github.com/openbudgetfun/skribble/tree/main/js/rough#options) work as in [`@skribble/react`](https://github.com/openbudgetfun/skribble/tree/main/js/react).
- Ink and fill default to `currentColor`. Set the `color` prop to theme them, or pass `stroke` and `fill`.
- Without a `label` the sketch is hidden from screen readers. With one it is an accessible image with that label.
- Other `react-native-svg` props (`style`, `testID`, `onPress`) pass through to the `<Svg>`.
- `useSketch(shape, options)` returns the drawing if you want to paint the paths yourself.

## License

MIT
