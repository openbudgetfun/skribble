"""Glyph geometry for the skribble Noto fonts.

Every simple glyph goes through the same steps, in font units:

1. flatten the outline to polygons and union them;
2. round the outer corners with a morphological opening;
3. re-draw the medial skeleton with a round pen of constant radius, so the
   letter reads as one drawn line (small marks keep their rounded shape);
4. push every point through a smooth displacement field and give the glyph a
   small rotation and baseline shift (the hand-drawn wobble and bounce);
5. fit a uniform quadratic B-spline, which TrueType stores as a contour of
   off-curve points only.

Steps 1-3 depend only on the pen, so their result is cached and shared by the
levels that use the same pen. Every random choice comes from a SHA-256 of the
seed, glyph name and variant, so builds are byte-identical.
"""

import hashlib
import math

import numpy as np
import pyclipper
from fontTools.pens.basePen import decomposeQuadraticSegment
from fontTools.pens.recordingPen import DecomposingRecordingPen
from PIL import Image, ImageDraw
from scipy import ndimage
from skimage.measure import find_contours
from skimage.morphology import skeletonize

SCALE = 8.0  # clipper works in integers: 1/8 font unit


def rng_for(*parts):
    digest = hashlib.sha256("|".join(map(str, parts)).encode()).digest()
    return np.random.default_rng(int.from_bytes(digest[:8], "little"))


def lerp(a, b, t):
    return (a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t)


def area(poly):
    return 0.5 * sum(
        poly[i - 1][0] * poly[i][1] - poly[i][0] * poly[i - 1][1] for i in range(len(poly))
    )


# --- outlines -> polygons ---------------------------------------------------


def flatten(glyphset, name, tol=3.0):
    """Outline of `name` (components decomposed) as polygons in font units."""
    rec = DecomposingRecordingPen(glyphset)
    glyphset[name].draw(rec)
    polys, cur = [], None

    def quad(p0, p1, p2):
        n = max(2, math.ceil((math.dist(p0, p1) + math.dist(p1, p2)) / tol))
        for i in range(1, n + 1):
            t = i / n
            a, b, c = (1 - t) ** 2, 2 * (1 - t) * t, t * t
            cur.append((a * p0[0] + b * p1[0] + c * p2[0], a * p0[1] + b * p1[1] + c * p2[1]))

    for op, args in rec.value:
        if op == "moveTo":
            cur = [args[0]]
        elif op == "lineTo":
            cur.append(args[0])
        elif op == "qCurveTo":
            if args[-1] is None:  # contour of off-curve points only
                pts = list(args[:-1])
                mids = [lerp(pts[i - 1], pts[i], 0.5) for i in range(len(pts))]
                cur = [mids[0]]
                for i in range(len(pts)):
                    quad(cur[-1], pts[i], mids[(i + 1) % len(pts)])
                continue
            for p1, p2 in decomposeQuadraticSegment(args):
                quad(cur[-1], p1, p2)
        elif op == "curveTo":
            p0, (p1, p2, p3) = cur[-1], args
            n = max(2, math.ceil((math.dist(p0, p1) + math.dist(p1, p2) + math.dist(p2, p3)) / tol))
            for i in range(1, n + 1):
                t = i / n
                mt = 1 - t
                cur.append(
                    tuple(
                        mt**3 * p0[k] + 3 * mt * mt * t * p1[k] + 3 * mt * t * t * p2[k] + t**3 * p3[k]
                        for k in (0, 1)
                    )
                )
        elif op in ("closePath", "endPath"):
            if cur and len(cur) > 2:
                polys.append(cur)
            cur = None
    return polys


def to_int(polys):
    return [[(round(x * SCALE), round(y * SCALE)) for x, y in p] for p in polys]


def to_float(ipolys):
    return [[(x / SCALE, y / SCALE) for x, y in p] for p in ipolys]


