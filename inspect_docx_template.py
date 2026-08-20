import pdfplumber as plb

with plb.open('docx_template.pdf') as pdf_inst:
    pg = pdf_inst.pages[15]
    for c in pg.chars:
        print(c['text'],end="")
        if c['text'] in '本空绪听':
            print(f"{c['y1']}, {c['y0']}\n")
        
        if c['text'] == '本':
            print(c['x0'], c['x1'], c['y0'], c['y1'])

        if c['text'] == '1':
            print(c['x0'], c['x1'], c['y0'], c['y1'])
    print(dir(pg))
    print(pg.edges[0])


    print("image:")
    print(pg.images[0])
    