import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:skribble/skribble.dart';
import 'package:skribble_docs_site/src/article.dart';
import 'package:skribble_docs_site/src/docs_keys.dart';
import 'package:skribble_docs_site/src/docs_surface.dart';
import 'package:skribble_docs_site/src/document.dart';
import 'package:skribble_docs_site/src/doodle_playground.dart';
import 'package:skribble_docs_site/src/find_in_page.dart';
import 'package:skribble_docs_site/src/font_comparison.dart';
import 'package:skribble_docs_site/src/loading_playground.dart';
import 'package:skribble_docs_site/src/playground.dart';
import 'package:url_launcher/url_launcher.dart';

const Color _paper = WiredPalette.paper;
const Color _ink = WiredPalette.ink;

/// Documentation built from the same Wired components it teaches.
class DocsApp extends HookWidget {
  /// Creates the app with a preloaded, immutable document catalog.
  const DocsApp({required this.documents, super.key, this.initialLocation});

  /// Every canonical content page, parsed before navigation begins.
  final List<DocDocument> documents;

  /// Optional initial route for embedded previews and tests.
  final String? initialLocation;

  @override
  Widget build(BuildContext context) {
    final roughness = useState(WiredRoughness.playful);
    final router = useMemoized(
      () => GoRouter(
        initialLocation: initialLocation,
        routes: [
          for (final document in documents)
            GoRoute(
              path: document.path,
              builder: (context, state) => _DocsPage(
                key: ValueKey(document.path),
                document: document,
                documents: documents,
                fragment: state.uri.fragment,
              ),
            ),
        ],
        errorBuilder: (context, state) => WiredScaffold(
          backgroundColor: _paper,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('This page wandered off.'),
                const SizedBox(height: 20),
                WiredButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Back to Skribble'),
                ),
              ],
            ),
          ),
        ),
      ),
      [documents, initialLocation],
    );
    useEffect(() => router.dispose, [router]);

    return WiredMaterialApp.router(
      routerConfig: router,
      title: 'skribble — make something delightful',
      wiredTheme: WiredThemeData.cuddly(roughnessLevel: roughness.value),
      builder: (context, child) => DefaultTextStyle(
        style: TextStyle(
          fontFamily: WiredTheme.of(context).fontFamily,
          package: 'skribble_font_recursive',
          color: _ink,
          fontSize: 16,
          height: 1.65,
        ),
        child: _DocsRoughness(value: roughness, child: child!),
      ),
    );
  }
}

class _DocsRoughness extends InheritedWidget {
  const _DocsRoughness({required this.value, required super.child});

  final ValueNotifier<WiredRoughness> value;

  @override
  bool updateShouldNotify(_DocsRoughness oldWidget) => value != oldWidget.value;
}

class _RoughnessPicker extends StatelessWidget {
  const _RoughnessPicker();

