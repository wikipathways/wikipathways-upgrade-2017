#!/bin/bash

#Installs dependecies on a vanilla ubuntu 18.04
#make // required by install
#mysql-server // required by mediawiki
#apache2 // required by mediawiki

#a2enmod rewrite // required by mediawiki
#a2enmod headers // required by mediawiki

#php // required by mediawiki
#php-xml // required by mediawiki
#php-mbstring // required by mediawiki
#php-mysql // required by mediawiki

#composer  // required by install
#zip //composer dependency

apt-get install make
apt-get install mysql-server
apt-get install apache2

a2enmod rewrite
a2enmod headers

apt-get install php
apt-get install php-xml
apt-get install php-mbstring
apt-get install php-mysql

apt-get install composer
apt-get install zip //composer dependency
