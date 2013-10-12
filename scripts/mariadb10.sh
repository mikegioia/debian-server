#!/bin/bash

# set up maria \db
#

echo 'This script will update the system and install MariaDB.'
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    echo "Aborted"
    exit
fi

# echo this out to mariadb.list if file not found
#
if ! [ -f /etc/apt/sources.list.d/mariadb.list ] ; then
    echo '  --> adding mariadb source and fetching key'
    echo '# https://downloads.mariadb.org/mariadb/repositories/' > /etc/apt/sources.list.d/mariadb.list
    echo 'deb http://mirror.jmu.edu/pub/mariadb/repo/10.0/debian wheezy main' >> /etc/apt/sources.list.d/mariadb.list
    echo 'deb-src http://mirror.jmu.edu/pub/mariadb/repo/10.0/debian wheezy main' >> /etc/apt/sources.list.d/mariadb.list
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
    apt-get update
fi

echo '  --> installing MariaDB'
apt-get install mariadb-server

# when prompted, set the root user password

echo '  --> copying over my.cnf to /etc/my.cnf'
if [ -f $basepath/conf/$profile/my.cnf ] ; then
    cp $basepath/conf/$profile/my.cnf /etc/mysql/conf.d/my.cnf
    /etc/init.d/mysql reload
fi

# if there's a mysql history file, write null to it
#
cd
if [ -f .mysql_history ] ; then
    cat /dev/null > .mysql_history
fi

echo '  --> adding to startup scripts'
update-rc.d mysql defaults

echo 'MariaDB completed'
echo ''