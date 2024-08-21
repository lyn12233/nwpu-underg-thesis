// my_titles.typ: titles in latex style, 
// implemented Title, Section, SubSection, SubSub

#import "font_zh.typ":font_zh,font_size_zh

// title
#let Title(body)={
  set text(font: font_zh.HeiTi, size: font_size_zh.ErHao)
  set align(center)
  context body
}

// counters
#let TheSection=counter("the_sction")
#let TheSubSection=counter("the_sub_section")
#let TheSubSub=counter("the_sub_sub_section")

// section
#let Section(body,inc:true)={
  set text(font: font_zh.HeiTi, size: font_size_zh.SanHao)
  set align(center)
  v(0.5*(font_size_zh.SanHao))
  if inc{
    TheSection.step()
    TheSubSection.update(0)
    TheSubSub.update(0)
    context TheSection.display("一、")
  }
  context body
  parbreak()
}

// subsection
#let SubSection(body,inc:true)={
  set text(font: font_zh.HeiTi, size: font_size_zh.SiHao)
  v(0.5*(font_size_zh.SiHao))
  if inc{
    TheSubSection.step()
    TheSubSub.update(0)
    context TheSection.display("1.")
    context TheSubSection.display("1  ")
  }
  context body
  parbreak()
}

// subsubsection
#let SubSub(body,inc:true)={
  set text(font: font_zh.HeiTi, size: font_size_zh.XiaoSi)
  v(0.5*(font_size_zh.XiaoSi))
  if inc{
    TheSubSub.step()
    context TheSection.display("1.")
    context TheSubSection.display("1.")
    context TheSubSub.display("1 ")
  }
  context body
  parbreak()
}