# Docx line-spacing pattern (from `test/test.pdf`)

`test/test.pdf` is a WPS-rendered PDF of `test/test.docx`: 14 pages, each a
single paragraph with one font / size / line-spacing combination, labelled in
the page text. All measurements come from pdfplumber char positions; the pitch
between consecutive lines is identical for top-edge, bottom-edge, and baseline
measurements.

## Measured line pitch

| page | 字体 | 字号 (pt) | option (xN) | pitch (pt) |
|---:|---|---:|---:|---:|
| 1 | 黑体 | 14.05 (四号) | 1.0 | 31.200 |
| 2 | 黑体 | 14.05 (四号) | 1.5 | 31.200 |
| 3 | 黑体 | 12.00 (小四) | 1.0 | 15.600 |
| 4 | 黑体 | 12.00 (小四) | 1.5 | 23.400 |
| 5 | 黑体 | 12.00 (小四) | 2.0 | 31.200 |
| 6 | 黑体 | 10.45 (五号) | 1.0 | 15.600 |
| 7 | 黑体 | 10.45 (五号) | 1.5 | 23.400 |
| 8 | 黑体 | 10.45 (五号) | 1.25 | 19.560 / 19.440 |
| 9 | 黑体 | 10.45 (五号) | 2.0 | 31.200 |
| 10 | Times | 12.00 (小四) | 1.5 | 23.400 |
| 11 | Times | 12.00 (小四) | 1.0 | 15.600 |
| 12 | Times | 12.00 (小四) | 2.0 | 31.200 |
| 13 | Times | 10.45 (五号) | 1.0 | 15.600 |
| 14 | Times | 10.45 (五号) | 1.5 | 23.400 |

Page 8 alternates 19.56 / 19.44 pt (average 19.5 pt); this is WPS subpixel
rounding of 15.6 × 1.25 = 19.5 pt.

## How the spacing is calculated

The docx section properties declare a document grid:

```xml
<w:docGrid w:type="lines" w:linePitch="312" w:charSpace="0"/>
```

`linePitch = 312` twips = **15.6 pt per grid line**, and every paragraph has
`snapToGrid`. The rule that fits all 14 pages exactly:

```
pitch = max( N × 15.6 pt , font_natural_single snapped up to a 15.6 pt multiple )
```

where `font_natural_single ≈ font_size × (hhea ascender + |descender| +
lineGap) / unitsPerEm` — ≈ 1.14 for SimHei and ≈ 1.15 for Times New Roman.

Consequences:

- 小四 12 pt and 五号 10.5 pt: the font's natural line (≈ 13.7–13.8 pt) is
  below one grid line, so the grid wins: **pitch = 15.6 × N**.
  x1 → 15.6, x1.25 → 19.5, x1.5 → 23.4, x2 → 31.2.
- 四号 14 pt: the natural line (≈ 16.0 pt) exceeds 15.6 pt, so the line
  occupies two grid lines = 31.2 pt; both x1 and x1.5 render 31.2 pt.

The "× 1.3" shortcut in earlier notes is just the coincidence that
12 pt × 1.3 = 15.6 pt = the grid pitch.

## Font independence — verified

Same size + option, different font (黑体 vs Times New Roman) gives identical
pitch in every comparable pair:

| size | option | 黑体 | Times |
|---:|---:|---:|---:|
| 12.0 | x1 | 15.6 | 15.6 |
| 12.0 | x1.5 | 23.4 | 23.4 |
| 12.0 | x2 | 31.2 | 31.2 |
| 10.45 | x1 | 15.6 | 15.6 |
| 10.45 | x1.5 | 23.4 | 23.4 |

Even at 14 pt, SimHei (1.141 em) and Times (1.150 em) both snap to the same
31.2 pt. In this example the document grid masks the font differences.

## Reference

- Analysis script: `test/inspect_spacing_agent.py` (reads the docGrid from
  `test/test.docx`, predicts each page's pitch, prints font-independence pairs).
- Typst reference: `test/test_spacing.pdf` measures 19.5 pt at 12 pt, which
  equals the docx x1.25 case.
