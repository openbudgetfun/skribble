import 'package:flutter/widgets.dart';

/// How Sketch Notes looks: day or night parchment, and how rough the ink is.
@immutable
class SketchSettings {
  /// Creates settings; the defaults are day parchment and gentle wobble.
  const SketchSettings({this.night = false, this.roughness = 1.2});

  /// Whether the app is drawn on night parchment.
  final bool night;

  /// How far lines waver from true, from 0.5 (tidy) to 2.5 (scribbly).
  final double roughness;

  /// A copy with the given fields replaced.
  SketchSettings copyWith({bool? night, double? roughness}) => SketchSettings(
    night: night ?? this.night,
    roughness: roughness ?? this.roughness,
  );

  @override
  bool operator ==(Object other) =>
      other is SketchSettings &&
      other.night == night &&
      other.roughness == roughness;

  @override
  int get hashCode => Object.hash(night, roughness);
}

/// Shares the app's [SketchSettings] with every page, so the settings page
/// can change how the whole app is drawn.
class SketchSettingsScope
    extends InheritedNotifier<ValueNotifier<SketchSettings>> {
  /// Provides [notifier] to [child].
  const SketchSettingsScope({
    required ValueNotifier<SketchSettings> super.notifier,
    required super.child,
    super.key,
  });

  /// The settings notifier above [context]; pages read and write through it.
  static ValueNotifier<SketchSettings> of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<SketchSettingsScope>()!
      .notifier!;
}
