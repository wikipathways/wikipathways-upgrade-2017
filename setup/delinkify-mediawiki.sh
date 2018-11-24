#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
. $DIR/link-files

test -e "$MW_INSTALL_PATH/.htaccess" && rm -f "$MW_INSTALL_PATH/.htaccess" || true

# Handling images seperately because it may be a dir in the original checkout
test -e "$MW_INSTALL_PATH/images" && rm -rf "$MW_INSTALL_PATH/images" || true

# We use '|| true' here because we want to continue even if these files don't exist
for i in $topdirFile $subdirFile; do
	test -L "$MW_INSTALL_PATH/$i" && rm "$MW_INSTALL_PATH/$i" || true
done

