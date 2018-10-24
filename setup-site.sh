#!/bin/sh -e

(
    export PWD=`pwd`;
    cd conf &&
        find . -type f | xargs -i{} sudo sh -c "cd /etc; rm -f {}; ln -s $PWD/{} {}" ||
            echo No conf directory!
)

sudo a2ensite wikipathways.conf
sudo systemctl reload apache2

# Remove Links temporarily
(cd mediawiki && git reset --hard )

git submodule update --init --recursive
for i in composer.lock vendor composer.local.json LocalSettings.php package-lock.json; do
	rm -rf mediawiki/$i
	ln -s ../$i mediawiki
done

for i in extensions/* skins/*; do
    if [ ! -d mediawiki/$i ]; then
        rm -rf mediawiki/$i
	ln -s ../$i mediawiki/$i
    fi
done

rm -f mediawiki/.htaccess
ln -s htaccess mediawiki/.htaccess

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
is_installed jq

if [ -n "$to_install" ]; then
	echo Installing: $to_install
	sudo apt install $to_install
fi

if [ ! -L /etc/apache2/mods-enabled/headers.load ]; then
	echo enable mod_headers
	sudo a2enmod headers
fi

#wget -qO- https://deb.nodesource.com/setup_10.x | sudo -E bash -
#sudo apt-get install -y nodejs
sudo apt install -y npm

stdir=`stat -c %a images`
if [ $stdir -ne 1777 ]; then
	echo Making images writable
	chmod 1777 $dir
fi

# Proper way to set up a symlink in Debian
# if [ -x /usr/bin/nodejs ]; then
#     sudo update-alternatives --install /usr/bin/node node /usr/bin/nodejs 1
# fi

sudo apt-get autoremove -y

cat > "./.git/hooks/post-checkout" <<EOF
#!/usr/bin/env bash
./update-submodules.sh
EOF
sudo chmod ug+x "./.git/hooks/post-checkout"

cat > "./.git/hooks/post-rewrite" <<EOF
#!/usr/bin/env bash
./update-submodules.sh
EOF
sudo chmod ug+x "./.git/hooks/post-rewrite"
