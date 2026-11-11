---
skribble: minor
skribble_jaspr: minor
---

# Vivid colourways and lively motion by default

skribble now looks like a sticker book out of the box instead of a pencil sketch on grey paper, and the docs and agent instructions steer people and coding agents toward colour and motion rather than safe, muted designs.

**Colour.** `WiredColorway` (`sunny`, `berry`, `ocean`, `citrus`, and the calm `quiet`) and `WiredThemeData.colorway(...)` build light and dark themes from a set of vivid washes added to `WiredPalette` (`sunshine`, `tomato`, `tangerine`, `sky`, `aqua`, `mint`, `lime`, `bubblegum`, `grape`, `cobalt`, `cherry`, `cherryGlow`). Every wash keeps 4.5:1 contrast with plum ink and night text. `WiredThemeData` gains `accentColor` and `accents`, with `accentAt(index)` for colour-coding content, and `onColor`, `onMarkerColor`, `onAccentColor`, and `inkOn` for labels on a wash. `cuddly()` is the sunny colourway.

The defaults change: the marker is `sunshine` (was `lilac`), errors use `cherry`, `WiredFilledButton`, `WiredFloatingActionButton`, and `WiredBadge` fill with the accent (tomato), and selected choice and filter chips are coloured in with the marker instead of solid ink. Selected navigation, segmented, toggle, and stepper items use `onMarkerColor`. Pass `WiredThemeData.colorway(WiredColorway.quiet)` to keep the earlier lilac look. `WiredCard` takes a `color` and inks its content to match. The Material bridge maps `accentColor` to and from `ColorScheme.tertiary`.

**Motion.** `WiredEntrance` springs a child in while its ink draws on, `WiredEntrance.staggered` and `WiredCascade` bring lists and columns in one after another, `WiredBoil` gives focal drawings the wriggle of hand-drawn animation, `WiredHighlight` swipes a marker or underline behind words, and `WiredCurves` (`springy`, `snappy`, `bouncy`, `pen`) and `WiredSpringCurve` time your own animations. All of it settles at once when `WiredMotion` is off or the platform asks for reduced motion.

**Web.** `skribble_jaspr`'s stylesheet uses the sunny colours, adds `--skribble-marker`, `--skribble-on-marker`, and six `--skribble-wash-*` properties with matching `skribble-wash-1` to `skribble-wash-6` classes, and adds the `skribble-draw`, `skribble-pop`, and `skribble-lift` motion classes, all behind `prefers-reduced-motion: no-preference`. Stroked paths carry `pathLength="1"` so they can draw on.

The new [Vivid and alive](https://openbudgetfun.github.io/skribble/guides/vivid-design) guide holds the design rules, shared with `AGENTS.md` and the agents reference page.
