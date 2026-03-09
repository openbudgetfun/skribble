import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A panel for interactive property editors in the storybook.
class PropertyPanel extends HookWidget {
  final List<PropertyItem> properties;

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
          ...properties.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: p,
              )),
        ],
      ),
    );
  }
}

/// A single property item widget.
class PropertyItem extends HookWidget {
  final String label;
  final Widget control;

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
