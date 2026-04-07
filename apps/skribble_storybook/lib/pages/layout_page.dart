import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_storybook/components/component_showcase.dart';

class LayoutPage extends HookWidget {
  const LayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final checkboxTileValue = useState(false);
    final radioTileValue = useState<String>('a');
    final switchTileValue = useState(false);
    final reorderItems = useState(['🍎 Apple', '🍌 Banana', '🍒 Cherry']);

    return WiredScaffold(
      appBar: WiredAppBar(
        leading: const BackButton(),
        title: const Text('Layout'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ShowcaseSection(
            title: 'WiredAvatar',
            children: [
              ComponentShowcase(
                title: 'Initials',
                description: 'Hand-drawn circle avatar with initials.',
                child: Row(
                  children: [
                    const WiredAvatar(radius: 24, child: Text('AB')),
                    const SizedBox(width: 12),
                    WiredAvatar(
                      radius: 24,
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      child: const Text('JD'),
                    ),
                    const SizedBox(width: 12),
                    const WiredAvatar(radius: 24, child: Icon(Icons.person)),
                  ],
                ),
              ),
              ComponentShowcase(
                title: 'Large Avatar',
                child: WiredAvatar(
                  radius: 40,
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  child: const Text('SK'),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredCard',
            children: [
              ComponentShowcase(
                title: 'Basic Card',
                description: 'Card with hand-drawn rectangle border.',
                child: WiredCard(
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Card content goes here'),
                  ),
                ),
              ),
              ComponentShowcase(
                title: 'Filled Card',
                child: WiredCard(
                  fill: true,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Filled card with hachure'),
                  ),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredDivider',
            children: [
              ComponentShowcase(
                title: 'Divider',
                description: 'Hand-drawn horizontal line.',
                child: const Column(
                  children: [Text('Above'), WiredDivider(), Text('Below')],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredListTile',
            children: [
              ComponentShowcase(
                title: 'List Tiles',
                description: 'Tiles with hand-drawn separator lines.',
                child: Column(
                  children: [
                    WiredListTile(
                      leading: const Icon(Icons.inbox),
                      title: const Text('Inbox'),
                      subtitle: const Text('2 new messages'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    WiredListTile(
                      leading: const Icon(Icons.send),
                      title: const Text('Sent'),
                      onTap: () {},
                    ),
                    WiredListTile(
                      leading: const Icon(Icons.drafts),
                      title: const Text('Drafts'),
                      showDivider: false,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredCheckboxListTile',
            children: [
              ComponentShowcase(
                title: 'Checkbox List Tile',
                child: WiredCheckboxListTile(
                  title: const Text('Enable notifications'),
                  value: checkboxTileValue.value,
                  onChanged: (v) => checkboxTileValue.value = v ?? false,
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredRadioListTile',
            children: [
              ComponentShowcase(
                title: 'Radio List Tiles',
                child: Column(
                  children: [
                    WiredRadioListTile<String>(
                      title: const Text('Option A'),
                      value: 'a',
                      groupValue: radioTileValue.value,
                      onChanged: (v) {
                        if (v != null) radioTileValue.value = v;
                        return true;
                      },
                    ),
                    WiredRadioListTile<String>(
                      title: const Text('Option B'),
                      value: 'b',
                      groupValue: radioTileValue.value,
                      onChanged: (v) {
                        if (v != null) radioTileValue.value = v;
                        return true;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredSwitchListTile',
            children: [
              ComponentShowcase(
                title: 'Switch List Tile',
                child: WiredSwitchListTile(
                  title: const Text('Dark Mode'),
                  value: switchTileValue.value,
                  onChanged: (v) => switchTileValue.value = v,
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredReorderableListView',
            children: [
              ComponentShowcase(
                title: 'Reorderable List',
                description: 'Drag handle items in a hand-drawn list.',
                child: SizedBox(
                  height: 200,
                  child: WiredReorderableListView(
                    onReorder: (oldIndex, newIndex) {
                      final items = [...reorderItems.value];
                      final adjustedIndex = newIndex > oldIndex
                          ? newIndex - 1
                          : newIndex;
                      final item = items.removeAt(oldIndex);
                      items.insert(adjustedIndex, item);
                      reorderItems.value = items;
                    },
                    children: [
                      for (final item in reorderItems.value)
                        Padding(
                          key: ValueKey(item),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(item),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredExpansionTile',
            children: [
              ComponentShowcase(
                title: 'Expansion Tile',
                description: 'Expandable with hand-drawn border.',
                child: const WiredExpansionTile(
                  title: Text('Expand me'),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Hidden content revealed!'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredScaffold',
            children: [
              ComponentShowcase(
                title: 'Material Shell',
                description:
                    'Paper-like Scaffold wrapper for app bars, drawers, and body content.',
                child: SizedBox(
                  height: 260,
                  child: WiredScaffold(
                    appBar: WiredAppBar(title: const Text('Sketch Shell')),
                    bodyPadding: const EdgeInsets.all(16),
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Use this as the default Material page shell.'),
                        SizedBox(height: 12),
                        WiredCard(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'Body content keeps the light paper tone.',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredPageScaffold',
            children: [
              ComponentShowcase(
                title: 'Page Scaffold',
                description: 'Hand-drawn page scaffold with nav bar.',
                child: SizedBox(
                  height: 200,
                  child: WiredPageScaffold(
                    navigationBar: WiredAppBar(
                      title: const Text('Sketch Page'),
                    ),
                    child: const Center(child: Text('Page content')),
                  ),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredTabScaffold',
            children: [
              ComponentShowcase(
                title: 'Tab Scaffold',
                description: 'Tabbed layout with hand-drawn tab bar.',
                child: SizedBox(
                  height: 240,
                  child: WiredTabScaffold(
                    tabs: const [
                      WiredTabItem(icon: Icons.home, label: 'Home'),
                      WiredTabItem(icon: Icons.search, label: 'Search'),
                      WiredTabItem(icon: Icons.person, label: 'Profile'),
                    ],
                    tabBuilder: (_, i) {
                      const labels = [
                        'Home view',
                        'Search view',
                        'Profile view',
                      ];
                      return Center(child: Text(labels[i]));
                    },
                  ),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredSliverAppBar',
            children: [
              ComponentShowcase(
                title: 'Sliver App Bar',
                description: 'Collapsible app bar with sketchy bottom border.',
                child: SizedBox(
                  height: 250,
                  child: CustomScrollView(
                    slivers: [
                      WiredSliverAppBar(
                        expandedHeight: 150,
                        pinned: true,
                        title: const Text('Collapsible'),
                        flexibleSpace: Container(color: Colors.indigo.shade50),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Text('Scroll item $i'),
                          ),
                          childCount: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredDismissible',
            children: [
              ComponentShowcase(
                title: 'Swipe to Dismiss',
                description:
                    'Swipe items left or right to dismiss with sketchy background.',
                child: Column(
                  children: [
                    for (final item in ['🍎 Apple', '🍌 Banana', '🍒 Cherry'])
                      WiredDismissible(
                        dismissKey: ValueKey(item),
                        onDismissed: (_) {},
                        child: WiredListTile(title: Text(item)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
