# Variable Recursive source

`Recursive-Variable.ttf` is the unmodified Recursive 1.085 desktop variable font by Arrow Type, under SIL OFL 1.1. Keep `RECURSIVE-OFL.txt` with derivatives.

- Source commit: `6d491202cea5cf6a493ef710cbef2527b9b08939`
- [Pinned source file](https://github.com/arrowtype/recursive/blob/6d491202cea5cf6a493ef710cbef2527b9b08939/fonts/ArrowType-Recursive-1.085/Recursive_Desktop/Recursive_VF_1.085.ttf)
- SHA-256: `653221ca467f4732fe6856ac493f6c409e9f56a7674abe36b2364acc89796f7c`

The bundled generator restricts weight to 300–900 with a 400 default, expands sparse deltas using the Nix-pinned FontTools CLI, and applies the Dart roughener without changing point topology. Derivatives use Skribble names, including variable instance PostScript names. All 126 static fonts come from the three finished variable fonts. Do not run FontForge over variable outputs; it discards variation tables.

Rebuild from repository root with `devenv shell dart run packages/skribble_font_roughen/bin/roughen_fonts.dart`. Append `--check` for a deterministic verification without writes. No network access is needed for rebuilding the committed source.

The desktop variable source has 1,304 glyphs, including 1,296 nonempty outlines. The previous converted static sources had one extra glyph, U+0337 COMBINING SHORT SOLIDUS OVERLAY, which is absent from the variable source. That mark now uses the consuming app's fallback font. The variable source adds a direct U+FB03 mapping for the existing ffi ligature. These differences do not change ordinary Latin text coverage.
