#!/bin/bash
#
# Installs CouchDB
##

## Prompt to continue
function promptInstall {
    echo -e "\n${blueBgWhiteBold}This script will install CouchDB and configure it.${NC}"
    read -p 'Do you want to continue [y/N]? ' wish
    if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        exit 0
    fi
}

## Install CouchDB if it's not installed
function installCouchdb {
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' couchdb|grep "install ok installed")
    if [[ "" == "$PKG_OK" ]] ; then
        echo -e "${green}Installing CouchDB from apt${NC}"
        apt-get install couchdb
    else
        echo -e "${yellow}CouchDB already installed${NC}"
    fi
}

function copyConfigs {
    ## Check if there's a local config file to update
    if [[ -f "$basepath/conf/$profile/couchdb" ]] ; then
        echo -e "${green}Copying couchdb config to /etc/couchdb/local.d/couchdb.ini${NC}"
        cp $basepath/conf/$profile/couchdb /etc/couchdb/local.d/couchdb.ini
    else
        echo -e "${yellow}No couchdb file found, skipping${NC}"
    fi
}

## Restart the service
function promptRestart {
    read -p 'Do you want restart CouchDB? [y/N]? ' wish
    if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        service couchdb restart
    fi
}

promptInstall
installCouchdb
copyConfigs
promptRestart
exit 0