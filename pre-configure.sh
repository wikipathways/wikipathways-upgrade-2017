#!/bin/bash

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
