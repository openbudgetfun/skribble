/// How ink leaves the pen along a rough centreline.
///
/// The rough generator decides *where* a line goes. A pen decides how wide
/// the ink is at each point along it: a light touchdown that swells to full
/// width, slow changes in pressure, a lift that thins out, and a lighter
/// repeat stroke when the generator draws a second pass. Closed loops keep
/// going a little past where they started, the way a hand closes a circle.
///
/// [RoughPen.uniform] reproduces a constant-width stroke exactly and takes a
/// cheaper painting path. The other presets trade a little preparation work
/// for ink that reads as drawn rather than plotted.
///
/// Widths are fractions of the stroke width supplied by the caller, and
/// lengths are measured in pen widths so a pen keeps its character when the
/// stroke gets thicker.
final class RoughPen {
  /// Creates a pen. Every fraction is clamped to a usable range when drawing.
  const RoughPen({
    this.startWidth = 0.45,
    this.endWidth = 0.3,
    this.taperIn = 4,
    this.taperOut = 7,
    this.pressure = 0.14,
    this.pressureWavelength = 26,
    this.repeatWidth = 0.6,
    this.repeatCoverage = 0.7,
    this.closure = 2.5,
    this.closureDrift = 0.9,
  });

  /// Constant width, round caps, and no closure. Painted as a plain stroke.
  static const RoughPen uniform = RoughPen(
    startWidth: 1,
    endWidth: 1,
    taperIn: 0,
    taperOut: 0,
    pressure: 0,
    repeatWidth: 1,
    repeatCoverage: 1,
    closure: 0,
    closureDrift: 0,
  );

  /// A technical pen: nearly even width with a slight touchdown.
  static const RoughPen fineliner = RoughPen(
    startWidth: 0.8,
    endWidth: 0.75,
    taperIn: 2,
    taperOut: 2,
    pressure: 0.04,
    repeatWidth: 0.75,
    repeatCoverage: 0.85,
    closure: 1.5,
    closureDrift: 0.5,
  );

  /// A dip pen: tapered ends, gentle swells, and a lighter second pass.
  static const RoughPen ink = RoughPen();

  /// A loaded brush: sharp entry and exit with pronounced pressure.
  static const RoughPen brush = RoughPen(
    startWidth: 0.15,
    endWidth: 0.08,
    taperIn: 6,
    taperOut: 10,
    pressure: 0.28,
    pressureWavelength: 34,
    repeatWidth: 0.45,
    repeatCoverage: 0.55,
    closure: 3.5,
    closureDrift: 1.2,
  );

  /// Width at the first touch, as a fraction of the full width.
  final double startWidth;

  /// Width as the pen lifts, as a fraction of the full width.
  final double endWidth;

  /// Distance over which the stroke reaches full width, in pen widths.
  final double taperIn;

  /// Distance over which the stroke thins before lifting, in pen widths.
  final double taperOut;

  /// Smooth width variation along the stroke, as a fraction of the width.
  final double pressure;

  /// Distance between pressure swells, in logical pixels.
  final double pressureWavelength;

  /// Width of repeat passes, as a fraction of the first pass.
  final double repeatWidth;

  /// Share of each repeat pass that is inked, from zero to one.
  ///
  /// A hand going over a shape a second time rarely retraces all of it. Below
  /// one, each repeat pass covers a seeded stretch of roughly this fraction,
  /// so the ink is heavier along some edges than others.
  final double repeatCoverage;

  /// How far a closed loop continues past its start, in pen widths.
  final double closure;

  /// How far the closing stretch drifts off the line, in pen widths.
  ///
  /// The pen does not land exactly on its starting point, so the seam of a
  /// closed shape crosses itself instead of disappearing. The drift always
  /// curls toward the inside of the shape and shrinks on small shapes, so it
  /// never needs extra room outside the outline.
  final double closureDrift;

  /// Whether this pen lays down constant-width ink.
  bool get isUniform =>
      startWidth == 1 &&
      endWidth == 1 &&
      pressure == 0 &&
      repeatWidth == 1 &&
      repeatCoverage >= 1 &&
      closure == 0;

  /// The widest the ink can get, as a multiple of the stroke width.
  double get peakWidth => 1 + pressure.clamp(0, 1);

  /// The furthest ink reaches outward from its centreline, in stroke widths.
  ///
  /// Half the [peakWidth]. Painters reserve this, plus the rough
  /// displacement, as bleed so ink never reaches a clipped edge.
  double get reach => peakWidth / 2;

  /// Returns a copy with the given values replaced.
  RoughPen copyWith({
    double? startWidth,
    double? endWidth,
    double? taperIn,
    double? taperOut,
    double? pressure,
    double? pressureWavelength,
    double? repeatWidth,
    double? repeatCoverage,
    double? closure,
    double? closureDrift,
  }) => RoughPen(
    startWidth: startWidth ?? this.startWidth,
    endWidth: endWidth ?? this.endWidth,
    taperIn: taperIn ?? this.taperIn,
    taperOut: taperOut ?? this.taperOut,
    pressure: pressure ?? this.pressure,
    pressureWavelength: pressureWavelength ?? this.pressureWavelength,
    repeatWidth: repeatWidth ?? this.repeatWidth,
    repeatCoverage: repeatCoverage ?? this.repeatCoverage,
    closure: closure ?? this.closure,
    closureDrift: closureDrift ?? this.closureDrift,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoughPen &&
          startWidth == other.startWidth &&
          endWidth == other.endWidth &&
          taperIn == other.taperIn &&
          taperOut == other.taperOut &&
          pressure == other.pressure &&
          pressureWavelength == other.pressureWavelength &&
          repeatWidth == other.repeatWidth &&
          repeatCoverage == other.repeatCoverage &&
          closure == other.closure &&
          closureDrift == other.closureDrift;

  @override
  int get hashCode => Object.hash(
    startWidth,
    endWidth,
    taperIn,
    taperOut,
    pressure,
    pressureWavelength,
    repeatWidth,
    repeatCoverage,
    closure,
    closureDrift,
  );

  @override
  String toString() =>
      'RoughPen(start: $startWidth, end: $endWidth, taper: $taperIn/$taperOut, '
      'pressure: $pressure, repeat: $repeatWidth x $repeatCoverage, '
      'closure: $closure ~ $closureDrift)';
}
