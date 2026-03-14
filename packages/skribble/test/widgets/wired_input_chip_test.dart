import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

Finder findWiredIcon(IconData icon) {
  return find.byWidgetPredicate(
    (widget) => widget is WiredIcon && widget.icon == icon,
    description: 'WiredIcon($icon)',
  );
}

void main() {
  group('WiredInputChip', () {
    testWidgets('renders label', (tester) async {
      await pumpApp(tester, WiredInputChip(label: Text('Tag')));
      expect(find.text('Tag'), findsOneWidget);
      expect(find.byType(WiredInputChip), findsOneWidget);
    });

    testWidgets('shows delete icon when onDeleted set', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredInputChip(label: const Text('X'), onDeleted: () {}),
          ),
        ),
      );
      expect(findWiredIcon(Icons.close), findsOneWidget);
    });

    testWidgets('calls onDeleted', (tester) async {
      var deleted = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredInputChip(
              label: const Text('Del'),
              onDeleted: () => deleted = true,
            ),
          ),
        ),
      );
      await tester.tap(findWiredIcon(Icons.close));
      expect(deleted, isTrue);
    });

    testWidgets('calls onSelected with toggled value', (tester) async {
      bool? val;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredInputChip(
              label: const Text('Sel'),
              onSelected: (v) => val = v,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Sel'));
      expect(val, isTrue);
    });

    testWidgets('renders avatar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WiredInputChip(
              label: Text('Name'),
              avatar: CircleAvatar(child: Text('A')),
            ),
          ),
        ),
      );
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('disabled state reduces opacity', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WiredInputChip(label: Text('Off'), enabled: false),
          ),
        ),
      );
      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 0.5);
    });
  });

  group('WiredActionChip', () {
    testWidgets('renders label', (tester) async {
      await pumpApp(tester, WiredActionChip(label: Text('Action')));
      expect(find.text('Action'), findsOneWidget);
    });

    testWidgets('calls onPressed', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredActionChip(
              label: const Text('Go'),
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Go'));
      expect(pressed, isTrue);
    });

    testWidgets('renders avatar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WiredActionChip(
              label: Text('Share'),
              avatar: Icon(Icons.share, size: 16),
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.share), findsOneWidget);
    });
  });
}
