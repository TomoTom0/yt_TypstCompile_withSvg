
// #import "template/tomo_doc_template.typ": *
// #show: master_thesis.with(
//   title: "開発手順書",
//   author: "Tomohiro Yoshitake",
//   paper-type: "内部向けPJルール",
//   date: (2024, 11, 15),
//   version: "0.1.0",
//   flag_toc_tbl: false,
//   flag_toc_img: false,
//   flag_index: false,
//   keywords_ja: ("開発", "実装"),
//   abstract_ja: [
//       PJ12人事向け社内開発プロジェクトにおける開発に関するメモをまとめる。
//       特に内部メンバーが閲覧するための文書として作成される。
//       随時追記していく。
//   ],
// )

// cited and modified from: https://github.com/ut-khanlab/master_thesis_template_for_typst

// cited from: https://github.com/typst/typst/issues/180
#let format(number, precision: 2, decimal_delim: ".", thousands_delim: ",") = {
  if number < 0 {
    return "-" + format(
      calc.abs(number),
      precision: precision,
      decimal_delim: decimal_delim,
      thousands_delim: thousands_delim,
    )
  }
  let integer = str(calc.floor(number))
  if precision <= 0 {
    return integer
  }

  let value = str(calc.round(number, digits: precision))
  let from_dot = decimal_delim + if value == integer {
    precision * "0"
  } else {
    let precision_diff = integer.len() + precision + decimal_delim.len() - value.len()
    value.slice(integer.len() + 1) + precision_diff * "0"
  }

  let cursor = 3
  while integer.len() > cursor {
    integer = integer.slice(0, integer.len() - cursor) + thousands_delim + integer.slice(
      integer.len() - cursor,
      integer.len(),
    )
    cursor += thousands_delim.len() + 3
  }
  integer + from_dot
}

// Store theorem environment numbering
#let thmcounters = state("thm", ("counters": ("heading": ()), "latest": ()))

// Setting theorem environment
#let thmenv(identifier, base, base_level, fmt, boxname: none) = {
  let global_numbering = numbering

  return (
    ..args,
    body,
    number: auto,
    numbering: "1.1",
    refnumbering: auto,
    supplement: identifier,
    base: base,
    base_level: base_level,
    boxname: boxname,
  ) => {
    let name = none
    if args != none and args.pos().len() > 0 {
      name = args.pos().first()
    }
    if refnumbering == auto {
      refnumbering = numbering
    }
    let result = none
    if number == auto and numbering == none {
      number = none
    }
    if number == auto and numbering != none {
      result = context {
        let loc = here()
        return thmcounters.update(thmpair => {
          let counters = thmpair.at("counters")
          // Manually update heading counter
          counters.at("heading") = counter(heading).at(loc)
          if not identifier in counters.keys() {
            counters.insert(identifier, (0,))
          }

          let tc = counters.at(identifier)
          if base != none {
            let bc = counters.at(base)

            // Pad or chop the base count
            if base_level != none {
              if bc.len() < base_level {
                bc = bc + (0,) * (base_level - bc.len())
              } else if bc.len() > base_level {
                bc = bc.slice(0, base_level)
              }
            }

            // Reset counter if the base counter has updated
            if tc.slice(0, -1) == bc {
              counters.at(identifier) = (..bc, tc.last() + 1)
            } else {
              counters.at(identifier) = (..bc, 1)
            }
          } else {
            // If we have no base counter, just count one level
            counters.at(identifier) = (tc.last() + 1,)
            let latest = counters.at(identifier)
          }

          let latest = counters.at(identifier)
          return ("counters": counters, "latest": latest)
        })
      }
      // number = global_numbering(numbering, ..(context thmcounters.get().at("latest")))
      number = context thmcounters.display(x => {
        return global_numbering(numbering, ..x.at("latest"))
      })
    }

    return figure(
      result + // hacky!
      fmt(
        name,
        number,
        body,
        boxname: boxname,
        ..args.named(),
      ) + [#metadata(identifier) <meta:thmenvcounter>] + [#metadata(boxname) <meta:boxname>],
      kind: "thmenv",
      outlined: false,
      caption: none,
      supplement: supplement,
      numbering: refnumbering,
    )
  }
}

