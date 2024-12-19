#!/bin/bash

# Convert Image and Compile the Typst document.

# # Install the required packages.

# ---- drawio ----
# sudo snap install drawio
# # after installing drawio, add the following line to .profile or .zprofile
# export PATH=$PATH:/snap/bin

# ---- librsvg2-bin ----
# sudo apt install librsvg2-bin

# ---- pdftocairo ----
# sudo apt install poppler-utils

# ---- typst and rust ----
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
  cd $dirpath

  # Convert Image.
  bash _convert_image.sh
  # Build the Typst document.
  bash _build_typst.sh

)
