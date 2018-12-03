#!/usr/bin/env bash

# see https://stackoverflow.com/a/246128/5354298
get_script_dir() { echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; }
SCRIPT_DIR=$(get_script_dir)

sudo chgrp -R wpdevs "$SCRIPT_DIR/../"
sudo chmod -R g+rw "$SCRIPT_DIR/../"

# TODO: would the following be better?
#sudo chgrp -R wpdevs !("$SCRIPT_DIR/../images") "$SCRIPT_DIR/../"
#sudo chmod -R g+rw !("$SCRIPT_DIR/../images") "$SCRIPT_DIR/../"

# We want the files in the images directory to have permissions like this:
# -rw-r--r-- 1 www-data www-data  809647 Nov 24 20:21 /home/wikipathways.org/images/wikipathways/3/39/WP2759_74754.gpml
sudo chown -R www-data:www-data "$SCRIPT_DIR/../images/"
sudo chmod -R 644 "$SCRIPT_DIR/../images/"

# But the directories need different permissions so commands like 'ls' work:
# drwxr-xr-x 18 www-data wpdevs    150 Oct 23 12:32 wikipathways
sudo find "$SCRIPT_DIR/../images/" -type d -print0 | xargs -0 sudo chown www-data:wpdevs
sudo find "$SCRIPT_DIR/../images/" -type d -print0 | xargs -0 sudo chmod 775 

# So WP devs can edit the metabolite pattern files
mkdir -p "$SCRIPT_DIR/../images/metabolite-pattern-cache"
sudo chown -R www-data:wpdevs "$SCRIPT_DIR/../images/metabolite-pattern-cache"
sudo chmod -R 664 "$SCRIPT_DIR/../images/metabolite-pattern-cache/"
sudo find "$SCRIPT_DIR/../images/metabolite-pattern-cache/" -type d -print0 | xargs -0 sudo chmod 775 