def union(ipolys, fill=pyclipper.PFT_NONZERO):
    if not ipolys:
        return []
    c = pyclipper.Pyclipper()
    c.AddPaths(ipolys, pyclipper.PT_SUBJECT, True)
    return c.Execute(pyclipper.CT_UNION, fill, fill)


def offset(ipolys, r):
    if not ipolys:
        return []
    o = pyclipper.PyclipperOffset(arc_tolerance=0.15 * SCALE)
    o.AddPaths(ipolys, pyclipper.JT_ROUND, pyclipper.ET_CLOSEDPOLYGON)
    return o.Execute(r * SCALE)


def split_small(ipolys, max_area):
    """Split polygons into small components (with their holes) and the rest."""
    outers = [p for p in ipolys if pyclipper.Orientation(p)]
    holes = [p for p in ipolys if not pyclipper.Orientation(p)]
    owner = {}
    for hi, h in enumerate(holes):
        best = None
        for oi, o in enumerate(outers):
            if pyclipper.PointInPolygon(h[0], o) and (
                best is None or abs(pyclipper.Area(o)) < abs(pyclipper.Area(outers[best]))
            ):
                best = oi
        owner[hi] = best
    small, big = [], []
    for oi, o in enumerate(outers):
        mine = [holes[hi] for hi, b in owner.items() if b == oi]
        net = abs(pyclipper.Area(o)) - sum(abs(pyclipper.Area(h)) for h in mine)
        (small if net < max_area else big).extend([o] + mine)
    return small, big


# --- monoline re-stroke -----------------------------------------------------

PAD = 120
NEIGHBOURS = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]


def rasterize(polys, res):
    xs = [x for p in polys for x, _ in p]
    ys = [y for p in polys for _, y in p]
    x0, y0 = min(xs) - PAD, min(ys) - PAD
    w = int(math.ceil((max(xs) - x0 + PAD) * res))
    h = int(math.ceil((max(ys) - y0 + PAD) * res))
    img = Image.new("L", (w, h), 0)
    draw = ImageDraw.Draw(img)
    for p in sorted(polys, key=lambda p: -abs(area(p))):
        draw.polygon(
            [((x - x0) * res, h - 1 - (y - y0) * res) for x, y in p],
            fill=255 if area(p) > 0 else 0,
        )
    return np.array(img) > 127, (x0, y0, h, res)


def prune(skel, max_len):
    """Drop skeleton branches shorter than max_len pixels that end freely."""
    sk = skel.copy()
    for _ in range(3):
        count = ndimage.convolve(sk.astype(np.uint8), np.ones((3, 3), np.uint8), mode="constant") - 1
        count[~sk] = 0
        changed = False
        for end in zip(*np.nonzero(sk & (count == 1))):
            path, prev, cur = [end], None, end
            seen = {end}
            while len(path) <= max_len:
                nxt = []
                for dy, dx in NEIGHBOURS:
                    q = (cur[0] + dy, cur[1] + dx)
                    if 0 <= q[0] < sk.shape[0] and 0 <= q[1] < sk.shape[1] and sk[q] and q != prev and q not in seen:
                        nxt.append(q)
                if len(nxt) != 1:
                    break
                prev, cur = cur, nxt[0]
                if count[cur] >= 3:  # reached a junction, so this is a spur
                    for p in path:
                        sk[p] = False
                    changed = True
                    break
                path.append(cur)
                seen.add(cur)
        if not changed:
            break
    return sk


def stroke_width(polys, res=0.5):
    """Median stroke width of a glyph, from the distance transform on its skeleton."""
    polys = to_float(union(to_int(polys)))
    if not polys:
        return None
    mask, (_, _, _, res) = rasterize(polys, res)
    skel = skeletonize(mask)
    if skel.sum() < 10:
        return None
    dist = ndimage.distance_transform_edt(mask)
    return float(np.median(dist[skel])) * 2 / res


def restroke(polys, radius, res, spur):
    mask, (x0, y0, h, res) = rasterize(polys, res)
    skel = prune(skeletonize(mask), int(spur * res))
    dist = ndimage.distance_transform_edt(~skel)
    out = []
    for c in find_contours(dist, radius * res):
        pts = [(col / res + x0, (h - 1 - row) / res + y0) for row, col in c]
        if len(pts) > 3:
            out.append(pts[:-1])
    return out