// Definition of theorem box
#let thmbox(
  identifier,
  head,
  ..blockargs,
  supplement: auto,
  padding: (top: 0.0em, bottom: 0.0em),
  namefmt: x => [(#x)],
  titlefmt: strong,
  bodyfmt: x => x,
  separator: [#h(0.1em):#h(0.2em)],
  boxalign: left,
  base: "heading",
  base_level: none,
  boxname: none,
) = {
  if supplement == auto {
    supplement = head
  }
  let boxfmt(name, number, body, title: auto, boxname: none) = {
    if not name == none {
      name = [ #namefmt(name) ]
    } else {
      name = []
    }
    if title == auto {
      title = head
    }
    if not number == none {
      title += " " + number
    }
    if not boxname == none {
      title += "《" + boxname + "》"
    }
    title = titlefmt(title)
    body = bodyfmt(body)
    pad(
      ..padding,
      align(
        boxalign,
        block(
          width: 100%,
          inset: 0.8em,
          radius: 0.3em,
          stroke: 0.05em,
          breakable: false,
          ..blockargs.named(),
          [#title#name#linebreak()#body],
        ),
      ),
    )
  }
  return thmenv(identifier, base, base_level, boxfmt,boxname: boxname).with(supplement: supplement)
}

// Setting plain version
#let thmplain = thmbox.with(
  padding: (top: 0em, bottom: 0em),
  breakable: true,
  inset: (top: 0em, left: 1.2em, right: 1.2em),
  namefmt: name => emph([(#name)]),
  titlefmt: emph,
)

// Counting equation number
#let equation_num(_) = {
  locate(loc => {
    let chapt = counter(heading).at(loc).at(0)
    let c = counter(math.equation)
    let n = c.at(loc).at(0)
    "(" + str(chapt) + "." + str(n) + ")"
  })
}

// Counting table number
#let table_num(_) = {
  locate(loc => {
    let chapt = counter(heading).at(loc).at(0)
    let c = counter("table-chapter" + str(chapt))
    let n = c.at(loc).at(0)
    str(chapt) + "." + str(n + 1)
  })
}

// Counting image number
#let image_num(_) = {
  locate(loc => {
    let chapt = counter(heading).at(loc).at(0)
    let c = counter("image-chapter" + str(chapt))
    let n = c.at(loc).at(0)
    str(chapt) + "." + str(n + 1)
  })
}

// Definition of table format
#let tbl(tbl, caption: "") = {
  figure(tbl, caption: caption, supplement: [表], numbering: table_num, kind: "table")
}

// Definition of image format
#let img(img, caption: "", title: "") = {
  figure(img, caption: title + caption, supplement: [図], numbering: image_num, kind: "image")
}

// Definition of abstract page
#let abstract_page(abstract_ja, abstract_en, keywords_ja: (), keywords_en: ()) = {
  if abstract_ja != [] {
    show <_ja_abstract_>: {
      align(center)[
        #text(size: 1.7em, "概要")
      ]
    }
    [= 概要 <_ja_abstract_>]

    v(30pt)
    set text(size: 1em)
    h(1em)
    abstract_ja
    par(first-line-indent: 0em)[
      #text(weight: "bold", size: 1em)[
        キーワード:
        #keywords_ja.join(", ")
      ]
    ]
  } else {
    show <_en_abstract_>: {
      align(center)[
        #text(size: 18pt, "Abstract")
      ]
    }
    [= Abstract <_en_abstract_>]

    set text(size: 1em)
    h(1em)
    abstract_en
    par(first-line-indent: 0em)[
      #text(weight: "bold", size: 1em)[
        Key Words:
        #keywords_en.join("; ")
      ]
    ]
  }
}

