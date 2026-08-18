"""Validate the 绪论 page of test_sty.pdf (typst) against docx_template.pdf.

Only the region from the "（空 2行，小四号，下同）" instruction line through the
paragraph that contains "可听化（Auralization）... 主观感知[...]。" is compared
(everything after, e.g. lorem ipsum / trailing template notes, is ignored).

Output: test/validate_1.md (and the same report to stdout).
"""

from __future__ import annotations

import re
from collections import Counter
from pathlib import Path

import pdfplumber as pb


CANON = "docx_template.pdf"   # canonical WPS-rendered docx template
MIMIC = "test_sty.pdf"        # typst output to validate
CANON_PAGE = 15               # 0-based index of the 绪论 page
MIMIC_PAGE = 3

Y_TOL = 3.0                   # pt: merge chars into a visual line
GEOM_TOL = 0.05               # pt

ANNOT_RE = re.compile(r"（(?:三|四|五|小三|小四|小二|一号|二号)号[^）]*）")
SUBSET_RE = re.compile(r"^[A-Z0-9]{6}\+")
ASCII_RE = re.compile(r"[A-Za-z0-9.~\-–]")


def visual_lines(page: pb.Page) -> list[dict]:
    """Group chars into visual lines (mixed CJK/Latin runs share a line)."""
    chars = sorted(page.chars, key=lambda c: (c["top"], c["x0"]))
    clusters: list[list] = []
    for c in chars:
        if clusters and c["top"] - min(x["top"] for x in clusters[-1]) <= Y_TOL:
            clusters[-1].append(c)
        else:
            clusters.append([c])

    lines = []
    for cluster in clusters:
        cs = sorted(cluster, key=lambda c: (round(c["x0"], 3), round(c["top"], 3)))
        dominant = Counter(round(c["size"], 3) for c in cs).most_common(1)[0][0]
        body = [c for c in cs if c["size"] >= 0.8 * dominant and c["text"].strip()]
        subs = [c for c in cs if c["size"] < 0.8 * dominant and c["text"].strip()]
        ascii_chars = [c for c in body if ASCII_RE.search(c["text"])]
        lines.append(
            {
                "top": min((c["top"] for c in body),
                           default=min(c["top"] for c in cs)),
                "bottom": max(c["bottom"] for c in cs),
                "x0": min(c["x0"] for c in cs),
                "x1": max(c["x1"] for c in cs),
                "text": "".join(c["text"] for c in cs),
                "sizes": Counter(round(c["size"], 3) for c in cs),
                "fonts": Counter(c["fontname"] for c in cs),
                "sub_top": min((c["top"] for c in subs), default=None),
                "ascii_top": min((c["top"] for c in ascii_chars), default=None),
            }
        )
    return lines


def norm_text(text: str) -> str:
    """Remove whitespace and template annotations like （三号黑体）."""
    text = ANNOT_RE.sub("", text)
    return re.sub(r"\s+", "", text)


def region(lines: list[dict]) -> list[dict]:
    start = next(i for i, ln in enumerate(lines) if re.search(r"空\s*2", ln["text"]))
    end = next(i for i, ln in enumerate(lines) if "主观感知" in ln["text"])
    return lines[start : end + 1]


def fam(fontname: str) -> str:
    return SUBSET_RE.sub("", fontname)


