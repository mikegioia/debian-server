#!/bin/bash
#
# Sets up the user profile, copies bash configs
##

## Prompt to continue
function promptInstall {
    echo -e "\n${blueBgWhiteBold}This script will set the user's profile, aliases, and authorized keys.${NC}"
    read -p 'Do you want to continue [y/N]? ' wish
    if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        exit 0
    fi
}

## Copy over logout, profile, and rc files and set up bash dir
function copyBashFiles {
    echo -e "${green}Copying bash config files${NC}"
    cp $basepath/src/dotfiles/bash_logout /home/$username/.bash_logout
    cp $basepath/src/dotfiles/bash_profile /home/$username/.bash_profile
    cp $basepath/src/dotfiles/bashrc /home/$username/.bashrc
    cp $basepath/src/dotfiles/inputrc /home/$username/.inputrc

    ## Create ~/.bash directory for files
    if ! [[ -d "/home/$username/.bash" ]] ; then
        mkdir /home/$username/.bash
    fi

    cp $basepath/src/dotfiles/aliases /home/$username/.bash/aliases
    cp $basepath/src/dotfiles/functions /home/$username/.bash/functions
    cp $basepath/src/dotfiles/linux /home/$username/.bash/linux

    ## If there's a private config, copy it over
    if [[ -f "$basepath/conf/$profile/bash_private" ]] ; then
        cp $basepath/conf/$profile/bash_private /home/$username/.bash/private
    fi
}

## Check if hosts is in conf folder first
function copyHosts {
    if [[ -f "$basepath/conf/$profile/hosts" ]] ; then
        echo -e "${green}Overwriting hosts file in /etc/hosts${NC}"
        if [[ -f "/etc/hosts" ]] ; then
            rm /etc/hosts
        fi
        cp $basepath/conf/$profile/hosts /etc/hosts
    fi
}

## Copy over the banner
function copyBanner {
    echo -e "${green}Overwriting login banner in /etc/issue${NC}"
    cp $basepath/src/banner /etc/issue

    if [[ -f "$basepath/conf/$profile/banner" ]] ; then
        cp $basepath/conf/$profile/banner /etc/issue
    fi
}

## Ask to change the timezone
function changeTimezone {
    read -p 'Do you want to change the system timezone? [y/N] ' wish
    if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        echo -e "${green}Changing system timezone${NC}"
        dpkg-reconfigure tzdata
    fi
}

## Set up the SSH profile
function setupSsh {
    if ! [[ -d "/home/$username/.ssh" ]] ; then
        mkdir /home/$username/.ssh
    fi

    if [[ -f "$basepath/conf/$profile/authorized_keys" ]] ; then
        echo -e "${green}Copying your authorized keys file${NC}"
        if [[ -f "/home/$username/.ssh/authorized_keys" ]] ; then
            rm /home/$username/.ssh/authorized_keys
        fi
        cp $basepath/conf/$profile/authorized_keys /home/$username/.ssh/authorized_keys
    fi

    if [[ -f "/home/$username/.ssh/id_rsa" ]] ; then
        chmod 400 /home/$username/.ssh/id_rsa
    fi
}

## Set up other home folders and if any files in similarly-named
## folders exist in the local config, copy them in.
function homeFolders {
    echo -e "${green}Creating home folders and copying files over${NC}"
    if ! [[ -d "/home/$username/scripts" ]] ; then
        mkdir /home/$username/scripts
    fi
    if [[ -d "$basepath/conf/$profile/scripts" ]] ; then
        cp -r $basepath/conf/$profile/scripts/* /home/$username/scripts/
    fi
    if ! [[ -d "/home/$username/archive" ]] ; then
        mkdir /home/$username/archive
    fi
    if [[ -d "$basepath/conf/$profile/archive" ]] ; then
        cp -r $basepath/conf/$profile/archive/* /home/$username/archive/
    fi
    if ! [[ -d "/home/$username/install" ]] ; then
        mkdir /home/$username/install
    fi
    if [[ -d "$basepath/conf/$profile/install" ]] ; then
        cp -r $basepath/conf/$profile/install/* /home/$username/install/
    fi
}

## Make scripts executable
function makeScriptsExec {
    if test -n "$(find /home/$username/install/ -maxdepth 1 -name '*.sh' -print -quit)" ; then
        echo -e "${green}Making ~/install files executable${NC}"
        chmod +x /home/$username/install/*.sh
    fi
    if test -n "$(find /home/$username/scripts/ -maxdepth 1 -name '*.sh' -print -quit)" ; then
        echo -e "${green}Making ~/scripts files executable${NC}"
        chmod +x /home/$username/scripts/*.sh
    fi
}

## Ask to change shell to bash
function changeShell {
    read -p 'Do you want to change the login shell to bash? [y/N] ' wish
    if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        echo -e "${green}Changing login shell to bash${NC}"
        chsh -s '/bin/bash' $username
    fi
}

## Ask to re-own home directory files
function reownHome {
    chmod 750 /home/$username
    read -p "Do you want to change ownership of all home directory files to ${username}? [y/N] " wish
    if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        chown -R $username:$username /home/$username
    fi
}

promptInstall
copyBashFiles
copyHosts
copyBanner
changeTimezone
setupSsh
homeFolders
makeScriptsExec
changeShell
reownHome
exit 0