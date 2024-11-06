#import "template/tomo_like-latex_template.typ": *
#show: master_thesis.with(
  title: "Title",
  author: "Your Name",
  paper-type: "Type",
  date: (2024, 11, 6),
  version: "0.1.1",
  flag_toc_tbl: true,
  flag_toc_img: true,
  flag_index: true,
  icon_img_srcs: ("../img/typst.svg", "../img/sample_notext.svg"),
  keywords_ja: ("word1", "word2"),
  abstract_ja: [
    Abstract...
  ],
)

= Header 1 <chap-header1>

conent...

#img(
  image("img/sample_notext.svg", width: 100%),
  caption: ["Sample Image"],
)