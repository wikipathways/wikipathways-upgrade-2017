#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. $DIR/link-files

for i in $topdirFile; do
    test -e "$MW_INSTALL_PATH/$i" || ln -s ../$i "$MW_INSTALL_PATH/$i"
done

for i in $subdirFile; do
    if [ -d "$MW_INSTALL_PATH/$i" -a ! -L "$MW_INSTALL_PATH/$i" ]; then
        echo $i is in core MW now.  You should probably remove it from extensions or fix this script.
        exit 1
    else
        if [ ! -L  "$MW_INSTALL_PATH/$i" ]; then
            ln -s ../../$i "$MW_INSTALL_PATH/$i"
        fi
    fi
done

test -e "$MW_INSTALL_PATH/.htaccess" || ln -s ../htaccess "$MW_INSTALL_PATH/.htaccess"
