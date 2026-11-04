import 'package:flutter/widgets.dart';

/// How large Sketch Notes writes its text, on top of the reader's own system
/// text size.
enum NoteTextSize {
  /// A little smaller than the system size.
  small('Small', 0.9),

  /// The system size, unchanged.
  medium('Medium', 1),

  /// Noticeably larger, for reading at arm's length.
  large('Large', 1.3);

  const NoteTextSize(this.label, this.scale);

  /// The name shown on the settings page.
  final String label;

  /// The factor applied to the system text scale.
  final double scale;
}

/// How Sketch Notes looks: day or night parchment, how rough the ink is, and
/// how large the text is.
@immutable
class SketchSettings {
  /// Creates settings; the defaults are day parchment, gentle wobble, and the
  /// system text size.
  const SketchSettings({
    this.night = false,
    this.roughness = 1.2,
    this.textSize = NoteTextSize.medium,
  });

  /// Whether the app is drawn on night parchment.
  final bool night;

  /// How far lines waver from true, from 0.5 (tidy) to 2.5 (scribbly).
  final double roughness;

  /// How large the app writes its text.
  final NoteTextSize textSize;

  /// A copy with the given fields replaced.
  SketchSettings copyWith({
    bool? night,
    double? roughness,
    NoteTextSize? textSize,
  }) => SketchSettings(
    night: night ?? this.night,
    roughness: roughness ?? this.roughness,
    textSize: textSize ?? this.textSize,
  );

  @override
  bool operator ==(Object other) =>
      other is SketchSettings &&
      other.night == night &&
      other.roughness == roughness &&
      other.textSize == textSize;

  @override
  int get hashCode => Object.hash(night, roughness, textSize);
}

/// Shares the app's [SketchSettings] with every page, so the settings page
/// can change how the whole app is drawn.
///
/// An [InheritedNotifier] rebuilds its dependents whenever the notifier
/// changes, so a page that calls [of] redraws when a setting does. A real app
/// might reach for a state-management package here; this is the smallest
/// thing Flutter itself provides.
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
