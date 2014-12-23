#!/bin/bash
#
# Copy sshd_config and restart SSH
##

## Prompt to continue
function promptSsh {
    echo -e "\n${blueBgWhiteBold}This script will create copy sshd_config and restart SSH server${NC}"
    read -p 'Do you want to continue [y/N]? ' wish
    if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        exit 0
    fi
}

## Copy the sshd_config
function copyConfig {
    rm /etc/ssh/sshd_config

    if [[ -f "$basepath/conf/$profile/sshd_config" ]] ; then
        cp $basepath/conf/$profile/sshd_config /etc/ssh/sshd_config
    else
        cp $basepath/src/sshd_config /etc/ssh/sshd_config
    fi

    /etc/init.d/ssh reload
fi

## Ask the user to test the SSH connection
function testConnection {
    echo -e "${yellow}SSH has been reloaded; now is a good time to re-test the connection!${NC}"
    read -p "Press any key to continue" anykey
    echo ""
}

promptSsh
copyConfig
testConnection
exit 0