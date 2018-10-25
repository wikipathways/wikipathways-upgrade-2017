#!/bin/sh -e

mediawiki_dir="mediawiki"

. ./revert-mediawiki.sh

git submodule sync && git submodule update --init --recursive

# TODO: should this be enabled?
cd "$mediawiki_dir"
composer update
cd ..

. ./linkify-mediawiki.sh
