#!/bin/bash
#
# Install and configure Percona XtraBackup
##

## Prompt to continue
function promptInstall {
    echo -e "\n${blueBgWhiteBold}This script will install Percona XtraBackup.${NC}"
    read -p 'Do you want to continue [y/N]? ' wish
    if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        exit 0
    fi
}

## Echo this out to xtrabackup.list if file not found
function addAptSource {
    if ! [[ -f "/etc/apt/sources.list.d/xtrabackup.list" ]] ; then
        echo -e "${green}Adding XtraBackup source and fetching key${NC}"
        echo 'deb http://repo.percona.com/apt wheezy main' > /etc/apt/sources.list.d/xtrabackup.list
        echo 'deb-src http://repo.percona.com/apt wheezy main' >> /etc/apt/sources.list.d/xtrabackup.list
        apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
        apt-get update
    else
        echo -e "${yellow}Skipping, XtraBackup source set in /etc/apt/sources.list.d/${NC}"
    fi
}

## Install xtrabackup
function installXtrabackup {
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' xtrabackup|grep "install ok installed")
    if [[ "" == "$PKG_OK" ]] ; then
        echo -e "${green}Installing XtraBackup from apt${NC}"
        apt-get install xtrabackup
    else
        echo -e "${yellow}XtraBackup already installed${NC}"
    fi
}

promptInstall
addAptSource
installXtrabackup
exit 0