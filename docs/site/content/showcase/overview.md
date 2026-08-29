---
title: Live Showcase
description: Preview every hand-drawn widget, icon, emoji, and font glyph live in the browser — no install required.
---

# Live Showcase

The complete Skribble storybook runs as a web build on this site. Every
widget category, all 8,600+ roughened Material icons, the curated icon set,
the 1,827 hand-drawn emoji, and the full Skribble font specimen are
interactive in your browser — no install required.

## Open the live storybook

**[▶ Open the interactive storybook](../../storybook/)**

The storybook is organized into categories:

| Section                     | Link                                               |
| --------------------------- | -------------------------------------------------- |
| Buttons                     | [Live preview →](../../storybook/#/buttons)        |
| Inputs                      | [Live preview →](../../storybook/#/inputs)         |
| Navigation                  | [Live preview →](../../storybook/#/navigation)     |
| Selection                   | [Live preview →](../../storybook/#/selection)      |
| Feedback                    | [Live preview →](../../storybook/#/feedback)       |
| Layout                      | [Live preview →](../../storybook/#/layout)         |
| Data Display                | [Live preview →](../../storybook/#/data-display)   |
| Rough Icons (8,600+)        | [Live preview →](../../storybook/#/rough-icons)    |
| Skribble Icons (curated)    | [Live preview →](../../storybook/#/skribble-icons) |
| Emoji (1,827)               | [Live preview →](../../storybook/#/emoji)          |
| Font Specimen (every glyph) | [Live preview →](../../storybook/#/font-specimen)  |

## Embed the storybook

Paste this into any page to embed the live preview:

```html
<iframe
  src="../../storybook/"
  style="width: 100%; height: 720px; border: 1px dashed #a39aad; border-radius: 8px;"
  title="Skribble Storybook">
</iframe>
```

## Try it interactively

The storybook below is the real Flutter application compiled to web — resize
the window to see the hand-drawn widgets reflow at different device sizes:

<iframe src="../../storybook/" style="width: 100%; height: 720px; border: 1px dashed #a39aad;"
  title="Skribble Storybook interactive preview"></iframe>

## Screenshot galleries

Static screenshots of every widget are captured by the integration-test
pipeline (`.screenshots/`) and uploaded to external object storage after each
release. Run `melos run screenshot` locally, then
`scripts/upload_screenshots.sh` with Backblaze B2 credentials to publish a
versioned gallery.
