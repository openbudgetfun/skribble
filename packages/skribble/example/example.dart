import 'package:flutter/material.dart';
import 'package:skribble/skribble.dart';

/// Minimal Skribble example.
///
/// Run with:
/// ```sh
/// cd packages/skribble/example
/// flutter run -t example.dart
/// ```
void main() => runApp(const SkribbleExample());

class SkribbleExample extends StatelessWidget {
  const SkribbleExample({super.key});

  @override
  Widget build(BuildContext context) {
    return WiredTheme(
      data: WiredThemeData(
        borderColor: const Color(0xFF2D1B69),
        fillColor: const Color(0xFFFFF8E1),
      ),
      child: MaterialApp(
        title: 'Skribble Example',
        theme: ThemeData(useMaterial3: true),
        debugShowCheckedModeBanner: false,
        home: const _ExamplePage(),
      ),
    );
  }
}

class _ExamplePage extends StatelessWidget {
  const _ExamplePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WiredAppBar(title: const Text('Skribble')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Buttons
            const Text(
              'Buttons',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                WiredButton(onPressed: () {}, child: const Text('Button')),
                WiredFilledButton(
                  onPressed: () {},
                  child: const Text('Filled'),
                ),
                WiredElevatedButton(
                  onPressed: () {},
                  child: const Text('Elevated'),
                ),
                WiredOutlinedButton(
                  onPressed: () {},
                  child: const Text('Outlined'),
                ),
                WiredIconButton(onPressed: () {}, icon: Icons.favorite),
              ],
            ),
            const SizedBox(height: 24),
            const WiredDivider(),
            const SizedBox(height: 24),

            // Card with input
            const Text(
              'Card & Input',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            WiredCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const WiredInput(hintText: 'Type something…'),
                    const SizedBox(height: 12),
                    const WiredTextArea(hintText: 'Multiline input…'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        WiredCheckbox(value: true, onChanged: (_) {}),
                        const SizedBox(width: 8),
                        const Text('Agree to terms'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const WiredDivider(),
            const SizedBox(height: 24),

            // Selection
            const Text(
              'Selection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            WiredCombo<String>(
              value: 'flutter',
              items: const [
                DropdownMenuItem(value: 'flutter', child: Text('Flutter')),
                DropdownMenuItem(value: 'dart', child: Text('Dart')),
                DropdownMenuItem(value: 'skribble', child: Text('Skribble')),
              ],
            ),
            const SizedBox(height: 24),
            const WiredDivider(),
            const SizedBox(height: 24),

            // Feedback
            const Text(
              'Feedback',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            WiredDialog(
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Text('This is a hand-drawn dialog box.'),
              ),
            ),
            const SizedBox(height: 12),
            WiredBadge(
              label: '3',
              child: const Icon(Icons.mail_outline, size: 32),
            ),
          ],
        ),
      ),
    );
  }
}
