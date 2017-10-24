#!/bin/sh -e

git submodule init
git submodule update
for i in composer.lock vendor composer.local.json LocalSettings.php; do
    rm mediawiki/$i
    ln -s ../$i mediawiki
done

for i in extensions/* skins/*; do
    rm mediawiki/$i
    ln -s ../../$i mediawiki/$i
done

echo installing mbstring, mysql, and xml for php
sudo apt install php-mbstring php-mysql php-xml

chmod 1777 mediawiki/images

