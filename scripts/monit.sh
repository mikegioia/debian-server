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
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' monit|grep "install ok installed")
    if [[ "" == "$PKG_OK" ]] ; then
        echo -e "${green}Installing Monit from apt${NC}"
        apt-get install monit
    else
        echo -e "${yellow}Monit already installed${NC}"
    fi

    read -p 'Do you want to add monit to system startup [y/N] ' wish
    if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        update-rc.d monit defaults
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