#!/bin/bash
#
# Sets up fail2ban
##

echo 'This script will install Fail2Ban and configure it.'
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    exit
fi

## Install fail2ban if it's not installed
if ! [ hash fail2ban 2>/dev/null ]; then
    apt-get install fail2ban
fi

## Check if there's a local config file to update
if [ -f $basepath/conf/$profile/jail.local ] ; then
    cp $basepath/conf/$profile/jail.local /etc/fail2ban/jail.local
fi

## Copy over configs if they're not there
if ! [ -f /etc/fail2ban/filter.d/nginx-dos.conf ] ; then
    cp $basepath/src/fail2ban_conf/nginx-dos.conf /etc/fail2ban/filter.d/nginx-dos.conf
fi

## Restart the service
service fail2ban restart

echo 'Fail2Ban completed'
echo ''