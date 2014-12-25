#!/bin/bash
#
# Creates new user and set up the locale settings
##

## Check if the user already exists. if so, abort.
function checkUser {
    egrep "^$username" /etc/passwd >/dev/null
    if [[ $? -eq 0 ]] ; then
        echo -e "${yellow}Skipping, ${username} already exists${NC}"
        exit 0
    fi
}

## Prompt to continue
function promptInstall {
    echo -e "\n${blueBgWhiteBold}This script will create a new user and reset locale settings.${NC}"
    read -p 'Do you want to continue [y/N]? ' wish
    if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        exit 0
    fi
}

## Add new user
function addUser {
    echo -n "Enter password for new user ${username}: "
    read password
    echo -e "${green}Creating new user ${username}${NC}"
    pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
    useradd -m -p $pass $username
    chown $username /home/$username
    chgrp $username /home/$username
    
    if ! [[ $? -eq 0 ]] ; then 
        echo -e "${redBold}Failed to add user!${NC}"
    fi

    ## Add to sudoers
    echo -e "${green}Adding ${username} to sudoers group${NC}"
    usermod -a -G sudo $username
}

## Set locale (ask first)
function setLocale {
    read -p "Do you want to set the system locale [y/N]? " wish
    if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        echo -e "${green}Setting locale for ${username}${NC}"
        rm /etc/locale.gen
        cp ./src/locale.gen /etc/locale.gen
        locale-gen
    fi
}

checkUser
promptInstall
addUser
setLocale
exit 0