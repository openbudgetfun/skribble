import 'package:flutter/services.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:yaml/yaml.dart';

/// A Markdown document parsed once and shared across route visits.
class DocDocument {
  /// Parses the canonical content, including its frontmatter.
  factory DocDocument.parse(String asset, String source) {
    final frontmatter = RegExp(r'^---\r?\n([\s\S]*?)\r?\n---\r?\n')
        .firstMatch(source);
    final metadata = frontmatter == null
        ? null
        : loadYaml(frontmatter.group(1)!);
    final body = frontmatter == null
        ? source
        : source.substring(frontmatter.end);
    final path = asset
        .substring('content'.length)
        .replaceFirst(RegExp(r'\.md$'), '')
        .replaceFirst(RegExp(r'/index$'), '');

    return DocDocument._(
      path: path.isEmpty ? '/' : path,
      title: metadata is YamlMap ? metadata['title'] as String? ?? path : path,
      description: metadata is YamlMap
          ? metadata['description'] as String? ?? ''
          : '',
      source: body,
      nodes: md.Document(
        extensionSet: md.ExtensionSet.gitHubWeb,
        encodeHtml: false,
      ).parseLines(body.split('\n')),
    );
  }

  DocDocument._({
    required this.path,
    required this.title,
    required this.description,
    required this.source,
    required this.nodes,
  }) {
    final counts = <String, int>{};
    for (final node in nodes.whereType<md.Element>()) {
      if (!RegExp(r'^h[1-6]$').hasMatch(node.tag)) continue;
      final slug = headingSlug(node.textContent);
      final occurrence = counts.update(
        slug,
        (value) => value + 1,
        ifAbsent: () => 0,
      );
      headingIds[node] = occurrence == 0 ? slug : '$slug-$occurrence';
    }
  }

  /// Extensionless route relative to the deployment base.
  final String path;

  /// Frontmatter title used for navigation and browser history.
  final String title;

  /// Short description of the document.
  final String description;

  /// Original Markdown without frontmatter, available to copy.
  final String source;

  /// Cached Markdown syntax tree.
  final List<md.Node> nodes;

  /// Stable, unique fragment identifiers, including repeated heading names.
  final Map<md.Element, String> headingIds = {};
}

/// Loads all documentation from Flutter's generated asset manifest.
///
/// Keeping the catalog derived from assets prevents navigation drifting from
/// the canonical Markdown files when a contributor adds a page.
Future<List<DocDocument>> loadDocuments({AssetBundle? bundle}) async {
  final assets = bundle ?? rootBundle;
  final manifest = await AssetManifest.loadFromAssetBundle(assets);
  final paths =
      manifest
          .listAssets()
          .where((path) => path.startsWith('content/') && path.endsWith('.md'))
          .toList()
        ..sort();
  final documents = await Future.wait(
    paths.map(
      (path) async => DocDocument.parse(path, await assets.loadString(path)),
    ),
  );

  return List.unmodifiable(documents);
}

/// Matches the heading anchors used by the previous documentation site.
String headingSlug(String text) => text
    .toLowerCase()
    .replaceAll(RegExp('[^a-z0-9 -]'), '')
    .replaceAll(RegExp(r'\s+'), '-');
