"""OpenType table work for the skribble Noto fonts: spacing fix-ups in GPOS,
contextual alternates and stylistic sets in GSUB, and naming."""

import copy

from fontTools.feaLib.builder import addOpenTypeFeaturesFromString

def fix_gpos(font, sx, track, zero_width, alt_names):
    """Scale x positions by sx, add tracking to base anchors, and give alternates their base glyph's kerning and anchors."""
    if "GPOS" not in font:
        return
    gpos = font["GPOS"].table
    gdef = font["GDEF"].table if "GDEF" in font else None
    alts_of = {}
    for (b, v), n in alt_names.items():
        alts_of.setdefault(b, []).append(n)
    gid = font.getGlyphID

    def scale_vr(vr):
        if vr is None:
            return
        for a in ("XPlacement", "XAdvance"):
            if hasattr(vr, a):
                setattr(vr, a, round(getattr(vr, a) * sx))

    def scale_anchor(a, shift):
        if a is not None:
            a.XCoordinate = round(a.XCoordinate * sx + shift)

    for lk in gpos.LookupList.Lookup:
        for st in lk.SubTable:
            t = lk.LookupType
            if t == 9:
                st = st.ExtSubTable
                t = st.LookupType
            if t == 1:
                if st.Format == 1:
                    scale_vr(st.Value)
                else:
                    for v in st.Value:
                        scale_vr(v)
            elif t == 2:
                if st.Format == 1:
                    for ps in st.PairSet:
                        for r in ps.PairValueRecord:
                            scale_vr(r.Value1)
                            scale_vr(r.Value2)
                    if alts_of:
                        cov = list(st.Coverage.glyphs)
                        for ps in st.PairSet:
                            extra = []
                            for r in ps.PairValueRecord:
                                for a in alts_of.get(r.SecondGlyph, []):
                                    nr = copy.deepcopy(r)
                                    nr.SecondGlyph = a
                                    extra.append(nr)
                            ps.PairValueRecord += extra
                            ps.PairValueRecord.sort(key=lambda r: gid(r.SecondGlyph))
                            ps.PairValueCount = len(ps.PairValueRecord)
                        pairs = list(zip(cov, st.PairSet))
                        for g, ps in list(pairs):
                            for a in alts_of.get(g, []):
                                pairs.append((a, copy.deepcopy(ps)))
                        pairs.sort(key=lambda p: gid(p[0]))
                        st.Coverage.glyphs = [p[0] for p in pairs]
                        st.PairSet = [p[1] for p in pairs]
                        st.PairSetCount = len(pairs)
                else:
                    for c1 in st.Class1Record:
                        for c2 in c1.Class2Record:
                            scale_vr(c2.Value1)
                            scale_vr(c2.Value2)
                    if alts_of:
                        cd1, cd2 = st.ClassDef1.classDefs, st.ClassDef2.classDefs
                        cov = st.Coverage.glyphs
                        for b, alts in alts_of.items():
                            for a in alts:
                                if b in cd1:
                                    cd1[a] = cd1[b]
                                if b in cd2:
                                    cd2[a] = cd2[b]
                                if b in cov:
                                    cov.append(a)
                        cov.sort(key=gid)
            elif t == 4:
                for r in st.MarkArray.MarkRecord:
                    scale_anchor(r.MarkAnchor, 0)
                cov = st.BaseCoverage.glyphs
                recs = st.BaseArray.BaseRecord
                for g, r in zip(cov, recs):
                    for a in r.BaseAnchor:
                        scale_anchor(a, 0 if g in zero_width else track)
                if alts_of:
                    pairs = list(zip(cov, recs))
                    for g, r in list(pairs):
                        for a in alts_of.get(g, []):
                            pairs.append((a, copy.deepcopy(r)))
                    pairs.sort(key=lambda p: gid(p[0]))
                    st.BaseCoverage.glyphs = [p[0] for p in pairs]
                    st.BaseArray.BaseRecord = [p[1] for p in pairs]
                    st.BaseArray.BaseCount = len(pairs)
            elif t == 5:
                for r in st.MarkArray.MarkRecord:
                    scale_anchor(r.MarkAnchor, 0)
                for g, la in zip(st.LigatureCoverage.glyphs, st.LigatureArray.LigatureAttach):
                    for cr in la.ComponentRecord:
                        for a in cr.LigatureAnchor:
                            scale_anchor(a, 0 if g in zero_width else track)
            elif t == 6:
                for r in st.Mark1Array.MarkRecord:
                    scale_anchor(r.MarkAnchor, 0)
                for r in st.Mark2Array.Mark2Record:
                    for a in r.Mark2Anchor:
                        scale_anchor(a, 0)
    if gdef and gdef.GlyphClassDef and alts_of:
        cd = gdef.GlyphClassDef.classDefs
        for b, alts in alts_of.items():
            for a in alts:
                if b in cd:
                    cd[a] = cd[b]