// Definition of content to string
#let to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(to-string).join("")
  } else if content.has("body") {
    to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

// Definition of chapter outline
#let toc() = {
  align(left)[
    #text(size: 1.7em, weight: "bold")[
      #v(30pt)
      目次
      #v(30pt)
    ]
  ]
  set text(size: 1em)
  set par(leading: 1.24em, first-line-indent: 0pt)
  context {
    let loc = here()
    let elements = query(heading.where(outlined: true))
    for el in elements {
      let before_toc = query(heading.where(outlined: true).before(loc)).find(one => {
        one.body == el.body
      }) != none
      let page_num = if before_toc {
        numbering("i", counter(page).at(el.location()).first())
      } else {
        counter(page).at(el.location()).first()
      }

      link(el.location())[#{
          // acknoledgement has no numbering
          let chapt_num = if el.numbering != none {
            numbering(el.numbering, ..counter(heading).at(el.location()))
          } else { none }

          if el.level == 1 {
            set text(weight: "black")
            if chapt_num == none { } else {
              chapt_num
              "  "
            }
            let rebody = to-string(el.body)
            rebody
          } else if el.level == 2 {
            h(2em)
            chapt_num
            " "
            let rebody = to-string(el.body)
            rebody
          } else {
            h(5em)
            chapt_num
            " "
            let rebody = to-string(el.body)
            rebody
          }
        }]
      box(width: 1fr, h(0.5em) + box(width: 1fr, repeat[.]) + h(0.5em))
      [#page_num]
      linebreak()
    }
  }
}

// Definition of image outline
#let toc_img() = {
  align(left)[
    #text(size: 1.7em, weight: "bold")[
      #v(30pt)
      図目次
      #v(30pt)
    ]
  ]

  set text(size: 1em)
  set par(leading: 1.24em, first-line-indent: 0pt)
  locate(loc => {
    let elements = query(figure.where(outlined: true, kind: "image"), loc)
    for el in elements {
      let chapt = counter(heading).at(el.location()).at(0)
      let num = counter(el.kind + "-chapter" + str(chapt)).at(el.location()).at(0) + 1
      let page_num = counter(page).at(el.location()).first()
      let caption_body = to-string(el.caption.body)
      // let image_alt = to-string(el.body)
      // let title = image_alt or caption_body
      str(chapt)
      "."
      str(num)
      h(1em)
      caption_body
      box(width: 1fr, h(0.5em) + box(width: 1fr, repeat[.]) + h(0.5em))
      [#page_num]
      linebreak()
    }
  })
}

// Definition of table outline
#let toc_tbl() = {
  align(left)[
    #text(size: 1.7em, weight: "bold")[
      #v(30pt)
      表目次
      #v(30pt)
    ]
  ]

  set text(size: 1em)
  set par(leading: 1.24em, first-line-indent: 0pt)
  locate(loc => {
    let elements = query(figure.where(outlined: true, kind: "table"), loc)
    for el in elements {
      let chapt = counter(heading).at(el.location()).at(0)
      let num = counter(el.kind + "-chapter" + str(chapt)).at(el.location()).at(0) + 1
      let page_num = counter(page).at(el.location()).first()
      let caption_body = to-string(el.caption.body)
      str(chapt)
      "."
      str(num)
      h(1em)
      caption_body
      box(width: 1fr, h(0.5em) + box(width: 1fr, repeat[.]) + h(0.5em))
      [#page_num]
      linebreak()
    }
  })
}

// Setting empty par
#let empty_par() = {
  v(-1em)
  box()
}

