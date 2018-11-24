#!/bin/bash -e

dir="${WP_DIR}/images"
stdir=`stat -c %a $dir`
if [ $stdir -ne 1777 ]; then
	chmod 1777 $dir
fi

if [ "$WP_USESSL" == "false" ]; then
	rm -f ${WP_DIR}/conf/apache2/sites-available/ssl-site.conditional
fi

a2query -m mod_headers || sudo a2enmod headers
a2query -s wikipathways.conf || sudo a2ensite wikipathways.conf

sudo systemctl restart apache2
