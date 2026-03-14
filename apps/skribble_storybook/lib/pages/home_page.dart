import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WiredAppBar(title: const Text('Skribble Storybook')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          const Text(
            'Hand-drawn UI components for Flutter',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap a category to explore components',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          for (final cat in _categories)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: WiredCard(
                height: null,
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, cat.route),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(cat.icon, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cat.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Category {
  const _Category({
    required this.title,
    required this.description,
    required this.route,
    required this.icon,
  });

  final String title;
  final String description;
  final String route;
  final IconData icon;
}

const _categories = [
  _Category(
    title: 'Buttons',
    description: 'Button variants with hand-drawn styles',
    route: '/buttons',
    icon: Icons.smart_button,
  ),
  _Category(
    title: 'Inputs',
    description: 'Text fields, checkboxes, sliders, and more',
    route: '/inputs',
    icon: Icons.text_fields,
  ),
  _Category(
    title: 'Navigation',
    description: 'App bars, tabs, drawers, and navigation rails',
    route: '/navigation',
    icon: Icons.menu,
  ),
  _Category(
    title: 'Selection',
    description: 'Chips, filters, and choice selectors',
    route: '/selection',
    icon: Icons.check_circle_outline,
  ),
  _Category(
    title: 'Feedback',
    description: 'Progress indicators, dialogs, and snack bars',
    route: '/feedback',
    icon: Icons.feedback_outlined,
  ),
  _Category(
    title: 'Layout',
    description: 'Cards, dividers, list tiles, and expansion tiles',
    route: '/layout',
    icon: Icons.dashboard_outlined,
  ),
  _Category(
    title: 'Data Display',
    description: 'Calendar, date/time pickers, steppers, and tables',
    route: '/data-display',
    icon: Icons.calendar_today,
  ),
  _Category(
    title: 'Rough Icons',
    description: 'Gallery of all generated rough Material icons',
    route: '/rough-icons',
    icon: Icons.draw_outlined,
  ),
];
