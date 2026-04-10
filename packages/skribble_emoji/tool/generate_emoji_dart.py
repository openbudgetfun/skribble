#!/usr/bin/env python3
"""Extract path data from OpenMoji SVGs and generate Dart code."""

import xml.etree.ElementTree as ET
import os
import re
import json

EMOJI_DIR = os.path.join(os.path.dirname(__file__), '..', 'emoji')

# Emoji definitions: (codepoint_hex, identifier)
EMOJIS = [
    # Smileys
    ("1F600", "grinning_face"),
    ("1F602", "face_with_tears_of_joy"),
    ("1F60D", "smiling_face_with_heart_eyes"),
    ("1F914", "thinking_face"),
    ("1F622", "crying_face"),
    ("1F621", "pouting_face"),
    ("1F973", "partying_face"),
    ("1F634", "sleeping_face"),
    ("1F92F", "exploding_head"),
    ("1F60E", "smiling_face_with_sunglasses"),
    # Hands/Gestures
    ("1F44D", "thumbs_up"),
    ("1F44E", "thumbs_down"),
    ("1F44B", "waving_hand"),
    ("1F64F", "folded_hands"),
    ("1F44F", "clapping_hands"),
    ("270C", "victory_hand"),
    ("1F4AA", "flexed_biceps"),
    ("1F91D", "handshake"),
    # Hearts/Symbols
    ("2764", "red_heart"),
    ("1F4AF", "hundred_points"),
    ("2B50", "star"),
    ("1F525", "fire"),
    ("2705", "check_mark"),
    ("274C", "cross_mark"),
    ("26A1", "high_voltage"),
    # Objects
    ("1F4F1", "mobile_phone"),
    ("1F4BB", "laptop"),
    ("1F4F7", "camera"),
    ("1F3B5", "musical_note"),
    ("1F4E7", "email"),
    ("1F511", "key"),
    ("1F3E0", "house"),
    ("1F4C5", "calendar"),
    ("23F0", "alarm_clock"),
    ("1F514", "bell"),
    # Nature/Food
    ("1F31F", "glowing_star"),
    ("1F308", "rainbow"),
    ("2600", "sun"),
    ("1F319", "crescent_moon"),
    ("1F355", "pizza"),
    ("1F389", "party_popper"),
    ("1F381", "wrapped_present"),
    ("1F3C6", "trophy"),
    # People/Activities
    ("1F680", "rocket"),
    ("1F4A1", "light_bulb"),
    ("1F3AF", "direct_hit"),
    ("1F4AC", "speech_balloon"),
    ("1F4DD", "memo"),
    ("1F512", "locked"),
    ("1F513", "unlocked"),
]

NS = {'svg': 'http://www.w3.org/2000/svg'}


def polygon_points_to_path(points_str):
    """Convert polygon points attribute to SVG path data."""
    points_str = points_str.strip()
    # Split on whitespace or commas (but pairs are x,y)
    # Points can be "x1,y1 x2,y2 ..." or "x1 y1 x2 y2 ..."
    parts = re.split(r'\s+', points_str)
    if not parts:
        return ''

    # Check if points are comma-separated pairs or space-separated
    path_parts = []
    for i, part in enumerate(parts):
        if ',' in part:
            x, y = part.split(',')
            if i == 0:
                path_parts.append(f'M{x} {y}')
            else:
                path_parts.append(f'L{x} {y}')
        else:
            # space-separated: pairs of values
            # This is harder, handle by collecting pairs
            pass

    if path_parts:
        path_parts.append('Z')
        return ''.join(path_parts)

    # Fallback: space-separated values
    values = []
    for part in parts:
        if ',' in part:
            values.extend(part.split(','))
        else:
            values.append(part)

    path_parts = []
    for i in range(0, len(values) - 1, 2):
        x, y = values[i], values[i + 1]
        if i == 0:
            path_parts.append(f'M{x} {y}')
        else:
            path_parts.append(f'L{x} {y}')
    path_parts.append('Z')
    return ''.join(path_parts)


def circle_to_path(cx, cy, r):
    """Convert circle to SVG path data using arcs."""
    # Two semi-circular arcs
    return (
        f'M{cx - r},{cy}'
        f'A{r},{r},0,1,0,{cx + r},{cy}'
        f'A{r},{r},0,1,0,{cx - r},{cy}Z'
    )


def ellipse_to_path(cx, cy, rx, ry):
    """Convert ellipse to SVG path data using arcs."""
    return (
        f'M{cx - rx},{cy}'
        f'A{rx},{ry},0,1,0,{cx + rx},{cy}'
        f'A{rx},{ry},0,1,0,{cx - rx},{cy}Z'
    )


def rect_to_path(x, y, w, h, rx=0, ry=0):
    """Convert rect to SVG path data."""
    if rx == 0 and ry == 0:
        return f'M{x},{y}L{x+w},{y}L{x+w},{y+h}L{x},{y+h}Z'
    # Rounded rectangle
    if rx == 0:
        rx = ry
    if ry == 0:
        ry = rx
    return (
        f'M{x+rx},{y}'
        f'L{x+w-rx},{y}'
        f'A{rx},{ry},0,0,1,{x+w},{y+ry}'
        f'L{x+w},{y+h-ry}'
        f'A{rx},{ry},0,0,1,{x+w-rx},{y+h}'
        f'L{x+rx},{y+h}'
        f'A{rx},{ry},0,0,1,{x},{y+h-ry}'
        f'L{x},{y+ry}'
        f'A{rx},{ry},0,0,1,{x+rx},{y}Z'
    )


def should_skip_element(elem):
    """Check if an element should be skipped."""
    fill = elem.get('fill', '')
    stroke = elem.get('stroke', '')

    # Skip elements with fill="none" AND no stroke (invisible)
    if fill.lower() == 'none' and (not stroke or stroke.lower() == 'none'):
        return True

    return False


