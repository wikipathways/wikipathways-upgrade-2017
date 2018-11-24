#!/bin/bash -e

stdir=`stat -c %a images`
if [ $stdir -ne 1777 ]; then
	chmod 1777 $dir
fi

if [ "$WP_USESSL" == "false" ]; then
	rm conf/apache2/sites-available/ssl-site.conditional
fi

if [ ! -L /etc/apache2/mods-enabled/headers.load ]; then
	echo enable mod_headers
	sudo a2enmod headers
fi


sudo a2ensite wikipathways.conf
sudo systemctl restart apache2
