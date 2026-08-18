/// @file style.typ
/// this style should align to docx_template.pdf
///
/// (max-char-in-line=74)
///
/// # usage
/// ```rust
/// #show thesis.abstract // todo: differ cn/en
/// // your abstract
/// #show thesis.catalog // todo: or just #thesis.catalog()
/// #show thesis.main_body
/// // your thesis body
/// // bibliography, acknowledgement, etc
/// ```
///
/// # implementation details
/// ## text
/// (1) font and font size/boundary for section(hdr1), subsection(hdr2),
/// subsubsection(hdr3), main body and caption. (2) normal horizontal
/// spacing, edges to cap-height and baseline. (3) enable kerning, disable
/// hyphenate and ligature.
/// ## paragraph
/// (1) spacing between lines and paragraphs, which is always a 1.25x
/// scale. this needs a conversion skip=scale*1.3-1, weird. (2) allow full
/// justification support, currently the default parameters.
/// ## page
/// (1) margin 3.18cm horizontal and 2.54cm vertical. typst now behaves
/// weird here. (2) paper=a4. (3) footer: header:
/// ## heading
/// (1)

#import "@preview/cuti:0.4.0": show-cn-fakebold
#import "corrections.typ": calib

#let font_parms = (
  size: (
    SanHao: 16pt,
    SiHao: 14pt,
    XiaoSi: 12pt,
    WuHao: 10.5pt,
    XiaoWu: 9pt,
  ),
  _font: (
    SongTi: ("Times New Roman", "SimSun"),
    HeiTi: ("Arial", "SimHei"), // todo: may it be times new roman
    NCMMath: ("New Computer Modern Math", "SimSun"),
  ),
)

#let basic_text_parms = (
  font: font_parms._font.SongTi,
  fallback: false, // unknown glyph without fallback cause panic
  // style: "normal",
  weight: "regular", // heading will try to change this implicitly
  // stretch: 100%,
  size: font_parms.size.XiaoSi,
  // fill: luma(0),
  // stroke: none,
  // tracking: 0pt, // space between chars
  // spacing: 100%+0pt, // space between words
  cjk-latin-spacing: none, // auto spacing may not work normal
  baseline: -0.15em,
  // overhang: true,
  top-edge: 1em,
  bottom-edge: 0em,
  // lang: "en",
  // region: none,
  // script: auto,
  dir: ltr,
  hyphenate: false, // 连字符
  // costs: ...,
  // kerning: true,
  ligatures: false, // 连字
  number-type: "lining",
  // number-width: auto
  // slashed-zero: false,
  // fractions: false,
  // variations: ..., // 变体，包括磅数等
)

#let small_text_parms = (
  ..basic_text_parms,
  size: font_parms.size.WuHao,
  top-edge: 1.45em,
  bottom-edge: -0.45em,
)

#let par_common_skip = 1.25em * 1.3 - 1em
#let par_parms = (
  leading: 0pt,
  spacing: 0pt,
  justify: true,
  // justification-limits:(
  //  spacing:(min:66.67%+0pt,max:150%+0pt),
  //  tracking:(min:0pt,max:0pt),
  // )
  // // need to change this later
  // // same as the fields in text, meaning spacing between words and chars
  linebreaks: "optimized", // change linebreak position for justification
  first-line-indent: (amount: 0pt, all: true),
  // hanging-indent: 0pt,
)

#let page_parms = (
  paper: "a4",
  // width:auto, height:auto,
  // flipped:false,
  margin: (x: 3.18cm, y: 2.54cm), // todo: calib
  // bleed: (:) // margin out of the page
  // binding: auto // bound page with text direction
  // columns: 1,
  // fill: auto, // color
  // numbering: none, // override this with explicit footer
  // supplement: auto, // supplement in page reference
  // number-align: auto, // override this with footer
  header: align(top)[
    #set text(..basic_text_parms, size: font_parms.size.SanHao)
    #v(1.5cm)
    #block(inset: 2.4pt, width: 100%)[
      #h(10.45 * 8pt)
      #box(width: 1fr, align(center)[
        #h(3 * 8pt + calib.header_text_dx)
        *本科毕业设计（论文）*
      ])
    ]
    #v(calib.header_line_dy)
    #line(length: 100%, stroke: 0.72pt)
    #place(top + left, dx: 3.44cm, dy: 1.5cm - 0.06cm, image("ref/npu_logo_1.png", height: 0.61cm, width: 2.99cm))
  ],
  // todo: impl
  header-ascent: 0pt, //
  footer: [
    #block(width: 100%, height: 1fr, place(bottom + left, dx: 23 * font_parms.size.XiaoWu, text(
      ..basic_text_parms,
      size: font_parms.size.XiaoWu,
    )[#context counter(page).display("1")]))
    #v(1.75cm)
  ],
  footer-descent: 0pt,
  // background: none, foreground: none,
)