// Construction of paper
#let master_thesis(
  // The master thesis title.
  title: "ここにtitleが入る",
  // The paper`s author.
  author: "ここに著者が入る",
  // The author's information
  university: "",
  school: "",
  department: "",
  id: "",
  mentor: "",
  mentor-post: "",
  class: "",
  flag_toc_img: false,
  flag_toc_tbl: false,
  flag_abstract: true,
  flag_index: false,
  date: (datetime.today().year(), datetime.today().month(), datetime.today().day()),
  version: "",
  icon_img_srcs: (),
  paper-type: "",
  // Abstract
  abstract_ja: [],
  abstract_en: [],
  keywords_ja: (),
  keywords_en: (),
  // The paper size to use.
  paper-size: "a4",
  font-size: 12pt,
  flipped: false,
  // The path to a bibliography file if you want to cite some external
  // works.
  bibliography-file: none,
  // The paper's content.
  body,
) = {
  // citation number
  show ref: it => {
    if it.element != none and it.element.func() == figure {
      let el = it.element
      let loc = el.location()
      let chapt = counter(heading).at(loc).at(0)

      link(loc)[#if el.kind == "image" or el.kind == "table" {
          // counting
          let num = counter(el.kind + "-chapter" + str(chapt)).at(loc).at(0) + 1
          it.element.supplement
          " "
          str(chapt)
          "."
          str(num)
        } else if el.kind == "thmenv" {
          let thms = query(selector(<meta:thmenvcounter>).after(loc))
          let number = thmcounters.at(thms.first().location()).at("latest")
          it.element.supplement
          " "
          numbering(it.element.numbering, ..number)

          let boxname_metas = query(selector(<meta:boxname>).after(loc))
          let boxname = boxname_metas.first().value
          if not it.element.body == none {
            "《" + boxname + "》"
          }
        } else {
          it
        }
      ]
    } else if it.element != none and it.element.func() == math.equation {
      let el = it.element
      let loc = el.location()
      let chapt = counter(heading).at(loc).at(0)
      let num = counter(math.equation).at(loc).at(0)

      it.element.supplement
      " ("
      str(chapt)
      "."
      str(num)
      ")"
    } else if it.element != none and it.element.func() == heading {
      let el = it.element
      let loc = el.location()
      let num = numbering(el.numbering, ..counter(heading).at(loc))
      link(
        loc,
        [
          #if el.level == 1 {
            str(num)
            "章"
          } else if el.level == 2 {
            str(num)
            "節"
          } else if el.level == 3 {
            str(num)
            "項"
          }
          #text("《" + it.element.body + "》")
        ],
      )
    } else {
      it
    }
  }

  // counting caption number
  show figure: it => {
    set align(center)
    if it.kind == "image" {
      set text(size: 1em)
      it.body
      it.supplement
      " " + it.counter.display(it.numbering)
      " " + it.caption.body
      locate(loc => {
        let chapt = counter(heading).at(loc).at(0)
        let c = counter("image-chapter" + str(chapt))
        c.step()
      })
    } else if it.kind == "table" {
      set text(size: 1em)
      it.supplement
      " " + it.counter.display(it.numbering)
      " " + it.caption.body
      set text(size: 0.9em)
      it.body
      locate(loc => {
        let chapt = counter(heading).at(loc).at(0)
        let c = counter("table-chapter" + str(chapt))
        c.step()
      })
    } else {
      it
    }
  }

  // Set the document's metadata.
  set document(title: title, author: author)

  // Set the body font. TeX Gyre Pagella is a free alternative
  // to Palatino.
  set text(
    font: (
      "Yu Mincho",
      "Nimbus Roman",
      // "Hiragino Mincho ProN",
      // "MS Mincho",
      // "Noto Serif CJK JP",
    ),
    size: 1em,
  )

  // Configure the page properties.
  set page(paper: paper-size, margin: (bottom: 1.75cm, top: 2.25cm))

  // The first page.
  if flipped {
    set text(size: 0.6em)
  }
  align(center)[
    #v(if not flipped { 7em } else { 0em })

    #text(size: 1.3em)[
      #university #school #department
    ]

    #text(size: 1.3em)[
      #class#paper-type
    ]
    #v(3em)
    #text(size: 2em)[
      #title
    ]
    #v(4em)
    #text(size: 1.3em)[
      #id #author
    ]

    #v(4em)
    #if icon_img_srcs.len() > 0 {
      grid(
        columns: icon_img_srcs.len(),
        align: center,
        gutter: 2.5em,
        ..icon_img_srcs.map(src => {
          image(src, height: 2.5em)
        })
      )
    }
    #v(if not flipped { 8em } else { 2em })
    #text(size: 1.3em)[
      #date.at(0) - #date.at(1) - #str(date.at(2))
    ]

    // if version != "" {
    //   #v(1.7em)
    //   #text(
    //     size: 1.3em,
    //   )[
    //     #version
    //   ]
    // }

    #v(0.8em)
    #text(size: 1.3em)[
      #if version != "" { [Ver.] }
      #version
    ]

    // #v(0.8em)
    // #text(size: 1.3em)[
    //   Ver. #version
    // ]
    #v(4em)
    #pagebreak()
  ]

  set page(footer: [
    #align(center)[#context counter(page).display("i")]
  ])

  counter(page).update(1)
  // Show abstract
  if flag_abstract and (abstract_ja != [] or abstract_en != []) {
    abstract_page(abstract_ja, abstract_en, keywords_ja: keywords_ja, keywords_en: keywords_en)
    pagebreak()
  }
  // abstract_page(abstract_ja, abstract_en, keywords_ja: keywords_ja, keywords_en: keywords_en)

  // Configure paragraph properties.
  set par(leading: 0.78em, first-line-indent: 1em, justify: true)
  // show par:
  set block(spacing: 0.78em)

  // Configure chapter headings.
  set heading(numbering: (..nums) => {
    nums.pos().map(str).join(".") + " "
  })
  show heading.where(level: 1): it => {
    pagebreak()
    counter(math.equation).update(0)
    set text(weight: "bold", size: 1.7em)
    set block(spacing: 1.5em)
    let pre_chapt = if it.numbering != none {
      text()[
        #v(if not flipped { 4em } else { 1em })
        第
        #numbering(it.numbering, ..counter(heading).at(it.location()))
        章
      ]
    } else { none }
    text()[
      #pre_chapt \
      #it.body \
      #v(if not flipped { 4em } else { 1em })
    ]
  }
  show heading.where(level: 2): it => {
    set text(weight: "bold", size: 1.3em)
    set block(above: 1.5em, below: 1.5em)
    it
  }

  show heading: it => (
    {
      set text(weight: "bold", size: 1.2em)
      set block(above: 1.5em, below: 1.5em)
      it
    } + empty_par()
  )

  // Start with a chapter outline.
  toc()

  set page(footer: [
    #align(center)[#context counter(page).display("1")]
  ])

  counter(page).update(1)

  set math.equation(supplement: [式], numbering: equation_num)

  body

  if (flag_toc_img) {
    pagebreak()
    toc_img()
  }
  if (flag_toc_tbl) {
    pagebreak()
    toc_tbl()
  }

  // let add-index-entry(word) = {
  //   index(word)
  //   word
  // }

  // let indexwords = [
  //   "Epic"
  // ]

  // for line in body {
  //   let words = split(line, " ")
  //   for word in words {
  //     if (word in indexwords) {
  //       add-index-entry(word)
  //     } else {
  //       word
  //     }
  //   }
  // }

  // if (flag_index) {
  //   pagebreak()
  //   columns(3)[
  //     make-index(title: "索引")
  //   ]
  // }

  // Display bibliography.
  if bibliography-file != none {
    show bibliography: set text(1em)
    bibliography(bibliography-file, title: "参考文献", style: "ieee")
  }
}

