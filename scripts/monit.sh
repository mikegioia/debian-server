#!/bin/bash
#
# Installs Monit and copies over config file
##

echo 'This script will install Monit from source.'
read -p 'Do you want to continue? [y/N] ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    echo "Aborted"
    exit
fi

## Install if it isn't already
if ! [[ `hash monit 2>/dev/null` ]] ; then
    apt-get install monit
    update-rc.d monit defaults
fi

## Copy over the monitrc file and reload monit
if [[ -f "$basepath/conf/$profile/monitrc" ]] ; then
    cp $basepath/conf/$profile/monitrc /etc/monit/monitrc
fi

monit reload

echo 'Monit completed'
echo ''