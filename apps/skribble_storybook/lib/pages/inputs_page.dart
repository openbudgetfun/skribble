import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_storybook/components/component_showcase.dart';

class InputsPage extends HookWidget {
  const InputsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final checkboxValue = useState<bool?>(false);
    final radioValue = useState<String>('a');
    final toggleValue = useState(false);
    final sliderValue = useState(0.5);
    final comboValue = useState<String?>(null);
    final switchValue = useState(false);

    return Scaffold(
      appBar: WiredAppBar(
        leading: const BackButton(),
        title: const Text('Inputs'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ShowcaseSection(
            title: 'WiredInput',
            children: [
              ComponentShowcase(
                title: 'Text Field',
                description: 'Single-line text input with hand-drawn border.',
                child: WiredInput(
                  hintText: 'Enter text...',
                  onChanged: (v) {},
                ),
              ),
              ComponentShowcase(
                title: 'With Label',
                child: WiredInput(
                  labelText: 'Name',
                  hintText: 'John Doe',
                  onChanged: (v) {},
                ),
              ),
              ComponentShowcase(
                title: 'Password',
                child: WiredInput(
                  labelText: 'Password',
                  obscureText: true,
                  onChanged: (v) {},
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredTextArea',
            children: [
              ComponentShowcase(
                title: 'Multi-line',
                description: 'Multi-line text input with hand-drawn border.',
                child: WiredTextArea(
                  hintText: 'Write something...',
                  onChanged: (v) {},
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredCheckbox',
            children: [
              ComponentShowcase(
                title: 'Checkbox',
                child: Row(
                  children: [
                    WiredCheckbox(
                      value: checkboxValue.value,
                      onChanged: (v) => checkboxValue.value = v,
                    ),
                    const SizedBox(width: 12),
                    const Text('Accept terms'),
                  ],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredRadio',
            children: [
              ComponentShowcase(
                title: 'Radio Group',
                child: Column(
                  children: [
                    for (final option in ['a', 'b', 'c'])
                      Row(
                        children: [
                          WiredRadio<String>(
                            value: option,
                            groupValue: radioValue.value,
                            onChanged: (v) {
                              if (v != null) radioValue.value = v;
                              return true;
                            },
                          ),
                          const SizedBox(width: 8),
                          Text('Option ${option.toUpperCase()}'),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredToggle',
            children: [
              ComponentShowcase(
                title: 'Toggle',
                description: 'Animated toggle switch.',
                child: WiredToggle(
                  value: toggleValue.value,
                  onChange: (v) {
                    toggleValue.value = v;
                    return true;
                  },
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredSwitch',
            children: [
              ComponentShowcase(
                title: 'Switch',
                description: 'Standalone switch control.',
                child: WiredSwitch(
                  value: switchValue.value,
                  onChanged: (v) => switchValue.value = v,
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredSlider',
            children: [
              ComponentShowcase(
                title: 'Slider',
                description: 'Hand-drawn track with circle thumb.',
                child: WiredSlider(
                  value: sliderValue.value,
                  onChanged: (v) {
                    sliderValue.value = v;
                    return true;
                  },
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredCombo',
            children: [
              ComponentShowcase(
                title: 'Dropdown',
                description: 'Hand-drawn dropdown selector.',
                child: WiredCombo<String>(
                  value: comboValue.value,
                  items: const [
                    DropdownMenuItem(value: 'red', child: Text('Red')),
                    DropdownMenuItem(value: 'green', child: Text('Green')),
                    DropdownMenuItem(value: 'blue', child: Text('Blue')),
                  ],
                  onChanged: (v) {
                    comboValue.value = v;
                    return true;
                  },
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredSearchBar',
            children: [
              ComponentShowcase(
                title: 'Search',
                description: 'Rounded rect input with search icon.',
                child: WiredSearchBar(
                  hintText: 'Search...',
                  onChanged: (v) {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
