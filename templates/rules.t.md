<!-- Project rules shared by AGENTS.md (the rules agents load), CONTRIBUTING.md,
     the contributing and agents reference pages, and the custom-widgets
     guide. Edit a rule here, then run `mdt update`. -->

<!-- {@docsBrandCasingRules} -->

- The brand word is always lowercase **skribble** — in READMEs, docs site pages and frontmatter, and source comments. Sentence position does not change it: a heading reads `# skribble`, and a page title reads `title: skribble — Hand-Drawn Flutter Design System`.
- Keep machine-readable names as they are: identifiers (`SkribbleIcons`), bundled font families (`Skribble`, `SkribbleGentle`), asset names (`Skribble-Bold.ttf`), the Figma URL slug (`Skribble-Design-System`), and runtime strings such as app titles, page names, and semantic labels.
- The root `README.md` keeps a centered header: the logo (240px, linked to the docs site), `<h1 align="center">skribble</h1>`, a one-line tagline, centered links into the documentation, then the badges. Those links point at `https://openbudgetfun.github.io/skribble/`.

<!-- {/docsBrandCasingRules} -->

<!-- {@docsInkPaddingRule} -->

Give the ink room to breathe. Content keeps at least `kWiredInkPadding` (8 pixels above and below, 12 at the sides) from any hand-drawn line around it; buttons and chips use `kWiredButtonPadding` (16 at the sides). Heights are minimums (`BoxConstraints(minHeight: kWiredButtonHeight)`), never fixed, so controls grow with larger fonts and text scaling instead of squeezing their text against the ink. `package:skribble/testing.dart` (`crampedText`, `squeezedText`) checks this, and the storybook, docs, and example app run it on every page and example at 360, 768, and 1280 pixels and at 1.3× text.

<!-- {/docsInkPaddingRule} -->

<!-- {@docsImagesOutOfGit} -->

- **Keep image files out of Git**, including screenshots, design exports, and golden snapshots. Save them in gitignored local output directories, upload review images with `gh pr create/edit/comment --attach`, or use external file storage. Put the resulting attachment or download URL in the PR or a README. Prefer pixel assertions against in-memory renders when a visual test can express the expected behavior without a committed image.
- Before pushing, check staged additions and the branch's commits for image files. Remove newly introduced images from an unmerged branch's history before publishing the corrected branch; deleting them only in a later commit still leaves the repository bloated.

<!-- {/docsImagesOutOfGit} -->

<!-- {@docsDesignScreenshotsRule} -->

- Every pull request that changes what skribble draws or how it lays out must show the change. That covers widget appearance, the rough engine, pens and fillers, icons and emoji, fonts, theme defaults, spacing, and the storybook or docs visuals.
- Capture **before and after** screenshots from the same harness: the storybook, `melos run screenshot`, or an in-memory render. Include both light and dark themes, and narrow and wide widths when layout changes.
- Upload them to the pull request itself with the GitHub CLI's `--attach` flag, never by committing them:
  - when opening: `gh pr create --attach './before.png#Before' --attach './after.png#After'`;
  - later captures: `gh pr edit <n> --attach ...` or `gh pr comment <n> --attach ...`.
- Text after `#` is the image's alt text. A local path already referenced in the body (`![Before](./before.png)`) is replaced with the uploaded URL; anything else is appended.
- Put the images in a collapsible `<details>` section of the description, and say what the captures do not cover. Inspect every image first so it exposes no secrets or personal data.

<!-- {/docsDesignScreenshotsRule} -->

<!-- {@docsFigmaReleaseRule} -->

**Figma exports belong on the latest GitHub release, never in Git**, including renamed or archived copies. Save `.fig` files outside the checkout, publish them as `skribble-design-system.fig` on the release marked Latest, and verify the uploaded size and SHA-256 digest; `docs/design/README.md` describes the upload and verification. Link downloads through `releases/latest/download/skribble-design-system.fig`. The `design-asset-policy` CI job rejects tracked Figma exports.

<!-- {/docsFigmaReleaseRule} -->