def extract_paths(svg_file):
    """Extract all path data from an SVG file."""
    try:
        tree = ET.parse(svg_file)
    except ET.ParseError as e:
        print(f"  ERROR parsing {svg_file}: {e}")
        return []

    root = tree.getroot()
    paths = []

    # Register namespace
    ET.register_namespace('', 'http://www.w3.org/2000/svg')

    def process_element(elem):
        tag = elem.tag.split('}')[-1] if '}' in elem.tag else elem.tag

        if tag == 'path':
            d = elem.get('d', '').strip()
            if d and not should_skip_element(elem):
                paths.append(d)

        elif tag == 'polygon':
            points = elem.get('points', '').strip()
            if points and not should_skip_element(elem):
                path_d = polygon_points_to_path(points)
                if path_d:
                    paths.append(path_d)

        elif tag == 'polyline':
            points = elem.get('points', '').strip()
            if points and not should_skip_element(elem):
                # Same as polygon but without closing Z
                path_d = polygon_points_to_path(points)
                if path_d:
                    # Remove the trailing Z for polyline
                    path_d = path_d.rstrip('Z')
                    paths.append(path_d)

        elif tag == 'circle':
            if not should_skip_element(elem):
                cx = float(elem.get('cx', 0))
                cy = float(elem.get('cy', 0))
                r = float(elem.get('r', 0))
                if r > 0:
                    path_d = circle_to_path(cx, cy, r)
                    paths.append(path_d)

        elif tag == 'ellipse':
            if not should_skip_element(elem):
                cx = float(elem.get('cx', 0))
                cy = float(elem.get('cy', 0))
                rx = float(elem.get('rx', 0))
                ry = float(elem.get('ry', 0))
                if rx > 0 and ry > 0:
                    path_d = ellipse_to_path(cx, cy, rx, ry)
                    paths.append(path_d)

        elif tag == 'rect':
            if not should_skip_element(elem):
                x = float(elem.get('x', 0))
                y = float(elem.get('y', 0))
                w = float(elem.get('width', 0))
                h = float(elem.get('height', 0))
                rx = float(elem.get('rx', 0))
                ry = float(elem.get('ry', 0))
                if w > 0 and h > 0:
                    path_d = rect_to_path(x, y, w, h, rx, ry)
                    paths.append(path_d)

        elif tag == 'line':
            if not should_skip_element(elem):
                x1 = elem.get('x1', '0')
                y1 = elem.get('y1', '0')
                x2 = elem.get('x2', '0')
                y2 = elem.get('y2', '0')
                paths.append(f'M{x1},{y1}L{x2},{y2}')

        # Recurse into children
        for child in elem:
            process_element(child)

    process_element(root)
    return paths


def escape_path_data(d):
    """Escape single quotes in path data for Dart string."""
    return d.replace("'", "\\'")


def generate_dart():
    """Generate the Dart file with all emoji data."""

    entries = []
    failed = []

    for code_hex, name in EMOJIS:
        svg_path = os.path.join(EMOJI_DIR, f'{name}.svg')
        if not os.path.exists(svg_path):
            print(f"  MISSING: {svg_path}")
            failed.append(name)
            continue

        paths = extract_paths(svg_path)
        if not paths:
            print(f"  NO PATHS: {name}")
            failed.append(name)
            continue

        code_int = int(code_hex, 16)
        print(f"  {name} ({code_hex}): {len(paths)} paths")

        primitives = []
        for p in paths:
            escaped = escape_path_data(p)
            primitives.append(f"      WiredSvgPrimitive.path('{escaped}')")

        primitives_str = ',\n'.join(primitives)

        entry = f"""  // {name}
  0x{code_hex.lower()}: WiredSvgIconData(
    width: 72.0,
    height: 72.0,
    primitives: <WiredSvgPrimitive>[
{primitives_str},
    ],
  )"""
        entries.append(entry)

    entries_str = ',\n'.join(entries)

    dart_code = f"""// GENERATED CODE - DO NOT MODIFY BY HAND.
// ignore_for_file: lines_longer_than_80_chars

import '../wired_svg_icon_data.dart';

const Map<int, WiredSvgIconData> kSkribbleEmoji = <int, WiredSvgIconData>{{
{entries_str},
}};
"""

    return dart_code, failed


def generate_manifest():
    """Generate the manifest JSON."""
    icons = []
    for code_hex, name in EMOJIS:
        svg_path = os.path.join(EMOJI_DIR, f'{name}.svg')
        if not os.path.exists(svg_path):
            continue
        icons.append({
            "name": name,
            "codePoint": f"0x{code_hex}",
            "svgPath": f"../emoji/{name}.svg",
        })

    return json.dumps({"icons": icons}, indent=2)


if __name__ == '__main__':
    print("Generating emoji Dart code...")

    # Generate Dart
    dart_code, failed = generate_dart()

    # Write Dart file
    gen_dir = os.path.join(os.path.dirname(__file__), '..', 'lib', 'src', 'generated')
    os.makedirs(gen_dir, exist_ok=True)
    dart_path = os.path.join(gen_dir, 'skribble_emoji.g.dart')
    with open(dart_path, 'w') as f:
        f.write(dart_code)
    print(f"  Written: {dart_path}")

    # Generate manifest
    manifest = generate_manifest()
    manifest_path = os.path.join(os.path.dirname(__file__), 'skribble_emoji.manifest.json')
    with open(manifest_path, 'w') as f:
        f.write(manifest)
        f.write('\n')
    print(f"  Written: {manifest_path}")

    if failed:
        print(f"\n  FAILED: {', '.join(failed)}")
    else:
        print("\n  All emoji processed successfully!")