// LATEX character
#let LATEX = {
  [L]
  box(move(dx: -4.2pt, dy: -1.2pt, box(scale(65%)[A])))
  box(move(dx: -5.7pt, dy: 0pt, [T]))
  box(move(dx: -7.0pt, dy: 2.7pt, box(scale(100%)[E])))
  box(move(dx: -8.0pt, dy: 0pt, [X]))
  h(-8.0pt)
}

// ---------------------------------------------------------------------------------------

#import "@preview/in-dexter:0.5.3": *
#import "@preview/showybox:2.0.3": showybox
#import "@preview/codelst:2.0.2": sourcefile, sourcecode

#let axiom = thmbox(
  "theorem",
  "公理",
  base_level: 1,
)

#let definition = thmbox(
  "theorem",
  "定義",
  base_level: 1,
)

#let theorem = thmbox(
  "theorem",
  "定理",
  base_level: 1,
)

#let conclusion = thmbox(
  "theorem",
  "結論",
  base_level: 1,
)

#let assump = thmbox(
  "theorem",
  "前提",
  base_level: 1,
)


#let br = linebreak()

#let bitter-green = rgb("#3d6e41")
#let bitter-blue = rgb("#3f81a9")
#let purple-company = rgb("#5f249f")
#let royal-blue = rgb("#4169e1")
#let olivedrab = rgb("#6b8e23")
#let red = rgb("#ff0000")
#let orange = rgb("#ff8c00")


#let stbox(..args) = box(stroke: black, outset: 0.5em, radius: 0.3em, ..args)

