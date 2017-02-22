#!/bin/sh
lua -e "package.path=package.path..\";`pwd`/luajsong/?.lua\"" ./tests/encode.lua
luajit -e "package.path=package.path..\";`pwd`/luajsong/?.lua\"" ./tests/encode.lua

lua -e "package.path=package.path..\";`pwd`/luajsong/?.lua\"" ./tests/decode.lua
luajit -e "package.path=package.path..\";`pwd`/luajsong/?.lua\"" ./tests/decode.lua
