#!/bin/bash
#
# Installs MariaDB from apt source
##

## Check if the nginx version is set
function checkMariadb {
    if ! [[ -n "${mariadbVersion}" ]] ; then
        echo -e "${yellow}Skipping, mariadbVersion not set in config${NC}"
        exit 0
    fi
}

## Prompt to continue
function promptInstall {
    echo -e "\n${blueBgWhiteBold}This script will install MariaDB ${mariadbVersion}.${NC}"
    read -p 'Do you want to continue [y/N]? ' wish
    if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        exit 0
    fi
}

## Echo this out to mariadb.list if file not found
function addAptSource {
    if ! [[ -f "/etc/apt/sources.list.d/mariadb.list" ]] ; then
        echo -e "${green}Adding MariaDB source and fetching key${NC}"
        echo '# https://downloads.mariadb.org/mariadb/repositories/' > /etc/apt/sources.list.d/mariadb.list
        echo 'deb http://mirror.jmu.edu/pub/mariadb/repo/10.0/debian wheezy main' >> /etc/apt/sources.list.d/mariadb.list
        echo 'deb-src http://mirror.jmu.edu/pub/mariadb/repo/10.0/debian wheezy main' >> /etc/apt/sources.list.d/mariadb.list
        apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
        apt-get update
    else
        echo -e "${yellow}Skipping, MariaDB source set in /etc/apt/sources.list.d/${NC}"
    fi
}

## Install mariadb
function installMariadb {
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' mariadb-server|grep "install ok installed")
    if [[ "" == "$PKG_OK" ]] ; then
        echo -e "${green}Installing MariaDB. You may be prompted to set username and password${NC}"
        apt-get install mariadb-server
    else
        echo -e "${yellow}MariaDB already installed${NC}"
    fi
}

## Copy over configs
function copyConfigs {
    if [[ -f "$basepath/conf/$profile/my.cnf" ]] ; then
        wish="Y"
        if [[ -f "/etc/mysql/conf.d/my.cnf" ]] ; then
            read -p "Do you want copy my.cnf and reload mysql? " wish
        fi
        if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
            echo -e "${green}Copying my.cnf to /etc/mysql/conf.d and reloading mysql${NC}"
            cp $basepath/conf/$profile/my.cnf /etc/mysql/conf.d/my.cnf
            /etc/init.d/mysql reload
        fi
    fi

    ## If there's a mysql history file, write null to it
    if [[ -f "/root/.mysql_history" ]] ; then
        cat /dev/null > /root/.mysql_history
    fi
    if [[ -f "/home/$username/.mysql_history" ]] ; then
        cat /dev/null > /home/$username/.mysql_history
    fi
}

## Add mysql to startup
function systemStart {
    read -p "Do you want to add mysql to system startup? [y/N]? " wish
    if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        /usr/sbin/update-rc.d -f mysql defaults
    fi
}

checkMariadb
promptInstall
addAptSource
installMariadb
copyConfigs
systemStart
exit 0