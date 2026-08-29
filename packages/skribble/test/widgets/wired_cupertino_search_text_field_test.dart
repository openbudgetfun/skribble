import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  Future<void> pumpSubject(
    WidgetTester tester, {
    TextEditingController? controller,
    String? placeholder,
    Widget? prefixWidget,
    Widget? suffixWidget,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    bool enabled = true,
    bool autofocus = false,
    TextInputAction? textInputAction,
    double height = 36,
  }) {
    return pumpApp(
      tester,
      Center(
        child: SizedBox(
          width: 280,
          child: WiredCupertinoSearchTextField(
            controller: controller,
            placeholder: placeholder,
            prefixWidget: prefixWidget,
            suffixWidget: suffixWidget,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            enabled: enabled,
            autofocus: autofocus,
            textInputAction: textInputAction,
            height: height,
          ),
        ),
      ),
    );
  }

  group('WiredCupertinoSearchTextField', () {
    testWidgets('renders without error', (tester) async {
      await pumpSubject(tester);
      expect(find.byType(WiredCupertinoSearchTextField), findsOneWidget);
    });

    testWidgets('shows placeholder when empty', (tester) async {
      await pumpSubject(tester, placeholder: 'Search widgets');
      expect(find.text('Search widgets'), findsOneWidget);
    });

    testWidgets('hides placeholder after typing', (tester) async {
      await pumpSubject(tester, placeholder: 'Search widgets');
      await tester.enterText(find.byType(EditableText), 'cupertino');
      await tester.pump();
      expect(find.text('Search widgets'), findsNothing);
      expect(find.text('cupertino'), findsOneWidget);
    });

    testWidgets('respects initial controller text', (tester) async {
      await pumpSubject(
        tester,
        controller: TextEditingController(text: 'prefilled'),
        placeholder: 'Search widgets',
      );
      expect(find.text('prefilled'), findsOneWidget);
      expect(find.text('Search widgets'), findsNothing);
    });

    testWidgets('calls onChanged when text is entered', (tester) async {
      String? changed;
      await pumpSubject(tester, onChanged: (v) => changed = v);
      await tester.enterText(find.byType(EditableText), 'hello');
      expect(changed, 'hello');
    });

    testWidgets('calls onSubmitted when the search action fires', (
      tester,
    ) async {
      String? submitted;
      await pumpSubject(
        tester,
        autofocus: true,
        onSubmitted: (v) => submitted = v,
      );
      await tester.pump();
      await tester.enterText(find.byType(EditableText), 'icons');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      expect(submitted, 'icons');
    });

    testWidgets('is read-only and inert when disabled', (tester) async {
      String? changed;
      await pumpSubject(tester, enabled: false, onChanged: (v) => changed = v);

      final opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(opacity.opacity, 0.4);

      final editable = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(editable.readOnly, isTrue);

      await tester.enterText(find.byType(EditableText), 'nope');
      expect(changed, isNull);
    });

    testWidgets('shows the default sketchy magnifier glyph', (tester) async {
      await pumpSubject(tester);
      final glyph = find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == '_SearchGlyph',
      );
      expect(glyph, findsOneWidget);
    });

    testWidgets('replaces magnifier with a custom prefix', (tester) async {
      await pumpSubject(
        tester,
        prefixWidget: const Text('PREFIX', key: Key('prefix')),
      );
      expect(find.byKey(const Key('prefix')), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == '_SearchGlyph',
        ),
        findsNothing,
      );
    });

    testWidgets('renders a custom suffix widget', (tester) async {
      await pumpSubject(
        tester,
        suffixWidget: const Text('CANCEL', key: Key('suffix')),
      );
      expect(find.byKey(const Key('suffix')), findsOneWidget);
    });

    testWidgets('defaults to the search input action', (tester) async {
      await pumpSubject(tester);
      final editable = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(editable.textInputAction, TextInputAction.search);
    });

    testWidgets('passes through a custom input action', (tester) async {
      await pumpSubject(tester, textInputAction: TextInputAction.done);
      final editable = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(editable.textInputAction, TextInputAction.done);
    });

    testWidgets('defaults to a stadium border for the given height', (
      tester,
    ) async {
      await pumpSubject(tester, height: 36);
      final canvas = tester.widget<WiredCanvas>(
        find.byType(WiredCanvas).first,
      );
      final radius = (canvas.painter as dynamic).borderRadius as BorderRadius;
      expect(radius.topLeft.x, 18);
    });

    testWidgets('honors a custom height', (tester) async {
      await pumpSubject(tester, height: 52, autofocus: false);
      final sized = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(WiredCupertinoSearchTextField),
              matching: find.byWidgetPredicate(
                (w) => w is SizedBox && w.height == 52,
              ),
            )
            .first,
      );
      expect(sized.height, 52);
    });

    testWidgets('sets textField semantics with a semantic label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpSubject(tester, placeholder: 'Find things');
      final semantics = tester.getSemantics(find.text('Find things'));
      expect(semantics.hasFlag(SemanticsFlag.isTextField), isTrue);
      handle.dispose();
    });
  });
}
