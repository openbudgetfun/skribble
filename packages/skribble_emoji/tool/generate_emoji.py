#!/usr/bin/env python3
"""Generate Dart emoji maps from OpenMoji SVGs and the OpenMoji CSV catalog.

Downloads the OpenMoji catalog CSV, cross-references it with a directory of
OpenMoji SVG files, and produces two Dart generated files:

  - skribble_emoji.g.dart        (codepoint -> WiredSvgIconData map)
  - skribble_emoji_codepoints.g.dart  (name -> codepoint map)

Usage:
  python3 tool/generate_emoji.py \
      --svg-dir /tmp/openmoji-svgs \
      --output-dir lib/src/generated/

  python3 tool/generate_emoji.py \
      --svg-dir /tmp/openmoji-svgs \
      --csv-url https://raw.githubusercontent.com/hfg-gmuend/openmoji/master/data/openmoji.csv \
      --output-dir lib/src/generated/
"""

import argparse
import csv
import io
import os
import re
import sys
import xml.etree.ElementTree as ET
from urllib.request import urlopen

DEFAULT_CSV_URL = (
    'https://raw.githubusercontent.com/hfg-gmuend/openmoji/master/data/openmoji.csv'
)


# ---------------------------------------------------------------------------
# SVG shape -> path-data converters (reused from generate_emoji_dart.py)
# ---------------------------------------------------------------------------


def polygon_points_to_path(points_str: str) -> str:
    """Convert a polygon ``points`` attribute to an SVG path ``d`` string."""
    points_str = points_str.strip()
    parts = re.split(r'\s+', points_str)
    if not parts:
        return ''

    path_parts: list[str] = []
    for i, part in enumerate(parts):
        if ',' in part:
            x, y = part.split(',', 1)
            path_parts.append(f'M{x} {y}' if i == 0 else f'L{x} {y}')

    if path_parts:
        path_parts.append('Z')
        return ''.join(path_parts)

    # Fallback: space-separated values
    values: list[str] = []
    for part in parts:
        if ',' in part:
            values.extend(part.split(','))
        else:
            values.append(part)

    path_parts = []
    for i in range(0, len(values) - 1, 2):
        x, y = values[i], values[i + 1]
        path_parts.append(f'M{x} {y}' if i == 0 else f'L{x} {y}')
    path_parts.append('Z')
    return ''.join(path_parts)


def circle_to_path(cx: float, cy: float, r: float) -> str:
    return (
        f'M{cx - r},{cy}'
        f'A{r},{r},0,1,0,{cx + r},{cy}'
        f'A{r},{r},0,1,0,{cx - r},{cy}Z'
    )


def ellipse_to_path(cx: float, cy: float, rx: float, ry: float) -> str:
    return (
        f'M{cx - rx},{cy}'
        f'A{rx},{ry},0,1,0,{cx + rx},{cy}'
        f'A{rx},{ry},0,1,0,{cx - rx},{cy}Z'
    )


def rect_to_path(
    x: float, y: float, w: float, h: float, rx: float = 0, ry: float = 0
) -> str:
    if rx == 0 and ry == 0:
        return f'M{x},{y}L{x+w},{y}L{x+w},{y+h}L{x},{y+h}Z'
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


# ---------------------------------------------------------------------------
# SVG extraction
# ---------------------------------------------------------------------------


def _should_skip_element(elem: ET.Element) -> bool:
    fill = elem.get('fill', '')
    stroke = elem.get('stroke', '')
    if fill.lower() == 'none' and (not stroke or stroke.lower() == 'none'):
        return True
    return False