#let blue-box(size: 1em, title-color: royal-blue, ..args) = text(size: size)[
  #showybox(frame: (title-color: title-color), ..args)]


// ---------------------------------------------------------------------------------------

// #show table.cell.where(y: 0): strong
#let table2(..args) = table(
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
  ..args
)

#let slimedTable = (
  arg_columns,
  arg_tableData,
  slimedHeaders,
  stroke_color: royal-blue.lighten(30%),
  font-size: 0.8em,
  arg_align: left,
) => {
  let tableData = arg_tableData;
  if tableData.len() == 0 {
    return table()
  }
  let headers = tableData.at(0).map(cell => cell.trim())
  let rowIndex_starts = headers.map(_ => 0);
  let slimed = ()
  for enu_row in tableData.enumerate() {
    let (rowIndex, row) = enu_row;
    let row_new = ()
    for enu_cell in row.enumerate() {
      let (colIndex, cell) = enu_cell;
      let header = headers.at(colIndex);
      let flag_slimTarget = slimedHeaders.contains(header);
      let flag_sameCell = rowIndex > 0 and cell == tableData.at(rowIndex - 1).at(colIndex);
      if flag_slimTarget and flag_sameCell {
        let rowIndex_start = rowIndex_starts.at(colIndex);
        row_new.push((cell: "", fill: none));
      } else {
        row_new.push((cell: cell.trim(), fill: white));
      }
      if slimed.len() > 0 and flag_slimTarget and (rowIndex == tableData.len() - 1 or not flag_sameCell) {
        let rowIndex_start = rowIndex_starts.at(colIndex);
        let rowspan = rowIndex - rowIndex_start;
        if rowIndex == tableData.len() - 1 and flag_sameCell {
          rowspan += 1;
        }
        let content = slimed.at(rowIndex_start).at(colIndex);
        slimed.at(rowIndex_start).at(colIndex) = (cell: table.cell(rowspan: rowspan, content.cell), fill: content.fill);
        rowIndex_starts.at(colIndex) = rowIndex;
      }
    }
    slimed.push(row_new)
  }

  let slimed_filtered_body = slimed.slice(1).flatten().filter(row=>row.fill != none).map(row => row.cell);

  text(size: font-size)[
    #table(inset: (x: 0% + 0.7em, y: 0.4em), columns: arg_columns, align: arg_align, fill: (x, y)=> {
      if y == 0 {
        return stroke_color.lighten(80%);
        return none;
      }
      // return slimed.at(y).at(x).fill;
    }, stroke: (x, y)=>{
      let info = (:)
      // let cellData = slimed_filtered.at(y).at(x);
      // let cellData = (cell:"", fill:none);
      if y <= 0 {
        info.insert("top", 0.5pt + stroke_color);
        info.insert("bottom", 1pt + stroke_color);
      } else {
        info.insert("top", 0.5pt + stroke_color);
        info.insert("bottom", 0.5pt + stroke_color);
      }
      if y == slimed.len() - 1 {
        info.insert("bottom", 0.5pt + stroke_color);
      }
      return info;
    },table.header(..headers), ..slimed_filtered_body)
  ]
}

#let filter_tableData_custom = (tableData, func) => tableData.enumerate().filter(enum_row => {
  let (rowIndex, row) = enum_row;
  return rowIndex == 0 or func(row)
}).map(enum_row => {
  let (rowIndex, row) = enum_row;
  return row;
});

#let filter_tableData = (tableData, colIndex, target) => filter_tableData_custom(tableData, row => row.at(colIndex) == target);

#let filter_tableData_regex = (tableData, colIndex, regex_str) => filter_tableData_custom(tableData, row => row.at(colIndex).contains(regex(regex_str)));

#let filterWithHeader_tableData = (tableData, headers) => {
  let orig_headers = tableData.at(0);
  let arr_colIndex = orig_headers.map(header => {
    if headers.contains(header) {
      return orig_headers.position(d=> d==header);
    } else {
      return -1;
    }}).filter(colIndex => colIndex != -1);
  return tableData.map(row => arr_colIndex.map(colIndex => row.at(colIndex)));
};