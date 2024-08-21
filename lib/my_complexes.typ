// my_complexes.typ: styling equation, image and table
// this file should be included instead of imported

#set math.equation(numbering: "(1)", supplement: "公式")
#show figure.caption: set text(font:font_zh.SongTi, size: font_size_zh.WuHao)
#show figure.where(kind:image): set figure(supplement: "图") 
#show figure.where(kind:table): set figure(supplement: "表") 
#show figure.where(kind: table): set figure.caption(position:top)