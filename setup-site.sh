#!/bin/sh -e

git submodule init
git submodule update
for i in composer.lock vendor composer.local.json LocalSettings.php package-lock.json; do
	rm -rf mediawiki/$i
	ln -s ../$i mediawiki
done

for i in extensions/* skins/*; do
	rm -rf mediawiki/$i
	ln -s ../../$i mediawiki/$i
done

to_install=""
is_installed() {
	dpkg -l $1 > /dev/null  2>&1
	if [ $? -ne 0 ]; then
		to_install="$1 $to_install"
	fi
}

is_installed php-mbstring
is_installed php-mysql
is_installed php-xml
is_installed python-pygments
is_installed npm
is_installed jq

# Proper way to set up a symlink in Debian
sudo update-alternatives --install /usr/bin/node node /usr/bin/nodejs 1

if [ -n "$to_install" ]; then
	echo Installing: $to_install
	sudo apt install $to_install
fi

if [ ! -L /etc/apache2/mods-enabled/headers.load ]; then
	echo enable mod_headers
	sudo a2enmod headers
fi

dir=mediawiki/images
stdir=`stat -c %a mediawiki/images`
if [ $stdir -ne 1777 ]; then
	echo need to make images writable
	sudo chmod 1777 $dir
fi
