#!/bin/bash
#
# Installs Monit and copies over config file
##

## Prompt to continue
function promptInstall {
    echo -e "\n${blueBgWhiteBold}This script will install monit.${NC}"
    read -p 'Do you want to continue [y/N]? ' wish
    if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        exit 0
    fi
}

## Install if it isn't already
function installMonit {
    if ! [[ `hash monit 2>/dev/null` ]] ; then
        echo -e "${green}Installing monit and adding monit to system startup${NC}"
        apt-get install monit
        update-rc.d monit defaults
    else
        echo -e "${yellow}Monit already installed${NC}"
        read -p 'Do you want to add monit to system startup [y/N] ' wish
        if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
            update-rc.d monit defaults
        fi
    fi
}

## Copy over the monitrc file and reload monit
function copyRcFile {
    if [[ -f "$basepath/conf/$profile/monitrc" ]] ; then
        cp $basepath/conf/$profile/monitrc /etc/monit/monitrc
    fi
    monit reload
}

promptInstall
installMonit
copyRcFile
exit 0