# Skribble Noto generator

Builds the Skribble Noto typefaces: every [Google Noto](https://fonts.google.com/noto) script redrawn with a round pen, at three levels of hand-drawn character.

| Level  | Family                 | Package                     | What changes                                                                    |
| ------ | ---------------------- | --------------------------- | ------------------------------------------------------------------------------- |
| Soft   | `Skribble Noto`        | `skribble_font_noto`        | Round pen, gentle wobble. The default.                                          |
| Sketch | `Skribble Noto Sketch` | `skribble_font_noto_sketch` | Stronger wobble, slight bounce, three alternating drawings of each a–z and A–Z. |
| Lively | `Skribble Noto Lively` | `skribble_font_noto_lively` | Wider pen, strongest wobble and bounce, roomier spacing.                        |

The pub packages ship Latin, Greek and Cyrillic (the `Noto Sans` file). Every other script is a separate file per level in the Skribble Noto kit, attached to each GitHub release by `scripts/release/publish_noto_kit.sh`. [`KIT.md`](KIT.md) is the README that ships inside the kit.

## How a glyph is redrawn

1. **Instance.** The variable Noto source is pinned at one weight (`wght` 480 for Latin, 450 elsewhere) with fontTools' [instancer](https://fonttools.readthedocs.io/en/latest/varLib/instancer.html), unhinted, keeping every glyph and layout table.
2. **Open.** A morphological opening ([pyclipper](https://github.com/fonttools/pyclipper) offsets) rounds every corner and terminal.
3. **Re-stroke.** The glyph is rasterised, reduced to its medial skeleton ([scikit-image `skeletonize`](https://scikit-image.org/docs/stable/api/skimage.morphology.html#skimage.morphology.skeletonize)), pruned of short spurs, and redrawn with a round pen of one constant width: the monoline marker look of [Short Stack](https://fonts.google.com/specimen/Short+Stack), on Noto's proportions. Dots, small marks, and solid blobs such as bullets (any hole-free piece at least as round as a square) keep their rounded Noto shape. The pen width scales with each script's own stem width, so dense scripts are not clogged.
4. **Wobble.** A smooth field of plane waves, seeded by a SHA-256 hash of the glyph name and drawing variant, nudges every point. Sketch and Lively also rotate and lift each glyph slightly. Outside Latin and CJK, the wobble fades to zero near the sidebearings, so joining scripts such as Arabic, Syriac, N'Ko and Mongolian still connect.
5. **Fit.** Each contour is fitted with a periodic quadratic B-spline (all off-curve TrueType points), so curves stay smooth and files stay small.
6. **Layout.** Character maps, GSUB and GPOS are kept. For Latin, Greek and Cyrillic the build rescales kerning and mark anchors to the new spacing. Sketch and Lively also add two more drawings of each basic Latin letter (a–z, A–Z, and the single-storey `ɑ`), cycled by a `calt` lookup, and every level maps a single-storey `a` under `ss01`.

## Run it

```bash
python3 -m pip install -r tool/skribble_noto/requirements.txt

# Noto sources: Google Fonts' ofl/noto* folders (sparse checkout, about 120 MB).
git clone --filter=blob:none --no-checkout https://github.com/google/fonts gf
git -C gf sparse-checkout set --no-cone '/ofl/noto*/*.ttf' '/ofl/noto*/OFL.txt' '/ofl/noto*/METADATA.pb'
git -C gf checkout 47d54ca1ebb14fd864695f1d39dc734f39017c33

# Latin, Greek and Cyrillic only (about a minute), then copy into the packages.
python3 tool/skribble_noto/build.py gf/ofl build/noto --only notosans
cp build/noto/soft/SkribbleNoto-Regular.ttf packages/skribble_font_noto/assets/fonts/
cp build/noto/sketch/SkribbleNotoSketch-Regular.ttf packages/skribble_font_noto_sketch/assets/fonts/
cp build/noto/lively/SkribbleNotoLively-Regular.ttf packages/skribble_font_noto_lively/assets/fonts/

# Every script at every level (about 6 hours on 4 cores;
# resumable, skips finished files).
python3 tool/skribble_noto/build.py gf/ofl build/noto
./scripts/release/publish_noto_kit.sh build/noto v<version> --dry-run
```

`--only` takes family keys from [`families.json`](families.json); `--levels` takes `soft,sketch,lively`. Re-stroked outlines are cached in `<out>/.cache`, so Soft and Sketch share one re-stroke and Lively widens it with an offset. The cache is keyed only by family and pen width, and finished fonts are skipped, so after changing a source, a pen or any re-stroke parameter, delete `<out>/.cache` and the affected outputs (or use a fresh `<out>`).

`families.json` lists all 169 families: one per script, preferring Noto Sans, falling back to Noto Serif where a script has no sans, and including Noto's other single-purpose families (Music, Znamenny Musical Notation, Symbols, Math). UI, display, mono, looped, unjoined and serif duplicates of a covered script are left out. CJK and other very dense scripts (`cjk` and `dense` categories) use a finer raster and a lighter wobble so their strokes stay legible.

## Check coverage

`coverage.py` compares every character in the Noto sources with a built level and lists what the kit leaves out, by script and by source family:

```bash
python3 tool/skribble_noto/coverage.py gf/ofl build/noto/sketch
```

At the pinned sources the only gaps are 26 Han ideographs added in Unicode 13 and 14 (U+4DB6–4DBF, U+9FF0–9FFF) that only Noto Serif SC and HK draw, 13 private-use Nüshu code points, and five single characters from Noto Sans Mono, Noto Naskh Arabic (U+20C1), Noto Sans Syriac Western and Noto Serif Khojki.

## Determinism

The same sources, `requirements.txt` versions and generator rebuild byte-identical fonts. Randomness comes only from SHA-256 seeds, and `head.created` and `head.modified` are pinned to the source's values.

## Licence and naming

Noto is licensed under the [SIL Open Font License 1.1](https://openfontlicense.org), which allows modified versions to be redistributed under the same licence and declares no Reserved Font Name. Each output keeps the Noto copyright, adds a skribble modification notice, and sets the vendor ID to `SKRB`. "Noto" is a trademark of Google LLC; the family name says the faces are derived from it.

Sources: [google/fonts](https://github.com/google/fonts), [notofonts](https://github.com/notofonts), [Noto on Google Fonts](https://fonts.google.com/noto), [OFL FAQ](https://openfontlicense.org/ofl-faq/).
