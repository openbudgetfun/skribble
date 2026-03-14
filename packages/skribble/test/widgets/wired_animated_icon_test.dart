import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredAnimatedIcon', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(
        tester,
        WiredAnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: const AlwaysStoppedAnimation(0.0),
        ),
      );
      expect(find.byType(WiredAnimatedIcon), findsOneWidget);
    });

    testWidgets('renders at progress 1.0', (tester) async {
      await pumpApp(
        tester,
        WiredAnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: const AlwaysStoppedAnimation(1.0),
        ),
      );
      expect(find.byType(WiredAnimatedIcon), findsOneWidget);
    });

    testWidgets('renders at mid progress', (tester) async {
      await pumpApp(
        tester,
        WiredAnimatedIcon(
          icon: AnimatedIcons.play_pause,
          progress: const AlwaysStoppedAnimation(0.5),
        ),
      );
      expect(find.byType(AnimatedIcon), findsOneWidget);
    });

    testWidgets('respects custom color', (tester) async {
      await pumpApp(
        tester,
        WiredAnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: const AlwaysStoppedAnimation(0.0),
          color: Colors.red,
        ),
      );
      final animIcon = tester.widget<AnimatedIcon>(find.byType(AnimatedIcon));
      expect(animIcon.color, Colors.red);
    });

    testWidgets('respects custom size', (tester) async {
      await pumpApp(
        tester,
        WiredAnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: const AlwaysStoppedAnimation(0.0),
          size: 48,
        ),
      );
      final animIcon = tester.widget<AnimatedIcon>(find.byType(AnimatedIcon));
      expect(animIcon.size, 48);
    });

    testWidgets('animates with controller', (tester) async {
      late AnimationController controller;
      await pumpApp(
        tester,
        _AnimatedIconHost(onController: (c) => controller = c),
      );

      expect(find.byType(WiredAnimatedIcon), findsOneWidget);
      unawaited(controller.forward());
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(WiredAnimatedIcon), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('has semantic label when provided', (tester) async {
      await pumpApp(
        tester,
        WiredAnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: const AlwaysStoppedAnimation(0.0),
          semanticLabel: 'Menu icon',
        ),
      );
      final animIcon = tester.widget<AnimatedIcon>(find.byType(AnimatedIcon));
      expect(animIcon.semanticLabel, 'Menu icon');
    });
  });
}

class _AnimatedIconHost extends StatefulWidget {
  final ValueChanged<AnimationController> onController;

  const _AnimatedIconHost({required this.onController});

  @override
  State<_AnimatedIconHost> createState() => _AnimatedIconHostState();
}

class _AnimatedIconHostState extends State<_AnimatedIconHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    widget.onController(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WiredAnimatedIcon(
      icon: AnimatedIcons.menu_arrow,
      progress: _controller,
    );
  }
}
