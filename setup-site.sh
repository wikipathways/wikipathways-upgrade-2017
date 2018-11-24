#!/bin/bash -e

setup/conf-links.sh

CURRENT_ENVVARS_PATH="$(readlink -f /etc/apache2/envvars)"
CURRENT_ENVVARS_DIR="$(dirname $CURRENT_ENVVARS_PATH)"
EXPECTED_ENVVARS_PRIVATE_PATH="$CURRENT_ENVVARS_DIR/envvars.private"
setup/create-private-envvars.sh
. "$EXPECTED_ENVVARS_PRIVATE_PATH"

# Remove Links temporarily
setup/delinkify-mediawiki.sh

# Remove git hooks unless requested to keep
setup/fixup-hooks.sh

git submodule update --init --recursive
setup/linkify-mediawiki.sh
setup/install-packages.sh

sudo -i bash "./extensions/GPMLConverter/install"

setup/apache.sh
