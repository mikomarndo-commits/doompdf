# DoomHTML

This is a Doom source port that runs inside an HTML file, with no CSS or `<canvas>` tag used.

It was made for the [Hack Club Flavorless](https://flavorless.hackclub.com/) event, which was a challenge to create a website with only HTML and JavaScript.

Play it here: [doom.html](https://doomhtml.pages.dev/doom.html)

## Explanation
This port works by setting an `<img>` src to dynamically generated BMP image files in order to display the framebuffer. Emscripten is used to compile [doomgeneric](https://github.com/ozkl/doomgeneric) to JS and WASM.

Audio and music are enabled, using the [Gravis Ultrasound soundfont](https://www.doomworld.com/idgames/music/dgguspat). 

## Build Instructions

Clone this repository and run the following commands:
```
python3 -m venv .venv
source .venv/bin/activate
pip3 install -r requirements.txt
env CFLAGS=-O3 ./build.sh
```

The `build.sh` script will download Emscripten `3.1.69` automatically. You must be on Linux to build this. 

The generated files will be in the `out/` directory. Then you can run `(cd out; python3 -m http.server)` to serve the files on a web server.

## Credits

This port is made by [@ading2210](https://github.com/ading2210/).

Forked from [doomgeneric](https://github.com/ozkl/doomgeneric).

## License

This repository is licensed under the GNU GPL v2.

```
ading2210/doomhtml - Doom running inside an HTML file without CSS or canvas
Copyright (C) 2025 ading2210

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
```
