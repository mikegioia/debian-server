#!/bin/bash

# install and configure Percona xtrabackup
#

echo 'This script will install xtrabackup'
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    echo "Aborted"
    exit 0
fi

# echo this out to mariadb.list if file not found
#
if ! [ -f /etc/apt/sources.list.d/xtrabackup.list ] ; then
    echo '  --> adding xtrabackup source and fetching key'
    echo 'deb http://repo.percona.com/apt wheezy main' > /etc/apt/sources.list.d/xtrabackup.list
    echo 'deb-src http://repo.percona.com/apt wheezy main' >> /etc/apt/sources.list.d/xtrabackup.list
    apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
    apt-get update
fi

echo '  --> installing xtrabackup'

apt-get install xtrabackup

echo 'xtrabackup completed'
echo ''
