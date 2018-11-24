#!/usr/bin/env bash
set -e

checkDir() {
	check=$1
	if [ ! -d "$check" ]; then
		echo "Missing directory: '$check'"
		exit 1
	fi
}

checkDir "$MW_INSTALL_PATH"
checkDir "$MW_INSTALL_PATH/.git"

for i in composer.lock vendor composer.local.json LocalSettings.php package-lock.json; do
	rm -rf "$MW_INSTALL_PATH/$i"
done

( # This happens in a subshell so we can be back where we began no matter what $MW_INSTALL_PATH is
    cd "$MW_INSTALL_PATH"

    rm -f .htaccess

    rm -rf images
    rm -rf extensions
    rm -rf skins

    git checkout .
)
