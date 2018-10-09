#!/bin/sh -e

echo 'Running a git hook...'

mediawiki_dir="mediawiki"
if [ -d "$mediawiki_dir" ] && [ -d "$mediawiki_dir/.git" ]; then
	cd "$mediawiki_dir"
	git checkout .
	cd ..
fi

git submodule update --init --recursive

rm -f "$mediawiki_dir/.htaccess"
ln -s htaccess "$mediawiki_dir/.htaccess"

for i in composer.lock composer.local.json LocalSettings.php package-lock.json vendor; do
	rm -rf "$mediawiki_dir/$i"
	ln -s ../$i "$mediawiki_dir"
done

for i in extensions/* skins/*; do
	rm -rf "$mediawiki_dir/$i"
	ln -s ../../$i "$mediawiki_dir/$i"
done

dir="$mediawiki_dir/images"
stdir=`stat -c %a mediawiki/images`
if [ $stdir -ne 1777 ]; then
	echo need to make images writable
	sudo chmod 1777 $dir
fi
