#!/usr/bin/env bash
set -e

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
is_installed php-zip
is_installed composer
is_installed python-pygments

if [ -n "$to_install" ]; then
	echo Installing: $to_install
	sudo apt install $to_install
fi

sudo apt-get autoremove -y
