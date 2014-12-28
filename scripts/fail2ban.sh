#!/bin/bash
#
# Sets up fail2ban
##

## Prompt to continue
function promptInstall {
    echo -e "\n${blueBgWhiteBold}This script will install Fail2Ban and configure it.${NC}"
    read -p 'Do you want to continue [y/N]? ' wish
    if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        exit 0
    fi
}

## Install fail2ban if it's not installed
function installFail2ban {
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' fail2ban|grep "install ok installed")
    if [[ "" == "$PKG_OK" ]] ; then
        echo -e "${green}Installing Fail2Ban from apt${NC}"
        apt-get install fail2ban
    else
        echo -e "${yellow}Fail2Ban already installed${NC}"
    fi
}

function copyConfigFiles {
    ## Check if there's a local config file to update
    if [[ -f "$basepath/conf/$profile/jail.local" ]] ; then
        echo -e "${green}Copying jail.local to /etc/fail2ban${NC}"
        cp $basepath/conf/$profile/jail.local /etc/fail2ban/jail.local
    else
        echo -e "${yellow}No jail.local found, skipping${NC}"
    fi

    ## Copy over configs if they're not there
    if ! [[ -f "/etc/fail2ban/filter.d/nginx-dos.conf" ]] ; then
        read -p 'Do you want to install the nginx-dos filter [y/N]? ' wish
        if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
            echo -e "${green}Copying nginx-dos.confto /etc/fail2ban/filter.d${NC}"
            cp $basepath/src/fail2ban_conf/nginx-dos.conf /etc/fail2ban/filter.d/nginx-dos.conf
        fi
    fi
}

## Restart the service
function promptRestart {
    read -p 'Do you want restart Fail2Ban? [y/N]? ' wish
    if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        service fail2ban restart
    fi
}

promptInstall
installFail2ban
copyConfigFiles
promptRestart
exit 0