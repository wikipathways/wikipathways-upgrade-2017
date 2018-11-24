#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. $DIR/link-files

for i in $topdirFile; do
    test -e $i || ln -s ../$i "$MW_INSTALL_PATH/$i"
done

for i in $subdirFile; do
    test -d "$MW_INSTALL_PATH/$i" || ln -s ../../$i "$MW_INSTALL_PATH/$i"
done

test -e "$MW_INSTALL_PATH/.htaccess" || ln -s ../htaccess "$MW_INSTALL_PATH/.htaccess"
