import 'package:flutter/widgets.dart';
import 'package:skribble/skribble.dart';
import 'package:skribble_maps/src/wired_map_schema.dart';

/// Typed visual style for Skribble's semantic vector-map renderer.
@immutable
class WiredMapStyle {
  /// Creates a semantic map style.
  const WiredMapStyle({
    required this.paperColor,
    required this.landColor,
    required this.parkColor,
    required this.parkInkColor,
    required this.waterColor,
    required this.waterInkColor,
    required this.buildingColor,
    required this.buildingInkColor,
    required this.roadColor,
    required this.roadPaperColor,
    required this.pathColor,
    required this.railColor,
    required this.boundaryColor,
    required this.labelColor,
    required this.labelHaloColor,
    this.roughness = 0.65,
    this.roadRoughnessFactor = 0.32,
    this.lineEchoOpacity = 0.14,
    this.strokeWidth = 1.1,
    this.hachureGap = 9,
    this.seed = 71,
    this.showHachure = true,
    this.minimumBuildingZoom = 15,
    this.minimumPathZoom = 14,
    this.minimumRoadLabelZoom = 15.5,
  }) : assert(roughness >= 0, 'roughness cannot be negative'),
       assert(
         roadRoughnessFactor >= 0,
         'roadRoughnessFactor cannot be negative',
       ),
       assert(
         lineEchoOpacity >= 0 && lineEchoOpacity <= 1,
         'lineEchoOpacity must be between 0 and 1',
       ),
       assert(strokeWidth > 0, 'strokeWidth must be positive'),
       assert(hachureGap > 0, 'hachureGap must be positive'),
       assert(
         minimumBuildingZoom >= 0,
         'minimumBuildingZoom cannot be negative',
       ),
       assert(minimumPathZoom >= 0, 'minimumPathZoom cannot be negative'),
       assert(
         minimumRoadLabelZoom >= 0,
         'minimumRoadLabelZoom cannot be negative',
       );

  /// Creates a map style from the active Skribble theme palette.
  factory WiredMapStyle.fromTheme(WiredThemeData theme) {
    return WiredMapStyle(
      paperColor: theme.fillColor,
      landColor: Color.alphaBlend(
        theme.borderColor.withValues(alpha: 0.05),
        theme.fillColor,
      ),
      parkColor: Color.alphaBlend(
        const Color(0xFF91B978).withValues(alpha: 0.3),
        theme.fillColor,
      ),
      parkInkColor: const Color(0xFF718761),
      waterColor: Color.alphaBlend(
        const Color(0xFF77BDD0).withValues(alpha: 0.42),
        theme.fillColor,
      ),
      waterInkColor: const Color(0xFF527D86),
      buildingColor: Color.alphaBlend(
        theme.borderColor.withValues(alpha: 0.12),
        theme.fillColor,
      ),
      buildingInkColor: theme.borderColor.withValues(alpha: 0.62),
      roadColor: theme.borderColor,
      roadPaperColor: theme.fillColor,
      pathColor: theme.borderColor.withValues(alpha: 0.68),
      railColor: theme.textColor.withValues(alpha: 0.72),
      boundaryColor: theme.borderColor.withValues(alpha: 0.58),
      labelColor: theme.textColor,
      labelHaloColor: theme.fillColor.withValues(alpha: 0.92),
      roughness: theme.roughness * 0.4,
      strokeWidth: theme.strokeWidth * 0.5,
      seed: theme.drawConfig.seed ?? 71,
    );
  }

  /// Warm-paper light style.
  static const paper = WiredMapStyle(
    paperColor: Color(0xFFFFFAF0),
    landColor: Color(0xFFF4EAD8),
    parkColor: Color(0xFFD8E7C3),
    parkInkColor: Color(0xFF72825E),
    waterColor: Color(0xFFB8DBE1),
    waterInkColor: Color(0xFF527D86),
    buildingColor: Color(0xFFE3CFB4),
    buildingInkColor: Color(0xFF796956),
    roadColor: Color(0xFF55483F),
    roadPaperColor: Color(0xFFFFF7E7),
    pathColor: Color(0xFF856D59),
    railColor: Color(0xFF625B69),
    boundaryColor: Color(0xFF705C83),
    labelColor: Color(0xFF322B35),
    labelHaloColor: Color(0xEFFFFAF0),
  );

