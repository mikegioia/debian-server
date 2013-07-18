#!/bin/bash

# install and configure php
#

echo 'This script will install php and php-fpm'
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    echo "Aborted"
    exit 0
fi

if ! [ -f /etc/apt/sources.list.d/dotdeb.list ] ; then
    echo '  --> adding dotdeb source and fetching key'
    echo 'deb http://packages.dotdeb.org stable all' >> /etc/apt/sources.list.d/dotdeb.list
    echo 'deb-src http://packages.dotdeb.org stable all' >> /etc/apt/sources.list.d/dotdeb.list
    wget http://www.dotdeb.org/dotdeb.gpg
    cat dotdeb.gpg | sudo apt-key add -
    rm dotdeb.gpg
    cd /opt
    apt-get update
fi

echo '  --> installing php5 with FPM'
# optionally:
#   php5-idn, php5-ming, php5-recode, php5-cgi, php5-imap
apt-get install php5 php5-fpm php5-common php5-curl php5-dev \
    php5-gd php5-imagick php5-mcrypt php5-memcache php5-mysql \
    php5-pspell php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl \
    php-pear libssh2-php php5-cli

echo '  --> configuring php-fpm'

# loop through any FPM domains and generate the pool.d conf file. we need
# to re-source the config file to get the array data.
#
. $basepath/conf/$profile/config

for fpm_site in "${fpm_sites[@]}"
do
    # generate nginx site config files to sites-available and add 
    # symbolic links in sites-enabled
    #
    $basepath/src/fpm_example.sh $fpm_site
done

update-rc.d php5-fpm defaults

echo 'PHP and FPM completed'
echo ''