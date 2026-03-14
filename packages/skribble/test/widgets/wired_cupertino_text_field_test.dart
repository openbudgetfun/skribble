import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  Future<void> pumpSubject(
    WidgetTester tester, {
    TextEditingController? controller,
    String? placeholder,
    Widget? prefix,
    Widget? suffix,
    ValueChanged<String>? onChanged,
    bool readOnly = false,
    bool obscureText = false,
    bool enabled = true,
    int? maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    bool autofocus = false,
  }) {
    return pumpApp(
      tester,
      Padding(
        padding: const EdgeInsets.all(16),
        child: WiredCupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          prefix: prefix,
          suffix: suffix,
          onChanged: onChanged,
          readOnly: readOnly,
          obscureText: obscureText,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          autofocus: autofocus,
        ),
      ),
    );
  }

  group('WiredCupertinoTextField', () {
    testWidgets('renders without error', (tester) async {
      await pumpSubject(tester);
      expect(find.byType(WiredCupertinoTextField), findsOneWidget);
    });

    testWidgets('shows placeholder text', (tester) async {
      await pumpSubject(tester, placeholder: 'Enter name');
      expect(find.text('Enter name'), findsOneWidget);
    });

    testWidgets('calls onChanged when text entered', (tester) async {
      String? changed;
      await pumpSubject(tester, onChanged: (v) => changed = v);
      await tester.enterText(find.byType(TextField), 'hello');
      expect(changed, 'hello');
    });

    testWidgets('renders prefix widget', (tester) async {
      await pumpSubject(
        tester,
        prefix: const Icon(Icons.search, key: Key('prefix')),
      );
      expect(find.byKey(const Key('prefix')), findsOneWidget);
    });

    testWidgets('renders suffix widget', (tester) async {
      await pumpSubject(
        tester,
        suffix: const Icon(Icons.clear, key: Key('suffix')),
      );
      expect(find.byKey(const Key('suffix')), findsOneWidget);
    });

    testWidgets('obscures text when obscureText is true', (tester) async {
      await pumpSubject(tester, obscureText: true);
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });

    testWidgets('is read-only when readOnly is true', (tester) async {
      await pumpSubject(tester, readOnly: true);
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.readOnly, isTrue);
    });

    testWidgets('has reduced opacity when disabled', (tester) async {
      await pumpSubject(tester, enabled: false);
      final opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(opacity.opacity, 0.4);
    });

    testWidgets('uses provided controller', (tester) async {
      final controller = TextEditingController(text: 'initial');
      addTearDown(controller.dispose);
      await pumpSubject(tester, controller: controller);
      expect(find.text('initial'), findsOneWidget);
    });
  });
}
