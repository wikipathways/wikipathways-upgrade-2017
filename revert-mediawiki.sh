#!/bin/sh -e

mediawiki_dir="mediawiki"

for i in composer.lock vendor composer.local.json LocalSettings.php package-lock.json; do
	rm -rf mediawiki/$i
done

for i in extensions/* skins/*; do
    if [ ! -d mediawiki/$i ]; then
        rm -rf mediawiki/$i
    fi
done

rm -f mediawiki/.htaccess
rm -f mediawiki/images/wikipathways
rm -f mediawiki/images/wpi

if [ -d "$mediawiki_dir" ] && [ -d "$mediawiki_dir/.git" ]; then
	cd "$mediawiki_dir"
	git checkout .
	cd ..
fi