  /// Ink-on-charcoal dark style.
  static const night = WiredMapStyle(
    paperColor: Color(0xFF201F25),
    landColor: Color(0xFF29292D),
    parkColor: Color(0xFF354334),
    parkInkColor: Color(0xFF91AB82),
    waterColor: Color(0xFF263E49),
    waterInkColor: Color(0xFF78ABB9),
    buildingColor: Color(0xFF443D42),
    buildingInkColor: Color(0xFFA9968C),
    roadColor: Color(0xFFE4D9C8),
    roadPaperColor: Color(0xFF302D31),
    pathColor: Color(0xFFC4A98C),
    railColor: Color(0xFFB6AFC1),
    boundaryColor: Color(0xFFBBA2CE),
    labelColor: Color(0xFFF3EADB),
    labelHaloColor: Color(0xE6201F25),
  );

  /// Base paper color.
  final Color paperColor;

  /// General land-use fill.
  final Color landColor;

  /// Park and forest fill.
  final Color parkColor;

  /// Park outline and hatch ink.
  final Color parkInkColor;

  /// Water fill.
  final Color waterColor;

  /// Water outline and waterway ink.
  final Color waterInkColor;

  /// Building fill.
  final Color buildingColor;

  /// Building outline.
  final Color buildingInkColor;

  /// Road casing ink.
  final Color roadColor;

  /// Road inner stroke.
  final Color roadPaperColor;

  /// Footpath and track ink.
  final Color pathColor;

  /// Railway ink.
  final Color railColor;

  /// Administrative boundary ink.
  final Color boundaryColor;

  /// Label foreground color.
  final Color labelColor;

  /// Label contrast halo color.
  final Color labelHaloColor;

  /// Rough line displacement in logical pixels.
  final double roughness;

  /// Multiplier that keeps roads steadier than other basemap geometry.
  ///
  /// App-owned routes and areas are unaffected.
  final double roadRoughnessFactor;

  /// Opacity of the offset line that gives basemap geometry a pencil edge.
  final double lineEchoOpacity;

  /// Base geometry stroke width.
  final double strokeWidth;

  /// Logical spacing between polygon hatch lines.
  final double hachureGap;

  /// Global deterministic sketch seed.
  final int seed;

  /// Whether parks receive clipped hatch marks.
  final bool showHachure;

  /// Smallest camera zoom at which building footprints are painted.
  final double minimumBuildingZoom;

  /// Smallest camera zoom at which footpaths and tracks are painted.
  final double minimumPathZoom;

  /// Smallest camera zoom at which road names are displayed.
  final double minimumRoadLabelZoom;

  /// Returns paint values for [kind].
  WiredMapFeaturePaint paintFor(WiredMapFeatureKind kind) {
    return switch (kind) {
      WiredMapFeatureKind.land => WiredMapFeaturePaint(fill: landColor),
      WiredMapFeatureKind.park => WiredMapFeaturePaint(
        fill: parkColor,
        ink: parkInkColor,
        width: strokeWidth,
        hachure: showHachure,
      ),
      WiredMapFeatureKind.water => WiredMapFeaturePaint(
        fill: waterColor,
        ink: waterInkColor,
        width: strokeWidth,
      ),
      WiredMapFeatureKind.waterway => WiredMapFeaturePaint(
        ink: waterInkColor,
        width: strokeWidth * 1.25,
      ),
      WiredMapFeatureKind.building => WiredMapFeaturePaint(
        fill: buildingColor,
        ink: buildingInkColor,
        width: strokeWidth * 0.8,
      ),
      WiredMapFeatureKind.boundary => WiredMapFeaturePaint(
        ink: boundaryColor,
        width: strokeWidth,
        dashed: true,
      ),
      WiredMapFeatureKind.road => WiredMapFeaturePaint(
        ink: roadColor,
        secondaryInk: roadPaperColor,
        width: strokeWidth * 3.2,
      ),
      WiredMapFeatureKind.rail => WiredMapFeaturePaint(
        ink: railColor,
        width: strokeWidth,
        dashed: true,
      ),
      WiredMapFeatureKind.path => WiredMapFeaturePaint(
        ink: pathColor,
        width: strokeWidth,
        dashed: true,
      ),
      WiredMapFeatureKind.label => const WiredMapFeaturePaint(),
    };
  }

