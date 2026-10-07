import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

/// Every palette colour, by name.
const Map<String, Color> _palette = {
  'paper': WiredPalette.paper,
  'night': WiredPalette.night,
  'ink': WiredPalette.ink,
  'lilac': WiredPalette.lilac,
  'peach': WiredPalette.peach,
  'sage': WiredPalette.sage,
  'butter': WiredPalette.butter,
  'mutedInk': WiredPalette.mutedInk,
  'mutedPaper': WiredPalette.mutedPaper,
  'dusk': WiredPalette.dusk,
  'coral': WiredPalette.coral,
  'blush': WiredPalette.blush,
};

/// WCAG contrast ratio between two opaque colours.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (light, dark) = la > lb ? (la, lb) : (lb, la);
  return (light + .05) / (dark + .05);
}

void main() {
  test('every colour is opaque and distinct', () {
    for (final MapEntry(key: name, value: colour) in _palette.entries) {
      expect(colour.a, 1, reason: name);
    }
    expect(_palette.values.toSet(), hasLength(_palette.length));
  });

  test('ink reads on both papers', () {
    expect(_contrast(WiredPalette.ink, WiredPalette.paper), greaterThan(12));
    expect(_contrast(WiredPalette.paper, WiredPalette.night), greaterThan(12));
    // Secondary text stays readable (WCAG AA for large text and UI).
    expect(
      _contrast(WiredPalette.mutedInk, WiredPalette.paper),
      greaterThan(4.5),
    );
    expect(
      _contrast(WiredPalette.mutedPaper, WiredPalette.night),
      greaterThan(4.5),
    );
  });

  test('marker washes stay behind the ink', () {
    // Ink drawn over a marker stays readable (WCAG AA for body text).
    for (final wash in [
      WiredPalette.lilac,
      WiredPalette.peach,
      WiredPalette.sage,
      WiredPalette.butter,
      WiredPalette.blush,
    ]) {
      expect(_contrast(WiredPalette.ink, wash), greaterThan(4.5));
    }
    expect(_contrast(WiredPalette.paper, WiredPalette.dusk), greaterThan(4.5));
  });

  test('the cuddly theme takes its colours from the palette', () {
    final day = WiredThemeData.cuddly();
    final night = WiredThemeData.cuddly(brightness: Brightness.dark);
    expect(day.fillColor, WiredPalette.paper);
    expect(day.textColor, WiredPalette.ink);
    expect(day.markerColor, WiredPalette.lilac);
    expect(night.fillColor, WiredPalette.night);
    expect(night.textColor, WiredPalette.paper);
    expect(night.markerColor, WiredPalette.dusk);
  });
}
