#!/bin/bash

# Build the Typst document.

(
  dirpath=$(
    cd $(dirname $0)
    pwd
  )
  echo $dirpath
  cd $dirpath/src
  docname=$(basename $dirpath)

  # Compile the main document.
  echo "Compiling the main document..."
  typst compile main.typ && mv main.pdf ../$docname.pdf
)
