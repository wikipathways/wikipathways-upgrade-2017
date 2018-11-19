#!/usr/bin/env bash

mediawiki_dir="mediawiki"

./revert-mediawiki.sh

# TODO: --recursive is failing with this error:
# fatal: no submodule mapping found in .gitmodules for path 'jetbrains/phpstorm-stubs'
# I've disabled --recursive and added a section for the mediawiki submodules
# later in this file. Why are we getting that error?
#git submodule sync && git submodule update --init --recursive
git submodule sync && git submodule update --init

cd "$mediawiki_dir"
# TODO: should we run composer update every time?
#composer update
git submodule sync && git submodule update --init
cd ..

./linkify-mediawiki.sh
