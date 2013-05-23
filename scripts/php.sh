#!/bin/bash

# install and configure php
#

echo 'This script will install php, daemontools, and spawn-fcgi'
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    echo "Aborted"
    exit 0
fi


echo '  --> adding dotdeb source and fetching key'
cd /opt
echo 'deb http://packages.dotdeb.org stable all' >> /etc/apt/sources.list
wget http://www.dotdeb.org/dotdeb.gpg
cat dotdeb.gpg | apt-key add -
rm dotdeb.gpg
cd

echo '  --> installing php5 with FPM'
apt-get update
apt-get install php5-fpm php5-cgi php5-mysql php5-curl php5-gd php5-idn \
    php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-ming \
    php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc \
    php5-xsl

# @TODO
# see http://www.rackspace.com/knowledge_center/article/installing-nginx-and-php-fpm-setup-for-php-fpm
# for more info on finishing the FPM installation

