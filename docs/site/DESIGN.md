---
name: Skribble documentation
description: Warm paper, playful ink, and working hand-drawn Flutter components.
colors:
  paper: "#fffaf0"
  ink: "#34283f"
  quiet-ink: "#796c7a"
  link-ink: "#714265"
  coral: "#e87960"
  selected-paper: "#f6dfd5"
  code-paper: "#eee9f0"
  inline-code-paper: "#eee7f0"
  quote-paper: "#eef1df"
  syntax-keyword: "#784175"
  syntax-string: "#35634b"
  syntax-number: "#9c482b"
  syntax-comment: "#716275"
  syntax-type: "#315c83"
typography:
  headline:
    fontFamily: SkribblePlayful
    fontSize: "42px"
    fontWeight: 700
    lineHeight: 1.25
  section:
    fontFamily: SkribblePlayful
    fontSize: "29px"
    fontWeight: 700
    lineHeight: 1.25
  subsection:
    fontFamily: SkribblePlayful
    fontSize: "23px"
    fontWeight: 700
    lineHeight: 1.25
  body:
    fontFamily: SkribblePlayful
    fontSize: "16px"
    lineHeight: 1.65
  navigation:
    fontFamily: SkribblePlayful
    fontSize: "13px"
  label:
    fontFamily: SkribblePlayful
    fontSize: "12px"
  code:
    fontFamily: SkribblePlayful
    fontSize: "14px"
    lineHeight: 1.7
rounded:
  code: "8px"
spacing:
  small: "8px"
  control-gap: "12px"
  paragraph: "16px"
  inset: "20px"
  roomy: "24px"
  section: "32px"
components:
  button-filled:
    backgroundColor: "{colors.coral}"
    textColor: "{colors.ink}"
  button-outline:
    textColor: "{colors.ink}"
  button-text:
    textColor: "{colors.ink}"
  search:
    textColor: "{colors.ink}"
    padding: "14px 12px"
  navigation-selected:
    backgroundColor: "{colors.selected-paper}"
    textColor: "{colors.ink}"
    typography: "{typography.navigation}"
  code-block:
    backgroundColor: "{colors.code-paper}"
    typography: "{typography.code}"
    rounded: "{rounded.code}"
    padding: "18px"
  quotation:
    backgroundColor: "{colors.quote-paper}"
    padding: "{spacing.inset}"
---

# Design System: Skribble documentation

## Overview

**Creative North Star: "A little ink. A lot of possibility."**

The documentation is a working expression of the Wired identity: warm paper, hand-lettered plum text, rough outlines, restrained marker overlap, and coloured hatching. Playful is the default. The toolbar offers Gentle, Playful, and Expressive, changing inherited lettering and rough geometry throughout the site.

Reading space stays calm around the interactive ink. Examples use real Wired controls, and decorative movement leaves text and layout available. The binding product constraints are readable, selectable documentation on phones and desktops, keyboard navigation, accessible controls, and reduced-motion support; see [PRODUCT.md](PRODUCT.md).

**Key Characteristics:**

- Warm paper and dark plum ink.
- Playful lettering and seed-stable rough geometry.
- Colour and hatching on working examples.
- Open reading space with compact navigation.
- Ink motion that preserves content and state.

This file records the implemented documentation system. Values in frontmatter describe the default preset; logical Flutter pixels are expressed as pixels for portable tooling. Sources are `lib/src/app.dart`, `lib/src/article.dart`, `lib/src/docs_surface.dart`, `lib/src/code_view.dart`, `lib/src/font_comparison.dart`, `lib/src/examples/example.dart`, and the library's Wired implementations. The sidecar's HTML previews illustrate Flutter components; they do not replace the library's seeded painters. Its synthesized tonal ramps are panel visualizations, not additional application colour tokens.

## Colors

Warm neutral surfaces carry plum text, with coral marking the working filled action and softer colour fields separating reading contexts.

### Primary

- **Plum ink** (`ink`) carries body text, navigation, and the standard rough outline.
- **Link ink** (`link-ink`) accompanies underlining in article links.

### Secondary

- **Coral marker** (`coral`) fills the live action while retaining plum foreground text.

### Neutral

- **Warm paper** (`paper`) is the documentation canvas.
- **Quiet ink** (`quiet-ink`) identifies secondary copy, navigation groups, breadcrumbs, and the search hint.
- **Selected paper** (`selected-paper`) identifies the current navigation item.
- **Code paper** and **inline code paper** distinguish source text from surrounding prose.
- **Quote paper** separates block quotations through a pale green field.

The golden note and moss motion card are local example themes, not mandatory colours for every card. Their scoped overrides demonstrate the library's theme model.

Syntax colours distinguish keywords and literals in purple, strings in green, numbers in rust, comments in muted plum, and types and titles in blue. Unclassified source retains the surrounding ink colour.

**The Opaque Label Rule.** Filled actions keep an opaque backing under their text throughout decorative redraw.

## Typography

SkribblePlayful is the bundled default, derived from Recursive Casual with warped outlines. Headings, body, navigation, and code inherit the selected preset's handwriting. Gentle uses SkribbleGentle and Expressive uses Skribble. Emphasis comes from weight, scale, and spacing; syntax colouring does not introduce a separate monospace family.

The frontmatter records the recurring article hierarchy. Lower heading levels continue at 20 and 18 logical pixels. Heading line height is compact; paragraph line height is more open. Selection separators are supplied by the selection delegate, not extra blank lines in rendered text.

The introductory display is a surface-specific expression: 52 logical pixels on larger screens and 36 below the narrow breakpoint, weight 800, line height 1.12. It does not set the heading size for every documentation page.

## Layout

