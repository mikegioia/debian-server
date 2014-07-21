#!/bin/bash
#
# Copy firewall over
##

echo 'This script will overwrite your firewall script.'
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    exit
fi

## If it exists, copy it over
if [ -f $basepath/conf/$profile/firewall.sh ] ; then
    cp $basepath/conf/$profile/firewall.sh /etc/firewall.sh
    chmod +x /etc/firewall.sh
    sh /etc/firewall.sh
fi

## Set up the pre-up rule in /etc/network/if-pre-up.d


echo 'Firewall completed'
echo ''