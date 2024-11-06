#!/bin/bash

# Convert Image and Compile the Typst document.

# Install the required packages.
# ---- drawio ----
# sudo snap install drawio
# # after installing drawio, add the following line to .profile or .zprofile
# export PATH=$PATH:/snap/bin

# ---- pdftocairo ----
# sudo apt install poppler-utils

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
  while read filename_main; do
    if [[ ! img/${filename_main}.svg -nt img/${filename_main}.drawio ]]; then
      drawio -xrf pdf --crop -o tmp/ img/${filename_main}.drawio
      pdftocairo -svg tmp/${filename_main}.pdf img/${filename_main}.svg
    else
      echo "skipped: ${filename_main}.drawio is not updated"
    fi
  done < <(find img -name "*.drawio" -printf "%f\n" | rev | sed s/oiward.// | rev)
  rm -rf tmp/*

  # Compile the main document.
  echo "Compiling the main document..."
  typst compile main.typ && mv main.pdf ../$docname.pdf
)
