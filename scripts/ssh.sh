#!/bin/bash
#
# Copy sshd_config and reload SSH
##

## Prompt to continue
function promptInstall {
    echo -e "\n${blueBgWhiteBold}This script will create copy sshd_config and reload SSH server.${NC}"
    read -p 'Do you want to continue [y/N]? ' wish
    if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        exit 0
    fi
}

## Copy the sshd_config
function copyConfig {
    if [[ -f "$basepath/conf/$profile/sshd_config" ]] ; then
        echo -e "${green}Copying over sshd_config to /etc/ssh${NC}"
        rm /etc/ssh/sshd_config
        cp $basepath/conf/$profile/sshd_config /etc/ssh/sshd_config
    else
        echo -e "${yellow}No sshd_config file found in conf/${profile}.${NC}"
    fi
    
    ## Prompt to reload
    if [[ -f "/etc/ssh/sshd_config" ]] ; then
        read -p "Do you want to reload SSH? [y/N]? " wish
        if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
            /etc/init.d/ssh reload
        fi
    else
        echo -e "${redBgWhiteBold}No config file found at /etc/ssh/sshd_config! Did you forget to add one to conf/${profile}?${NC}"
        echo -e "${yellowBold}Try running './configure.sh ${profile}' again to generate a new sshd_config file.${NC}"
    fi
}

## Ask the user to test the SSH connection
function testConnection {
    echo -e "${yellow}If SSH has been reloaded, now would be a good time to re-test the connection!${NC}"
    read -p "Press any key to continue" anykey
}

promptInstall
copyConfig
testConnection
exit 0