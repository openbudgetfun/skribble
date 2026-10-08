# Changelog

Earlier unpublished versions are documented in [the pre-release development history](PRE_RELEASE_HISTORY.md).

## [0.3.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.3.0) (2026-10-08)

### Breaking changes

#### skribble draws its own emoji

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #230](https://github.com/openbudgetfun/skribble/pull/230)

`skribble_emoji` no longer converts OpenMoji. Every fully-qualified emoji in Unicode Emoji 18.0 (3,963, including skin tones, gendered variants, families, keycaps, and flags) is drawn for skribble as SVG art in one style and inked at runtime by the theme pen, so emoji follow the theme's roughness, pen, and `weight`. The art is MIT.

```dart
// Before
WiredEmoji.fromName('grinning_face', size: 32);
PrecomputedEmoji.fromSequence('🇬🇧', size: 32);
lookupSkribbleEmojiByName('red_heart');
EmojiSearch.search('cat');

// After
const WiredEmoji('😀', size: 32);
const WiredEmoji('🇬🇧', size: 32);
SkribbleEmoji.named('red_heart');
SkribbleEmoji.search('cat');
```

`SkribbleEmoji` is the catalog (`all`, `defaults`, `lookup`, `named`, `inGroup`, `search`, `withTone`), and `EmojiEntry` carries each emoji's name, group, subgroup, and art. `WiredEmojiText` draws emoji inside text. `EmojiPalette` restyles every emoji by colour role and compares by value; `EmojiDrawing` prepares an emoji for custom painters with named parts that a pose can move. `PrecomputedEmoji`, `EmojiSearch`, `EmojiSearchResult`, the `kSkribbleEmoji*` maps, the `lookupSkribbleEmojiBy*` functions, and the `WiredSvgIconData` re-exports are removed.

`skribble_emoji_gen` replaces the OpenMoji conversion with `EmojiArtCompiler`, which enforces the authoring rules in `art/STYLE.md`, and `parseEmojiTest` and `planEmoji`, which plan the pinned Unicode list onto art. `generate_emoji.dart` takes `--art`, `--output`, `--unicode`, `--report`, `--allow-missing`, and `--check`, and `update_assets.dart` no longer downloads OpenMoji.

`skribble` exports `waverPath`, `waveredPolygons`, and `WaveredContour`, the smooth wavering that icons and emoji share.

### Features

#### Animated emoji, and emoji outside Flutter

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #231](https://github.com/openbudgetfun/skribble/pull/231)

`WiredAnimatedEmoji` brings an emoji to life: its parts move and its lines boil, retraced eight times a second by a fresh hand like a hand-drawn cartoon. The most-used emoji have their own choreography (a heart beats, a hand waves around its wrist, a flame flickers, tears fall and fade), and every other emoji moves with its family. Motion follows `WiredMotion`, the platform's reduced-motion setting, and `TickerMode`, showing the emoji at rest when motion is off, and `loops` plays a reaction a set number of times before it rests.

```dart
const WiredAnimatedEmoji('❤️', size: 48);

const wave = EmojiMotion([
  EmojiTrack('hand', EmojiMove.wave(swings: 3), pivot: Alignment(0, .8)),
]);
const WiredAnimatedEmoji('👋', motion: wave);
```

`EmojiMotion`, `EmojiTrack`, `EmojiMove`, and `EmojiPose` describe motion, and `EmojiMotions.of` gives skribble's own. `EmojiDrawing` gains `inking` (a retraced inking of the same shapes), `boundsOf(part)`, and per-part `opacity` when painting.

`EmojiVector` exposes the same inked geometry as SVG path data, with `toSvg()`, and `package:skribble_emoji/lottie.dart` exports `emojiLottie`, which builds a Lottie animation of an emoji's motion and boil for lottie-web and the iOS and Android players. Releases attach the choreographed emoji as `skribble-emoji-lottie.zip`.

## [0.2.1](https://github.com/openbudgetfun/skribble/releases/tag/v0.2.1) (2026-09-22)

### Fixes

#### Keep hand-drawn icons upright and rounded borders visibly irregular

Preserve authored icon endpoints while adding small bends along each stroke. Remove the shared displacement that made unrelated icon sets lean to the right, and regenerate the icon and emoji catalogs. Runtime icon drawing removes overall tilt, while wide rounded borders gain local variation with smooth corner joins.

Normalize insignificant floating-point drift so ARM and x64 generate identical icon and emoji coordinates.

The documentation and storybook activate the rough icon catalog at startup. The storybook bundles the current font package, exposes all six icon catalogs, and adds the missing loading, doodle, fill, typography, and table demonstrations.

_Owner:_ Ifiok Jr. · _Introduced in:_ [26f116a](https://github.com/openbudgetfun/skribble/commit/26f116ae5da5dcdfc1b29b90c341b62ba1fb17f4)

## [0.2.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.2.0) (2026-09-14)

### Documentation

- **Lowercase the skribble brand word across documentation.** READMEs, docs site pages and titles, package descriptions, and source comments now write the brand word as lowercase skribble. Dart identifiers, bundled font families such as SkribbleGentle, asset names, and runtime strings keep their casing, so no API or behaviour changes. _Owner:_ Ifiok Jr. · _Introduced in:_ [5e3937c](https://github.com/openbudgetfun/skribble/commit/5e3937ccb6db77bc38e9ac95d273e018def98843) · _Last updated in:_ [77bb664](https://github.com/openbudgetfun/skribble/commit/77bb6649c58d5be1876aec0eb1cc3a2389c7dc89)

## [0.1.1](https://github.com/openbudgetfun/skribble/releases/tag/v0.1.1) (2026-09-13)

### Changed

- **No package-specific changes were recorded; `skribble_emoji` was updated to 0.1.1 as part of group `main`.**

## [0.1.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.1.0) (2026-09-11)

### Changed

#### No package-specific changes were recorded; `skribble_emoji` was updated to 0.1.0 as part of group `main`.
