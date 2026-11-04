import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A panel for interactive property editors in the storybook.
class PropertyPanel extends HookWidget {
  /// The property editors to list, one per row.
  final List<PropertyItem> properties;

  /// Creates a panel listing [properties].
  const PropertyPanel({required this.properties, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Properties',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...properties.map(
            (p) => Padding(padding: const EdgeInsets.only(bottom: 8), child: p),
          ),
        ],
      ),
    );
  }
}

/// A single property item widget.
class PropertyItem extends HookWidget {
  /// Name of the property, shown before the control.
  final String label;

  /// The editor widget that changes the property.
  final Widget control;

  /// Creates a row pairing [label] with [control].
  const PropertyItem({required this.label, required this.control, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
        Expanded(child: control),
      ],
    );
  }
}
