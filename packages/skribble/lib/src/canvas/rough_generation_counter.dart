/// Counts rough geometry regenerations, for cache regression tests.
///
/// WiredPainter records a generation every time it re-runs the rough
/// pipeline (generator, filler, ink sampling) instead of reusing its prepared
/// drawing. Widget tests assert on the count to prove that rebuilds with
/// equal-valued painters reuse cached geometry; a climbing count during an
/// animation or a parent rebuild is a caching regression.
///
/// Exposed through `package:skribble/testing.dart`.
abstract final class RoughGenerationCounter {
  static int _generations = 0;

  /// How many times rough geometry has been generated since the last
  /// [reset], across every painter in the tree.
  static int get generations => _generations;

  /// Returns the count to zero. Call at the start of a measurement.
  static void reset() => _generations = 0;

  /// Records one rough geometry generation. Called by the canvas painter.
  static void record() => _generations++;
}
