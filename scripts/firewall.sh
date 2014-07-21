#!/bin/bash
#
# Copy firewall over and set up pre-up script
##

echo 'This script will overwrite your firewall script.'
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    exit
fi

## If it exists, copy it over
if [[ -f "$basepath/conf/$profile/firewall.sh" ]] ; then
    cp $basepath/conf/$profile/firewall.sh /etc/firewall.sh
    chmod 700 /etc/firewall.sh
    chown root:root /etc/firewall.sh
    sh /etc/firewall.sh

    ## Set up the pre-up rule in /etc/network/if-pre-up.d
    cp $basepath/src/firewall_preup.sh /etc/network/if-pre-up.d/firewall
    chmod 700 /etc/network/if-pre-up.d/firewall
    chown root:root /etc/network/if-pre-up.d/firewall
fi

echo 'Firewall completed'
echo ''