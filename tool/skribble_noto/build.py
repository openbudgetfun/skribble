"""Build the skribble Noto fonts.

    python3 tool/skribble_noto/build.py SOURCE_DIR OUT_DIR [--only notosans,...] [--levels soft,...]

SOURCE_DIR holds Google Fonts' `ofl/noto*` folders (see README.md). Each
family is built once per level (Soft, Sketch, Lively) into
OUT_DIR/<level>/<File>-Regular.ttf. Re-stroked outlines are cached in
OUT_DIR/.cache, so Soft and Sketch, which share a pen, re-stroke only once.
"""

import os

# one BLAS thread per worker process; the pool already uses every core
for _var in ("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS"):
    os.environ.setdefault(_var, "1")

import argparse  # noqa: E402
import gzip
import json
import math
import multiprocessing as mp
import pickle
import re
import sys
import tempfile
import time

import numpy as np
from fontTools import subset
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import ink  # noqa: E402
import opentype  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))

# The three levels of hand-drawn-ness. Values are font units per 1,000 em.
LEVELS = {
    "soft": {"suffix": "", "pen": 1.0, "wobble": 6, "wavelength": 380, "bounce": 0,
             "bounce_rot": 0, "alternates": 1, "sx": 1.02, "track": 10},
    "sketch": {"suffix": "Sketch", "pen": 1.0, "wobble": 11, "wavelength": 380, "bounce": 9,
               "bounce_rot": 1.6, "alternates": 3, "sx": 1.02, "track": 14},
    "lively": {"suffix": "Lively", "pen": 1.1, "wobble": 14, "wavelength": 320, "bounce": 14,
               "bounce_rot": 2.5, "alternates": 3, "sx": 1.04, "track": 18},
}

LATIN_PEN = 40  # Soft pen radius for Noto Sans, the approved prototype
LATIN_DOT_AREA = 22000
SEED = "skribble"


def load_manifest():
    with open(os.path.join(HERE, "families.json")) as f:
        return json.load(f)


def category_of(family, manifest):
    for cat, names in manifest["categories"].items():
        if family in names:
            return cat
    return "other"


def script_name(source_family):
    """'Noto Sans Arabic' -> 'Arabic', 'Noto Sans' -> '', 'Noto Music' -> 'Music'."""
    s = re.sub(r"^Noto (Sans|Serif)\s*", "", source_family)
    return re.sub(r"^Noto\s*", "", s).strip()


def family_name(level, script):
    parts = ["Skribble Noto", LEVELS[level]["suffix"], script]
    return " ".join(p for p in parts if p)


def prepare_source(path, wght):
    """Static, unhinted copy of the source at the given weight."""
    font = TTFont(path)
    if "fvar" in font:
        axes = {a.axisTag: a for a in font["fvar"].axes}
        loc = {}
        if "wght" in axes:
            loc["wght"] = min(max(wght, axes["wght"].minValue), axes["wght"].maxValue)
        if "wdth" in axes:
            loc["wdth"] = 100
        for tag, a in axes.items():
            loc.setdefault(tag, a.defaultValue)
        font = instancer.instantiateVariableFont(font, loc)
    opts = subset.Options()
    opts.layout_features = ["*"]
    opts.name_IDs = ["*"]
    opts.name_languages = ["*"]
    opts.glyph_names = True
    opts.notdef_outline = True
    opts.notdef_glyph = True
    opts.hinting = False
    opts.legacy_kern = True
    opts.drop_tables += ["STAT", "DSIG"]
    sub = subset.Subsetter(opts)
    sub.populate(glyphs=font.getGlyphOrder())
    sub.subset(font)
    return font


# --- worker side ------------------------------------------------------------

_W = {}


def _init_worker(path):
    font = TTFont(path)
    _W["gs"] = font.getGlyphSet()


def _base_task(args):
    name, pen, r_out, res, dot_area = args
    try:
        polys = ink.flatten(_W["gs"], name)
        if not polys:
            return name, []
        return name, ink.compact(ink.ink_base(polys, pen, r_out, res, dot_area))
    except Exception as e:  # keep the source outline rather than fail the build
        print(f"  ! {name}: {e}", file=sys.stderr)
        return name, ink.compact(ink.union(ink.to_int(ink.flatten(_W["gs"], name))))


def _stem_task(name):
    polys = ink.flatten(_W["gs"], name)
    return ink.stroke_width(polys) if polys else None


