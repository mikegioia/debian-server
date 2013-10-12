#!/bin/bash

# set up mysql
#

echo 'This script will update the system and install MySQL.'
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    echo "Aborted"
    exit
fi

echo '  --> installing mysql'
apt-get install mysql-server mysql-client

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

echo 'MySQL completed'
echo ''