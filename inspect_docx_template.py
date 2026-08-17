import pdfplumber as plb

with plb.open('docx_template.pdf') as pdf_inst:
    pg = pdf_inst.pages[15]
    for c in pg.chars:
        print(c['text'],end="")
        if c['text'] == '空':
            print(c)
        if c['text'] == '绪':
            print(c)
        if c['text'] == '概':
            print(c)