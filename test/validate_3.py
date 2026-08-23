"""Compare citation superscript vertical offsets: test_sty.pdf vs docx_template.pdf.

Citations are small "[...]" runs (superscripts) attached to body text lines.
For every citation in each PDF we measure how far it sits above the containing
line's body glyphs (top and bottom offsets) as well as its absolute position,
then report the docx-vs-typst difference.

Output: test/validate_3.md (and the same report to stdout).
"""

from __future__ import annotations

import re
from collections import Counter
from pathlib import Path

import pdfplumber as pb


CANON = "docx_template.pdf"   # canonical WPS-rendered docx template
MIMIC = "test_sty.pdf"        # typst output to validate

Y_TOL = 3.0                   # pt: chars within this vertical distance share a line
SMALL_FRAC = 0.8              # citation glyphs are < 0.8 * the line's dominant size
CIT_RE = re.compile(r"^\[[0-9~\-–,; ]+\]$")
SUBSET_RE = re.compile(r"^[A-Z0-9]{6}\+")


def fam(fontname: str) -> str:
    return SUBSET_RE.sub("", fontname)


def find_citations(pdf_path: str) -> list[dict]:
    """Return citation runs in document order, with line-relative offsets."""
    cites: list[dict] = []
    with pb.open(pdf_path) as pdf:
        for pi, pg in enumerate(pdf.pages):
            chars = sorted(pg.chars, key=lambda c: (round(c["top"], 3), c["x0"]))
            lines: list[list] = []
            for c in chars:
                if lines and c["top"] - min(x["top"] for x in lines[-1]) <= Y_TOL:
                    lines[-1].append(c)
                else:
                    lines.append([c])

            for line in lines:
                cs = sorted(line, key=lambda c: (round(c["x0"], 3), round(c["top"], 3)))
                if not cs:
                    continue
                dominant = Counter(round(c["size"], 3) for c in cs).most_common(1)[0][0]
                body = [c for c in cs
                        if c["size"] >= SMALL_FRAC * dominant and c["text"].strip()]
                if not body:
                    continue
                body_top = min(c["top"] for c in body)
                body_bottom = max(c["bottom"] for c in body)
                line_text = "".join(c["text"] for c in cs)

                # Contiguous runs of small (superscript) glyphs.
                runs: list[list[int]] = []
                for i, c in enumerate(cs):
                    if c["size"] >= SMALL_FRAC * dominant:
                        continue
                    if runs and i == runs[-1][-1] + 1:
                        runs[-1].append(i)
                    else:
                        runs.append([i])

                for run in runs:
                    rcs = [cs[i] for i in run]
                    text = "".join(c["text"] for c in rcs)
                    if not CIT_RE.match(text):
                        continue
                    cites.append(
                        {
                            "page": pi + 1,
                            "text": text,
                            "line": line_text,
                            "top": min(c["top"] for c in rcs),
                            "bottom": max(c["bottom"] for c in rcs),
                            "size": max(c["size"] for c in rcs),
                            "font": fam(
                                Counter(c["fontname"] for c in rcs).most_common(1)[0][0]
                            ),
                            "body_top": body_top,
                            "body_bottom": body_bottom,
                            "d_top": min(c["top"] for c in rcs) - body_top,
                            "d_bottom": max(c["bottom"] for c in rcs) - body_bottom,
                        }
                    )
    return cites