  /// Returns a map style with selected values replaced.
  WiredMapStyle copyWith({
    Color? paperColor,
    Color? landColor,
    Color? parkColor,
    Color? parkInkColor,
    Color? waterColor,
    Color? waterInkColor,
    Color? buildingColor,
    Color? buildingInkColor,
    Color? roadColor,
    Color? roadPaperColor,
    Color? pathColor,
    Color? railColor,
    Color? boundaryColor,
    Color? labelColor,
    Color? labelHaloColor,
    double? roughness,
    double? roadRoughnessFactor,
    double? lineEchoOpacity,
    double? strokeWidth,
    double? hachureGap,
    int? seed,
    bool? showHachure,
    double? minimumBuildingZoom,
    double? minimumPathZoom,
    double? minimumRoadLabelZoom,
  }) {
    return WiredMapStyle(
      paperColor: paperColor ?? this.paperColor,
      landColor: landColor ?? this.landColor,
      parkColor: parkColor ?? this.parkColor,
      parkInkColor: parkInkColor ?? this.parkInkColor,
      waterColor: waterColor ?? this.waterColor,
      waterInkColor: waterInkColor ?? this.waterInkColor,
      buildingColor: buildingColor ?? this.buildingColor,
      buildingInkColor: buildingInkColor ?? this.buildingInkColor,
      roadColor: roadColor ?? this.roadColor,
      roadPaperColor: roadPaperColor ?? this.roadPaperColor,
      pathColor: pathColor ?? this.pathColor,
      railColor: railColor ?? this.railColor,
      boundaryColor: boundaryColor ?? this.boundaryColor,
      labelColor: labelColor ?? this.labelColor,
      labelHaloColor: labelHaloColor ?? this.labelHaloColor,
      roughness: roughness ?? this.roughness,
      roadRoughnessFactor: roadRoughnessFactor ?? this.roadRoughnessFactor,
      lineEchoOpacity: lineEchoOpacity ?? this.lineEchoOpacity,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      hachureGap: hachureGap ?? this.hachureGap,
      seed: seed ?? this.seed,
      showHachure: showHachure ?? this.showHachure,
      minimumBuildingZoom: minimumBuildingZoom ?? this.minimumBuildingZoom,
      minimumPathZoom: minimumPathZoom ?? this.minimumPathZoom,
      minimumRoadLabelZoom: minimumRoadLabelZoom ?? this.minimumRoadLabelZoom,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is WiredMapStyle &&
      other.paperColor == paperColor &&
      other.landColor == landColor &&
      other.parkColor == parkColor &&
      other.parkInkColor == parkInkColor &&
      other.waterColor == waterColor &&
      other.waterInkColor == waterInkColor &&
      other.buildingColor == buildingColor &&
      other.buildingInkColor == buildingInkColor &&
      other.roadColor == roadColor &&
      other.roadPaperColor == roadPaperColor &&
      other.pathColor == pathColor &&
      other.railColor == railColor &&
      other.boundaryColor == boundaryColor &&
      other.labelColor == labelColor &&
      other.labelHaloColor == labelHaloColor &&
      other.roughness == roughness &&
      other.roadRoughnessFactor == roadRoughnessFactor &&
      other.lineEchoOpacity == lineEchoOpacity &&
      other.strokeWidth == strokeWidth &&
      other.hachureGap == hachureGap &&
      other.seed == seed &&
      other.showHachure == showHachure &&
      other.minimumBuildingZoom == minimumBuildingZoom &&
      other.minimumPathZoom == minimumPathZoom &&
      other.minimumRoadLabelZoom == minimumRoadLabelZoom;

  @override
  int get hashCode => Object.hashAll([
    paperColor,
    landColor,
    parkColor,
    parkInkColor,
    waterColor,
    waterInkColor,
    buildingColor,
    buildingInkColor,
    roadColor,
    roadPaperColor,
    pathColor,
    railColor,
    boundaryColor,
    labelColor,
    labelHaloColor,
    roughness,
    roadRoughnessFactor,
    lineEchoOpacity,
    strokeWidth,
    hachureGap,
    seed,
    showHachure,
    minimumBuildingZoom,
    minimumPathZoom,
    minimumRoadLabelZoom,
  ]);
}

/// Resolved colors and line behavior for a semantic feature.
@immutable
class WiredMapFeaturePaint {
  /// Creates resolved feature paint.
  const WiredMapFeaturePaint({
    this.fill,
    this.ink,
    this.secondaryInk,
    this.width = 1,
    this.dashed = false,
    this.hachure = false,
  });

  /// Polygon fill.
  final Color? fill;

  /// Primary outline or line color.
  final Color? ink;

  /// Optional inner line color used for roads.
  final Color? secondaryInk;

  /// Primary stroke width.
  final double width;

  /// Whether the line uses a broken pencil pattern.
  final bool dashed;

  /// Whether polygon hatching is enabled.
  final bool hachure;
}
