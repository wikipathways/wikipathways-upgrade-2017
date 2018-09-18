#!/bin/sh -e

git submodule init

cd mediawiki
git checkout .
cd ..

git submodule update
for i in composer.lock vendor composer.local.json LocalSettings.php package-lock.json; do
	rm -rf mediawiki/$i
	ln -s ../$i mediawiki
done

for i in extensions/* skins/*; do
	rm -rf mediawiki/$i
	ln -s ../../$i mediawiki/$i
done

dir=mediawiki/images
stdir=`stat -c %a mediawiki/images`
if [ $stdir -ne 1777 ]; then
	echo need to make images writable
	sudo chmod 1777 $dir
fi
