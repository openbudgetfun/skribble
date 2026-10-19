# skribble_site

The skribble.dev landing page. It is a [Jaspr](https://jaspr.site) app that renders to static HTML, drawn with [`skribble_jaspr`](../../packages/skribble_jaspr) and the pure-Dart rough engine [`skribble_rough`](../../packages/skribble_rough). Every line on the page is a seeded SVG path generated at build time, so it ships no client framework and the same build always produces the same markup.

## Build and preview

From the repository root, inside `devenv shell`:

```bash
site:serve                          # build, then serve on http://localhost:8080/
site:build                          # build into apps/skribble_site/build/web
site:build --base-path=/skribble/   # build for a sub-path
```

Without devenv, run the build script directly:

```bash
dart run apps/skribble_site/bin/build.dart \
  --output=build/web \
  --base-path=/ \
  --site-url=https://skribble.dev
```

The build writes `index.html`, `404.html`, `site.css`, `site.js`, the favicon, the font faces the page uses (from `packages/skribble_font_recursive`), and the featured emoji (from `packages/skribble_emoji/art`, with palette tokens resolved).

## How it fits together

| Path                      | What it holds                                                                          |
| ------------------------- | -------------------------------------------------------------------------------------- |
| `lib/src/page.dart`       | The document shell, header, footer, landing page, and not-found page                   |
| `lib/src/sections/`       | One file per group of page sections                                                    |
| `lib/src/ink.dart`        | `doodle()` and `penDoodle()`: seeded rough SVG that can draw itself on                 |
| `lib/src/controls.dart`   | Hand-drawn checkboxes, switches, radios, chips, fields, and sliders over native inputs |
| `lib/src/build.dart`      | Reads workspace assets and writes the static site                                      |
| `web/site.css`, `site.js` | Layout, both palettes, motion, and progressive enhancement                             |

Controls are real `<input>` elements, so they work with a keyboard, a screen reader, and without JavaScript; CSS draws their state. `site.js` adds scroll reveals, the theme toggle, copy buttons, live slider values, the phone's pen switch, and seed shuffling. All motion stops under `prefers-reduced-motion: reduce`.

## Deployment

The `Docs Pages` workflow publishes one GitHub Pages site: this page at the root, the Flutter documentation under `docs/`, and the storybook under `docs/storybook/`. It reads the base path and URL from the repository's Pages settings, so the same workflow serves `https://openbudgetfun.github.io/skribble/` and, once the custom domain is set, `https://skribble.dev/`.

GitHub Pages serves only the root `404.html`. Before this page existed the documentation lived at the root, so the not-found page first retries a missing path under `docs/`, and sends links from the old skribble.dev font shop (`/monospace`, `/downloads`, and so on) to the lettering section.

## Tests

```bash
cd apps/skribble_site && dart test
```

The suite checks the page structure and accessibility attributes, that every relative link respects the base path, that every `docs/...` link has a page in `docs/site/content`, that builds are byte-stable, and that the workspace assets resolve.