  @override
  Widget build(BuildContext context) {
    final state = context.dependOnInheritedWidgetOfExactType<_DocsRoughness>()!;

    return SelectionContainer.disabled(
      child: Semantics(
        container: true,
        label: 'Pen roughness',
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 2,
          children: [
            const ExcludeSemantics(
              child: Padding(
                padding: EdgeInsets.only(right: 6),
                child: Text(
                  'Pen',
                  style: TextStyle(fontSize: 12, color: docsQuietInk),
                ),
              ),
            ),
            for (final level in WiredRoughness.values)
              DocsAction(
                key: DocsKeys.roughness(level.name),
                dense: true,
                selected: WiredTheme.of(context).roughnessLevel == level,
                onPressed: () => state.value.value = level,
                child: Text(
                  '${level.name[0].toUpperCase()}${level.name.substring(1)}',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DocsPage extends HookWidget {
  const _DocsPage({
    required this.document,
    required this.documents,
    required this.fragment,
    super.key,
  });
  final DocDocument document;
  final List<DocDocument> documents;
  final String fragment;

  @override
  Widget build(BuildContext context) {
    final scroll = useScrollController();
    final navigationOpen = useState(false);
    final query = useState('');
    final copied = useState(false);
    final findOpen = useState(false);
    final findController = useTextEditingController();
    final findFocus = useFocusNode();
    final pageFocus = useFocusNode();
    final findIndex = useState(0);
    useListenable(findController);
    final findQuery = findController.text;
    final blockKeys = useMemoized(
      () => List.generate(document.nodes.length, (_) => GlobalKey()),
      [document],
    );
    final matches = useMemoized(
      () => [
        for (var index = 0; index < document.nodes.length; index++)
          if (findTextMatches(
            _searchableBlock(document.nodes[index]),
            findQuery,
          ).isNotEmpty)
            index,
      ],
      [document, findQuery],
    );
    final headings = useMemoized(
      () => document.nodes
          .whereType<md.Element>()
          .where((node) => node.tag == 'h2' || node.tag == 'h3')
          .toList(),
      [document],
    );
    final anchors = useMemoized(
      () => {
        for (final node in document.nodes.whereType<md.Element>().where(
          (node) => RegExp(r'^h[1-6]$').hasMatch(node.tag),
        ))
          document.headingIds[node]!: GlobalKey(),
      },
      [document],
    );
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 1050;
    final showContents = width >= 1440 && headings.isNotEmpty;
    final reading = useMemoized(() => docsReadingOrder(documents), [documents]);
    final readingIndex = reading.indexOf(document);
    final activeHeading = useState<String?>(null);

    // Highlights the last contents entry whose heading has scrolled past the
    // top of the reading column.
    useEffect(() {
      if (!showContents) return null;
      void track() {
        final viewport = scroll.position.context.notificationContext
            ?.findRenderObject();
        if (viewport is! RenderBox) return;
        final top = viewport.localToGlobal(Offset.zero).dy + 96;
        String? active;
        for (final heading in headings) {
          final id = document.headingIds[heading]!;
          final box = anchors[id]?.currentContext?.findRenderObject();
          if (box is! RenderBox || !box.attached) continue;
          if (box.localToGlobal(Offset.zero).dy > top) break;
          active = id;
        }
        // The last sections of a page may never reach the top edge.
        if (scroll.position.extentAfter < 4) {
          active = document.headingIds[headings.last];
        }
        activeHeading.value = active;
      }

      scroll.addListener(track);
      return () => scroll.removeListener(track);
    }, [scroll, showContents, document]);

    void jump(String anchor) {
      final target = anchors[anchor]?.currentContext;
      if (target != null) {
        Scrollable.ensureVisible(
          target,
          alignment: .04,
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 220),
        );
      }
    }

    useEffect(() {
      if (fragment.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) jump(fragment);
        });
      }
      return null;
    }, [fragment]);

    useEffect(() {
      if (!findOpen.value || matches.isEmpty) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        final target =
            blockKeys[matches[findIndex.value % matches.length]].currentContext;
        if (target != null) {
          Scrollable.ensureVisible(
            target,
            alignment: .15,
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 180),
          );
        }
      });
      return null;
    }, [findOpen.value, findQuery, findIndex.value, matches]);

    void openFind() {
      navigationOpen.value = false;
      findOpen.value = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        findFocus.requestFocus();
        findController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: findController.text.length,
        );
      });
    }

    void closeFind() {
      findOpen.value = false;
      findController.clear();
      findIndex.value = 0;
      findFocus.unfocus();
      pageFocus.requestFocus();
    }

    void nextMatch(int direction) {
      if (matches.isEmpty) return;
      findIndex.value =
          (findIndex.value + direction + matches.length) % matches.length;
    }

    Future<void> navigate(String href) async {
      final uri = Uri.parse(href);
      if (uri.hasScheme || href.startsWith('//')) {
        await launchUrl(uri);
        return;
      }
      final resolved = Uri(path: document.path).resolveUri(uri);
      if (resolved.path == '/storybook' ||
          resolved.path.startsWith('/storybook/')) {
        await launchUrl(
          Uri(
            path: resolved.path.substring(1),
            fragment: resolved.hasFragment ? resolved.fragment : null,
          ),
        );
        return;
      }
      final path = resolved.path
          .replaceFirst(RegExp(r'\.md$'), '')
          .replaceFirst(RegExp(r'/index$'), '');
      context.go(
        Uri(
          path: path.isEmpty ? '/' : path,
          fragment: resolved.hasFragment ? resolved.fragment : null,
        ).toString(),
      );
      navigationOpen.value = false;
    }

    final navigation = _Navigation(
      documents: documents,
      currentPath: document.path,
      query: query.value,
      onQuery: (value) => query.value = value,
      onNavigate: navigate,
    );

    final findInput = WiredCupertinoSearchTextField(
      key: DocsKeys.findInput,
      controller: findController,
      focusNode: findFocus,
      placeholder: 'Find in this article',
      semanticLabel: 'Find in this article',
      onChanged: (_) => findIndex.value = 0,
      onSubmitted: (_) => nextMatch(1),
    );
    final findControls = <Widget>[
      Text(
        key: DocsKeys.findCount,
        findQuery.isEmpty
            ? '0 matches'
            : matches.isEmpty
            ? 'No matches'
            : '${findIndex.value % matches.length + 1} of ${matches.length} sections',
        style: const TextStyle(fontSize: 13),
      ),
      DocsAction(
        key: DocsKeys.findPrevious,
        onPressed: () => nextMatch(-1),
        child: Semantics(label: 'Previous match', child: const Text('↑')),
      ),
      DocsAction(
        key: DocsKeys.findNext,
        onPressed: () => nextMatch(1),
        child: Semantics(label: 'Next match', child: const Text('↓')),
      ),
      DocsAction(
        key: DocsKeys.findClose,
        onPressed: closeFind,
        child: Semantics(label: 'Close find', child: const Text('×')),
      ),
    ];

    final page = WiredScaffold(
      backgroundColor: _paper,
      bodyPadding: EdgeInsets.zero,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: _headerHeight,
              padding: EdgeInsets.symmetric(horizontal: wide ? 24 : 18),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: docsRule)),
              ),
              child: LayoutBuilder(
                builder: (context, header) => Row(
                  children: [
                    // The brand takes the free space so the actions sit at the
                    // far edge; it scales down rather than overflowing phones.
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 180),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: _NavigationLink(
                                  onActivate: () => navigate('/'),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      WiredLogo(size: 40, semanticLabel: null),
                                      SizedBox(width: 8),
                                      Text(
                                        'skribble',
                                        style: TextStyle(
                                          fontSize: 31,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (width >= 1200) ...[
                            const SizedBox(width: 18),
                            const Flexible(
                              child: Text(
                                'A little ink. A lot of possibility.',
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: docsQuietInk,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Large text scales the actions down instead of pushing
                    // them past the edge; the brand keeps a small minimum.
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: math.max(0, header.maxWidth - 64),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (wide) ...[
                              const _RoughnessPicker(),
                              const SizedBox(width: 12),
                              const _HeaderRule(),
                              const SizedBox(width: 8),
                            ],
                            DocsAction(
                              key: DocsKeys.find,
                              onPressed: openFind,
                              child: const Text('Find'),
                            ),
                            if (wide)
                              DocsAction(
                                onPressed: () => launchUrl(
                                  Uri.parse(
                                    'https://github.com/openbudgetfun/skribble',
                                  ),
                                ),
                                child: const Text('GitHub'),
                              ),
                            if (!wide)
                              DocsAction(
                                key: DocsKeys.menu,
                                onPressed: () => navigationOpen.value =
                                    !navigationOpen.value,
                                child: Text(
                                  navigationOpen.value
                                      ? 'Close menu'
                                      : 'Explore',
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!wide)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: _RoughnessPicker(),
              ),
            if (findOpen.value)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: docsRule)),
                ),
                child: width < 600
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          findInput,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: findControls,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: findInput),
                          const SizedBox(width: 8),
                          ...findControls,
                        ],
                      ),
              ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (wide) SizedBox(width: 254, child: navigation),
                  Expanded(
                    child: !wide && navigationOpen.value
                        ? navigation
                        : SingleChildScrollView(
                            key: const ValueKey('document-scroll'),
                            controller: scroll,
                            padding: EdgeInsets.fromLTRB(
                              wide ? 46 : 22,
                              32,
                              wide ? 46 : 22,
                              70,
                            ),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 820,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (document.path == '/' ||
                                        document.path == '/showcase/overview')
                                      const Playground(),
                                    if (document.path ==
                                        '/core/font-comparison')
                                      const FontComparison(),
                                    if (document.path == '/core/motion')
                                      const MotionPlayground(),
                                    if (document.path == '/widgets/loading')
                                      const LoadingPlayground(),
                                    if (document.path == '/widgets/flourishes')
                                      const DoodlePlayground(),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            document.path == '/'
                                                ? ''
                                                : document.path
                                                      .split('/')
                                                      .where(
                                                        (part) =>
                                                            part.isNotEmpty,
                                                      )
                                                      .join(' / '),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: docsQuietInk,
                                            ),
                                          ),
                                        ),
                                        DocsAction(
                                          key: DocsKeys.copyPage,
                                          onPressed: () async {
                                            await Clipboard.setData(
                                              ClipboardData(
                                                text: document.source,
                                              ),
                                            );
                                            if (context.mounted) {
                                              copied.value = true;
                                            }
                                          },
                                          child: Text(
                                            copied.value
                                                ? 'Copied!'
                                                : 'Copy page',
                                          ),
                                        ),
                                      ],
                                    ),
                                    DocArticle(
                                      document: document,
                                      onLink: navigate,
                                      anchors: anchors,
                                      findQuery: findOpen.value
                                          ? findQuery
                                          : '',
                                      blockKeys: blockKeys,
                                    ),
                                    const SizedBox(height: 40),
                                    _Pager(
                                      previous: readingIndex > 0
                                          ? reading[readingIndex - 1]
                                          : null,
                                      next:
                                          readingIndex >= 0 &&
                                              readingIndex < reading.length - 1
                                          ? reading[readingIndex + 1]
                                          : null,
                                      onNavigate: navigate,
                                    ),
                                    const SizedBox(height: 28),
                                    const Text(
                                      'Made with Skribble. Including this page.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: docsQuietInk,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),
                  if (showContents)
                    SizedBox(
                      width: 218,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(8, 34, 20, 16),
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 8, bottom: 10),
                            child: Text(
                              'On this page',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: docsQuietInk,
                              ),
                            ),
                          ),
                          for (final heading in headings)
                            _ContentsEntry(
                              key: DocsKeys.contents(
                                document.headingIds[heading]!,
                              ),
                              label: heading.textContent,
                              nested: heading.tag == 'h3',
                              active:
                                  activeHeading.value ==
                                  document.headingIds[heading],
                              onActivate: () => navigate(
                                '#${document.headingIds[heading]}',
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyF, meta: true): openFind,
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): openFind,
        if (findOpen.value)
          const SingleActivator(LogicalKeyboardKey.escape): closeFind,
      },
      child: Focus(autofocus: true, focusNode: pageFocus, child: page),
    );
  }
}

