#!/bin/bash
#
# Copy firewall over and set up pre-up script
##

## Prompt to continue
function promptInstall {
    echo -e "\n${blueBgWhiteBold}This script will overwrite your firewall and add it to the network pre-up.${NC}"
    read -p 'Do you want to continue [y/N]? ' wish
    if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        exit 0
    fi
}

## Copy the firewall script and add it to pre-up
function copyFirewall {
    ## If it exists, copy it over
    if ! [[ -f "$basepath/conf/$profile/firewall.sh" ]] ; then
        echo -e "${yellow}No firewall.sh found in conf/${profile}${NC}"
        return
    fi

    cp $basepath/conf/$profile/firewall.sh /etc/firewall.sh
    chmod 700 /etc/firewall.sh
    chown root:root /etc/firewall.sh

    ## Ask to run firewall
    read -p 'Do you want to run the firewall script [Y/n]? ' wish
    if ! [[ "$wish" == "n" || "$wish" == "N" ]] ; then
        sh /etc/firewall.sh
    fi

    ## Set up the pre-up rule in /etc/network/if-pre-up.d
    cp $basepath/src/firewall/firewall_preup.sh /etc/network/if-pre-up.d/firewall
    chmod 700 /etc/network/if-pre-up.d/firewall
    chown root:root /etc/network/if-pre-up.d/firewall
}

## Copy the interfaces file if it exists
function copyInterfaces {
    ## If it exists, copy it over
    if ! [[ -f "$basepath/conf/$profile/interfaces" ]] ; then
        echo -e "${yellow}No interfaces found in conf/${profile}${NC}"
        return
    fi

    cp $basepath/conf/$profile/interfaces /etc/network/interfaces
}

## Ask to restart networking services
function restartNetworking {
    read -p 'Do you want to restart networking? [y/N] ' wish
    if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        echo -e "${green}Restarting networking${NC}"
        ifdown eth0 && ifup eth0
    fi
}

promptInstall
copyFirewall
copyInterfaces
restartNetworking
exit 0