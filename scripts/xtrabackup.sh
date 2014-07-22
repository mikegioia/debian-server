#!/bin/bash
#
# Install and configure Percona XtraBackup
##

echo 'This script will install Percona XtraBackup'
read -p 'Do you want to continue? [y/N] ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    echo "Aborted"
    exit 0
fi

## Add apt list and update
if ! [[ -f "/etc/apt/sources.list.d/xtrabackup.list" ]] ; then
    echo '  --> adding XtraBackup source and fetching key'
    echo 'deb http://repo.percona.com/apt wheezy main' > /etc/apt/sources.list.d/xtrabackup.list
    echo 'deb-src http://repo.percona.com/apt wheezy main' >> /etc/apt/sources.list.d/xtrabackup.list
    apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
    apt-get update
fi

echo '  --> installing XtraBackup'
apt-get install xtrabackup

echo 'XtraBackup completed'
echo ''