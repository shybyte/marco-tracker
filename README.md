# MarcoTracker

A simple music tracker just for me.

Goals:

* **Fast Song Sketching** - It should be very easy and fast to sketch a song.
* **Just for me** - This tracker is just for me. I don't care about the wishes of others.
* **Simple** - As simple as possible while still having all features I need.
* **No distractions**
* **Integrated simple Synthesizer** - Should have roughly the capabilities of a C64 SID but not much more.
* **Fixed default effect pipeline** - Delay/Reverb/Chorus/Distortion... Not much more.
* **Default Instruments** - Based on the synth.
* **Native Linux & Webbrowser** - Runs natively on Linux and in a Webbrowser. 
* **Small** - The complete programm should fit on a 880 KB Amiga floppy disc.
* **No Plugins** - Everytime I have tried to use a modern music software, 
  I have spent hours to find the right plugins, but rarely wrote a complete song. 
* **No modular synth/routing/signals** - Everytime I have tried to use a modular synth,
  I have spent hours to connect signals, but rarely wrote a complete song.  
* **No support for other formats than mine** 
* **Midi Input**
* **Usable for 32KB demos/games**
* **ChipTunes** - Makes typical ChipTune effects simple.

Maybe Goals:
* Plays samples
* Midi output
* Export to a midi file

## Build and Run

Requires Zig version 0.11.0

Zig installation: https://github.com/ziglang/zig/wiki/Install-Zig-from-a-Package-Manager

```bash
zig build run
```

On Linux, you need to install the usual dev-packages for GL-, X11- and ALSA-development.

## Experimental web support

Building the project to run in web browsers requires the Emscripten SDK to provide
a sysroot and linker:

```bash
# install emsdk into a subdirectory
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install latest
./emsdk activate latest
cd ..

# build for wasm32-emscripten
zig build -Doptimize=ReleaseSmall -Dtarget=wasm32-freestanding --sysroot emsdk/upstream/emscripten/cache/sysroot
```

The resulting .html, .js and .wasm files are under ```zig-out/web```.

...to build and start the result in a browser, add a 'run' argument to 'zig build', this
uses the Emscripten SDK ```emrun``` tool to start a local webserver and the browser.
Note that you need to hit ```Ctrl-C``` to exit after closing the browser:

```bash
zig build run -Doptimize=ReleaseSmall -Dtarget=wasm32-freestanding --sysroot emsdk/upstream/emscripten/cache/sysroot
```

Note that the Emscripten build currently requires a couple of hacks and workarounds in
the build process, details are in the build.zig file.


## Links

* https://github.com/floooh/pacman.zig (Used as starting point for this project)
* https://github.com/floooh/sokol-zig
* https://github.com/floooh/sokol


## License

GNU AFFERO GENERAL PUBLIC LICENSE


## Copyright

Copyright (c) 2023 Marco Stahl