def main() -> None:
    out: list[str] = []

    def emit(s: str = "") -> None:
        print(s)
        out.append(s)

    with pb.open(CANON) as pdf:
        pg_a = pdf.pages[CANON_PAGE]
        geom_a = (pg_a.width, pg_a.height)
        la = region(visual_lines(pg_a))
    with pb.open(MIMIC) as pdf:
        pg_b = pdf.pages[MIMIC_PAGE]
        geom_b = (pg_b.width, pg_b.height)
        lb = region(visual_lines(pg_b))

    emit(f"# 绪论 page validation: {CANON} (canonical) vs {MIMIC} (typst)")
    emit()
    emit(f"- canonical page: {CANON_PAGE + 1} (size {geom_a[0]:.2f} x {geom_a[1]:.2f} pt)")
    emit(f"- mimic page: {MIMIC_PAGE + 1} (size {geom_b[0]:.2f} x {geom_b[1]:.2f} pt)")
    emit(f"- page geometry diff: {geom_b[0] - geom_a[0]:+.4f} x {geom_b[1] - geom_a[1]:+.4f} pt")
    emit(f"- region: '（空 2行，小四号，下同）' .. '主观感知[...]。' ({len(la)} lines)")
    emit()

    assert len(la) == len(lb), f"region line count differs: {len(la)} vs {len(lb)}"

    pitch_a = [la[i + 1]["top"] - la[i]["top"] for i in range(len(la) - 1)]
    pitch_b = [lb[i + 1]["top"] - lb[i]["top"] for i in range(len(lb) - 1)]

    emit("## Per-line comparison")
    emit()
    emit("| # | docx text | typst text | dTop | dX0 | dX1 | dPitch | "
         "size docx->typst | fonts |")
    emit("|---:|:--|:--|--:|--:|--:|--:|:--|:--|")

    deviations: list[dict] = []
    for i, (a, b) in enumerate(zip(la, lb)):
        dt = b["top"] - a["top"]
        dx0 = b["x0"] - a["x0"]
        dx1 = b["x1"] - a["x1"]
        dp = pitch_b[i] - pitch_a[i] if i < len(pitch_a) else 0.0
        size_a = a["sizes"].most_common(1)[0][0]
        size_b = b["sizes"].most_common(1)[0][0]
        d_sub = None
        if a["sub_top"] is not None and b["sub_top"] is not None:
            d_sub = (b["sub_top"] - b["top"]) - (a["sub_top"] - a["top"])
        d_ascii = None
        if a["ascii_top"] is not None and b["ascii_top"] is not None:
            d_ascii = (b["ascii_top"] - b["top"]) - (a["ascii_top"] - a["top"])

        flags: list[str] = []
        if a["text"] != b["text"]:
            flags.append("text")
        if norm_text(a["text"]) != norm_text(b["text"]):
            flags.append("content")
        if abs(dt) > GEOM_TOL:
            flags.append("top")
        if abs(dx0) > GEOM_TOL:
            flags.append("x0")
        if abs(dx1) > GEOM_TOL:
            flags.append("x1")
        if abs(dp) > GEOM_TOL:
            flags.append("pitch")
        if abs(size_b - size_a) > 0.02:
            flags.append("size")
        if {fam(f) for f in a["fonts"]} != {fam(f) for f in b["fonts"]}:
            flags.append("font")
        if d_sub is not None and abs(d_sub) > GEOM_TOL:
            flags.append("sub")
        if d_ascii is not None and abs(d_ascii) > GEOM_TOL:
            flags.append("ascii")

        emit(f"| {i + 1} | {a['text']} | {b['text']} | {dt:+.2f} | {dx0:+.2f} | "
             f"{dx1:+.2f} | {dp:+.2f} | {size_a:.2f}->{size_b:.2f} | "
             f"{'/'.join(sorted({fam(f) for f in a['fonts']}))} vs "
             f"{'/'.join(sorted({fam(f) for f in b['fonts']}))} |")
        deviations.append(
            {
                "line": i + 1,
                "docx": a["text"],
                "typst": b["text"],
                "flags": flags,
                "dt": dt, "dx0": dx0, "dx1": dx1, "dp": dp,
                "size_a": size_a, "size_b": size_b,
                "fonts_a": set(a["fonts"]), "fonts_b": set(b["fonts"]),
                "d_sub": d_sub, "d_ascii": d_ascii,
                "annot_only": "text" in flags and "content" not in flags,
            }
        )

    emit()
    emit("## All deviations")
    emit()
    for d in deviations:
        if not d["flags"]:
            continue
        emit(f"### L{d['line']}: {d['flags']}")
        emit()
        if "text" in d["flags"]:
            emit(f"- docx : `{d['docx']}`")
            emit(f"- typst: `{d['typst']}`")
            if "content" in d["flags"]:
                emit(f"  - real content diff: `{norm_text(d['docx'])}` vs "
                     f"`{norm_text(d['typst'])}`")
            else:
                emit("  - whitespace/annotation-only diff")
                if d["annot_only"] and abs(d["dx1"]) > 1:
                    emit("  - right-edge gap is mostly the missing template "
                         "annotation (e.g. （三号黑体）)")
        if "top" in d["flags"]:
            emit(f"- line top: typst is {d['dt']:+.2f} pt vs docx")
        if "x0" in d["flags"]:
            emit(f"- left edge x0: typst is {d['dx0']:+.2f} pt vs docx")
        if "x1" in d["flags"]:
            emit(f"- right edge x1: typst is {d['dx1']:+.2f} pt vs docx")
        if "pitch" in d["flags"]:
            emit(f"- line pitch: typst {d['dp']:+.2f} pt vs docx")
        if "size" in d["flags"]:
            emit(f"- font size: docx {d['size_a']:.2f} pt -> typst {d['size_b']:.2f} pt")
        if "font" in d["flags"]:
            emit(f"- fonts: docx {', '.join(sorted({fam(f) for f in d['fonts_a']}))} | "
                 f"typst {', '.join(sorted({fam(f) for f in d['fonts_b']}))}")
        if "sub" in d["flags"]:
            emit(f"- superscript offset from line top differs by {d['d_sub']:+.2f} pt "
                 f"(typst vs docx)")
        if "ascii" in d["flags"]:
            emit(f"- Latin/ASCII baseline offset from line top differs by "
                 f"{d['d_ascii']:+.2f} pt (typst vs docx)")
        emit()

    emit("## Summary")
    emit()
    counts = Counter(f for d in deviations for f in d["flags"])
    emit(f"- lines compared: {len(la)}")
    emit(f"- lines with any deviation: {sum(1 for d in deviations if d['flags'])} / {len(la)}")
    for kind in ("content", "text", "top", "x0", "x1", "pitch", "size", "font",
                 "sub", "ascii"):
        if counts[kind]:
            emit(f"- {kind}: {counts[kind]}")

    Path("test/validate_1.md").write_text("\n".join(out) + "\n", encoding="utf-8")
    print()
    print("written: test/validate_1.md")


if __name__ == "__main__":
    main()