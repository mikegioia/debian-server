#!/bin/bash
#
# Installs MySQL from apt
##

## Prompt to continue
function promptInstall {
    echo -e "\n${blueBgWhiteBold}This script will update the system and install MySQL.${NC}"
    read -p 'Do you want to continue [y/N]? ' wish
    if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        exit 0
    fi
}

## Install mysql
function installMysql {
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' mysql-server|grep "install ok installed")
    if [[ "" == "$PKG_OK" ]] ; then
        echo -e "${green}Installing MySQL. You may be prompted to set username and password${NC}"
        apt-get install mysql-server mysql-client
    else
        echo -e "${yellow}MySQL already installed${NC}"
    fi
}

## Copy over configs
function copyConfigs {
    if [[ -f "$basepath/conf/$profile/my.cnf" ]] ; then
        wish="Y"
        if [[ -f "/etc/mysql/conf.d/my.cnf" ]] ; then
            read -p "Do you want copy my.cnf and reload mysql [y/N]? " wish
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
    read -p "Do you want to add mysql to system startup [y/N]? " wish
    if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        /usr/sbin/update-rc.d -f mysql defaults
    fi
}

promptInstall
installMysql
copyConfigs
systemStart
exit 0