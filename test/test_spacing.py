import pdfplumber as pb
import pandas as pd

def demo(fn):
    with pb.open(fn) as p:
        pg = p.pages[0]
        data = pd.DataFrame(pg.chars)
    y0 = data['y1'].unique()
    y0.sort()
    print(y0)
    print(y0[:-1] - y0[1:])

if __name__ == '__main__':
    demo('test/test_spacing.pdf')
    demo('test/test.pdf')