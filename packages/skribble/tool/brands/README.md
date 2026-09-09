# Curated Simple Icons

GitHub, Dart, Flutter, and Figma source SVGs are copied unchanged from [Simple Icons 16.30.0](https://github.com/simple-icons/simple-icons/tree/ad0ef17e0036bf3e87e91c424ec2eac8cf950029/icons), commit `ad0ef17e0036bf3e87e91c424ec2eac8cf950029`. Simple Icons distributes this artwork under CC0; brand marks remain subject to their owners' brand guidelines. See the upstream [disclaimer](https://github.com/simple-icons/simple-icons/blob/ad0ef17e0036bf3e87e91c424ec2eac8cf950029/DISCLAIMER.md).

The manifest drives the existing Dart SVG importer. From the repository root:

```bash
dart run packages/skribble/tool/generate_rough_icons.dart --kit svg-manifest --manifest packages/skribble/tool/brands/manifest.json --output packages/skribble/lib/src/generated/brand_rough_icons.g.dart --map-name kBrandRoughIcons
dart format packages/skribble/lib/src/generated/brand_rough_icons.g.dart
```

CI rebuilds this catalog and checks the diff. Add a pinned SVG and manifest entry, then expose its codepoint through `WiredBrandIcon`. Runtime rendering applies the inherited roughness; no raster files or separate roughness assets are needed.