def ink_base(polys, pen, r_out, res, dot_area):
    """Steps 1-3: rounded, re-stroked glyph as clipper integer polygons."""
    ip = union(to_int(polys))
    if r_out > 0:
        ip = offset(offset(ip, -r_out), r_out)
    if not ip:
        return []
    small, big = split_small(ip, dot_area * SCALE * SCALE)
    stroked = []
    if big:
        stroked = union(to_int(restroke(to_float(big), pen, res, spur=pen * 1.2)), pyclipper.PFT_EVENODD)
    return union(stroked + small)


# --- hand-drawn wobble ------------------------------------------------------


class Field:
    """Smooth 2D displacement: a few random plane waves per axis."""

    def __init__(self, rng, amp, wavelength, waves=4):
        self.terms = []
        for axis in (0, 1):
            for _ in range(waves):
                ang = rng.uniform(0, 2 * math.pi)
                wl = wavelength * rng.uniform(0.7, 1.5)
                k = 2 * math.pi / wl
                self.terms.append(
                    (axis, math.cos(ang) * k, math.sin(ang) * k, rng.uniform(0, 2 * math.pi),
                     amp * rng.uniform(0.5, 1.0) / math.sqrt(waves))
                )

    def __call__(self, x, y):
        d = np.zeros((2,) + np.shape(x))
        for axis, kx, ky, ph, a in self.terms:
            d[axis] += a * np.sin(kx * x + ky * y + ph)
        return d


def resample(poly, spacing):
    pts = np.asarray(poly + [poly[0]], dtype=float)
    seg = np.hypot(*np.diff(pts, axis=0).T)
    cum = np.concatenate([[0], np.cumsum(seg)])
    total = cum[-1]
    n = max(8, int(round(total / spacing)))
    t = np.arange(n) * total / n
    return np.stack([np.interp(t, cum, pts[:, 0]), np.interp(t, cum, pts[:, 1])], axis=1)


def wobble(ipolys, name, variant, cfg, xheight, advance):
    """Step 4. Returns dense float polygons (numpy arrays)."""
    # light smoothing removes the pixel ripple the raster skeleton leaves behind
    polys = [ndimage.gaussian_filter1d(resample(p, 4.0), 2.5, axis=0, mode="wrap")
             for p in to_float(ipolys) if len(p) > 2]
    if not polys or not (cfg["wobble"] or cfg["bounce"]):
        return polys
    rng = rng_for(cfg["seed"], name, variant)
    field = Field(rng, cfg["wobble"], cfg["wavelength"])
    xs = np.concatenate([p[:, 0] for p in polys])
    cx, cy = (xs.min() + xs.max()) / 2, xheight / 2
    bounce = cfg["bounce"]
    th = math.radians(rng.normal(0, cfg["bounce_rot"])) if bounce else 0.0
    dy = rng.normal(0, bounce) if bounce else 0.0
    ct, st = math.cos(th), math.sin(th)
    out = []
    for p in polys:
        x, y = p[:, 0], p[:, 1]
        d = field(x, y)
        if cfg["pin_edges"] and advance > 0:
            # joining scripts: no movement where a letter meets its neighbour
            edge = np.minimum(np.abs(x), np.abs(advance - x)) / cfg["pin_edges"]
            w = np.clip(edge, 0, 1)
            w = w * w * (3 - 2 * w)
            d = d * w
        x, y = x + d[0] - cx, y + d[1] - cy
        out.append(np.stack([x * ct - y * st + cx, x * st + y * ct + cy + dy], axis=1))
    return out


# --- compact curves ---------------------------------------------------------


