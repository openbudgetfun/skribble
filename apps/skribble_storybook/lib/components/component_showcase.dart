import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A reusable showcase wrapper that displays a component with a title
/// and optional description.
class ComponentShowcase extends HookWidget {
  /// Bold heading shown above the component.
  final String title;

  /// Optional grey caption under the [title].
  final String? description;

  /// The component being shown.
  final Widget child;

  /// Creates a showcase for [child] headed by [title].
  const ComponentShowcase({
    required this.title,
    required this.child,
    super.key,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Groups multiple showcases under a section heading.
class ShowcaseSection extends HookWidget {
  /// Section heading, usually the widget's class name.
  final String title;

  /// The showcases in this section.
  final List<Widget> children;

  /// Creates a section headed by [title].
  const ShowcaseSection({
    required this.title,
    required this.children,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(),
        ...children,
      ],
    );
  }
}