String _searchableBlock(md.Node node) {
  if (node is md.Text && node.textContent.trimLeft().startsWith('<!--')) {
    return '';
  }
  if (node is md.Element) {
    if (node.tag == 'html' ||
        (node.tag == 'pre' &&
            node.textContent.startsWith('// Live example:'))) {
      return '';
    }
  }
  return node.textContent.replaceFirst(
    RegExp(r'^// Static example: [a-z-]+\n'),
    '',
  );
}

/// Sidebar groups in reading order, keyed by the first path segment.
const Map<String, String> _groups = {
  '': 'Welcome',
  'getting-started': 'Start making',
  'core': 'The good stuff',
  'widgets': 'Your toolbox',
  'guides': 'Go a little further',
  'showcase': 'Made of possibilities',
  'reference': 'Under the hood',
};

String _groupOf(DocDocument document) =>
    document.path.split('/').where((part) => part.isNotEmpty).firstOrNull ?? '';

/// Documents in the order the sidebar lists them, which is also the order the
/// previous and next links walk through.
List<DocDocument> docsReadingOrder(List<DocDocument> documents) => [
  for (final group in _groups.keys)
    ...documents.where((document) => _groupOf(document) == group),
];

/// Short label used for a document in the sidebar and the pager.
String docsNavigationTitle(DocDocument document) => document.path == '/'
    ? 'Hello, Skribble'
    : document.title.split(' — ').first;

