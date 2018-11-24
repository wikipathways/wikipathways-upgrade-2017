#!/usr/bin/env bash

. ./link-files

for i in $topdirFile $subdirFile; do
	test -L "$mediawiki_dir/$i" && rm "$mediawiki_dir/$i"
done

test -e "$mediawiki_dir/.htaccess" && rm -f "$mediawiki_dir"/.htaccess
