import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  testWidgets('custom placeholders stay decorative and cannot acquire focus', (
    tester,
  ) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        WiredSkeletonOverlay(
          loading: true,
          skeleton: Focus(focusNode: focus, child: const Text('Placeholder')),
          child: const SizedBox(width: 80, height: 40),
        ),
      ),
    );
    focus.requestFocus();
    await tester.pump();
    expect(focus.hasFocus, isFalse);
    expect(find.semantics.byLabel('Placeholder'), findsNothing);
    expect(find.semantics.byLabel('Loading'), findsOneWidget);
    semantics.dispose();
  });

  for (final policy in ['ancestor', 'ticker', 'local']) {
    testWidgets('skeleton settles under $policy policy and resumes', (
      tester,
    ) async {
      const block = WiredSkeleton(width: 80, height: 32);
      final quiet = switch (policy) {
        'ancestor' => const WiredMotion(enabled: false, child: block),
        'ticker' => const TickerMode(enabled: false, child: block),
        _ => const WiredSkeleton(width: 80, height: 32, animating: false),
      };
      await tester.pumpWidget(_app(quiet));
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pumpWidget(_app(block));
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpWidget(_app(const SizedBox()));
      expect(tester.hasRunningAnimations, isFalse);
    });
  }

  testWidgets('skeleton dimensions, constraints, motion and null height', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const WiredSkeleton(width: 120, height: 18)));
    expect(tester.getSize(find.byType(WiredSkeleton)), const Size(120, 18));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpWidget(
      _app(const WiredSkeleton(width: 120, height: 18, animating: false)),
    );
    expect(tester.hasRunningAnimations, isFalse);
    await tester.pumpWidget(
      _app(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: SizedBox(
            width: 50,
            height: 40,
            child: WiredSkeleton(height: null),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(WiredSkeleton)), const Size(50, 40));
    expect(tester.hasRunningAnimations, isFalse);
    await tester.pumpWidget(_app(const WiredSkeleton(width: 0, height: 0)));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'overlay retains state and dimensions while excluding input and semantics',
    (tester) async {
      final semantics = tester.ensureSemantics();

      var taps = 0;
      final focus = FocusNode();
      addTearDown(focus.dispose);
      Widget content(bool loading) => _app(
        WiredSkeletonOverlay(
          loading: loading,
          semanticLabel: 'Loading account',
          child: Focus(
            focusNode: focus,
            child: GestureDetector(
              onTap: () => taps++,
              child: const SizedBox(
                width: 200,
                height: 80,
                child: Text('Account balance'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpWidget(content(false));
      final element = tester.element(find.text('Account balance'));
      final size = tester.getSize(find.byType(WiredSkeletonOverlay));
      focus.requestFocus();
      await tester.pump();
      expect(focus.hasFocus, isTrue);
      await tester.tap(find.text('Account balance'));
      expect(taps, 1);
      await tester.pumpWidget(content(true));
      expect(tester.element(find.text('Account balance')), same(element));
      expect(tester.getSize(find.byType(WiredSkeletonOverlay)), size);
      expect(focus.hasFocus, isFalse);
      focus.requestFocus();
      await tester.pump();
      expect(focus.hasFocus, isFalse);
      expect(find.semantics.byLabel('Account balance'), findsNothing);
      expect(find.semantics.byLabel('Loading account'), findsOneWidget);
      await tester.tapAt(tester.getCenter(find.text('Account balance')));
      expect(taps, 1);
      await tester.pumpWidget(content(false));
      expect(find.semantics.byLabel('Account balance'), findsOneWidget);
      expect(find.semantics.byLabel('Loading account'), findsNothing);
      expect(tester.element(find.text('Account balance')), same(element));
      await tester.tap(find.text('Account balance'));
      expect(taps, 2);
      semantics.dispose();
      expect(tester.hasRunningAnimations, isFalse);
    },
  );

  testWidgets(
    'overlay mutes child tickers and accepts structured placeholders',
    (tester) async {
      for (final loading in [true, false, true, false]) {
        await tester.pumpWidget(
          _app(
            WiredSkeletonOverlay(
              loading: loading,
              skeleton: const Row(
                children: [
                  WiredSkeleton(width: 30, height: 30, animating: false),
                ],
              ),
              child: const WiredLoader(size: 80),
            ),
          ),
        );
        expect(tester.hasRunningAnimations, !loading);
        expect(
          tester.getSize(find.byType(WiredSkeletonOverlay)),
          const Size.square(80),
        );
      }
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _app(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: FocusScope(child: Center(child: child)),
);
