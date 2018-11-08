#!/bin/sh -e

(
    export PWD=`pwd`;
    cd conf &&
        find . -type f | xargs -i{} sudo sh -c "cd /etc; rm -f {}; ln -s $PWD/{} {}" ||
            echo No conf directory!
)

sudo a2ensite wikipathways.conf

CURRENT_ENVVARS_PATH="$(readlink -f /etc/apache2/envvars)"
CURRENT_ENVVARS_DIR="$(dirname $CURRENT_ENVVARS_PATH)"
EXPECTED_ENVVARS_PRIVATE_PATH="$CURRENT_ENVVARS_DIR/envvars.private"
if [ -e "$EXPECTED_ENVVARS_PRIVATE_PATH" ]; then
  . "$EXPECTED_ENVVARS_PRIVATE_PATH"
else
  echo "We need to set private Apache2 environment variables"

  wp_domain_default="www.wikipathways.org"
  echo -n "Enter site domain and press ENTER [default: $wp_domain_default]: "
  read wp_domain_input
  WP_DOMAIN="${wp_domain_input:-$wp_domain_default}"

  wp_dir_default="/home/$WP_DOMAIN"
  echo -n "Enter path to WikiPathways directory and press ENTER [default: $wp_dir_default]: "
  read wp_dir_input
  WP_DIR="${wp_dir_input:-$wp_dir_default}"
  CURRENT_ENVVARS_PRIVATE_DIR="$WP_DIR/conf/apache2"
  mkdir -p "$CURRENT_ENVVARS_PRIVATE_DIR"
  CURRENT_ENVVARS_PRIVATE_PATH="$CURRENT_ENVVARS_PRIVATE_DIR/envvars.private"
  echo '# -*- sh -*-' > "$CURRENT_ENVVARS_PRIVATE_PATH"
  echo '# envvars.private - private environment variables for apache2ctl' >> "$CURRENT_ENVVARS_PRIVATE_PATH"
  echo "export WP_DIR=$WP_DIR" >> "$CURRENT_ENVVARS_PRIVATE_PATH"
  echo "export WP_DOMAIN=$WP_DOMAIN" >> "$CURRENT_ENVVARS_PRIVATE_PATH"

  wp_dbname_default="wikipathways"
  echo -n "Enter database name and press ENTER [default: $wp_dbname_default]: "
  read wp_dbname_input
  WP_DBNAME="${wp_dbname_input:-$wp_dbname_default}"
  echo "export WP_DBNAME=$WP_DBNAME" >> "$CURRENT_ENVVARS_PRIVATE_PATH"

  wp_dbuser_default="wikiuser"
  echo -n "Enter database name and press ENTER [default: $wp_dbuser_default]: "
  read wp_dbuser_input
  WP_DBUSER="${wp_dbuser_input:-$wp_dbuser_default}"
  echo "export WP_DBUSER=$WP_DBUSER" >> "$CURRENT_ENVVARS_PRIVATE_PATH"

  echo -n "Enter database password and press [ENTER]: "
  read WP_DBPASS
  echo "export WP_DBPASS=$WP_DBPASS" >> "$CURRENT_ENVVARS_PRIVATE_PATH"

  wp_adminemail_default="admin@example.org"
  echo -n "Enter admin email and press ENTER [default: $wp_adminemail_default]: "
  read wp_adminemail_input
  WP_ADMINEMAIL="${wp_adminemail_input:-$wp_adminemail_default}"
  echo "export WP_ADMINEMAIL=$WP_ADMINEMAIL" >> "$CURRENT_ENVVARS_PRIVATE_PATH"

  WP_USESSL="true"
  while true; do
    read -rp "Use SSL? y/n [default: yes] " yn
    case $yn in
      [Yy]* ) WP_USESSL="true"; break;;
      [Nn]* ) WP_USESSL="false"; break;;
      * ) echo "Please answer yes or no.";;
    esac
  done
  echo "export WP_USESSL=$WP_USESSL" >> "$CURRENT_ENVVARS_PRIVATE_PATH"

  if [ "$CURRENT_ENVVARS_PRIVATE_PATH" != "$EXPECTED_ENVVARS_PRIVATE_PATH" ]; then
    ln -s "$CURRENT_ENVVARS_PRIVATE_PATH" "$EXPECTED_ENVVARS_PRIVATE_PATH"
  fi

  . "$EXPECTED_ENVVARS_PRIVATE_PATH"
fi

sudo systemctl restart apache2

# Remove Links temporarily
(cd mediawiki && git reset --hard )

git submodule update --init --recursive
. ./linkify-mediawiki.sh

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

sudo -i bash "./extensions/GPMLConverter/install"

if [ ! -L /etc/apache2/mods-enabled/headers.load ]; then
	echo enable mod_headers
	sudo a2enmod headers
fi

stdir=`stat -c %a images`
if [ $stdir -ne 1777 ]; then
	echo Making images writable
	chmod 1777 $dir
fi

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
