# Yt_Typst_Support

This repository is a support repository for writing Typst Document and compiling it including drawio images.

## Write Typst Document

You should write Typst Document in `src/main.typ` with the following format:

```typst
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
  keywords_ja: ("word1", "word2"),
  abstract_ja: [
    Abstract...
  ],
)

= Header 1 <chap-header1>

conent...
```

It is important to learn more about Typst Document from the following links:

- https://zenn.dev/eplison/articles/53301ca7f1249f#%E5%8B%A2%E3%81%84%E3%81%AE%E3%81%82%E3%82%8Btypst%F0%9F%9A%80
- https://zenn.dev/chantakan/articles/ed80950004d145#3.1-%E8%A1%A8%E7%B4%99
- https://zenn.dev/yuhi_ut/articles/how2write-typst1

## How to compile

You can compile Typst Document with the following command:

```bash
bash ./compile.sh
```

In `compile.sh`, the following steps are executed:
1. `.drawio` images are converted to `.pdf` images into temporary folder.
2. `.pdf` images are converted to `.svg` images.
3. Typst Document is compiled to `.pdf` file.

The step 1 and 2 are necessary to compile Typst Document with drawio images including texts. If not, the texts in drawio images are not shown correclty in the compiled document.

Or you can compile with VSCode Extension `Tinymist Typst` simply if there is no svg files.


### Requirements

The following software is required to compile the document:

- rust
- typst-cli
- drawio
- poppler-utils

You can obtain additional information from Comments of `compile.sh`.

## Feature Works

- [ ] enable to paste image directly from clipboard on VSCode

## References

The templates are based on the following repository:

- `chantakan_master-thesis-template_modified.typ`: https://github.com/ut-khanlab/master_thesis_template_for_typst

