import pdfplumber as plb

with plb.open('test_sty.pdf') as pdf_inst:
    pg = pdf_inst.pages[0]
    pos = 0
    ds = []
    for c in pg.chars:
        print(c['text'],end="")
        if c['text'] in '本空绪听':
            print(f"{c['y1']}, {c['y0']}\n")
            if pos > c['y1']:
                ds.append(pos-c['y1'])
            pos=c['y0']
        if c['text'] == '本':
            print(f"{c['x1']}, {c['x0']}\n")
    print('\n'*2)
    for e in pg.edges:
        # print(e['pts'] if 'pts' in e else "<na>")
        print(e)


    c = pg.chars[-1]
    print(c['text'], c['x0'], c['x1'], c['y0'], c['y1'])

# print(f'deltas: {ds}')

print("image:")
print(pg.images[0])