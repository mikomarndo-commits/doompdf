#!/bin/bash

set -e
set -x

if [ ! -d "./emsdk" ]; then
  git clone https://github.com/emscripten-core/emsdk.git --depth=1 -b 3.1.69
  ./emsdk/emsdk install 3.1.69
  ./emsdk/emsdk activate 3.1.69
fi

source ./emsdk/emsdk_env.sh >/dev/null 2>&1


if [ ! -f "doomgeneric/doom1.wad" ]; then
  wget "https://distro.ibiblio.org/slitaz/sources/packages/d/doom1.wad" -O "doomgeneric/doom1.wad"
fi
if [ ! -d "doomgeneric/dgguspat" ]; then
  wget "https://youfailit.net/pub/idgames/music/dgguspat.zip" -O "/tmp/dgguspat.zip"
  mkdir -p "doomgeneric/dgguspat"
  unzip "/tmp/dgguspat.zip" -d "doomgeneric/dgguspat"
  rm -rf "/tmp/dgguspat.zip"
fi
if [ "$1" = "clean" ]; then
  emmake make -C doomgeneric -f Makefile_html clean
fi
emmake make -C doomgeneric -f Makefile_html -j$(nproc --all)

mkdir -p out
cp web/* out/
cat pre.js doomgeneric/doomgeneric.js > out/compiled.js

#python3 embed_file.py file_template.js doomgeneric/doom1.wad out/data.js
#cat pre.js out/data.js doomgeneric/doomgeneric.js > out/compiled.js
#cat pre.js file_template.js doomgeneric/doomgeneric.js > out/compiled_nowad.js

#python3 generate.py out/compiled.js out/doom.pdf
#python3 generate.py out/compiled_nowad.js out/doom_nowad.pdf