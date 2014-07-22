#!/bin/bash
#
# Installs MySQL from apt
##

echo 'This script will update the system and install MySQL.'
read -p 'Do you want to continue? [y/N] ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    echo "Aborted"
    exit
fi

echo '  --> installing mysql'
apt-get install mysql-server mysql-client

if [[ -f "$basepath/conf/$profile/my.cnf" ]] ; then
    echo '  --> copying over my.cnf to /etc/my.cnf'
    cp $basepath/conf/$profile/my.cnf /etc/mysql/conf.d/my.cnf
    /etc/init.d/mysql reload
fi

## If there's a mysql history file, write null to it
if [[ -f "~/.mysql_history" ]] ; then
    cat /dev/null > ~/.mysql_history
fi

echo '  --> adding to startup scripts'
update-rc.d mysql defaults

echo 'MySQL completed'
echo ''