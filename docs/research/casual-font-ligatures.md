# Casual font and ligature research

Investigated on 12 September 2026. This report distinguishes the shipped fonts from proposed drawing changes.

## What ships today

Skribble Casual is a derivative of Recursive Sans Casual. The source provenance pins Recursive 1.085 to commit `5f4be025122d72d4710267e959128e8986ebe435`. The four source faces are Regular, Bold, Italic, and Bold Italic. Skribble ships three outline roughness levels of each face, called Gentle, Playful, and Expressive. The Expressive family uses the name `Skribble`. See the [local source notice](../site/assets/fonts/README.md), [font generator](../../packages/skribble_font_roughen/bin/roughen_fonts.dart), and [pinned upstream files](https://github.com/arrowtype/recursive/tree/5f4be025122d72d4710267e959128e8986ebe435/fonts/ArrowType-Recursive-1.085/Recursive_Desktop/separate_statics/TTF).

The generator moves existing outline points using smooth waves and per-glyph tilt. It retains glyph order, character maps, spacing, and shaping tables. It does not draw new joins, add swashes, or make alternate versions of repeated letters. See [`TrueTypeFont.roughen` and `encode`](../../packages/skribble_font_roughen/lib/src/truetype_font.dart).

A direct binary audit of the four Casual sources and all 12 corresponding shipped derivatives found 1,305 glyphs per font. For every source/derivative pair, `GSUB`, `GPOS`, `GDEF`, `cmap`, and `hmtx` are byte-identical. Therefore, the current roughening preserves the inherited substitution rules and metrics. This is a check of the actual TTF tables, independent of the generator's claims.

## Ligatures already present

| Feature        | Regular and Bold | Italic and Bold Italic | Meaning                                               |
| -------------- | ---------------- | ---------------------- | ----------------------------------------------------- |
| `dlig`         | Present          | Present                | Optional code/operator ligatures                      |
| `liga`         | Absent           | Present                | The inherited `fi` and `ffi` rules use the italic `i` |
| `calt`         | Absent           | Absent                 | No contextual alternates feature                      |
| `swsh`         | Absent           | Absent                 | No switchable swash feature                           |
| `ss01`, `ss02` | Present          | Present                | Existing single-story `a` and `g` alternatives        |

The binary `dlig` feature references 76 chaining-contextual lookups. These are code and punctuation substitutions, including `->`, `=>`, `==`, `===`, `!=`, `<=`, `>=`, and `&&`. A contextual lookup inside `dlig` does not mean the font has a `calt` feature. Arrow Type documents these as optional code ligatures; its separate code-oriented releases can turn them on by default. See the [pinned `dlig` rules](https://github.com/arrowtype/recursive/blob/5f4be025122d72d4710267e959128e8986ebe435/src/features/features/dlig-generated.fea) and [designer's process notes](https://www.recursive.design/process/).

The source `liga` file defines only `f` followed by `i.italic`, and `f f` followed by `i.italic`. The actual italic binaries contain a ligature-substitution lookup; the regular binaries omit `liga`. It would be inaccurate to describe the current regular font as already supporting the familiar `fi fl ff ffi ffl` set. See the [pinned `liga` rules](https://github.com/arrowtype/recursive/blob/5f4be025122d72d4710267e959128e8986ebe435/src/features/features/liga.fea).

The inherited stylistic sets are letterform alternatives. For example, `ss01` selects single-story `a` and `ss02` selects single-story `g`. These can change the character of the face without new outline work, but they are not newly drawn flourishes. See the [pinned stylistic-set definitions](https://github.com/arrowtype/recursive/blob/5f4be025122d72d4710267e959128e8986ebe435/src/features/features/ss0x.fea).

## Using the existing features in Flutter

Flutter accepts OpenType tags through `TextStyle.fontFeatures`. A call to `FontFeature.enable('dlig')` requests discretionary ligatures; `FontFeature.enable('liga')` requests standard ligatures. A requested feature must exist in the selected face to have an effect. `FontFeature.contextualAlternates()` selects `calt`, and `FontFeature.swash()` selects `swsh`; neither adds missing drawings to a font. See [`TextStyle.fontFeatures`](https://api.flutter.dev/flutter/painting/TextStyle/fontFeatures.html) and [`FontFeature`](https://api.flutter.dev/flutter/dart-ui/FontFeature-class.html).

An explicit configuration for the inherited Casual face is:

```dart
const TextStyle(
  fontFamily: 'Skribble',
  package: 'skribble',
  fontFeatures: [
    FontFeature.enable('liga'),
    FontFeature.enable('dlig'),
    FontFeature('ss01'),
    FontFeature('ss02'),
  ],
)
```

A search of `packages/skribble/lib` and `docs/site/lib` found no explicit `FontFeature` or `fontFeatures` configuration at the time of this audit. This means the font supports optional code ligatures, but the library does not currently request them. It does not establish the defaults of every Flutter renderer. Side-by-side specimens should request features explicitly and include an off control.

## Proposed design direction

These are design judgments, not claims about the current font.

Use restrained changes to the whole alphabet for the default reading face: softer terminals, slightly rounder bowls, modest baseline variation, and clear open counters. More point displacement alone will make the outlines wobblier without creating the deliberate pen gestures the user requested.

Draw a separate set of flourished forms where a pen stroke can plausibly continue. Ascenders, descenders, capital entry strokes, and word endings offer useful locations. Keep long swashes optional so labels and paragraphs can use the quieter forms. Curving every punctuation mark or adding a curl to every letter would reduce distinctions and crowd neighboring characters.

Add actual outlines and GSUB substitutions for the missing prose ligatures. Start with `fi`, `fl`, `ff`, `ffi`, and `ffl`. Optional `st`, `tt`, or other decorative joins need specimen review before becoming defaults. A connected outline is a new ligature; enabling an inherited operator substitution is not.

A later contextual-alternate design could vary repeated letters, such as the two `l` letters in "hello". It requires alternate glyphs and substitution rules. Preserve accented forms, combining-mark placement, and coverage when adding decorated Latin bases. A small Latin proof is useful for selecting the direction, but it is not a completed redesign of all 1,305 glyphs or all four styles.

## License and verification limits

The bundled font notice licenses Recursive under SIL OFL 1.1. It permits modification and redistribution subject to its conditions. Preserve the copyright and license with derivatives, retain the OFL for font files, and name the experiment distinctly so users can identify the modified font. The bundled notice does not declare a Reserved Font Name. See the [bundled OFL](../../packages/skribble/assets/fonts/OFL.txt) and [official license text](https://openfontlicense.org/open-font-license-official-text/).

This research inspected feature presence and table preservation; it did not run a full text shaper across all sequences, languages, and platforms. The audit used a temporary Dart SFNT parser to inspect `maxp`, the `GSUB` feature and lookup lists, and the table bytes. A production change still needs shaped-text comparisons, glyph coverage checks, spacing and mark checks, small-size rendering, and verification that toggling a new ligature changes the glyph sequence while retaining the original text for selection and accessibility.

## Coding-font extension

The coding font needs a separate source choice. Existing `SkribbleMonoGentle`, `SkribbleMonoPlayful`, and `SkribbleMonoExpressive` come from Recursive Mono Linear desktop faces. The new exploration uses the actual Recursive Code Casual faces, pinned to the same 1.085 commit. These already contain the editor-specific substitution and spacing work. See the [pinned Recursive Code Casual sources](https://github.com/arrowtype/recursive/tree/5f4be025122d72d4710267e959128e8986ebe435/fonts/ArrowType-Recursive-1.085/Recursive_Code/RecMonoCasual).

### Existing Mono audit

A direct binary audit covered all four Recursive Mono Linear source styles and all 12 shipped Mono derivatives. Each has 1,305 glyphs. Each source/derivative pair has identical `GSUB`, `GPOS`, `GDEF`, `cmap`, and `hmtx` bytes. Printable ASCII characters U+0020 through U+007E are all present and each advances 600 units at 1,000 units per em. All four styles retain `post.isFixedPitch = 1`.

The font-wide advance widths are 0, 600, 1,200, 1,800, and 2,400 units. The zero-width marks and multi-cell ligature glyphs are compatible with monospaced text. Setting every glyph to 600 would damage the inherited shaping. These desktop sources retain optional `dlig` code ligatures and lack `calt` in all four styles. See the [existing Mono regression checks](../../packages/skribble_font_roughen/test/bundled_mono_test.dart) and [source notice](../site/assets/fonts/README.md).

### Recursive Code Casual audit

The four newly fetched source files, `RecMonoCasual-{Regular,Bold,Italic,BoldItalic}.ttf`, differ from the desktop sources as follows. These values come from direct inspection of their SFNT tables and a FontForge SFD export of Regular.

| Property                 | All four Recursive Code Casual faces           |
| ------------------------ | ---------------------------------------------- |
| Glyph count              | 1,379                                          |
| GSUB features            | `aalt`, `calt`, `rclt`                         |
| Programming feature      | `calt`, with 76 top-level contextual lookups   |
| Printable ASCII          | All 95 characters present, each 600 units wide |
| Units per em             | 1,000                                          |
| `post.isFixedPitch`      | 1                                              |
| `OS/2.xAvgCharWidth`     | 600                                            |
| `OS/2` Panose proportion | 9, monospaced                                  |
| `STAT`                   | Absent                                         |
| `GPOS`, `GDEF`           | Absent                                         |

All glyph advances are 0, 500, or 600. FontForge identifies the sole 500-unit glyph in Regular as the unencoded `.notdef#1`; ordinary code characters remain 600 units wide. Validation should compare optional table presence before comparing table bytes, because these sources do not contain `GPOS` or `GDEF`.

The code-font build does more than change a feature tag. Upstream converts wide code ligatures into drawings with a 600-unit advance and a negative left overhang. Contextual rules substitute blank `LIG` glyphs into earlier cells, and the final cell draws the operator across those cells. Preserve these positions and contextual rules together. See [upstream code-font conversion](https://github.com/arrowtype/recursive-code-config/blob/main/scripts/dlig2calt.py).

The SFD export contains inherited operator drawings for these useful specimen groups:

```text
== === != !== =~ !~ <= >= <=> =/= => -> --> <- <<-
<< <<< <<= >> >>> >>= <| |> <|> <$> <*> <+>
&& &&& || ||| ?? ?. ?: :: ://
++ +++ += -- --- -= ** *** *= /=
// /// /* */ <!-- __ ## ### ####
- [ ]   - [x]   \n \t \r \b \v
```

This is a specimen selection, not a claim that every possible programming combination is supported. The context rules also suppress some matches inside longer runs. The [pinned code-feature source](https://github.com/arrowtype/recursive/blob/5f4be025122d72d4710267e959128e8986ebe435/src/features/features/calt-generated--code_fonts_only.fea) and the actual rendered result should determine the supported sequence list.

### Editor activation and implementation choice

Use the existing code-specific fonts as the base for `SkribbleCode`, preserving `calt` and `rclt`. Aliasing the desktop `dlig` lookup list into a new `calt` feature would expose the substitutions, but would omit the code-specific cell and overhang construction described above. It is unnecessary for this prototype. Any future direct GSUB modification would also need to maintain sorted feature records, language-system feature indices, and offsets, rather than patching tag bytes blindly. See the [OpenType layout structure](https://learn.microsoft.com/en-us/typography/opentype/spec/chapter2).

For an installed family named `SkribbleCode`, VS Code can use:

```json
{
  "editor.fontFamily": "'SkribbleCode', monospace",
  "editor.fontLigatures": true
}
```

VS Code's boolean option enables `liga` and `calt`; it does not enable desktop `dlig`. A string value supports explicit feature settings when needed. This behavior is defined in [VS Code's editor options](https://github.com/microsoft/vscode/blob/main/src/vs/editor/common/config/editorOptions.ts). Arrow Type also documents `calt` as the activation path for its code builds in the [Recursive Code configuration guide](https://github.com/arrowtype/recursive-code-config#3-install-the-fonts-and-activate-the-ligatures).

Terminal support requires separate configuration and verification. VS Code exposes `terminal.integrated.fontFamily` and `terminal.integrated.fontLigatures.enabled`; other editors and terminals may handle shaping differently. See [VS Code terminal appearance](https://code.visualstudio.com/docs/terminal/appearance#_ligatures).

For the coding design, keep character disambiguation and the 600-unit grid as requirements. Compare `0O`, `1Il`, punctuation, indentation, and long operator runs at normal editor sizes. Test cursor placement, selection, and all four styles in a real editor before describing the result as verified editor support. Browser specimens and preserved OpenType tables establish a useful prototype, but do not establish that every editor or terminal displays it correctly.