def _basis(u, n):
    """Weights of a uniform periodic quadratic B-spline at parameters u in [0, n)."""
    i = np.floor(u).astype(int) % n
    s = u - np.floor(u)
    w0, w1, w2 = (1 - s) ** 2 / 2, (1 - s) ** 2 / 2 + 2 * s * (1 - s) + s * s / 2, s * s / 2
    rows = np.arange(len(u))
    a = np.zeros((len(u), n))
    np.add.at(a, (rows, (i - 1) % n), w0)
    np.add.at(a, (rows, i), w1)
    np.add.at(a, (rows, (i + 1) % n), w2)
    return a


DENSE = 12  # curve samples per control point when measuring the fit
WINDOW = 3 * DENSE


def _nearest(pts, curve, guess):
    """Nearest curve sample for each point, searching a window around its guess."""
    k = len(curve)
    idx = (guess[:, None] + np.arange(-WINDOW, WINDOW + 1)[None, :]) % k
    d2 = ((curve[idx] - pts[:, None, :]) ** 2).sum(-1)
    return idx[np.arange(len(pts)), d2.argmin(1)]


def _dist_to_polyline(pts, curve, j):
    """Distance from each point to the closed polyline `curve` near sample j."""
    k = len(curve)
    best = np.full(len(pts), np.inf)
    for a_idx, b_idx in (((j - 1) % k, j), (j, (j + 1) % k)):
        a, b = curve[a_idx], curve[b_idx]
        ab = b - a
        t = np.clip(((pts - a) * ab).sum(1) / np.maximum((ab * ab).sum(1), 1e-12), 0, 1)
        best = np.minimum(best, np.hypot(*(a + ab * t[:, None] - pts).T))
    return best


def _solve(a, pts, n, smooth=0.05):
    """Least squares with a light second-difference penalty, so a control point
    that no sample pins down stays between its neighbours instead of at zero."""
    reg = np.zeros((n, n))
    idx = np.arange(n)
    reg[idx, (idx - 1) % n] = smooth
    reg[idx, idx] = -2 * smooth
    reg[idx, (idx + 1) % n] = smooth
    lhs = np.vstack([a, reg])
    rhs = np.vstack([pts, np.zeros((n, 2))])
    return np.linalg.lstsq(lhs, rhs, rcond=None)[0]


def fit_spline(pts, tol, spacing=40):
    """Fewest off-curve control points whose implied TrueType spline stays within tol.

    A contour of off-curve points only is a uniform periodic quadratic B-spline,
    so this is a least-squares fit with parameter correction, growing the number
    of control points until every sample is within tol.
    """
    pts = np.asarray(pts, dtype=float)
    m = len(pts)
    seg = np.hypot(*np.diff(np.vstack([pts, pts[:1]]), axis=0).T)
    total = seg.sum()
    cum = np.concatenate([[0], np.cumsum(seg)])[:-1] / total
    n = max(4, int(total / spacing))
    while True:
        u = cum * n
        dense_u = np.arange(n * DENSE) / DENSE
        dense_basis = _basis(dense_u, n)
        for _ in range(2):
            ctrl = _solve(_basis(u, n), pts, n)
            curve = dense_basis @ ctrl
            j = _nearest(pts, curve, np.round(u * DENSE).astype(int) % (n * DENSE))
            u = dense_u[j]
        err = _dist_to_polyline(pts, curve, j)
        # inner corners may round off a little (it reads as ink pooling at joins)
        if (np.percentile(err, 98) <= tol and err.max() <= 3 * tol) or n * 2 >= m:
            return ctrl
        n = int(n * 1.2) + 1


def draw_glyph(pen, contours, tol, xform, fitted=False):
    """Draw contours as off-curve-only TrueType splines (fitting them unless already fitted)."""
    for poly in contours:
        ctrl = poly if fitted else fit_spline(poly, tol)
        pts = [xform(x, y) for x, y in ctrl]
        pts.reverse()  # clipper outers run counter-clockwise; TrueType wants clockwise
        pts = [p for i, p in enumerate(pts) if p != pts[i - 1]]
        if len(pts) < 3:
            continue
        pen.qCurveTo(*pts, None)
        pen.closePath()
