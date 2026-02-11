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

python3 inline.py out/index.html out/doom.html