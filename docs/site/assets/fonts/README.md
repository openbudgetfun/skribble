# Recursive comparison specimens

The twelve `RecursiveSansCslSt-*`, `RecursiveSansLnrSt-*`, and `RecursiveMonoLnrSt-*` specimens are unroughened instances of Recursive 1.085's desktop variable font. The source is pinned to commit `6d491202cea5cf6a493ef710cbef2527b9b08939`; its SHA-256 and source differences are recorded in [VARIABLE-SOURCE.md](../../../../packages/skribble/tool/font/VARIABLE-SOURCE.md).

Run `devenv shell dart run packages/skribble_font_roughen/bin/roughen_fonts.dart` at repository root to generate these original instances, 126 roughened static faces, and three variable families. Then run `devenv shell dart run tool/docs_font_comparison.dart` to copy the twelve originals into this directory. Add `--check` to compare without writing.

The modified Casual, Linear, Mono, and variable families live only in the Skribble package. Their renamed files and the original specimens retain Recursive's SIL Open Font License. The experimental Petal compiler bakes required variation substitutions before applying its custom ligatures and swashes, so those authored forms still take effect with this source.
