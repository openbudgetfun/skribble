# Figma coverage

The editable pages use the same `Wired` names as the Flutter package. Each page keeps the source component set beside a small set of readable examples, while the generated assets in `assets/` provide the hand-drawn vector source.

| Figma page            | Code surface                                                                                                     |
| --------------------- | ---------------------------------------------------------------------------------------------------------------- |
| Foundations           | `WiredThemeData`, `WiredPalette`, `WiredRoughness`                                                               |
| Brand                 | `WiredLogo` and light, dark, lilac, and transparent exports                                                      |
| Flourishes            | The original seven `WiredDoodleKind` values                                                                      |
| More Flourishes       | Cloud, sun, moon, rainbow, comet, balloon, mushroom, cupcake, bird, sprout, wave, and confetti; three seeds each |
| WiredButton           | `WiredButton` roughness and interaction states                                                                   |
| Fields                | `WiredInput` states and password treatment                                                                       |
| Selection             | Checkbox, radio, switch, chip, choice, filter, input, and action chip                                            |
| Actions               | Filled, outlined, elevated, text, icon, and floating action buttons                                              |
| Surfaces              | Cards, avatars, list tiles, dividers, and selection list tiles                                                   |
| Navigation            | App bars, tabs, navigation bars, rail, drawers, scaffold, and bottom app bar                                     |
| Feedback              | Dialog, snack bar, tooltip, sheet, banner, progress, and loading                                                 |
| More inputs           | Text area, search, combo, dropdown, autocomplete, sliders, segmented, and toggle controls                        |
| Menus and collections | Menus, tables, expansion panels, and stepper                                                                     |
| Pickers               | Calendar, date, range, time, and color pickers                                                                   |

The generated Figma components use `Kind=<name>, Seed=<integer>` properties so a designer can choose a stable variation and then detach or edit the vector when a one-off flourish is needed. The implementation remains the source of truth for geometry; regenerate the SVGs with:

```sh
devenv shell dart run packages/skribble/tool/export_design_assets.dart
```
