---
title: Figma workflow
description: How Skribble designs travel to Figma — the published .fig file, the generated font and specimen kit, the agent workflow, and the handoff rules for reviewers.
---

# Figma workflow

Skribble hands work to Figma as real assets, not screenshots. Two different artifacts make that possible:

- **The published Figma file** — the editable design system, exported from Figma and attached to the latest GitHub release as `skribble-design-system.fig`. Its page structure is documented in [the design directory README](https://github.com/openbudgetfun/skribble/blob/main/docs/design/README.md).
- **The generated design kit** — the bundled fonts, editable SVG pen specimens, token reference, and a manifest, produced from this repository at a chosen version. [Design kit](../reference/design-kit) is the reference table; this page is the procedure around it.

Use both: the kit gives you the current fonts and the exact rough pen geometry the Flutter library renders; the `.fig` gives you the assembled pages, components, palette, brand marks, and flourishes to edit against.

## Generate the design kit

Run from the repository root, at the tag that matches the `skribble` version your design targets:

```bash
git checkout v<version>
devenv shell dart run packages/skribble/tool/design_kit.dart
```

The kit lands in `build/design-kit/` and contains:

- 36 TTF files — the Casual, Linear, and Mono families at all three roughness levels, four styles each — plus `fonts/OFL.txt`
- 18 editable SVG pen specimens — six per roughness level
- `manifest.json` listing every font, specimen, layout frame, and the motion timings
- `README.md` (a copy of the [design kit](../reference/design-kit) page), `LICENSE`, and an offline `index.html` preview

Regenerate the kit after changing fonts or the rough engine; never hand-edit its output. Generating from `main` produces assets that do not match any published version — always check out the release tag first.

## The agent design workflow

Work the steps in order. The deliverable is a handover bundle another person or agent can consume without asking questions.

### Step 1: Anchor the design in the theme

Start from the theme, never from invented values. Pick the roughness preset (Gentle, Playful, or Expressive), the type family, and the ink and paper colors from `WiredThemeData` defaults or the consuming app's overrides. Every color, stroke width, and corner radius in the design must trace back to a token in the [pen and type reference](../reference/design-kit). Keep geometry stable: one seed per drawing, fixed across states.

### Step 2: Draft the screen with Wired widgets

Build the screen in the storybook app first. The widget library is the source of truth — a Figma design is only as good as its ability to be expressed in code. Compose the layout from real `Wired` widgets and record every gap where the design needs something the library does not offer. Gaps become follow-up issues; they are findings, not failures.

### Step 3: Generate the kit from the matching tag

Run the kit command above against the release you are designing for. Note the roughness preset each screen uses — specimens come in all three levels, and the preset decides which specimen file a Figma component should import.

### Step 4: Capture rendered evidence

Screenshot the storybook screen so reviewers can compare the Flutter render against the Figma rebuild:

```bash
melos run screenshot
```

Screenshots land in `.screenshots/<category>/<screen>.png` and are gitignored — bundle them, do not commit them. Check the rendered glyphs and the settled first frame before bundling, per the [screenshot guidance](screenshots).

### Step 5: Assemble the handover bundle

Collect everything a Figma user needs into one directory under `build/designs/<name>/`:

```
build/designs/checkout-flow/
├── manifest.json
├── README.md
├── fonts/            # copied from build/design-kit/fonts
├── svg/              # kit specimens plus per-screen exports
└── screenshots/      # rendered storybook evidence
```

Write the manifest so the bundle is self-describing:

```json
{
  "name": "checkout-flow",
  "skribbleVersion": "<release-version>",
  "sourceFiles": ["apps/skribble_storybook/lib/pages/checkout_page.dart"],
  "screens": [
    {
      "title": "Checkout",
      "svg": "svg/checkout.svg",
      "capture": "screenshots/checkout.png",
      "width": 390,
      "height": 844
    }
  ],
  "widgetsUsed": ["WiredAppBar", "WiredButton", "WiredInput"],
  "gaps": ["No WiredBadge — tracked in #<issue>"]
}
```

Keep this shape so bundles stay predictable across agents. Copy the kit's `README.md` (the design kit guide) into the bundle so the token tables travel with the assets. Share the whole directory as a zip when the recipient is outside the repository.

### Step 6: Load the results into Figma

1. Install the fonts locally for editing, and upload the four styles of each used family to your Figma account so remote runtimes (Figma MCP and agent access) can see them. The family table and upload steps are in the [design kit fonts section](../reference/design-kit#fonts-for-figma).
2. Import specimen SVGs from `svg/`. Each file carries an editable `ink` group and an invisible `layout-bounds` rectangle; size the frame from the root SVG dimensions, and never shrink a hit region to the visible stroke.
3. Add labels as live text using the installed Skribble styles — do not outline text and do not simulate bold or italic.
4. Create the variables and text styles from the token table below, then build components from the specimens.

### Step 7: Point at the results

Close the loop by stating where everything lives. A results pointer names the bundle, the kit it came from, and the preview to open, for example: "Checkout flow design: `build/designs/checkout-flow/` (manifest lists sources and gaps), rendered evidence in `screenshots/checkout.png`, tokens in the bundled design kit README. Generated from skribble `<version>`." Paste the pointer into the pull request, issue, or handoff note so the next person starts from files, not from memory.

## Tokens as Figma variables

Mirror the theme in Figma so both sides stay in sync:

| Skribble token                    | Figma home                                                                               |
| --------------------------------- | ---------------------------------------------------------------------------------------- |
| Ink outline `#1A2B3C`             | Color variable `ink/outline`                                                             |
| Paper fill `#FEFEFE`              | Color variable `ink/paper`                                                               |
| Text black                        | Color variable `ink/text`                                                                |
| Pen width 2.4 px                  | Number variable `ink/pen` (bind to stroke weights)                                       |
| Reserved bleed 3.7 / 4.6 / 5.8 px | Number variables `ink/bleed-gentle` / `-playful` / `-expressive`                         |
| Roughness preset                  | String variable `ink/roughness`; it selects which specimen set a component imports       |
| Typeface families and styles      | Text styles named `Skribble/Regular`, `Skribble-Bold`, and so on for every loaded family |

Do not translate roughness into Figma effects — there is no roughen filter that matches the pen engine. Roughness lives in the imported specimen geometry; the variable only records which preset a component uses. The published `.fig` carries the assembled version of these tokens on its `🎨 Foundations` page.

## Motion in a static file

The motion contract survives export as static references: the resting specimen shows the completed ink, the pressed specimen shows the 120 ms pressure response at its stronger pen width, and reduced-motion designs reuse the resting specimen unchanged. Keep label position, layout, and hit regions fixed across states, and do not add scale, bounce, or fresh randomness in prototypes. The full table is in the [design kit motion section](../reference/design-kit#motion-and-reduced-motion).

## Back from Figma to code

When a Figma file comes back for implementation, check parity before writing widgets:

- Every frame maps to real `Wired` widgets; anything unmappable is a recorded gap, not a custom one-off.
- Colors, stroke widths, and roughness come from the theme — hardcoded values from the Figma file are translated into `WiredThemeData` overrides, never literals.
- Hit regions match the layout frames, including the 48 px button target; visible ink is not the touch target.
- Clear space respects the preset bleed (3.7 / 4.6 / 5.8 px per edge).
- Selected and focus treatments stay distinguishable with motion disabled.
- Text uses the real Skribble styles loaded from the kit, so line heights and fallbacks match the Flutter render.

## Where released assets live

The editable Figma file is published as `skribble-design-system.fig` on the latest GitHub release; download it at `releases/latest/download/skribble-design-system.fig`. Each main-group release also attaches per-family font zips. Match the `skribble` version you implement against to the release you designed from — fonts and geometry evolve together with the code. [Releasing](../reference/releasing) documents the publish step and its rules.
