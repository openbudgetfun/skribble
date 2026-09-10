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
import 'package:skribble_docs_site/src/font_comparison.dart';
import 'package:skribble_docs_site/src/playground.dart';
import 'package:url_launcher/url_launcher.dart';

const _paper = Color(0xfffffaf0);
const _ink = Color(0xff34283f);

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
      title: 'Skribble',
      wiredTheme: WiredThemeData(
        roughnessLevel: roughness.value,
        borderColor: _ink,
        textColor: _ink,
        fillColor: _paper,
      ),
      builder: (context, child) => DefaultTextStyle(
        style: TextStyle(
          fontFamily: WiredTheme.of(context).fontFamily,
          package: 'skribble',
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
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 4,
        children: [
          for (final level in WiredRoughness.values)
            DocsAction(
              key: DocsKeys.roughness(level.name),
              selected: WiredTheme.of(context).roughnessLevel == level,
              onPressed: () => state.value.value = level,
              child: Text(
                '${level.name[0].toUpperCase()}${level.name.substring(1)}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
        ],
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

    return WiredScaffold(
      backgroundColor: _paper,
      bodyPadding: EdgeInsets.zero,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 82,
              padding: EdgeInsets.symmetric(horizontal: wide ? 32 : 18),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xffe4d9cd))),
              ),
              child: Row(
                children: [
                  Flexible(
                    child: SizedBox(
                      width: 132,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: _NavigationLink(
                          onActivate: () => navigate('/'),
                          child: const Text(
                            'skribble',
                            style: TextStyle(
                              fontSize: 31,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  if (wide)
                    const Text(
                      'A little ink. A lot of possibility.',
                      style: TextStyle(fontSize: 13, color: Color(0xff796c7a)),
                    ),
                  const Spacer(),
                  if (wide)
                    DocsAction(
                      onPressed: () => launchUrl(
                        Uri.parse('https://github.com/openbudgetfun/skribble'),
                      ),
                      child: const Text('GitHub'),
                    ),
                  if (!wide)
                    Flexible(
                      child: DocsAction(
                        key: DocsKeys.menu,
                        onPressed: () =>
                            navigationOpen.value = !navigationOpen.value,
                        child: Text(
                          navigationOpen.value ? 'Close menu' : 'Explore',
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const _RoughnessPicker(),
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
                                              color: Color(0xff796c7a),
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
                                    ),
                                    const SizedBox(height: 36),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Made with Skribble. Including this page.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xff796c7a),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),
                  if (width >= 1440 && headings.isNotEmpty)
                    SizedBox(
                      width: 218,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 40, 24, 16),
                        child: ListView(
                          children: [
                            const Text(
                              'On this page',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 14),
                            for (final heading in headings)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _NavigationLink(
                                  onActivate: () => navigate(
                                    '#${document.headingIds[heading]}',
                                  ),
                                  child: Text(
                                    heading.textContent,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: const Color(0xff796c7a),
                                      height: 1.5,
                                      fontWeight: heading.tag == 'h2'
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    const groups = {
      '': 'Welcome',
      'getting-started': 'Start making',
      'core': 'The good stuff',
      'widgets': 'Your toolbox',
      'guides': 'Go a little further',
      'showcase': 'Made of possibilities',
      'reference': 'Under the hood',
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 26, 20, 32),
      children: [
        WiredInput(
          key: DocsKeys.search,
          hintText: 'Find a page…',
          hintStyle: const TextStyle(color: Color(0xff796c7a)),
          semanticLabel: 'Find a documentation page',
          onChanged: onQuery,
        ),
        const SizedBox(height: 20),
        for (final group in groups.entries) ...[
          if (documents.any((document) => _inGroup(document, group.key))) ...[
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 8),
              child: Text(
                group.value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff796c7a),
                ),
              ),
            ),
            for (final document in documents.where(
              (document) => _inGroup(document, group.key),
            ))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: DocsAction(
                  key: DocsKeys.page(document.path),
                  selected: currentPath == document.path,
                  link: true,
                  onPressed: () => onNavigate(document.path),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      document.path == '/'
                          ? 'Hello, Skribble'
                          : document.title.split(' — ').first,
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

  bool _inGroup(DocDocument document, String group) {
    final segment =
        document.path.split('/').where((part) => part.isNotEmpty).firstOrNull ??
        '';
    return segment == group &&
        '${document.title} ${document.source}'.toLowerCase().contains(
          query.toLowerCase(),
        );
  }
}

class _NavigationLink extends HookWidget {
  const _NavigationLink({required this.onActivate, required this.child});

  final VoidCallback onActivate;
  final Widget child;

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
        onTap: onActivate,
        child: GestureDetector(
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
