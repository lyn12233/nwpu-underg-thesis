"""Inspect line spacing in docx-generated PDFs vs typst PDFs.

For each page of a PDF, group characters into lines and measure the pitch
(distance between successive line tops / bottoms / baselines).  Then relate
that pitch to the font size, the docx "multiple" line-spacing option, and the
document grid (docGrid linePitch) declared in the source docx.
"""

from __future__ import annotations

import argparse
import re
import zipfile
from collections import Counter

import pdfplumber as pb


DOCX_PATH = "test/test.docx"

# hhea(ascender + |descender| + lineGap) / unitsPerEm from installed fonts.
FONT_LINE_FACTOR = {
    "SimHei": 292 / 256,            # 220 + 36 + 36 over 256
    "Times New Roman": 2355 / 2048,  # 1825 + 443 + 87 over 2048
}


def parse_label(text: str) -> str:
    """Extract the trailing '(Font, Size, xN)' annotation, if present."""
    m = re.search(r"\(([^()]*)\)\s*$", text.strip())
    return m.group(1).strip() if m else ""


def line_metrics(page) -> list[dict]:
    """Group chars into lines and return per-line top/bottom/baseline."""
    lines: dict[float, list] = {}
    for c in page.chars:
        lines.setdefault(round(c["top"], 3), []).append(c)

    rows = []
    for top, chars in sorted(lines.items()):
        bottom = max(c["bottom"] for c in chars)
        baselines = {round(c.get("baseline", c["bottom"]), 3) for c in chars}
        rows.append(
            {
                "top": top,
                "bottom": bottom,
                "baseline": min(baselines) if baselines else bottom,
                "size": Counter(round(c["size"], 3) for c in chars).most_common(1)[0][0],
            }
        )
    return rows


def docx_grid_info(fn: str = DOCX_PATH) -> dict:
    """Return document-grid settings from the docx, if any."""
    info = {"line_pitch_pt": None, "type": None, "snap": False}
    with zipfile.ZipFile(fn) as z:
        xml = z.read("word/document.xml").decode("utf-8")
        m = re.search(r"<w:docGrid[^>]*/>", xml)
        if m:
            info["type"] = re.search(r'w:type="([^"]+)"', m.group(0)).group(1)
            lp = re.search(r'w:linePitch="(\d+)"', m.group(0))
            info["line_pitch_pt"] = int(lp.group(1)) / 20 if lp else None
        info["snap"] = bool(re.search(r"<w:snapToGrid[^>]*/>", xml))
    return info


def font_factor(fontname: str) -> float:
    for name, factor in FONT_LINE_FACTOR.items():
        if name.lower() in fontname.lower():
            return factor
    return 1.15


def expected_pitch(size: float, opt: float, grid: float, factor: float) -> float:
    """Model: with a 'lines' docGrid, line pitch =
    max(N * grid, font-natural single height snapped up to the grid)."""
    natural = size * factor
    snapped = max(grid, -(-natural // grid) * grid)  # ceil to a grid multiple
    return max(opt * grid, snapped)


def analyze_pdf(fn: str, show_lines: bool = False) -> list[dict]:
    results = []
    with pb.open(fn) as pdf:
        for i, pg in enumerate(pdf.pages):
            rows = line_metrics(pg)
            tops = [r["top"] for r in rows]
            bottoms = [r["bottom"] for r in rows]
            baselines = [r["baseline"] for r in rows]
            d_top = [round(b - a, 3) for a, b in zip(tops, tops[1:])]
            d_bot = [round(b - a, 3) for a, b in zip(bottoms, bottoms[1:])]
            d_base = [round(b - a, 3) for a, b in zip(baselines, baselines[1:])]

            text = pg.extract_text() or ""
            label = parse_label(text)
            fonts = Counter((c["fontname"], round(c["size"], 2)) for c in pg.chars)
            size = max((s for _, s in fonts), default=0)
            results.append(
                {
                    "page": i + 1,
                    "label": label,
                    "fonts": dict(fonts),
                    "size": size,
                    "n_lines": len(rows),
                    "d_top": d_top,
                    "d_bot": d_bot,
                    "d_base": d_base,
                    "line_heights": [round(b - t, 3) for t, b in zip(tops, bottoms)],
                }
            )
            if show_lines:
                print(f"--- page {i+1}: {label}  size={size:.3f}")
                for r in rows:
                    print(
                        f"  top={r['top']:9.3f} bottom={r['bottom']:9.3f} "
                        f"baseline={r['baseline']:9.3f} size={r['size']:.3f}"
                    )
                print(f"  d_top={d_top}")
                print(f"  d_bot={d_bot}")
                print(f"  d_base={d_base}")
    return results


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("pdfs", nargs="*", default=["test/test.pdf"])
    ap.add_argument("--lines", action="store_true")
    ap.add_argument("--table", action="store_true")
    args = ap.parse_args()

    grid_info = docx_grid_info()
    grid = grid_info["line_pitch_pt"] or 15.6
    print(f"docx grid: {grid_info}")

    for fn in args.pdfs:
        print(f"##### {fn}")
        res = analyze_pdf(fn, show_lines=args.lines)
        if args.table:
            print(f"{'pg':>3} {'size':>6} {'opt':>4} {'pitch':>8} {'exp':>8} "
                  f"{'diff':>7} {'font'}")
            for r in res:
                m = re.search(r"x([\d.]+)\s*$", r["label"])
                opt = float(m.group(1)) if m else 1.0
                pitch = r["d_top"][0] if r["d_top"] else float("nan")
                fname = max(r["fonts"])[0]
                exp = expected_pitch(r["size"], opt, grid, font_factor(fname))
                print(f"{r['page']:>3} {r['size']:6.3f} {opt:>4.2f} {pitch:8.3f} "
                      f"{exp:8.3f} {pitch - exp:7.3f} {fname}")

        groups = {}
        for r in res:
            m = re.search(r"x([\d.]+)\s*$", r["label"])
            opt = float(m.group(1)) if m else float("nan")
            key = (round(r["size"], 2), opt)
            fname = max(r["fonts"])[0]
            groups.setdefault(key, []).append((r["page"], fname, r["d_top"]))
        print("font-independence pairs (same size/option, different font):")
        for key, items in sorted(groups.items()):
            if len(items) > 1:
                pits = {it[1]: it[2] for it in items}
                same = all(
                    abs(pits[a][0] - pits[b][0]) < 0.01
                    for a in pits for b in pits
                )
                print(f"  size={key[0]:.2f} opt={key[1]:.2f}: {pits} -> equal: {same}")


if __name__ == "__main__":
    main()