#let heading_parms = (
  // level: auto,
  // depth: 1, // base level
  // offset: 0, // level offset, calc level=depth+offset
  numbering: (..nums) => {
    if nums.pos().len() == 1 {
      "第" + numbering("一", nums.at(0)) + "章  "
      counter(math.equation).update(0)
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
    } else if nums.pos().len() == 2 {
      numbering("1.1", ..nums)
    } else if nums.pos().len() == 3 {
      numbering("1.1.1", ..nums)
    }
  },
  // supplement: auto, // supplement in heading reference
  outlined: true, // include in typst's outline
  bookmarked: true, // include in pdf's outline
  // hanging-indent: auto, // indent for wrapping long heading
)

#let basic_block_parms = (
  // width: auto, height: auto,
  breakable: true, // allow break across pages
  // fill: none,
  // stroke: (:), radius: (:),
  inset: 0pt, // pad between border and content
  outset: 0pt, // pad between layout and border
  // spacing: none, // shorthand of above and below
  above: 0pt,
  below: 0pt,
  // clip: false,
  sticky: false, // you should manually prevent orphaned heading
)

#let outline_parms = (
  title: none,
  // target: heading,
  depth: 3,
  indent: 2em,
)
#let outline_entry = it => {
  // set block(stroke: 1pt)
  if it.level == 1 {
    strong(it.prefix())
    strong(it.body())
    box(width: 1fr, baseline: 0.3em, repeat(text(baseline: -0.5em, size: font_parms.size.WuHao)[…]))
    it.page()
  } else {
    h(1.7em * (it.level - 1))
    it.prefix()
    [ ]
    it.body()
    box(width: 1fr, baseline: 0.3em, repeat(text(baseline: -0.5em, size: font_parms.size.WuHao)[…]))
    it.page()
  }
  v(0pt)
}

#let equation_parms = (
  numbering: (..nums) => {
    set text(..basic_text_parms, font: "SimSun")
    context "（" + str(counter(heading).get().at(0)) + "-" + str(nums.pos().at(0)) + "）"
  },
  number-align: end + bottom,
  // supplement: auto,
  // alt: none, // alternative desc
)

#let figure_parms = (
  // alt: none,
  // placement: none,
  // scope: "column",
  // caption, kind, supplement, numbering,
  gap: 0pt,
  // outlined: true,
)

#let figure_caption = it => {
  if it.kind == table {
    block(..basic_block_parms, stroke: 0pt, text(
      ..small_text_parms,
      font: font_parms._font.HeiTi,
      (
        "表"
          + str(counter(heading).get().at(0))
          + "-"
          + str(counter(figure.where(kind: table)).get().at(0))
          + "  "
          + it.body
      ),
    ))
  } else if it.kind == image {
    block(..basic_block_parms, stroke: 0pt, text(
      ..small_text_parms,
      (
        "图"
          + str(counter(heading).get().at(0))
          + "-"
          + str(counter(figure.where(kind: image)).get().at(0))
          + "  "
          + it.body
      ),
    ))
  }
}

#let table_parms = (
  column-gutter: 0pt,
  row-gutter: 0pt,
  inset: 0pt,
  align: center + horizon,
  // fill: none,
  stroke: 0.5pt,
)