def extract_paths(svg_file: str) -> list[str]:
    """Return all path ``d`` strings from *svg_file*."""
    try:
        tree = ET.parse(svg_file)
    except ET.ParseError:
        return []

    root = tree.getroot()
    paths: list[str] = []

    def process(elem: ET.Element) -> None:
        tag = elem.tag.split('}')[-1] if '}' in elem.tag else elem.tag

        if tag == 'path':
            d = elem.get('d', '').strip()
            if d and d.lower() != 'none' and not _should_skip_element(elem):
                paths.append(d)

        elif tag == 'polygon':
            pts = elem.get('points', '').strip()
            if pts and not _should_skip_element(elem):
                pd = polygon_points_to_path(pts)
                if pd:
                    paths.append(pd)

        elif tag == 'polyline':
            pts = elem.get('points', '').strip()
            if pts and not _should_skip_element(elem):
                pd = polygon_points_to_path(pts).rstrip('Z')
                if pd:
                    paths.append(pd)

        elif tag == 'circle':
            if not _should_skip_element(elem):
                cx = float(elem.get('cx', 0))
                cy = float(elem.get('cy', 0))
                r = float(elem.get('r', 0))
                if r > 0:
                    paths.append(circle_to_path(cx, cy, r))

        elif tag == 'ellipse':
            if not _should_skip_element(elem):
                cx = float(elem.get('cx', 0))
                cy = float(elem.get('cy', 0))
                rx = float(elem.get('rx', 0))
                ry = float(elem.get('ry', 0))
                if rx > 0 and ry > 0:
                    paths.append(ellipse_to_path(cx, cy, rx, ry))

        elif tag == 'rect':
            if not _should_skip_element(elem):
                x = float(elem.get('x', 0))
                y = float(elem.get('y', 0))
                w = float(elem.get('width', 0))
                h = float(elem.get('height', 0))
                rx = float(elem.get('rx', 0))
                ry = float(elem.get('ry', 0))
                if w > 0 and h > 0:
                    paths.append(rect_to_path(x, y, w, h, rx, ry))

        elif tag == 'line':
            if not _should_skip_element(elem):
                x1 = elem.get('x1', '0')
                y1 = elem.get('y1', '0')
                x2 = elem.get('x2', '0')
                y2 = elem.get('y2', '0')
                paths.append(f'M{x1},{y1}L{x2},{y2}')

        for child in elem:
            process(child)

    process(root)
    return paths


# ---------------------------------------------------------------------------
# Name normalization
# ---------------------------------------------------------------------------

_NON_ALPHA = re.compile(r'[^a-z0-9_]+')
_MULTI_UNDERSCORE = re.compile(r'_+')


def annotation_to_identifier(annotation: str) -> str:
    """Convert an OpenMoji annotation to a Dart-safe snake_case identifier."""
    s = annotation.lower().strip()
    s = s.replace(' ', '_').replace('-', '_')
    s = _NON_ALPHA.sub('', s)
    s = _MULTI_UNDERSCORE.sub('_', s).strip('_')
    # Ensure it doesn't start with a digit (Dart identifiers)
    if s and s[0].isdigit():
        s = 'emoji_' + s
    return s


# ---------------------------------------------------------------------------
# Escape helper
# ---------------------------------------------------------------------------


def _escape(d: str) -> str:
    return d.replace("'", "\\'")


# ---------------------------------------------------------------------------
# Dart code generation
# ---------------------------------------------------------------------------


def generate_emoji_dart(entries: list[tuple[int, str, list[str]]]) -> str:
    """Return the contents of ``skribble_emoji.g.dart``."""
    lines: list[str] = [
        '// GENERATED CODE - DO NOT MODIFY BY HAND.',
        '// ignore_for_file: lines_longer_than_80_chars',
        '',
        "import '../wired_svg_icon_data.dart';",
        '',
        'const Map<int, WiredSvgIconData> kSkribbleEmoji = <int, WiredSvgIconData>{',
    ]

    for codepoint, name, path_list in entries:
        hex_str = format(codepoint, 'x')
        lines.append(f'  // {name}')
        lines.append(f'  0x{hex_str}: WiredSvgIconData(')
        lines.append('    width: 72.0,')
        lines.append('    height: 72.0,')
        lines.append('    primitives: <WiredSvgPrimitive>[')
        for p in path_list:
            lines.append(f"      WiredSvgPrimitive.path('{_escape(p)}'),")
        lines.append('    ],')
        lines.append('  ),')

    lines.append('};')
    lines.append('')
    return '\n'.join(lines)


def generate_codepoints_dart(
    entries: list[tuple[int, str, list[str]]],
) -> str:
    """Return the contents of ``skribble_emoji_codepoints.g.dart``."""
    lines: list[str] = [
        '// GENERATED CODE - DO NOT MODIFY BY HAND.',
        '// ignore_for_file: lines_longer_than_80_chars',
        '',
        "/// Maps each emoji identifier string to its Unicode codepoint in",
        "/// `kSkribbleEmoji`.",
        'const Map<String, int> kSkribbleEmojiCodePoints = <String, int>{',
    ]

    for codepoint, name, _ in entries:
        hex_str = format(codepoint, 'x')
        lines.append(f"  '{name}': 0x{hex_str},")

    lines.append('};')
    lines.append('')
    return '\n'.join(lines)


# ---------------------------------------------------------------------------
# Main pipeline
# ---------------------------------------------------------------------------


