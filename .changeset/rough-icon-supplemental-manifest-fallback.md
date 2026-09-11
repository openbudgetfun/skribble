---
skribble: patch
---

# Complete rough icon coverage with fallback sources and supplemental manifests

Resolution falls back from Material SVG sources to a best-effort `simple-icons` source (`--brand-icons-source`, with slug mappings such as `woo_commerce` to `woocommerce`) and then to a user-supplied supplemental manifest (`--supplemental-manifest`) whose identifier, codePoint, and svgPath entries close remaining gaps; committed supplemental assets cover the `face_unlock*` and `adobe*` families and are passed by default in workspace scripts and CI. `--supplemental-manifest-output` emits an editable starter manifest from unresolved results, `--kit svg-manifest --manifest <path>` processes arbitrary SVG sets with `--map-name` naming the generated constant, alias mappings recover `label_outline` and `wifi_tethering_error` variants, codepoint strings parse as bare hex, `U+`-prefixed, `0x`, and decimal forms, and duplicate manifest codepoints fail fast with a clear `FormatException`.
