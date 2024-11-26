
// #import "template/tomo_slide_template.typ": *
// #show: project.with(
//   title: "キックオフ",
//   sub-title: "FY25-PJ12 第2回報告会議",
//   author: "Tomohiro Yoshitake",
//   date: "2024/11/21",
//   index-title: "Agenda",
//   logo: image("img/PJ12_team_icon_notext.svg"),
//   logo-light: image("img/PJ12_team_icon_notext.svg"),
//   cover: image("img/2024-10-30_noon-sky.jpeg"),
//   main-color: rgb("#5f249f"),
// )

#import "@preview/minimal-presentation:0.2.0": *
#import "@preview/showybox:2.0.3": showybox

#let bitter-green = rgb("#3d6e41")
#let bitter-blue = rgb("#3f81a9")
#let purple-company = rgb("#5f249f")
#let royal-blue = rgb("#4169e1")
#let olivedrab = rgb("#6b8e23")
#let red = rgb("#ff0000")
#let orange = rgb("#ff8c00")

#set text(font: "BIZ UDPGothic", size: 18pt)

#show figure.caption: set text(10pt)
#let stbox(..args) = box(stroke: black, outset: 0.5em, radius: 0.3em, ..args)
#set text(size: 18pt)

#set list(body-indent: 0.5cm, marker: (place(center, "▸")), spacing: 1.2em)
#let br = linebreak()
#show grid: set grid(columns: 2, gutter: 1em, align: top + left)
#show figure: set figure(supplement: "Fig")
#let blue-box(size: 1em, title-color: royal-blue, ..args) = text(size: size)[
  #showybox(frame: (title-color: title-color), ..args)]

#show table.cell.where(y: 0): strong
#show table: set table(
  inset: 0.5em,
  stroke: (x, y) => {
    let info = (:)
    if y == 0 {
      info.insert("bottom", 1pt + black)
      info.insert("top", 2pt + black)
    }
    if y > 1 {
      info.insert("top", 0pt + black)
      info.insert("bottom", 2pt + black)
    }
    if y == -1 {
      info.insert("bottom", 1pt + black)
    }
    // if x!=0 {info.insert("left", 1pt+black)}
    return info
  },
  fill: (x, y) => {
    if y == 0 {
      return royal-blue.lighten(30%)
    }
    if calc.odd(y) {
      return royal-blue.lighten(90%)
    }
    return royal-blue.lighten(60%)
  },
)

#let tbl(table, size: 1em) = align(center)[
  #text(size: size)[ #table ]
]


