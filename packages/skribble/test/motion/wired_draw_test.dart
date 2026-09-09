import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

Widget host(Widget child, {bool reduced = false, bool ticking = true}) =>
    MediaQuery(
      data: MediaQueryData(disableAnimations: reduced),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: TickerMode(enabled: ticking, child: child),
      ),
    );

class CountingPainter extends WiredRectangleBase {
  int preparations = 0;
  @override
  RoughDrawing prepare(Size size, DrawConfig drawConfig, Filler filler) {
    preparations++;
    return super.prepare(size, drawConfig, filler);
  }
}

Widget shape(WiredPainterBase painter) => SizedBox(
  width: 160,
  height: 100,
  child: WiredCanvas(painter: painter, fillerType: RoughFilter.hatchFiller),
);

class HookExample extends HookWidget {
  const HookExample({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    useEffect(() {
      controller.forward();
      return null;
    }, [controller]);
    return WiredDrawTransition(
      progress: controller,
      child: shape(WiredRectangleBase()),
    );
  }
}

void main() {
  testWidgets(
    'external progress repaints without rebuilding children or regenerating geometry',
    (tester) async {
      final controller = TrackingController(vsync: tester);
      addTearDown(controller.dispose);
      final painter = CountingPainter();
      var builds = 0;
      await tester.pumpWidget(
        host(
          Center(
            child: WiredDrawTransition(
              progress: controller,
              child: Builder(
                builder: (context) {
                  builds++;
                  return shape(painter);
                },
              ),
            ),
          ),
        ),
      );
      final rect = tester.getRect(find.byType(WiredCanvas));
      for (final value in [.2, .6, 1.0, .5, 0.0]) {
        controller.value = value;
        await tester.pump();
      }
      expect(builds, 1);
      expect(painter.preparations, 1);
      expect(tester.getRect(find.byType(WiredCanvas)), rect);
    },
  );

  testWidgets('replacement and removal detach borrowed controllers', (
    tester,
  ) async {
    final a = TrackingController(vsync: tester);
    final b = TrackingController(vsync: tester);
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    Widget tree(Animation<double> progress) => host(
      WiredDrawTransition(
        progress: progress,
        child: shape(WiredRectangleBase()),
      ),
    );
    await tester.pumpWidget(tree(a));
    expect(a.hasListeners, true);
    await tester.pumpWidget(tree(b));
    expect(a.hasListeners, false);
    expect(b.hasListeners, true);
    a.value = .4;
    await tester.pumpWidget(const SizedBox());
    expect(b.hasListeners, false);
    b.value = .8;
    expect(tester.takeException(), isNull);
  });

  testWidgets('nested draw transitions use independent progress', (
    tester,
  ) async {
    Animation<double>? resolved;
    const outer = AlwaysStoppedAnimation(.2);
    const inner = AlwaysStoppedAnimation(.8);
    await tester.pumpWidget(
      host(
        WiredDrawTransition(
          progress: outer,
          child: WiredDrawTransition(
            progress: inner,
            child: Builder(
              builder: (context) {
                resolved = WiredDrawTransition.progressOf(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
    expect(resolved, same(inner));
  });

  for (final source in ['ancestor', 'theme', 'platform']) {
    testWidgets(
      '$source disable cannot be overridden by a nested enabled scope',
      (tester) async {
        Animation<double>? resolved = const AlwaysStoppedAnimation(0);
        Widget child = WiredMotion(
          child: WiredDrawTransition(
            progress: const AlwaysStoppedAnimation(.2),
            child: Builder(
              builder: (context) {
                resolved = WiredDrawTransition.progressOf(context);
                return const SizedBox();
              },
            ),
          ),
        );
        if (source == 'ancestor') {
          child = WiredMotion(enabled: false, child: child);
        }
        if (source == 'theme') {
          child = WiredTheme(
            data: WiredThemeData(motionEnabled: false),
            child: child,
          );
        }
        await tester.pumpWidget(host(child, reduced: source == 'platform'));
        expect(resolved, isNull);
      },
    );
  }

  testWidgets(
    'implicit drawing completes, keeps content, and does not replay on rebuild',
    (tester) async {
      Widget tree() => host(
        WiredDraw(
          child: Column(
            children: [const Text('Keep me'), shape(WiredRectangleBase())],
          ),
        ),
      );
      await tester.pumpWidget(tree());
      final element = tester.element(find.byType(WiredCanvas));
      expect(WiredDrawTransition.progressOf(element)!.value, 0);
      await tester.pump(const Duration(milliseconds: 700));
      expect(WiredDrawTransition.progressOf(element)!.value, 1);
      await tester.pumpWidget(tree());
      expect(WiredDrawTransition.progressOf(element)!.value, 1);
      expect(find.text('Keep me'), findsOneWidget);
    },
  );

  testWidgets(
    'dynamic reduced motion settles implicit entrance and stays complete when restored',
    (tester) async {
      final child = WiredDraw(child: shape(WiredRectangleBase()));
      await tester.pumpWidget(host(child));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpWidget(host(child, reduced: true));
      expect(
        WiredDrawTransition.progressOf(
          tester.element(find.byType(WiredCanvas)),
        ),
        isNull,
      );
      await tester.pumpWidget(host(child));
      expect(
        WiredDrawTransition.progressOf(
          tester.element(find.byType(WiredCanvas)),
        )!.value,
        1,
      );
      expect(tester.hasRunningAnimations, false);
    },
  );

  testWidgets(
    'muting detaches external paint signals and resumes at current progress',
    (tester) async {
      final controller = TrackingController(vsync: tester, value: .25);
      addTearDown(controller.dispose);
      final child = WiredDrawTransition(
        progress: controller,
        child: shape(WiredRectangleBase()),
      );
      await tester.pumpWidget(host(child));
      await tester.pumpWidget(host(child, ticking: false));
      expect(controller.hasListeners, false);
      controller.value = .8;
      await tester.pump();
      final frozen = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((widget) => widget.painter)
          .whereType<WiredPainter>()
          .single;
      expect(frozen.progress!.value, .25);
      await tester.pumpWidget(host(child));
      expect(controller.hasListeners, true);
    },
  );

  testWidgets(
    'zero duration settles on mount and early disposal leaves no ticker',
    (tester) async {
      await tester.pumpWidget(
        host(
          WiredDraw(
            duration: Duration.zero,
            child: shape(WiredRectangleBase()),
          ),
        ),
      );
      await tester.pump();
      expect(
        WiredDrawTransition.progressOf(
          tester.element(find.byType(WiredCanvas)),
        )!.value,
        1,
      );
      await tester.pumpWidget(
        host(
          WiredDraw(
            key: const ValueKey('new'),
            child: shape(WiredRectangleBase()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      expect(tester.hasRunningAnimations, false);
    },
  );

  testWidgets('hooks controller uses the same API and disposes cleanly', (
    tester,
  ) async {
    await tester.pumpWidget(host(const HookExample()));
    await tester.pumpAndSettle();
    expect(
      WiredDrawTransition.progressOf(tester.element(find.byType(WiredCanvas)))!
          .value,
      1,
    );
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  test(
    'decoration listeners deduplicate and dispose without taking ownership',
    () {
      final animation = TrackingController(vsync: TestVSync());
      var changes = 0;
      final decoration = RoughBoxDecoration(
        progress: animation,
        pressure: animation,
      );
      final painter = decoration.createBoxPainter(() {
        changes++;
      });
      animation.value = .5;
      expect(changes, 1);
      painter.dispose();
      animation.value = 1;
      expect(changes, 1);
      expect(animation.hasListeners, false);
      animation.dispose();
    },
  );
}

class TrackingController extends AnimationController {
  TrackingController({required super.vsync, super.value});
  final Set<VoidCallback> listeners = {};
  bool get hasListeners => listeners.isNotEmpty;
  @override
  void addListener(VoidCallback listener) {
    listeners.add(listener);
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    listeners.remove(listener);
    super.removeListener(listener);
  }
}