def main() -> None:
    parser = argparse.ArgumentParser(
        description='Generate Dart emoji maps from OpenMoji SVGs.'
    )
    parser.add_argument(
        '--svg-dir',
        required=True,
        help='Directory containing OpenMoji SVG files (named <HEXCODE>.svg).',
    )
    parser.add_argument(
        '--csv-url',
        default=DEFAULT_CSV_URL,
        help='URL of the OpenMoji catalog CSV.',
    )
    parser.add_argument(
        '--csv-file',
        default=None,
        help='Path to a local copy of the OpenMoji CSV (overrides --csv-url).',
    )
    parser.add_argument(
        '--output-dir',
        required=True,
        help='Directory where generated .g.dart files are written.',
    )
    args = parser.parse_args()

    svg_dir = os.path.abspath(args.svg_dir)
    output_dir = os.path.abspath(args.output_dir)
    os.makedirs(output_dir, exist_ok=True)

    # ------------------------------------------------------------------
    # 1. Load the catalog CSV
    # ------------------------------------------------------------------
    if args.csv_file:
        print(f'Reading local CSV: {args.csv_file}')
        with open(args.csv_file, encoding='utf-8') as f:
            csv_text = f.read()
    else:
        print(f'Downloading CSV from: {args.csv_url}')
        csv_text = urlopen(args.csv_url).read().decode('utf-8')

    reader = csv.DictReader(io.StringIO(csv_text))
    rows = list(reader)
    print(f'Catalog rows: {len(rows)}')

    # ------------------------------------------------------------------
    # 2. Filter and process
    # ------------------------------------------------------------------
    entries: list[tuple[int, str, list[str]]] = []
    seen_codepoints: set[int] = set()
    seen_names: set[str] = set()

    skipped_skin = 0
    skipped_zwj = 0
    skipped_missing = 0
    skipped_no_paths = 0
    skipped_dup_cp = 0
    skipped_dup_name = 0
    processed = 0

    for i, row in enumerate(rows):
        hexcode = row['hexcode'].strip()
        annotation = row.get('annotation', '').strip()
        skintone = row.get('skintone', '').strip()

        # Skip skin-tone variants
        if skintone:
            skipped_skin += 1
            continue

        # Count codepoint segments
        parts = hexcode.split('-')
        # Filter out FE0F (variation selector) when counting meaningful parts
        meaningful = [p for p in parts if p != 'FE0F']
        if len(meaningful) >= 3:
            skipped_zwj += 1
            continue

        # SVG filename matches the full hexcode (with dashes)
        svg_file = os.path.join(svg_dir, f'{hexcode}.svg')
        if not os.path.isfile(svg_file):
            skipped_missing += 1
            continue

        # Primary codepoint = first codepoint in the hexcode
        primary_cp = int(parts[0], 16)

        # Deduplicate by codepoint
        if primary_cp in seen_codepoints:
            skipped_dup_cp += 1
            continue

        # Build identifier from annotation
        name = annotation_to_identifier(annotation) if annotation else ''
        if not name:
            name = f'emoji_{hexcode.lower().replace("-", "_")}'

        # Deduplicate by name
        if name in seen_names:
            # Append codepoint to make unique
            name = f'{name}_{format(primary_cp, "x")}'
        if name in seen_names:
            skipped_dup_name += 1
            continue

        # Extract paths from SVG
        path_list = extract_paths(svg_file)
        if not path_list:
            skipped_no_paths += 1
            continue

        seen_codepoints.add(primary_cp)
        seen_names.add(name)
        entries.append((primary_cp, name, path_list))
        processed += 1

        if processed % 500 == 0:
            print(f'  Processing {processed}/{len(rows)}...')

    # ------------------------------------------------------------------
    # 3. Sort by codepoint for stable output
    # ------------------------------------------------------------------
    entries.sort(key=lambda e: e[0])

    # ------------------------------------------------------------------
    # 4. Write output files
    # ------------------------------------------------------------------
    emoji_path = os.path.join(output_dir, 'skribble_emoji.g.dart')
    with open(emoji_path, 'w', encoding='utf-8') as f:
        f.write(generate_emoji_dart(entries))
    print(f'Written: {emoji_path}')

    cp_path = os.path.join(output_dir, 'skribble_emoji_codepoints.g.dart')
    with open(cp_path, 'w', encoding='utf-8') as f:
        f.write(generate_codepoints_dart(entries))
    print(f'Written: {cp_path}')

    # ------------------------------------------------------------------
    # 5. Summary
    # ------------------------------------------------------------------
    print()
    print('=== Summary ===')
    print(f'Catalog rows:          {len(rows)}')
    print(f'Included:              {len(entries)}')
    print(f'Skipped (skin tones):  {skipped_skin}')
    print(f'Skipped (3+ ZWJ):      {skipped_zwj}')
    print(f'Skipped (missing SVG): {skipped_missing}')
    print(f'Skipped (no paths):    {skipped_no_paths}')
    print(f'Skipped (dup codepoint): {skipped_dup_cp}')
    print(f'Skipped (dup name):    {skipped_dup_name}')


if __name__ == '__main__':
    main()
