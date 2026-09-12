# Casual and coding font experiments

This is a reviewable type-design experiment. It produces installable TTF files and a portable side-by-side specimen without changing package assets, theme defaults, or release packaging.

## The two families

`SkribblePetal` starts with Recursive Sans Casual. It uses the source's single-storey `a` and `g`, a newly drawn looped `l`, and restrained contour waves and baseline movement. It adds five standard text ligatures, `fi fl ff ffi ffl`, plus optional decorative `ct st tt` joins. All three groups have actual outlines and OpenType substitutions.

The optional `swsh` feature currently adds curls to `a e h k m n r t u`. This first pass retains the source's 745 mapped codepoints, but does not hand-design a flourish for every character. Other glyphs receive the general outline treatment. Accented letters retain their source coverage; combining-mark placement, accented swashes, pair kerning for new drawings, and repeated-letter alternates need further design work. Display swashes increase the advances of the affected letters and are best judged at heading sizes.

`SkribbleCode` starts with the dedicated Recursive Code Casual release. Its outlines use strength 22 in the existing roughener. The entire character map, advances, substitution tables, and fixed-pitch metadata remain byte-identical to the Code source. Its programming ligatures use `calt`, which editors can enable without requesting discretionary desktop features. The existing shipped Mono family uses the Linear desktop source, so part of the visible change comes from selecting Casual.

Both experiments have Regular, Bold, Italic, and Bold Italic files with proper family names. The prototype Casual compiler uses FontForge; the Code compiler uses the existing Dart TrueType writer. Both remove obsolete source hinting, which also affects small-size rendering. The fonts carry Recursive's SIL OFL notice.

## Build and compare

Run in the task's separate worktree, from repository root:

```bash
devenv shell install:dart
devenv shell dart run tool/casual_font_experiment.dart
devenv shell dart run tool/font_exploration_specimen.dart --serve
```

Open `http://127.0.0.1:8765`. Type a sample, select a real weight/style, and toggle ligatures or swashes. The original, current Expressive, and experimental columns share text and sizes. The current Mono comparison explicitly enables `dlig` so it can show its existing operators too.

Outputs live in `.screenshots/font-exploration/`. `comparison.html` embeds every compared face and can be opened offline. `SkribblePetal-*.ttf` and `SkribbleCode-*.ttf` are the new font files. Copy `OFL.txt` with any distributed font. SFD and feature files in this directory expose the intermediate drawings and lookup rules for review. The directory is gitignored; rerun the commands to regenerate it. FontForge stamps modification times, so Casual binary output is not promised to be byte-reproducible across runs or compiler versions.

## Verify the actual fonts

The devenv shell includes HarfBuzz's `hb-shape` command. An explicit executable path can also be supplied:

```bash
devenv shell dart run packages/skribble_font_roughen/bin/verify_exploration.dart
devenv shell dart analyze --fatal-infos .
```

The verifier checks all four styles. It checks font checksums, original Casual codepoint coverage, Code table preservation and fixed-pitch metadata, all 95 printable ASCII cells, 11 programming sequences, eight text ligatures, and nine swash substitutions. Every tested Code operator keeps one 600-unit advance per input character. It writes a machine-readable `verification.json` beside the specimens. These checks exercise real HarfBuzz shaping, including the italic lookup ordering that initially allowed inherited `fi`/`ffi` to override the new drawings.

The CI font job rebuilds and verifies both families, then uploads the eight TTFs, license, comparison and verification report as its `font-exploration` artifact.

Browser review covers paragraph text, alphabet and punctuation, code columns, ambiguous characters, feature toggles, all four styles, and narrow layouts. It does not verify selection, cursor behavior, rendering or font installation in every editor. The Casual prototype also needs a broader typography review before replacing shipped assets.

## Try the coding font in an editor

Install the four `SkribbleCode` TTFs with your operating system's font manager. In VS Code:

```json
{
  "editor.fontFamily": "'SkribbleCode', monospace",
  "editor.fontLigatures": true
}
```

Restart the editor if its font cache does not refresh. Fonts do not change the underlying source text: operator sequences remain ordinary text. Terminal ligature configuration is separate from editor configuration. See the [source audit and editor references](casual-font-ligatures.md#editor-activation-and-implementation-choice).

In Flutter, declare the four faces in your app's font manifest and select `fontFamily: 'SkribbleCode'` with `FontFeature.contextualAlternates()`. For Petal, use `FontFeature.enable('liga')` and optionally `FontFeature.enable('dlig')` or `FontFeature.swash()`. These experimental families are not registered in the published Skribble package yet.
