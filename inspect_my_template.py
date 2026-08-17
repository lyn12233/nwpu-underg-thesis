import pdfplumber as plb

with plb.open('test_sty.pdf') as pdf_inst:
    pg = pdf_inst.pages[0]
    for c in pg.chars:
        print(c['text'],end="")
        if c['text'] == '空':
            print(c)
        if c['text'] == '绪':
            print(c)