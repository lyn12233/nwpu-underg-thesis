#import "../font/font_zh.typ":font_zh,font_size_zh

#import "@preview/outrageous:0.1.0"

#let outline_page(

)={
  pagebreak(weak: true)
  set text(
    font: font_zh.HeiTi,
    size: SanHao
  )
  set par(
    leading: 20pt,
    //there's no way to set parskip!
  )
}