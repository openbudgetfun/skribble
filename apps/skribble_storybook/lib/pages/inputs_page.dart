import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_storybook/components/component_showcase.dart';

String _displayOption(String option) => option;

class InputsPage extends HookWidget {
  const InputsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final checkboxValue = useState<bool?>(false);
    final radioValue = useState<String>('a');
    final toggleValue = useState(false);
    final sliderValue = useState(0.5);
    final comboValue = useState<String?>(null);
    final autocompleteValue = useState<String>('None');
    final switchValue = useState(false);
    final cupertinoSliderValue = useState(0.5);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final formStatus = useState('Form not validated yet');

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
                child: WiredInput(hintText: 'Enter text...', onChanged: (v) {}),
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
            title: 'WiredForm',
            children: [
              ComponentShowcase(
                title: 'Validated Form',
                description: 'Hand-drawn form container with validation.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 320,
                      child: WiredForm(
                        formKey: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Email',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email required';
                                }
                                if (!value.contains('@')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Name',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Name required';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        WiredButton(
                          onPressed: () {
                            final isValid =
                                formKey.currentState?.validate() ?? false;
                            formStatus.value = isValid
                                ? 'Form valid'
                                : 'Form invalid';
                          },
                          child: const Text('Validate Form'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(formStatus.value)),
                      ],
                    ),
                  ],
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
            title: 'WiredAutocomplete',
            children: [
              ComponentShowcase(
                title: 'Autocomplete',
                description: 'Suggests matching options in a wired overlay.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WiredAutocomplete<String>(
                      options: const [
                        'Apple',
                        'Apricot',
                        'Banana',
                        'Blueberry',
                        'Cherry',
                      ],
                      labelText: 'Fruit',
                      hintText: 'Type to search fruit',
                      displayStringForOption: _displayOption,
                      onSelected: (value) => autocompleteValue.value = value,
                    ),
                    const SizedBox(height: 12),
                    Text('Selected: ${autocompleteValue.value}'),
                  ],
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredCupertinoTextField',
            children: [
              ComponentShowcase(
                title: 'Cupertino Text Field',
                description:
                    'iOS-style text field with hand-drawn rounded border.',
                child: WiredCupertinoTextField(
                  placeholder: 'Enter your name',
                  onChanged: (v) {},
                ),
              ),
              ComponentShowcase(
                title: 'With Prefix & Suffix',
                child: WiredCupertinoTextField(
                  placeholder: 'Search...',
                  prefix: const Icon(Icons.search, size: 18),
                  suffix: const Icon(Icons.clear, size: 18),
                  onChanged: (v) {},
                ),
              ),
              ComponentShowcase(
                title: 'Password Field',
                child: WiredCupertinoTextField(
                  placeholder: 'Password',
                  obscureText: true,
                  prefix: const Icon(Icons.lock, size: 18),
                  onChanged: (v) {},
                ),
              ),
              ComponentShowcase(
                title: 'Disabled',
                child: const WiredCupertinoTextField(
                  placeholder: 'Disabled',
                  enabled: false,
                ),
              ),
            ],
          ),
          ShowcaseSection(
            title: 'WiredCupertinoSlider',
            children: [
              ComponentShowcase(
                title: 'Cupertino Slider',
                description:
                    'iOS-style slider with hand-drawn track and thumb.',
                child: WiredCupertinoSlider(
                  value: cupertinoSliderValue.value,
                  onChanged: (v) => cupertinoSliderValue.value = v,
                ),
              ),
              ComponentShowcase(
                title: 'With Divisions',
                child: WiredCupertinoSlider(
                  value: 0.5,
                  onChanged: (_) {},
                  divisions: 5,
                  activeColor: Colors.orange,
                ),
              ),
              ComponentShowcase(
                title: 'Disabled',
                child: const WiredCupertinoSlider(
                  value: 0.3,
                  onChanged: null,
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
                child: WiredSearchBar(hintText: 'Search...', onChanged: (v) {}),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