#let parms = (
  _text: (
    hdr1: (
      ..basic_text_parms,
      font: font_parms._font.HeiTi,
      size: font_parms.size.SanHao,
    ),
    hdr2: (
      ..basic_text_parms,
      font: font_parms._font.HeiTi,
      size: font_parms.size.SiHao,
    ),
    hdr3: (
      ..basic_text_parms,
      font: font_parms._font.HeiTi,
      size: font_parms.size.XiaoSi,
    ),
    main: (
      ..basic_text_parms,
      // baseline: -0.3em,
      top-edge: 1em + 3.75pt,
      bottom-edge: -3.75pt,
    ),
    math: (
      ..basic_text_parms,
      baseline: 0pt,
      font: font_parms._font.NCMMath,
    ),
    table: small_text_parms,
  ),
  _par: (
    main: par_parms,
  ),
  _page: (
    main: page_parms,
    before_main: (
      ..page_parms,
      footer: [
        #block(width: 100%, height: 1fr, place(bottom + left, dx: 23 * font_parms.size.XiaoWu, text(
          ..basic_text_parms,
          size: font_parms.size.XiaoWu,
        )[#context counter(page).display("I")]))
        #v(1.75cm)
      ],
    ),
  ),
  _heading: (
    main: heading_parms,
    before_main: (
      ..heading_parms,
      numbering: none,
      outlined: false,
    ),
    tail: (
      ..heading_parms,
      numbering: none,
    ),
  ),
  _block: (
    main: basic_block_parms,
    hdr1: (
      ..basic_block_parms,
      inset: (y: 15.6pt - 0.5em),
      // above: 3.75pt,
      // below: 3.75pt,
      // stroke: 1pt,
    ),
    hdr2: (
      ..basic_block_parms,
      inset: (y: 15.6pt - 0.5em),
      // above: 3.75pt,
      // stroke: 1pt,
    ),
    hdr3: (
      ..basic_block_parms,
      inset: (y: par_common_skip / 2),
      // below: par_common_skip / 2,
      // stroke: 1pt,
    ),
    math: (
      ..basic_block_parms,
      breakable: true,
      // stroke: 1pt,
    ),
  ),
  _outline: outline_parms,
  _outline_entry: outline_entry,
  _equation: equation_parms,
  _figure: figure_parms,
  _caption: figure_caption,
  _caption_pos: (table: top, image: bottom),
  _table: table_parms,
  _align: (none, center, left, left),
)

#let common_style(..args, body) = {
  show: show-cn-fakebold
  set text(..parms._text.main)
  set par(..parms._par.main)
  show math.equation: set text(..parms._text.math)
  show math.equation: set block(..parms._block.math)
  set math.equation(..parms._equation)
  set figure(..parms._figure)
  show figure.caption: parms._caption
  show figure.where(kind: table): set figure.caption(position: parms._caption_pos.table)
  show figure.where(kind: image): set figure.caption(position: parms._caption_pos.image)
  set table(..parms._table)
  show table: set text(..parms._text.table)
  body
}

#let main_body(..args, body) = {
  show: common_style

  set heading(..parms._heading.main)
  show heading: set par(..parms._par.main)
  show heading.where(level: 1): set block(..parms._block.hdr1)
  show heading.where(level: 2): set block(..parms._block.hdr2)
  show heading.where(level: 3): set block(..parms._block.hdr3)
  show heading.where(level: 1): set text(..parms._text.hdr1)
  show heading.where(level: 2): set text(..parms._text.hdr2)
  show heading.where(level: 3): set text(..parms._text.hdr3)
  show heading.where(level: 1): set align(parms._align.at(1))
  show heading.where(level: 2): set align(parms._align.at(2))
  show heading.where(level: 3): set align(parms._align.at(3))

  counter(page).update(1)

  body
}

#let before_main(..args, body) = {
  show: common_style

  set page(..parms._page.before_main)
  set heading(..parms._heading.before_main)
  show heading: set par(..parms._par.main)
  show heading: set block(..parms._block.hdr1)
  show heading: set text(..parms._text.hdr1)
  show heading: set align(center)
  body
}

#let catalog(..args, body) = {
  set outline(..parms._outline)
  show outline.entry: parms._outline_entry
  outline()
  pagebreak()
  body
}

#let main_tail(..args, body) = {
  set heading(..parms._heading.tail)
  body
}

#let bib(source) = {
  heading("参考文献", level: 1)
  bibliography(source, full: true, style: "gb-7714-2015-numeric", title: none)
}

#let thesis = (
  main_body: main_body,
  before_main: before_main,
  catalog: catalog,
  tail: main_tail,
  bib: bib,
)
