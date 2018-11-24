#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
$DIR/revert-mediawiki.sh

# TODO: --recursive is failing with this error:
# fatal: no submodule mapping found in .gitmodules for path 'jetbrains/phpstorm-stubs'
# I've disabled --recursive and added a section for the mediawiki submodules
# later in this file. Why are we getting that error?
#git submodule sync && git submodule update --init --recursive
git submodule sync && git submodule update --init

( # subshell so we don't have to come back to where we are
    cd "$MW_INSTALL_PATH"
    # TODO: should we run composer update every time?
    #composer update
    git submodule sync && git submodule update --init
}

$DIR/linkify-mediawiki.sh

