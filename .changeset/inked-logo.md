---
skribble: minor
---

# The logo is the inked brackets

`WiredLogo` keeps the smile in square brackets and gives it colour: a fineliner inks the outlines over a marker-filled face with rosy cheeks. The ink follows the theme's text colour and the face its marker colour, so the mark reads on day and night paper, and it now draws itself in under `WiredDrawTransition`.

- `WiredLogo.faceColor` (default: the theme's marker colour) and `WiredLogo.cheekColor` (default: the new `WiredPalette.blush`) set the fills. Make both transparent for a single-colour mark.
- The outlines are bolder, so the `mark` loader style's pen grew to match and still hands over to `WiredLogo` without the mark jumping.
- The brand SVGs in `assets/brand`, the docs and storybook favicons, and the storybook's web app icons are regenerated from the same paths.
