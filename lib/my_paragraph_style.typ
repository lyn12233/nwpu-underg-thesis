// my_paragraph_styles.typ: mainly size control
// this file should be included instead of imported
#import "font_zh.typ":font_zh,font_size_zh

// length PARSKIP seems slightly deviated
#let PARSKIP=0.5*(font_size_zh.XiaoSi)
// MYPAR as alternative of \par
#let MYPAR(parskip: PARSKIP)={
  parbreak()
  v(PARSKIP)
  parbreak()
  h(0.74cm)
}

// analogue of \lineskip, deviated(?)
#set par(leading: 12pt, first-line-indent: 0em, justify: true)

//weak page break
#set pagebreak(weak: true)