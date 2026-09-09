# Flutter documentation design

The docs should demonstrate Skribble while helping developers read, copy, and use it. Preserve the hand-drawn identity and the existing Markdown corpus. Use warm paper for reading, dark plum ink, and coral, moss, golden yellow, and lilac for meaningful interactive examples. Gentle is the default; the other styles stay available.

## Grounding

This refines the existing Wired identity under the user's request. No fresh identity roll or replacement concept is needed.

- THESIS: teach the library through working examples made from the library.
- OWN-WORLD: warm paper, hand-lettered plum text, rough ink, restrained marker overlap, and coloured hatching.
- STORY: try the small note, then read and copy the components that make it work.
- FIRST VIEWPORT: the hand-lettered introduction and a usable note establish the style on desktop and phone.
- FORM: generous reading space, persistent desktop navigation, compact mobile navigation, and real Wired controls.

Before this migration, Jaspr owned Markdown parsing, route generation, and page layout in `docs/site/lib/main.server.dart`. Canonical content lives in `docs/site/content/` and shares MDT providers with Dart documentation. Pages deployment bundles a separately built storybook. The docs package was outside the workspace; the Flutter replacement now participates in workspace analysis and tests. Preserve all content routes, including maps and pages absent from the old sidebar.

The motion layer already borrows ordinary animations and repaints cached geometry. Buttons own interactions through Flutter widget states, so additional effects belong in their existing ink response. Solid backgrounds must remain opaque for label contrast.

## Alternatives and decision

Two independent architecture explorations compared a generated typed block model with runtime Markdown parsing. Use Flutter’s generated asset manifest as the route catalog and load/parse each document once. The existing Markdown AST is enough for content rendering; duplicating it as another generated type hierarchy adds maintenance without solving selection. One document owner holds parsed blocks, headings, and copyable source. One renderer controls rich text and code presentation. Link resolution stays centralized.

Selection tests showed that copied prose needs explicit paragraph separators and access to off-screen blocks. Keep the current article mounted, isolate block repainting, and measure release scrolling before adopting lazy block removal. A whole-page copy action supplements ordinary text selection; it must not conceal broken drag selection. Use Flutter's selection registrar, handles, and context menus without adding Material imports. Code-copy actions copy exact source, not rendered labels.

## Public usage

```dart
WiredDraw(child: note);
WiredFilledButton(
  inkInteraction: WiredInkInteraction.redraw,
  onPressed: save,
  child: const Text('Keep this idea'),
);
```

Interaction choices are none, pressure, and redraw. Pressure remains the restrained default. Redraw re-inks the existing paths on an intentional press without changing layout or seed. Theme and local overrides compose; reduced motion wins. Filled buttons retain their opaque backing while their decorative ink changes.

## Verification

Every Markdown file has a route. Test base prefixes, heading anchors, reload, back/forward, not-found pages, and internal/external links. Verify copied prose and code through the clipboard, keyboard selection, cross-paragraph selection, and scroll-boundary selection. Measure scrolling in a release browser with the longest real article. Test responsive layouts, keyboard focus, motion opt-out, and live examples. Capture phone and desktop screenshots together, fix concrete issues in a batch, and use independent final design review.

## Fill treatment

The user reviewed the release screenshots and asked to keep a slight marker-like overlap while reducing the large bulge. Solid fills retain pixel-sized seeded vertex variation; polygon edges replace the spline that overshot in proportion to long button edges. Text backing stays opaque throughout redraw.
