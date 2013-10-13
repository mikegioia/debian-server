#!/bin/bash

# install and configure php
#

echo 'This script will install PHP and PHP-FPM.'
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    echo "Aborted"
    exit 0
fi

if ! [ -f /etc/apt/sources.list.d/dotdeb.list ] ; then
    echo '  --> adding dotdeb source and fetching key'
    echo 'deb http://packages.dotdeb.org stable all' > /etc/apt/sources.list.d/dotdeb.list
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
apt-get install php5 php5-common php5-curl php5-dev \
    php5-gd php5-imagick php5-mcrypt php5-memcache php5-mysql \
    php5-pspell php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl \
    php-pear libssh2-php php5-cli php5-fpm

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
    if [ -f $basepath/conf/$profile/fpm/$fpm_site.conf ] ; then
        cp $basepath/conf/$profile/fpm/$fpm_site.conf /etc/php5/fpm/pool.d/$fpm_site.conf
    else
        if ! [ -f /etc/php5/fpm/pool.d/$fpm_site.conf ] ; then
            $basepath/src/fpm_example.sh $fpm_site
        fi
    fi
done

read -p 'Do you want to add php-fpm to the startup? [Y/n] ' wish
if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    update-rc.d php5-fpm defaults
fi

# ask to install mongo for php
#
if ! [ -f /etc/php5/conf.d/mongo.ini ] ; then
    read -p 'Do you want to install the php mongo extension [Y/n]? ' wish
    if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        apt-get install php-pear php5-dev
        pecl install mongo
        cp $basepath/src/mongo.ini /etc/php5/conf.d/mongo.ini
    fi
fi

echo 'PHP and FPM completed'
echo ''