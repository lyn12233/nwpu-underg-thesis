#import "style.typ": thesis

#show: thesis.before_main

#align(center, text(fill: rgb(255, 0, 0))[*（空 2 行，小四号，下同）*])

= 摘要

#align(center, text(fill: rgb(255, 0, 0))[*（空 1 行）*])

#h(2em)
听觉虚拟又可称为可听化，是近年来随着声学仿真技术的发展而出现的新概念，即通过对包含单个（或多个）声源的声场进行物理或数学建模，以达到模拟空间听音效果的目的。若考虑双耳效应，则可称为双耳听觉虚拟（Binaural Modeling）。

#align(center, text(fill: rgb(255, 0, 0))[*（空 1 行，小四号）*])

#text("关键词：", font: "SimHei")听觉虚拟，HRTF，神经网络

#pagebreak()

#align(center, text(fill: rgb(255, 0, 0))[*（空 2 行，小四号，下同）*])

= ABSTRACT

#align(center, text(fill: rgb(255, 0, 0))[*（空 1 行）*])

#h(2em)
Virtual auditory technology is also called auralization. It is brought forward as a new concept with the development of acoustic simulation techniques in recent years and can be implemented by establishing the physical or mathematical models of a sound field to achieve sound effects simulation. If we consider the binaural effect, it can be called binaural virtual auditory.

#align(center, text(fill: rgb(255, 0, 0))[*（空 1 行，小四号）*])

*KEY WORDS*：virtual auditory, HRTF, neural network

#pagebreak()

#align(center, text(fill: rgb(255, 0, 0))[*（空 2 行，小四号，下同）*])

= #underline("目 录", stroke: 1pt, offset: 0em)

#align(center, text(fill: rgb(255, 0, 0))[*（空 1 行）*])

#show: thesis.catalog

#show: thesis.main_body


#align(center, text(fill: rgb(255, 0, 0))[*（空 2 行，小四号，下同）*])

= 绪论

#align(center, text(fill: rgb(255, 0, 0))[*（空 1 行）*])

== 可听化技术概述

=== 可听化的概念

#h(2em)
可听化（Auralization）@bib_1 是近年来随着声学仿真技术的长足发展而出现的新概念，它的具体含义是通过对一包含单个（或者多个）声源的声场进行物理或数学建模，以达到声音绘制（Audio rendering）或称声学仿真（Acoustical simulation）的目的。这样，人们可以获得该声场中任意位置的双耳听觉感受。换句话说，可听化技术在客观上主要是模拟特定声场（包括声源、声传播环境以及聆听者三要素）中声音传播的物理过程，从而使其中的聆听者作为一个主体能够获得对整个场景声学特性的主观感知@bib_2 @bib_3 @bib_coverage。

#lorem(100)

#pagebreak()

#align(center, text(fill: rgb(255, 0, 0))[*（公式居中，按章标号，小四号，标号右对齐）*])

#show math.equation: set text(baseline: 0pt, top-edge: 1em, bottom-edge: 0em)

$ N_("reft") = (4 pi c^3)/(3 V) t^3 $

$
  L_p & = integral_0^infinity E(t) dif t \
      & = integral_0^infinity e^(-1/2 x^2) dif t \
      & = 2 pi
$

#align(center, text(fill: rgb(255, 0, 0))[*（表格标题五号黑体，表中内容五号宋体，居中，按章标号）*])

#figure(
  table(
    columns: (3.18cm,) * 3,
    rows: 0.82cm,
    [方法], [方法A], [方法B],
    [误差/dB], [0.86], [1.02],
    [计算时间/s], [25], [25],
    // [], [], [],
  ),
  caption: [三种算法的比较],
)

#align(center, text(fill: rgb(255, 0, 0))[*（表前、后各空1行）*])

#align(center, text(fill: rgb(255, 0, 0))[*（图题及图内文字为五号字体，按章标号，单位格式见图）*])

#figure(image("ref/ksp.png", height: 9.9cm, width: 13.2cm, fit: "cover"), caption: [不同频率的声压级])

#align(center, text(fill: rgb(255, 0, 0))[*（图前、后各空1行）*])

= 测试

#pagebreak()

#show: thesis.tail


#align(center, text(fill: rgb(255, 0, 0))[*（空 2 行，小四号，下同）*])

#(thesis.bib)("test_sty.bib")
