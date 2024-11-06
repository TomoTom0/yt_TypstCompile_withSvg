#!/bin/bash

# Convert Image and Compile the Typst document.

# Install the required packages.
# ---- drawio ----
# sudo snap install drawio
# # after installing drawio, add the following line to .profile or .zprofile
# export PATH=$PATH:/snap/bin

# ---- pdftocairo ----
# sudo apt install poppler-utils

# ---- rsvg-convert ----
# sudo apt install librsvg2-bin

# ---- typst ----
# # Firstly, you need to install Rust.
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# # Then, install typst.
# cargo install typst-cli

(

  dirpath=$(
    cd $(dirname $0)
    pwd
  )
  echo $dirpath
  cd $dirpath/src
  docname=$(basename $dirpath)
  mkdir -p tmp img

  # Convert drawio files to svg through pdf.
  echo "Converting drawio files to svg..."
  while read filename; do
    filename_main=$(echo $filename | rev | sed -e "s/.*oiward\.//" | rev)
    if [[ ! img/${filename_main}_notext.svg -nt img/${filename} ]]; then
      drawio -xrf pdf --crop -o tmp/ img/${filename}
      pdftocairo -svg tmp/${filename_main}.pdf img/${filename_main}_notext.svg
    else
      echo "skipped: ${filename} is not updated"
    fi
  done < <(find img -name "*.drawio" -or -name "*.drawio.svg"  -printf "%f\n")
  rm -rf tmp/*

  echo ""
  echo "Converting svg to pdf, then to svg..."
  while read filename_main; do
    if [[ ! img/${filename_main}_notext.svg -nt img/${filename_main}.drawio ]]; then
      rsvg-convert -f pdf -o tmp/${filename_main}.pdf img/${filename_main}.svg
      pdftocairo -svg tmp/${filename_main}.pdf img/${filename_main}_notext.svg
    else
      echo "skipped: ${filename_main}.svg is not updated"
    fi
  done < <(find img -name "*.svg" -not -name "*_notext.svg" -printf "%f\n" |
   rev | sed s/gvs.// | rev)
  rm -rf tmp/*

  echo ""
  echo "Converting pdf to svg..."
  while read filename_main; do
    if [[ ! img/${filename_main}_notext.svg -nt img/${filename_main}.drawio ]]; then
      pdftocairo -svg img/${filename_main}.pdf img/${filename_main}_notext.svg
    else
      echo "skipped: ${filename_main}.pdf is not updated"
    fi
  done < <(find img -name "*.pdf" -printf "%f\n" | rev | sed s/fdp.// | rev)


  # Compile the main document.
  echo "Compiling the main document..."
  typst compile main.typ && mv main.pdf ../$docname.pdf
)
