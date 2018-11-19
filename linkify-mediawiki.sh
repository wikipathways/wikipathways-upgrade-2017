#!/usr/bin/env bash

mediawiki_dir="mediawiki"

for i in composer.lock vendor composer.local.json LocalSettings.php package-lock.json; do
	rm -rf "$mediawiki_dir/$i"
	ln -s ../$i "$mediawiki_dir"
done

for i in extensions/* skins/*; do
    if [ ! -d "$mediawiki_dir/$i" ]; then
        rm -rf "$mediawiki_dir/$i"
	ln -s ../../$i "$mediawiki_dir/$i"
    fi
done

rm -f "$mediawiki_dir"/.htaccess
ln -s ../htaccess "$mediawiki_dir/.htaccess"

rm -rf "$mediawiki_dir/images"
ln -s ../images "$mediawiki_dir/images"
