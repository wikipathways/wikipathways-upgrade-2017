#!/usr/bin/env bash
set -e

setup/conf-links.sh

CURRENT_ENVVARS_PATH="$(readlink -f /etc/apache2/envvars)"
CURRENT_ENVVARS_DIR="$(dirname $CURRENT_ENVVARS_PATH)"
EXPECTED_ENVVARS_PRIVATE_PATH="$CURRENT_ENVVARS_DIR/envvars.private"
setup/create-private-envvars.sh
. "$EXPECTED_ENVVARS_PRIVATE_PATH"

# Remove git hooks unless requested to keep
setup/fixup-hooks.sh

# Remove symlinks temporarily
setup/delinkify-mediawiki.sh

# Check out everything
git submodule update --init --recursive

# Reset symlinks
setup/linkify-mediawiki.sh

# Setup OS packages
setup/install-packages.sh

# Do GPMLConverter configuration
sudo -i bash "$WP_DIR/extensions/GPMLConverter/install"

# Finally, set up apache
setup/apache.sh
