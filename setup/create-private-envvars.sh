#!/usr/bin/env bash
set -e

CURRENT_ENVVARS_PATH="$(readlink -f /etc/apache2/envvars)"
CURRENT_ENVVARS_DIR="$(dirname $CURRENT_ENVVARS_PATH)"
EXPECTED_ENVVARS_PRIVATE_PATH="$CURRENT_ENVVARS_DIR/envvars.private"
if [ ! -e "$EXPECTED_ENVVARS_PRIVATE_PATH" ]; then
	echo "We need to set private Apache2 environment variables.  Defaults are in brackets."

	wp_domain_default="www.wikipathways.org"
	read -p "Enter site domain and press ENTER [$wp_domain_default]: " wp_domain_input
	WP_DOMAIN="${wp_domain_input:-$wp_domain_default}"

	wp_dir_default="/home/$WP_DOMAIN"
	read -p "Enter path to WikiPathways directory and press ENTER [$wp_dir_default]: " wp_dir_input
	WP_DIR="${wp_dir_input:-$wp_dir_default}"
	CURRENT_ENVVARS_PRIVATE_DIR="$WP_DIR/conf/apache2"
	CURRENT_ENVVARS_PRIVATE_PATH="$CURRENT_ENVVARS_PRIVATE_DIR/envvars.private"

	wp_dbname_default="wikipathways"
	read -p "Enter database name and press ENTER [$wp_dbname_default]: " wp_dbname_input
	WP_DBNAME="${wp_dbname_input:-$wp_dbname_default}"

	wp_dbuser_default="wikiuser"
	read -p "Enter database name and press ENTER [$wp_dbuser_default]: " wp_dbuser_input
	WP_DBUSER="${wp_dbuser_input:-$wp_dbuser_default}"

	# From https://stackoverflow.com/a/22249163
	while true; do
		read -s -p "Enter database password and press [ENTER]: " WP_DBPASS
		echo
		read -s -p "Password (again): " password2
		echo
		[ "$WP_DBPASS" = "$password2" ] && break
		echo "Please try again"
	done

	wp_adminemail_default="admin@example.org"
	read -p "Enter admin email and press ENTER [$wp_adminemail_default]: " wp_adminemail_input
	WP_ADMINEMAIL="${wp_adminemail_input:-$wp_adminemail_default}"

	WP_USESSL="true"
	while true; do
		# Read only one character. "-r" did not make sense here 
		read -N 1 -p "Use SSL? ('y' or 'n' only) " yn

		case $yn in
			[Yy]* ) WP_USESSL="true"; break;;
			[Nn]* ) WP_USESSL="false"; break;;
			* ) echo "Please answer yes or no.";;
		esac
	done

	echo
	echo Configuration complete.
	if [ -d "$CURRENT_ENVVARS_PRIVATE_DIR" ]; then
		mkdir -p "$CURRENT_ENVVARS_PRIVATE_DIR"
	fi

	test -d "$CURRENT_ENVVARS_PRIVATE_DIR" || mkdir -p "$CURRENT_ENVVARS_PRIVATE_DIR"
	test -w "${CURRENT_ENVVARS_PRIVATE_PATH}" || (
		touch "${CURRENT_ENVVARS_PRIVATE_PATH}"
		sudo chmod +w ${CURRENT_ENVVARS_PRIVATE_PATH}
	)

	echo Generating "'$CURRENT_ENVVARS_PRIVATE_PATH'"
	tee<<EOF > "$CURRENT_ENVVARS_PRIVATE_PATH"
# -*- sh -*-
# envvars.private - private environment variables for apache2ctl
export WP_DIR="$WP_DIR"
export WP_ROOT="${WP_DIR}/mediawiki"
export MW_INSTALL_PATH="${WP_DIR}/mediawiki"
export WP_LOGDIR="${WP_DIR}/logs"
export WP_DOMAIN="$WP_DOMAIN"
export WP_DBNAME="$WP_DBNAME"
export WP_DBUSER="$WP_DBUSER"
export WP_DBPASS="$WP_DBPASS"
export WP_ADMINEMAIL="$WP_ADMINEMAIL"
export WP_USESSL="$WP_USESSL"
EOF

	if [ "$CURRENT_ENVVARS_PRIVATE_PATH" != "$EXPECTED_ENVVARS_PRIVATE_PATH" ]; then
		ln -s "$CURRENT_ENVVARS_PRIVATE_PATH" "$EXPECTED_ENVVARS_PRIVATE_PATH"
	fi
fi
