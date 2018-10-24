#!/bin/sh -e

mediawiki_dir="mediawiki"

bash ./revert-mediawiki.sh

git submodule sync && git submodule update --init --recursive

# TODO: should this be enabled?
cd "$mediawiki_dir"
composer update
cd ..

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

rm -rf mediawiki/images
ln -s ../images mediawiki/images

dir=./images
stdir=`stat -c %a $dir`
if [ $stdir -ne 1777 ]; then
	#echo 'making images writable...'
	sudo chmod 1777 $dir
fi