A fixed-height header and a centred, wrapping roughness toolbar sit above the scrollable content. At 1050 logical pixels, navigation becomes a persistent left column, 254 pixels wide; below that, the Explore action opens navigation in the content area. At 1440 pixels, articles with section headings gain a 218-pixel right table of contents.

The reading column is constrained to 820 pixels. Horizontal document padding is 46 pixels with persistent navigation and 22 otherwise; top padding is 32 and bottom padding is 70. The header is 82 pixels tall. These are observed shell dimensions, not universal component sizes.

Paragraphs end with the paragraph spacing token. Subsequent headings receive section spacing above and 14 pixels below. Lists retain visible item spacing; tables and code can scroll horizontally without widening the article. Keep the current article mounted so ordinary selection can cross viewport boundaries.

**The Reading Space Rule.** Preserve reading width, selectable text, and visible focus when adapting the shell to another viewport.

## Elevation & Depth

The documentation uses flat paper fields, coloured hatching, and rough outlines. Cards have transparent underlying Material surfaces and shadows; code blocks and quotations use tonal separation. Do not introduce a shadow scale from the theme's compatibility colour scheme: it is not the site's depth vocabulary.

## Shapes

Wired geometry supplies softly bowed, uneven rectangular edges. The default stroke is 2.4 logical pixels. Playful uses roughness 1.5, maximum randomness offset 1.6, and line wobble 0.65. Gentle uses 1.25, 1.2, and 0 respectively; Expressive uses 1.8, 2, and 1. Reuse the library painter so lettering and edges respond together to the toolbar.

Solid fills retain slight seeded marker overlap. The user approved this restraint: preserve the pixel-sized irregularity without restoring the long-edge spline bulge. Selected, hovered, and focused documentation actions, code panels, and quotations share a rough rounded rectangle with an 8-pixel radius. That radius is not a global card or button radius.

## Components

### Buttons

Filled, outlined, and text actions are real Wired controls. The live filled action uses coral with plum text; outlined actions use the theme's rough border; text actions keep their lighter footprint. Inherit the library's control sizing and interaction states rather than inventing a second documentation button system.

Pressure is the theme's default interaction. The live save action explicitly uses redraw. Keyboard focus remains visible. Disabled states and activation semantics belong to the Wired implementation.

### Cards / Containers

WiredCard uses a rough rectangle with optional hachure fill. The interactive note takes its height from content and has a 22-pixel content inset. Fixed-height cards also exist in the library and the motion example; do not turn the note's sizing into a universal card rule.

### Inputs / Fields

Search uses one rough rectangle and the search padding token. Its quiet-ink hint has an explicit colour override. Focus adds 0.6 logical pixels to the existing stroke; it does not add a second rounded border. Provide a semantic label independently of the placeholder.

### Navigation

Navigation groups and secondary labels use quiet ink; page links use the navigation text role. Selected items receive selected-paper and selected semantics. Brand and table-of-contents links have keyboard activation, link semantics, and a rough two-pixel focus outline. Narrow layouts expose Explore and Close menu actions.

Sidebar page links, copy actions, and toolbar choices use DocsAction without a permanent underline. Each has a minimum height of 44 pixels and 9-pixel vertical, 12-pixel horizontal padding. Hover adds code-paper; selection takes precedence with selected-paper. Keyboard focus adds a 1.5-pixel plum rough outline. Keep article-link underlining distinct from these quiet controls.

### Articles and source panels

Article links are underlined. Code panels pair a separate Copy code action with horizontally scrollable, syntax-coloured source. Supported fences include Dart, Bash, CSS, JavaScript, JSON, Swift, XML, and YAML; unknown languages retain plain readable text. Copy exact source; exclude the action label from selection. Copy page supplements ordinary selection. Heading semantics track Markdown levels.

### Live examples

Compiled Flutter widgets appear above their typed parameter controls and matching source. Previews have a minimum height of 120 pixels with 20-pixel horizontal and 24-pixel vertical padding. Controls wrap with 16-pixel spacing and 12-pixel run spacing. Show only parameters used by the example, using Wired inputs or quiet choices. Valid edits update both the preview and copyable source; invalid numeric or colour input shows a nearby error and retains the last valid preview.

### Font comparison

Pair Sans Casual and Sans Linear at equal size, weight, and style in Original, Gentle, Playful, and Expressive rows. A labelled multiline WiredTextArea accepts two to four visible lines; changes update every specimen. Size choices are 14, 16, 24, 48, and 72 pixels, with 24 selected initially. Bold and Italic apply across the comparison. Pairs stack below 560 pixels of available width. Specimens retain their explicit families when the toolbar changes the surrounding site.

### Ink replay

WiredDraw draws over 650 milliseconds with Flutter's easeInOutCubic. Button pressure uses 120 milliseconds; redraw uses 360 milliseconds with easeOutCubic. Anchor scrolling uses 220 milliseconds. Platform reduced motion overrides decoration; the motion example also offers an explicit opt-out. Replay retains the note's checkbox and saved states.

**The Content Stays Rule.** Re-inking must not reset local choices, remove readable content, or change layout.

## Do's and Don'ts

### Do:

- **Do** use the selected preset's bundled lettering and Wired painters together, starting with Playful.
- **Do** retain slight marker overlap and coloured hatching where the component uses them.
- **Do** keep filled action text backed by opaque colour during redraw.
- **Do** preserve ordinary selection, accessible labels, keyboard focus, and reduced-motion behavior.
- **Do** scope example palettes through the local Wired theme.

### Don't:

- **Don't** replace the Wired identity with generic rounded controls or an invented shadow scale.
- **Don't** treat a home example's composition or palette as mandatory for all documentation pages.
- **Don't** create extra rendered blank lines to separate copied paragraphs.
- **Don't** reset interactive choices when replaying decorative ink.
