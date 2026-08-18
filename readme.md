# nwpu-thesis-undrergraduate

根据nwpu本科毕业设计docx模板设计的typst模板.
目前模板为 `style.typ`.

# usage

```rust
#import "style.typ": thesis
#show: thesis.before_main
// 中英文摘要
#show: thesis.catalog // 自动生成目录
#show thesis.main_body
// 正文
#show: thesis.tail
// 开始不记章节的内容
#(thesis.bib)("test_sty.bib") // 生成参考文献
// 致谢, 附录等
```

# coverage

- 字体
  - [x] 正文小四宋体+Times New Roman x1.25 行距, 一级标题三号黑体 x1.25, 二级标题四号黑体 x1.25, 三级标题小四黑体 x1.25
  - [ ] 公式`New Computer Modern Math`字体, 间距
  - [ ] 表格五号宋体 x1.5 行距
- 段落
  - [ ] justify
  - [ ] 默认缩进
- 页面
  - [x] 页眉3.18cm,距离顶部1.5cm,logo+文字+横线
  - [x] 页脚3.18cm,距离底部1.75cm, 页数小五Times New Roman左对齐缩进23字符
- 标题
  - [x] 标题/图/表计数,包含在目录
- 块
  - [x] 正文和标题的块,公式块可分割
  - [ ] 增加公式padding
- 目录
  - [x] 正文字体, 一级标题加粗, 缩进 (1.7em?)
- 公式
  - [x] 公式编号, 对齐
- 图表
  - [x] 图表编号
  - [x] 图题宋体五号,位置
  - [x] 表题黑体五号,位置
  - [ ] x1.5行距?
  - [ ] 图表引用格式
- 摘要,正文,参考文献
  - [x] 正文前后的编号
  - [x] 参考文献与引用格式
  - [ ] 参考文献 x1 行距
# todos
- 行距,字体设置

# license
[Public Domain](./LICENSE).