class _Navigation extends HookWidget {
  const _Navigation({
    required this.documents,
    required this.currentPath,
    required this.query,
    required this.onQuery,
    required this.onNavigate,
  });
  final List<DocDocument> documents;
  final String currentPath;
  final String query;
  final ValueChanged<String> onQuery;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 22, 16, 32),
      children: [
        WiredInput(
          key: DocsKeys.search,
          hintText: 'Find a page…',
          hintStyle: const TextStyle(color: docsQuietInk),
          semanticLabel: 'Find a documentation page',
          onChanged: onQuery,
        ),
        const SizedBox(height: 8),
        for (final group in _groups.entries) ...[
          if (documents.any((document) => _matches(document, group.key))) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 22, 0, 4),
              child: Text(
                group.value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: docsQuietInk,
                ),
              ),
            ),
            for (final document in documents.where(
              (document) => _matches(document, group.key),
            ))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: DocsAction(
                  key: DocsKeys.page(document.path),
                  dense: true,
                  selected: currentPath == document.path,
                  link: true,
                  onPressed: () => onNavigate(document.path),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      docsNavigationTitle(document),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ],
    );
  }

  bool _matches(DocDocument document, String group) =>
      _groupOf(document) == group &&
      '${document.title} ${document.source}'.toLowerCase().contains(
        query.toLowerCase(),
      );
}

