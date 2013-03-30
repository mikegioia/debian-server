#!/bin/bash

# install and configure php
#

echo 'This script will install php, daemontools, and spawn-fcgi'
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    exit
fi

usage="$0 <config>"
config=${1:-"server.cfg"}

if [ ! -f $config ] ; then
    echo "Could not find the config file you entered: $config."
    exit
fi

. ./$config

echo '  --> installing spawn-fcgi and php5'
apt-get install spawn-fcgi php5-cgi php5-mysql php5-curl php5-gd php5-idn php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-ming php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl

echo '  --> installing daemontools'
aptitude install daemontools daemontools-run

echo '  --> setting up spawn-fcgi'
mkdir -p /etc/sv/spawn-fcgi
cd
cp ./src/spawn-fcgi /etc/sv/spawn-fcgi/run
chmod +x /etc/sv/spawn-fcgi/run
update-service --add /etc/sv/spawn-fcgi spawn-fcgi
