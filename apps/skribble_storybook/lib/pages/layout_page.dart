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

    return Scaffold(
      appBar: WiredAppBar(
        leading: const BackButton(),
        title: const Text('Layout'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                  children: [
                    Text('Above'),
                    WiredDivider(),
                    Text('Below'),
                  ],
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
        ],
      ),
    );
  }
}