class _NavigationLink extends HookWidget {
  const _NavigationLink({
    required this.onActivate,
    required this.child,
    this.selected,
  });

  final VoidCallback onActivate;
  final Widget child;

  /// Whether the link marks the current location, or null when it cannot.
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    final focused = useState(false);
    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowFocusHighlight: (value) => focused.value = value,
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            onActivate();
            return null;
          },
        ),
      },
      child: Semantics(
        link: true,
        selected: selected,
        onTap: onActivate,
        child: GestureDetector(
          // The enclosing Semantics already exposes the tap, so the label
          // merges into one link node instead of a nested tappable child.
          excludeFromSemantics: true,
          onTap: onActivate,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: focused.value
                ? RoughBoxDecoration(
                    drawConfig: WiredTheme.of(context).drawConfig,
                    borderStyle: const RoughDrawingStyle(color: _ink, width: 2),
                  )
                : null,
            child: child,
          ),
        ),
      ),
    );
  }
}

const double _headerHeight = 72;

/// A short vertical hairline separating header control groups.
class _HeaderRule extends StatelessWidget {
  const _HeaderRule();

  @override
  Widget build(BuildContext context) =>
      const SizedBox(width: 1, height: 24, child: ColoredBox(color: docsRule));
}

/// One "On this page" link; subsections sit indented behind a hairline.
class _ContentsEntry extends StatelessWidget {
  const _ContentsEntry({
    required this.label,
    required this.nested,
    required this.active,
    required this.onActivate,
    super.key,
  });

  final String label;
  final bool nested;
  final bool active;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    final entry = _NavigationLink(
      onActivate: onActivate,
      selected: active,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: active
            ? docsSurface(context, color: WiredPalette.peach, radius: 6)
            : null,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            height: 1.45,
            color: active ? _ink : docsQuietInk,
            fontWeight: nested ? FontWeight.normal : FontWeight.w600,
          ),
        ),
      ),
    );

    if (!nested) {
      return Padding(padding: const EdgeInsets.only(top: 8), child: entry);
    }
    return Container(
      margin: const EdgeInsets.only(left: 10),
      padding: const EdgeInsets.only(left: 6),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: docsRule)),
      ),
      child: entry,
    );
  }
}

/// Previous and next links that follow the sidebar's reading order.
class _Pager extends StatelessWidget {
  const _Pager({
    required this.previous,
    required this.next,
    required this.onNavigate,
  });

  final DocDocument? previous;
  final DocDocument? next;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    Widget card(DocDocument? document, {required bool forward}) {
      if (document == null) return const Expanded(child: SizedBox.shrink());
      return Expanded(
        child: Container(
          decoration: docsFrame(context),
          child: DocsAction(
            key: forward ? DocsKeys.nextPage : DocsKeys.previousPage,
            link: true,
            onPressed: () => onNavigate(document.path),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Column(
                crossAxisAlignment: forward
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    forward ? 'Next →' : '← Previous',
                    style: const TextStyle(fontSize: 12, color: docsQuietInk),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    docsNavigationTitle(document),
                    textAlign: forward ? TextAlign.end : TextAlign.start,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SelectionContainer.disabled(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          card(previous, forward: false),
          const SizedBox(width: 14),
          card(next, forward: true),
        ],
      ),
    );
  }
}
