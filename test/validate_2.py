import pdfplumber as pb

target_text = "本科毕业设计（论文）（空2行，小四号，下同）目录（空1行）第一章绪论……可听化技术概述第二章双耳模型"

dir0,pg0 = "docx_template.pdf",14
dir1,pg1 = "test_sty.pdf",2

with pb.open(dir0) as pdf_inst:
    pg0 = pdf_inst.pages[pg0]
    len0 = len(pg0.chars)
with pb.open(dir1) as pdf_inst:
    pg1 = pdf_inst.pages[pg1]
    len1 = len(pg1.chars)

i0, i1 = 0, 0

for cand in target_text:
    while i0 < len0 and pg0.chars[i0]['text'] != cand:
        # print(f"skip {repr(pg0.chars[i0]['text'])}")
        i0+=1
    while i1 < len1 and pg1.chars[i1]['text'] != cand:
        # print(f"skip {repr(pg1.chars[i1]['text'])}")
        i1+=1
    if i0>=len0 or i1>=len1:
        print(f'can not find char {repr(cand)}')
        break
    c0 = pg0.chars[i0]
    c1 = pg1.chars[i1]
    i0+=1
    i1+=1
    print(f"{cand}: dx={c1['x0']-c0['x0']}, dy={c1['y1']-c0['y1']}")
    # if cand == '…':
    #     print('compare the dots:')
    #     print(c0)
    #     print(c1)

print('edges (ref):')
for e in pg0.edges:
    if 'pts' in e and 'linewidth' in e:
        print(f"points: {e['pts']}, stroke:{e['linewidth']}")
print('edges (mine):')
for e in pg1.edges:
    if 'pts' in e and 'linewidth' in e:
        print(f"points: {e['pts']}, stroke:{e['linewidth']}")

print(pg0.edges[0])
print(pg1.edges[1])

for c in pg0.chars:
    if c['text'] in "参致附毕":
        print(c['y0'])

for c in pg1.chars:
    if c['text'] in "参致附毕":
        print(c['y0'])