"""List the characters the Noto sources draw that a built Skribble Noto level does not.

Usage: python3 tool/skribble_noto/coverage.py SRC_ROOT LEVEL_DIR

SRC_ROOT is the Google Fonts ofl/ folder with the noto* families; LEVEL_DIR is
one level of the build output, such as build/noto/sketch. Colour emoji are
skipped. Exits 1 when anything is missing, after printing the gaps by script
and by source family.
"""

import collections
import glob
import os
import sys

from fontTools import unicodedata
from fontTools.ttLib import TTFont


def characters(path):
    return set(TTFont(path, lazy=True).getBestCmap() or {})


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    src_root, level_dir = sys.argv[1:]
    sources = {}
    for folder in sorted(glob.glob(os.path.join(src_root, "noto*"))):
        key = os.path.basename(folder)
        if "emoji" in key:
            continue
        for path in glob.glob(os.path.join(folder, "*.ttf")):
            if "Italic" not in os.path.basename(path):
                sources.setdefault(key, set()).update(characters(path))
    built = set()
    files = glob.glob(os.path.join(level_dir, "*-Regular.ttf"))
    for path in files:
        built |= characters(path)
    wanted = set().union(*sources.values())
    missing = wanted - built
    print(f"{len(files)} files cover {len(wanted & built)} of {len(wanted)} Noto characters")
    if not missing:
        return
    scripts = collections.Counter(unicodedata.script_name(unicodedata.script(c)) for c in missing)
    print("missing by script: " + ", ".join(f"{s} {n}" for s, n in scripts.most_common()))
    for key, chars in sorted(sources.items()):
        gap = sorted(chars & missing)
        if gap:
            sample = " ".join(f"U+{c:04X}" for c in gap[:12])
            print(f"  {key}: {len(gap)} ({sample}{' ...' if len(gap) > 12 else ''})")
    sys.exit(1)


if __name__ == "__main__":
    main()
