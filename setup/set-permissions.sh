#!/usr/bin/env bash

# see https://stackoverflow.com/a/246128/5354298
get_script_dir() { echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; }
SCRIPT_DIR=$(get_script_dir)

sudo chgrp -R wpdevs "$SCRIPT_DIR/../"
sudo chmod -R g+rw "$SCRIPT_DIR/../"
