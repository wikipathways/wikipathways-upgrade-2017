#!/bin/sh -e

mediawiki_dir="mediawiki"

bash ./revert-mediawiki.sh

git submodule sync && git submodule update --init --recursive

for i in composer.lock vendor composer.local.json LocalSettings.php package-lock.json; do
	rm -rf mediawiki/$i
	ln -s ../$i mediawiki
done

for i in extensions/* skins/*; do
    if [ ! -d mediawiki/$i ]; then
        rm -rf mediawiki/$i
	ln -s ../../$i mediawiki/$i
    fi
done

rm -f mediawiki/.htaccess
ln -s ../htaccess mediawiki/.htaccess

rm -f mediawiki/images/wikipathways
ln -s ../images/wikipathways mediawiki/images/wikipathways

rm -f mediawiki/images/wpi
ln -s ../images/wpi mediawiki/images/wpi

dir=mediawiki/images
stdir=`stat -c %a mediawiki/images`
if [ $stdir -ne 1777 ]; then
	#echo 'making images writable...'
	sudo chmod 1777 $dir
fi
