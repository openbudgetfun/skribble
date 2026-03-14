# Skribble UI Snapshots

Visual reference for all hand-drawn Flutter components in the Skribble design system.

Each category page documents the screenshot artifacts produced by the integration screenshot flow.

## Categories

- [Buttons](./buttons.md) - `buttons/buttons` + widget snapshots
- [Inputs](./inputs.md) - `inputs/inputs` + widget snapshots
- [Navigation](./navigation.md) - `navigation/navigation` + widget snapshots
- [Selection](./selection.md) - `selection/selection` + widget snapshots
- [Feedback](./feedback.md) - `feedback/feedback` + widget snapshots
- [Layout](./layout.md) - `layout/layout` + widget snapshots
- [Data Display](./data-display.md) - `data-display/data-display` + widget snapshots
- [Rough Icons](./rough-icons.md) - `rough-icons/rough-icons` generated icon catalog snapshot

## Screenshot Hosting

Screenshots are captured via integration tests and uploaded to Backblaze B2 storage. The base URL for all images is:

```
https://f005.backblazeb2.com/file/skribble-screenshots/
```

Example snapshot:

![Home Snapshot](https://f005.backblazeb2.com/file/skribble-screenshots/home/home.png)

## Expected Artifact Set

Canonical expected screenshots are defined in:

- `docs/ui-snapshots/screenshot-manifest.txt`

The manifest includes page-level and widget-level captures and is enforced in CI.

## Regenerating Screenshots

To capture screenshots locally:

```bash
melos run screenshot
```

This runs the integration tests that navigate through each storybook page and capture deterministic snapshots.
