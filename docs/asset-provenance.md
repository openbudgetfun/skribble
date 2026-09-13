# Asset provenance and determinism

Every visual asset in this repository — icon catalogs, emoji, and the bundled
typefaces — is generated from a source pinned by exact version and checksum.
Nothing is hand-edited, and nothing regenerates differently twice.

The registry lives in [`tool/asset_sources.txt`](../../tool/asset_sources.txt).
Each package's README repeats the rows relevant to it.

## Why this matters

Two failure modes are easy to fall into with generated artwork:

1. **Silent upstream drift.** An icon set publishes a new version, someone
   regenerates, and half the catalog changes shape in a commit that only says
   "regenerate". Pinning by checksum makes that impossible: an upstream bump is
   a deliberate edit to the registry in the same commit as the regenerated
   catalog, so review sees both together.
2. **Generator wobble.** Hand-drawn styling sounds like it needs randomness. If
   it did, every regeneration would shimmer and no two builds would agree, which
   would make review useless. It does not: see below.

## Determinism

**Yes — regeneration is byte-for-byte reproducible.** Given the same source
bytes and the same generator code, the output is identical. This is enforced,
not aspirational: CI re-derives every catalog and fails on any diff.

There is no `Random`, no clock, and no map-iteration-order dependence anywhere
in the generation pipeline. Each stage derives its "wobble" from a pure function
of stable inputs:

| Stage | Where the variation comes from | Why it is stable |
| --- | --- | --- |
| Icon and emoji outlines | `SvgTransform.path()` in `skribble_emoji_gen` | A fixed sum of `sin()` terms evaluated at each coordinate. Same coordinate in, same displacement out. |
| Font glyphs | `JitterAlgorithm.jitterValue(seed, index)` | An integer hash — `seed * 2654435761 + index * 40503`, masked to 32 bits. Deterministic by construction. |
| Material icons | `svg2roughjs` | Each icon gets seed `1337 + codePoint`, so per-icon output is pinned to its identity. |
| Catalog ordering | Every generator | Entries are sorted (icons by identifier, emoji by sequence) before codepoints are assigned, so ordering never depends on file-system or map iteration order. |

Because the displacement is a pure function of position rather than a random
walk, the same letter or icon always warps the same way — which is also why
repeated characters within one font keep matching outlines.

### Verified empirically

- Regenerating all four icon catalogs twice produces identical SHA-256 digests.
- `roughen_fonts.dart --check` rebuilds every font file into a temporary
  directory and compares each byte against the committed assets; it reports zero
  stale files. That is 130 files: the 3 variable faces, the 126 generated
  static faces, and the `OFL.txt` notice.
- The emoji generator sorts entries by sequence before writing, and the
  `visual-assets-sync` CI job fails if running it changes any committed file.

### The boundary of the guarantee

Determinism means *same input, same generator, same output*. It does not mean
output is frozen forever:

- **Bumping a source version** changes the artwork, because the artwork changed.
  That is the point, and the registry records it.
- **Changing generator code** (say, retuning the roughness curve) changes every
  catalog at once. That is also the point: it is how a roughness improvement
  propagates through the system. Do it in a dedicated commit, because the diff
  will be large and mechanical.

Both are visible, reviewable, and reversible. Neither happens by accident.

## Regenerating everything

```bash
dart run packages/skribble_emoji_gen/bin/update_assets.dart
```

That single command downloads the pinned OpenMoji payload (verifying both
checksums), rebuilds the emoji catalog, the curated simple icons, the three
Iconify icon catalogs, and all bundled fonts, then formats the output. Run it
after bumping any version in the registry.

Individual stages:

```bash
melos run icons-simple       # the 30 curated icons
melos run icons-iconify      # lucide, bxs, cib
melos run rough-icons-font   # the Material catalog and its icon font
devenv shell dart run packages/skribble_font_roughen/bin/roughen_fonts.dart
```

## Verifying a catalog is current

Every generator accepts `--check`, which re-derives the output in memory and
fails on any difference without writing:

```bash
melos run icons-check         # all icon catalogs
./scripts/check_icon_catalogs.sh
```

`package-sizes` then confirms the regenerated packages still fit their publish
budgets, so a catalog that quietly doubles in size is caught before it ships.
