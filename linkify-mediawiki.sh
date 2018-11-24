#!/bin/bash -e

. ./link-files

for i in $topdirFile; do
    test -e $i || ln -s ../$i "$mediawiki_dir/$i"
done

for i in $subdirFile; do
    test -d "$mediawiki_dir/$i" || ln -s ../../$i "$mediawiki_dir/$i"
done

test -e "$mediawiki_dir/.htaccess" || ln -s ../htaccess "$mediawiki_dir/.htaccess"