def main() -> None:
    out: list[str] = []

    def emit(s: str = "") -> None:
        print(s)
        out.append(s)

    ca = find_citations(CANON)
    cb = find_citations(MIMIC)

    emit(f"# Citation vertical-offset validation: {CANON} (canonical) vs {MIMIC} (typst)")
    emit()
    emit(f"- citations found: docx {len(ca)}, typst {len(cb)}")
    emit()

    emit("## Found citations")
    emit()
    emit("| # | docx | typst |")
    emit("|---:|:--|:--|")
    for i in range(max(len(ca), len(cb))):
        a = ca[i] if i < len(ca) else None
        b = cb[i] if i < len(cb) else None
        emit(f"| {i + 1} | {a['text'] if a else '-'} (p{a['page'] if a else '-'}) | "
             f"{b['text'] if b else '-'} (p{b['page'] if b else '-'}) |")
    emit()

    emit("## Offset comparison (per paired citation)")
    emit()
    emit("| # | text | dTop docx | dTop typst | ΔdTop | dBot docx | dBot typst | "
         "ΔdBot | abs ΔTop |")
    emit("|---:|:--|--:|--:|--:|--:|--:|--:|--:|")

    n = min(len(ca), len(cb))
    rows = []
    for i in range(n):
        a, b = ca[i], cb[i]
        d_dtop = b["d_top"] - a["d_top"]
        d_dbot = b["d_bottom"] - a["d_bottom"]
        abs_dtop = b["top"] - a["top"]
        rows.append(
            {
                "i": i + 1,
                "text": f"{a['text']} / {b['text']}",
                "a_dtop": a["d_top"], "b_dtop": b["d_top"], "d_dtop": d_dtop,
                "a_dbot": a["d_bottom"], "b_dbot": b["d_bottom"], "d_dbot": d_dbot,
                "abs_dtop": abs_dtop,
                "a": a, "b": b,
            }
        )
        emit(f"| {i + 1} | {a['text']} / {b['text']} | {a['d_top']:+.2f} | "
             f"{b['d_top']:+.2f} | {d_dtop:+.2f} | {a['d_bottom']:+.2f} | "
             f"{b['d_bottom']:+.2f} | {d_dbot:+.2f} | {abs_dtop:+.2f} |")
    emit()

    emit("## Details")
    emit()
    for r in rows:
        a, b = r["a"], r["b"]
        emit(f"### C{r['i']}: {a['text']} -> {b['text']}")
        emit()
        emit(f"- docx : page {a['page']}, top={a['top']:.2f}, bottom={a['bottom']:.2f}, "
             f"size={a['size']:.2f}pt, font={a['font']}")
        emit(f"- typst: page {b['page']}, top={b['top']:.2f}, bottom={b['bottom']:.2f}, "
             f"size={b['size']:.2f}pt, font={b['font']}")
        emit(f"- relative to line body: dTop docx={a['d_top']:+.2f} vs typst={b['d_top']:+.2f} "
             f"-> {r['d_dtop']:+.2f}pt; dBot docx={a['d_bottom']:+.2f} vs "
             f"typst={b['d_bottom']:+.2f} -> {r['d_dbot']:+.2f}pt")
        emit(f"- absolute: typst citation top is {r['abs_dtop']:+.2f}pt vs docx "
             f"(line body top itself: {b['body_top'] - a['body_top']:+.2f}pt)")
        emit(f"- line: `{a['line'][:38]}...` -> `{b['line'][:38]}...`")
        emit()

    emit("## Summary")
    emit()
    if rows:
        mean_dtop = sum(r["d_dtop"] for r in rows) / len(rows)
        mean_dbot = sum(r["d_dbot"] for r in rows) / len(rows)
        emit(f"- paired citations: {n}")
        emit(f"- mean ΔdTop (typst - docx): {mean_dtop:+.2f}pt")
        emit(f"- mean ΔdBot (typst - docx): {mean_dbot:+.2f}pt")
        emit("- interpretation: a negative Δ means the typst superscript sits "
             "higher (smaller top / larger raise) than the docx one.")
    else:
        emit("- no paired citations to compare.")
    if len(ca) != len(cb):
        emit(f"- note: citation counts differ ({len(ca)} vs {len(cb)}); only the "
             f"first {n} were paired.")

    Path("test/validate_3.md").write_text("\n".join(out) + "\n", encoding="utf-8")
    print()
    print("written: test/validate_3.md")


if __name__ == "__main__":
    main()
