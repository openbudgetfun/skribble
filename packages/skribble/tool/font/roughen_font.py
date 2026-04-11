#!/usr/bin/env fontforge
"""Roughen a font by adding controlled jitter to glyph outline points.

Usage:
    fontforge -script roughen_font.py <input.ttf> <output.ttf> [jitter_amount] [variant]

This script reads a font, adds small random displacements to each on-curve
outline point, and saves the result. The jitter creates a hand-drawn/sketchy
feel while preserving readability.

Only on-curve points are jittered. Off-curve control points are left in place
to maintain valid cubic Bezier spline structure.

Parameters:
    input.ttf       Source font file (TTF/OTF)
    output.ttf      Output file path
    jitter_amount   Maximum displacement in font units (default: 12)
                    Higher = more sketchy. Recommended range: 5-25.
    variant         Font variant name: Regular, Bold, Italic, or BoldItalic
                    (default: Regular). Sets fontname, fullname, and weight.
"""

import fontforge
import sys


def jitter_value(seed, index, jitter):
    """Deterministic pseudo-random jitter from seed and index."""
    h = (seed * 2654435761 + index * 40503) & 0xFFFFFFFF
    return ((h % 1000) / 500.0 - 1.0) * jitter


# Map variant names to (weight, fullname_suffix, italic_angle).
_VARIANT_MAP = {
    "Regular":    ("Regular",  "Regular",     0),
    "Bold":       ("Bold",     "Bold",        0),
    "Italic":     ("Regular",  "Italic",      -12),
    "BoldItalic": ("Bold",     "Bold Italic", -12),
}


def main():
    if len(sys.argv) < 3:
        print("Usage: fontforge -script roughen_font.py <input.ttf> <output.ttf> [jitter] [variant]")
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2]
    jitter = float(sys.argv[3]) if len(sys.argv) > 3 else 12.0
    variant = sys.argv[4] if len(sys.argv) > 4 else "Regular"

    if variant not in _VARIANT_MAP:
        print("Unknown variant '%s'. Choose from: %s" % (variant, ", ".join(_VARIANT_MAP)))
        sys.exit(1)

    weight, fullname_suffix, italic_angle = _VARIANT_MAP[variant]

    print("Opening font: %s" % input_path)
    font = fontforge.open(input_path)

    # Rename the font family to comply with OFL requirements.
    font.familyname = "Skribble"
    font.fontname = "Skribble-%s" % variant
    font.fullname = "Skribble %s" % fullname_suffix
    font.weight = weight
    if italic_angle != 0:
        font.italicangle = italic_angle

    print("Variant: %s (weight=%s, fullname='Skribble %s')" % (variant, weight, fullname_suffix))

    count = 0
    for glyph_name in font:
        glyph = font[glyph_name]
        if glyph.isWorthOutputting() is False:
            continue

        if glyph.unicode >= 0:
            seed = glyph.unicode
        else:
            seed = abs(hash(glyph_name)) & 0xFFFFFFFF

        layer = glyph.foreground
        idx = 0
        for contour in layer:
            for point in contour:
                # Only jitter on-curve points to maintain spline validity.
                if point.on_curve:
                    dx = jitter_value(seed, idx, jitter)
                    dy = jitter_value(seed, idx + 7919, jitter)
                    point.x += dx
                    point.y += dy
                idx += 1

        count += 1

    print("Roughened %d glyphs with jitter=%s" % (count, jitter))
    print("Saving to: %s" % output_path)

    font.generate(output_path)
    font.close()
    print("Done!")


if __name__ == "__main__":
    main()