def _level_task(args):
    name, base, variant, cfg, xheight, advance, tol = args
    polys = ink.wobble(base, name, variant, cfg, xheight, advance)
    if not polys:
        return name, variant, []
    cleaned = ink.to_float(ink.union(ink.to_int([p.tolist() for p in polys])))
    out = []
    for poly in cleaned:
        if len(poly) < 4 or abs(ink.area(poly)) < 4:
            continue
        out.append(ink.fit_spline(poly, tol).tolist())
    return name, variant, out


# --- one family -------------------------------------------------------------


def measure_stem(pool, font, sample=120):
    cmap = font.getBestCmap()
    glyf = font["glyf"]
    names = sorted({n for n in cmap.values() if glyf[n].numberOfContours > 0})
    if not names:
        return None
    step = max(1, len(names) // sample)
    widths = [w for w in pool.map(_stem_task, names[::step]) if w]
    return float(np.median(widths)) if widths else None


def build_family(src, family_key, out_dir, levels, manifest, workers):
    cat = category_of(family_key, manifest)
    params = manifest["params"][cat]
    t0 = time.time()
    script = source_script(src)
    font = prepare_source(src, params["wght"])
    upm = font["head"].unitsPerEm
    k = upm / 1000

    tmp = tempfile.NamedTemporaryFile(suffix=".ttf", delete=False)
    tmp.close()
    font.save(tmp.name)
    font = TTFont(tmp.name)
    glyf, hmtx = font["glyf"], font["hmtx"]
    order = font.getGlyphOrder()
    simple = [n for n in order if glyf[n].numberOfContours > 0]
    xheight = getattr(font["OS/2"], "sxHeight", 0) or 500 * k

    cache_dir = os.path.join(out_dir, ".cache")
    os.makedirs(cache_dir, exist_ok=True)
    with mp.Pool(workers, initializer=_init_worker, initargs=(tmp.name,)) as pool:
        if cat == "lgc":
            ratio = 1.0
        else:
            stem_path = os.path.join(cache_dir, f"{family_key}.stem.json")
            if os.path.exists(stem_path):
                stem = json.load(open(stem_path))["stem"]
            else:
                stem = measure_stem(pool, font)
                json.dump({"stem": stem}, open(stem_path, "w"))
            latin = manifest["latin_stem"]
            ratio = min(max((stem or latin) / latin, 0.55), 1.15)
        r_out = params["r_out"] * k * min(1.0, ratio)
        dot_area = LATIN_DOT_AREA * k * k * ratio * ratio
        pen = round(LATIN_PEN * k * ratio * params.get("pen", 1.0), 1)
        cache = os.path.join(cache_dir, f"{family_key}-pen{pen}.pkl.gz")
        if os.path.exists(cache):
            with gzip.open(cache, "rb") as f:
                base = {n: ink.compact(p) for n, p in pickle.load(f).items()}
        else:
            tasks = [(n, pen, r_out, params["res"], dot_area) for n in simple]
            base = dict(pool.imap_unordered(_base_task, tasks, chunksize=8))
            with gzip.open(cache, "wb") as f:
                pickle.dump(base, f)
            print(f"  {family_key}: re-stroked {len(simple)} glyphs, pen {pen} ({time.time() - t0:.0f}s)",
                  file=sys.stderr)
        for level in levels:
            # a wider pen is the same skeleton drawn wider: grow the outline instead of re-stroking
            grow = (LEVELS[level]["pen"] - 1) * pen
            level_base = base if not grow else {n: ink.compact(ink.offset(p, grow))
                                                for n, p in base.items()}
            write_level(pool, src, family_key, cat, params, level, script, level_base,
                        xheight, k, out_dir)
            del level_base
            print(f"  {family_key}: {level} done ({time.time() - t0:.0f}s)", file=sys.stderr)
    os.unlink(tmp.name)


def write_level(pool, src, family_key, cat, params, level, script, base, xheight, k, out_dir):
    lv = LEVELS[level]
    font = prepare_source(src, params["wght"])
    glyf, hmtx = font["glyf"], font["hmtx"]
    order = font.getGlyphOrder()
    lgc = cat == "lgc"
    cfg = {
        "seed": SEED,
        "wobble": lv["wobble"] * k * params["wobble"],
        "wavelength": lv["wavelength"] * k * params["wavelength"],
        "bounce": lv["bounce"] * k * params["bounce"],
        "bounce_rot": lv["bounce_rot"] * params["bounce"],
        "pin_edges": params["pin_edges"] * k,
    }
    n_alt = lv["alternates"] if lgc else 1
    sx = lv["sx"] if lgc else 1.0
    track = lv["track"] * k if lgc else 0.0

    alt_bases, alt_names = [], {}
    if n_alt > 1:
        alt_bases = [n for n in order if len(n) == 1 and n.isalpha()] + ["uni0251"]
        alt_bases = [n for n in alt_bases if n in base]
        new_order = list(order)
        for v in range(1, n_alt):
            for b in alt_bases:
                n = f"{b}.ink{v}"
                alt_names[(b, v)] = n
                new_order.append(n)
                glyf.glyphs[n] = glyf[b]
                hmtx[n] = hmtx[b]
        font.setGlyphOrder(new_order)
        glyf.glyphOrder = new_order
        order = new_order

    tasks = []
    for name in order:
        b, v = (name.rsplit(".ink", 1)[0], int(name.rsplit(".ink", 1)[1])) if ".ink" in name else (name, 0)
        if b in base and len(base[b]):
            tasks.append((b, base[b], v, cfg, xheight, hmtx[b][0], params["tol"] * k))
    drawn = {}
    for b, v, ctrls in pool.imap_unordered(_level_task, tasks, chunksize=8):
        drawn[alt_names[(b, v)] if v else b] = [np.asarray(c) for c in ctrls]

    zero_width = {n for n in order if hmtx[n][0] == 0}
    for name in order:
        g = glyf[name]
        adv = hmtx[name][0]
        shift = 0 if name in zero_width else track
        if name in drawn:
            pen = TTGlyphPen(None)
            ink.draw_glyph(pen, drawn[name], 0,
                           lambda x, y: (round(x * sx + shift), round(y)), fitted=True)
            glyf[name] = pen.glyph()
        elif g.isComposite():
            for c in g.components:
                c.x = round(c.x * sx)
                if name not in zero_width and c.glyphName in zero_width:
                    c.x += round(track)
        elif g.numberOfContours > 0:  # base failed entirely; keep the source outline, re-spaced
            pass
        hmtx[name] = (adv if name in zero_width else round(adv * sx + 2 * track), 0)
    for name in order:
        g = glyf[name]
        g.recalcBounds(glyf)
        hmtx[name] = (hmtx[name][0], getattr(g, "xMin", 0) if g.numberOfContours else 0)

    if lgc and (sx != 1 or track or alt_names):
        opentype.fix_gpos(font, sx, track, zero_width, alt_names)
    if lgc:
        opentype.add_features(font, alt_bases, alt_names, n_alt)

    family = family_name(level, script)
    opentype.rename(
        font, family,
        description=f"Hand-drawn {level} level of {script or 'Latin, Greek and Cyrillic'}, "
        f"generated from Noto by skribble.",
    )
    font["head"].modified = font["head"].created
    font.recalcTimestamp = False
    dest = os.path.join(out_dir, level)
    os.makedirs(dest, exist_ok=True)
    font.save(os.path.join(dest, file_name(level, script)))


def source_script(path):
    names = TTFont(path, lazy=True)["name"]
    return script_name(names.getDebugName(16) or names.getDebugName(1))


def file_name(level, script):
    return family_name(level, script).replace(" ", "") + "-Regular.ttf"


def source_file(src_root, key):
    folder = os.path.join(src_root, key)
    files = sorted(f for f in os.listdir(folder) if f.endswith(".ttf") and "-Italic" not in f)
    regular = [f for f in files if "-Regular" in f or "[" in f]
    return os.path.join(folder, (regular or files)[0])


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("src_root", help="folder with Google Fonts ofl/noto* folders")
    ap.add_argument("out_dir")
    ap.add_argument("--only", default="", help="comma-separated family keys, e.g. notosans,notosansarabic")
    ap.add_argument("--levels", default="soft,sketch,lively")
    ap.add_argument("--workers", type=int, default=os.cpu_count())
    args = ap.parse_args()
    manifest = load_manifest()
    keys = [k for k in args.only.split(",") if k] or manifest["families"]
    levels = [l for l in args.levels.split(",") if l]
    failed = []
    for key in keys:
        src = source_file(args.src_root, key)
        script = source_script(src)
        todo = [l for l in levels
                if not os.path.exists(os.path.join(args.out_dir, l, file_name(l, script)))]
        if not todo:
            continue
        print(f"{key}: building {', '.join(todo)}", file=sys.stderr, flush=True)
        try:
            build_family(src, key, args.out_dir, todo, manifest, args.workers)
        except Exception as e:  # one broken family must not stop the kit
            failed.append(key)
            print(f"{key}: FAILED {e!r}", file=sys.stderr, flush=True)
    if failed:
        print("failed: " + ", ".join(failed), file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    mp.set_start_method("fork")
    main()
