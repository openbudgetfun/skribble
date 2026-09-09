# Recursive comparison specimens

Sources are Recursive 1.085 from [arrowtype/recursive](https://github.com/arrowtype/recursive/tree/5f4be025122d72d4710267e959128e8986ebe435/fonts/ArrowType-Recursive-1.085/Recursive_Desktop/separate_statics/TTF), pinned to commit `5f4be025122d72d4710267e959128e8986ebe435`.

`RecursiveSansCslSt-*`, `RecursiveSansLnrSt-*`, and `RecursiveMonoLnrSt-*` are unchanged source fonts. Modified Linear families are renamed `SkribbleLinearGentle`, `SkribbleLinearPlayful`, and `SkribbleLinearExpressive`, under the included SIL Open Font License. All modified Casual, Linear, and Mono families live in the Skribble package.

Run `dart run tool/docs_font_comparison.dart` from the repository root to reproduce the twelve copied originals. Run `dart run packages/skribble_font_roughen/bin/roughen_fonts.dart` to generate the 36 modified faces. Use `--check` with either command to compare without writing. The source files live in `packages/skribble/tool/font` alongside their license.

SHA-256 of the pinned Linear sources:

| Style       | SHA-256                                                            |
| ----------- | ------------------------------------------------------------------ |
| Regular     | `ca6aeb615fe2d1c2a97b101ee32c9cad19ffbdfaf3011f0935d6b210d365fb4e` |
| Bold        | `a8d93b2c5082171c3a841744b5cb4dd427483e9a104911206c5f05fb0d0dc99b` |
| Italic      | `62e4d508318ec18f689c3c528b890577f33b49f65249781fd8bb6be22e424744` |
| Bold Italic | `c65925fa7be536d7ab950d13e97c8a0089095e1d8784cd7664718b7d05b75bb2` |

SHA-256 of the pinned Mono Linear sources:

| Style       | SHA-256                                                            |
| ----------- | ------------------------------------------------------------------ |
| Regular     | `c0f71b949136946bd0b103c79585be4e4005d19fb935e98c6183e5cb44a4f64b` |
| Bold        | `da1e3c4913fffd14124506827ec0790161056d86e45fe25f5deb211056349f54` |
| Italic      | `4f20329481b316b226ce849ddcb65ced329a7384bbf8f8250907f8cb05561587` |
| Bold Italic | `d7ed83ef6c654143e3603862bfcc2e3c2587bbe1d06845cd7a14bc50c583a4a8` |
