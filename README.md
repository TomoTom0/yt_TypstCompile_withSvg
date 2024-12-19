# Yt_TypstCompile_withVector

This repository is a support repository for writing Typst Document and compiling it including drawio, pdf, svg images.

## Write Typst Document

You should write Typst Document in `src/main.typ` with the following format:

```typst
#import "template/tomo_doc_template.typ": *
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

## How to Use

### Setup and Start

1. Clone this repository.
2. Copy all shell scripts in `script/` the repository to the root of your project.
3. If you want to use the templates, copy the templates in `template/` to `src/template/` of your project.
4. Write Typst Document in `src/main.typ`.
5. Place drawio, pdf, svg images in `src/img/` folder.
6. Maybe you should convert images to typst-safe vector images while writing: `bash _convert`.
7. Finally, compile Typst Document with the following command: `bash compile.sh`.

## Features

### Convert and Compile

You can compile Typst Document with the following command:

```bash
bash ./compile.sh
```

In `compile.sh`, the following steps are executed:
1. Drawio images are converted to SVG images.
   1. `.drawio`, `.drawio.svg` images are converted to `.pdf` images into temporary folder.
   2. if multiples pages are included in the drawio file, the pages are separated into multiple `.pdf` files.
   3. `.pdf` images are converted to `_notext.svg` images.
2. SVG images are converted to PDF images.
   1. `.svg` images are converted to `.pdf` images into temporary folder.
   2. `.pdf` images are converted to `_notext.svg` images.
3. PDF images are converted to `_drawio.svg` images.
   1. `.pdf` images are converted to `_notext.svg` images.
4. Typst Document is compiled to `.pdf` file.

The step 1, 2 and 3 are necessary to compile Typst Document with vector images including texts. If not, the texts in vector images are not shown correclty in the compiled document. You can additional information from [official issue](https://github.com/typst/typst/issues/1421).

Or you can compile with VSCode Extension `Tinymist Typst` simply if there is no svg files.

### Only Convert or Compile

If you want to only convert images or compile Typst Document, you can use the following commands:

```bash
# only convert images
bash _convert_images.sh

# only compile Typst Document
bash _build_typst.sh
```

The shell scripts with the prefix `_` are called in `compile.sh`.

## Requirements

The following software is required to compile the document:

- rust
- typst-cli
- drawio
- poppler-utils
- librsvg2-bin

You can obtain additional information from Comments of `compile.sh`.

### Templates

The templates are included in the `template` folder. You can modify the templates as you like.

## Feature Works

- [ ] enable to paste image directly from clipboard on VSCode

## Updates

- 2024/12/9: if multiple pages are included in the drawio file, the pages are separated on converting vector images.
- 2024/11/7: drawio, pdf images are converted to typst-safe vector images.
- 2024/11/6: svg images are converted to typst-safe vector images.

## References

The templates are based on the following repository:

- `chantakan_master-thesis-template_modified.typ`: https://github.com/ut-khanlab/master_thesis_template_for_typst

## License

MIT License

