# Animation style guide

Skribble motion follows the pen. An outline appears along its actual rough
path, then shading scribbles into place. Buttons respond with slightly firmer
ink. Keep labels and paper still so controls remain easy to read and target.

Use `WiredDraw` for a deliberate entrance and `WiredDrawTransition` when a
screen, route, or interaction already owns an animation. Ordinary cards stay
static by default. Avoid repeated drawing loops on routine content.

The default entrance takes 650 milliseconds. Interaction emphasis takes 120
milliseconds. Use a slower entrance for a focal illustration, and Flutter
`Interval` animations for a small stagger. Do not place independent auto-playing
controllers on every item in a long list.

Set `WiredThemeData.motionEnabled` or wrap a section in `WiredMotion` to opt out.
Honor platform reduced motion. Ink motion never hides semantic content, changes
layout, or removes a button's solid background while its label remains visible.

See [the ink motion guide](site/content/core/motion.md) for controller ownership,
Flutter hooks examples, accessibility behavior, and custom painter integration.
The [design rationale](ink-motion-design.md) records alternatives and rendering
constraints. The storybook's **Ink in motion** page provides replay, reverse,
scrubbing, slow motion, and an opt-out for visual verification.
