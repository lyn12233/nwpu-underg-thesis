#set text(font: ("Times New Roman", "SimSun"), size: 12pt,
top-edge: 1em, bottom-edge: 0em)
#let x=1.25em*1.3-1em
#set par(leading: x, spacing: x, justify: true)
#set page(paper: "a4", margin: (x: 3.18cm, y: 2.54cm + 0.2635em))

#lorem(100)

#lorem(100)

// 12pt
// 1em -> 15.6 (x1.3)
// 1.25em -> 19.56 (x1.63), 19.44 (x1.62)
// 1.5em -> 23.40 (x1.95)
// 1.75em -> 27.24 (x2.27), 27.36 (x2.28)
// 2em -> 31.2 (x2.6)
// 16pt
// any -> 31.2 (x1.95)

// typ
// b-b, (x1.25)
// x-b,16pt, (1,23.1563) (1.25,27.1563) (2,39.1563), x-height=7.1563pt->0.448em
// c-b,16pt, (1,26.59375) (2,42.59375) cap-heght = 10.59375pt -> ?
// asc-b, 16pt 11.09375pt, asc-desc: 14.54685pt

// top margin (12pt)
// desired top: 841.89-72pt = 769.89
// 1 -> 766.178, 1.25 -> 764.138, 2->758.378 delta = 7.8pt/12pt=0.65 hei+1: 767.858