def add_features(font, alt_bases, alt_names, n_alt):
    """Add ss01 (single-storey a) and a calt lookup that cycles the alternates."""
    fea = []
    if "uni0251" in font.getGlyphOrder():
        fea.append("feature ss01 { sub a by uni0251; } ss01;")
    if n_alt > 1:
        cls = lambda v: " ".join(alt_names[(b, v)] if v else b for b in alt_bases)
        for v in range(n_alt):
            fea.append(f"@INK{v} = [{cls(v)}];")
        rules = "\n".join(
            f"  sub @INK{v} @INK0' by @INK{v + 1};" for v in range(n_alt - 1)
        )
        fea.append(f"feature calt {{\n  lookup inkcycle {{\n{rules}\n  }} inkcycle;\n}} calt;")
    if not fea:
        return
    orig = font["GSUB"] if "GSUB" in font else None
    if orig is not None:
        del font["GSUB"]
    addOpenTypeFeaturesFromString(font, "\n".join(fea), tables={"GSUB"})
    new = font["GSUB"].table
    if orig is None:
        return
    font["GSUB"] = orig
    merge_gsub(orig.table, new)


def shift_nested(obj, off):
    """Shift every nested SubstLookupRecord in a (chain) context subtable."""
    for r in getattr(obj, "SubstLookupRecord", None) or []:
        r.LookupListIndex += off
    for attr in ("ChainSubRuleSet", "ChainSubClassSet", "SubRuleSet", "SubClassSet"):
        for rs in getattr(obj, attr, None) or []:
            if rs is None:
                continue
            for rattr in ("ChainSubRule", "ChainSubClassRule", "SubRule", "SubClassRule"):
                for rule in getattr(rs, rattr, None) or []:
                    shift_nested(rule, off)


def merge_gsub(dst, src):
    off = len(dst.LookupList.Lookup)
    for lk in src.LookupList.Lookup:
        for st in lk.SubTable:
            shift_nested(st, off)
        dst.LookupList.Lookup.append(lk)
    dst.LookupList.LookupCount = len(dst.LookupList.Lookup)
    fl = dst.FeatureList.FeatureRecord
    new_idx = []
    for fr in src.FeatureList.FeatureRecord:
        fr.Feature.LookupListIndex = [i + off for i in fr.Feature.LookupListIndex]
        new_idx.append(len(fl))
        fl.append(fr)
    # attach to every langsys
    def langsyses(sl):
        for sr in sl.ScriptRecord:
            if sr.Script.DefaultLangSys:
                yield sr.Script.DefaultLangSys
            for lr in sr.Script.LangSysRecord:
                yield lr.LangSys
    for ls in langsyses(dst.ScriptList):
        ls.FeatureIndex = list(ls.FeatureIndex) + new_idx
    # sort features by tag and remap
    order = sorted(range(len(fl)), key=lambda i: fl[i].FeatureTag)
    remap = {old: new for new, old in enumerate(order)}
    dst.FeatureList.FeatureRecord = [fl[i] for i in order]
    dst.FeatureList.FeatureCount = len(fl)
    for ls in langsyses(dst.ScriptList):
        ls.FeatureIndex = sorted(remap[i] for i in ls.FeatureIndex)
        ls.FeatureCount = len(ls.FeatureIndex)
        if ls.ReqFeatureIndex != 0xFFFF:
            ls.ReqFeatureIndex = remap[ls.ReqFeatureIndex]




def rename(font, family, style="Regular", description=""):
    """Give the font its skribble family name, keeping the Noto copyright."""
    name = font["name"]
    ps = family.replace(" ", "") + "-" + style.replace(" ", "")
    noto_copyright = name.getDebugName(0) or "Copyright The Noto Project Authors"
    for rec in list(name.names):
        if rec.nameID in (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 16, 17, 21, 22, 25):
            name.removeNames(nameID=rec.nameID)
    records = {
        0: noto_copyright + ". Hand-drawn modifications Copyright 2026 The skribble Authors.",
        1: family,
        2: style,
        3: ps + ";skribble",
        4: f"{family} {style}" if style != "Regular" else family,
        5: "Version 1.000",
        6: ps,
        8: "skribble",
        10: description,
        11: "https://github.com/openbudgetfun/skribble",
    }
    for nid, val in records.items():
        if val:
            name.setName(val, nid, 3, 1, 0x409)
    font["OS/2"].achVendID = "SKRB"
