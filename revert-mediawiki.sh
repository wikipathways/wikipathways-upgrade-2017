#!/bin/sh -e

mediawiki_dir="mediawiki"

if [ ! -d "$mediawiki_dir" ] && [ ! -f "$mediawiki_dir/.git" ]; then
	echo "$mediawiki directory does not exist or is missing .git"
	exit 1
fi

cd "$mediawiki_dir"

for i in composer.lock vendor composer.local.json LocalSettings.php package-lock.json; do
	rm -rf "$mediawiki_dir/$i"
done

for i in extensions/* skins/*; do
    if [ ! -d "$mediawiki_dir/$i" ]; then
        rm -rf "$mediawiki_dir/$i"
    fi
done

rm -f .htaccess
rm -f images/wikipathways
rm -f images/wpi


rm -rf extensions
rm -rf skins

git checkout .
cd ..
