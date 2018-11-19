#!/usr/bin/env bash

mediawiki_dir="mediawiki"

if [ ! -d "$mediawiki_dir" ] && [ ! -f "$mediawiki_dir/.git" ]; then
	echo "Missing directory $mediawiki or $mediawiki/.git"
	exit 1
fi

for i in composer.lock vendor composer.local.json LocalSettings.php package-lock.json; do
	rm -rf "$mediawiki_dir/$i"
done

cd "$mediawiki_dir"

rm -f .htaccess

rm -rf images
rm -rf extensions
rm -rf skins

git checkout REL1_31
git pull origin REL1_31
git checkout .
cd ..
