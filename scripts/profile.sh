#!/bin/bash
#
# Sets up the user profile
##

echo "This script will set the user's profile, aliases, SSH config, and authorized keys."
read -p 'Do you want to continue? [y/N] ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    echo "Aborted"
    exit 0
fi

echo '  --> overwriting the home dot files'

## Copy over logout, profile, and rc files
cp $basepath/src/dotfiles/bash_logout /home/$username/.bash_logout
cp $basepath/src/dotfiles/bash_profile /home/$username/.bash_profile
cp $basepath/src/dotfiles/bashrc /home/$username/.bashrc
cp $basepath/src/dotfiles/inputrc /home/$username/.inputrc

## Create ~/.bash directory for files
if ! [[ -d "/home/$username/.bash" ] ; then
    mkdir /home/$username/.bash
fi

cp $basepath/src/dotfiles/aliases /home/$username/.bash/aliases
cp $basepath/src/dotfiles/functions /home/$username/.bash/functions
cp $basepath/src/dotfiles/linux /home/$username/.bash/linux

## If there's a private config, copy it over
if [[ -f "$basepath/conf/$profile/bash_private" ]] ; then
    cp $basepath/conf/$profile/bash_private /home/$username/.bash/private
fi

## Check if hosts is in conf folder first
if [[ -f "$basepath/conf/$profile/hosts" ]] ; then
    echo '  --> overwriting the hosts file'
    if [[ -f "/etc/hosts" ]] ; then
        rm /etc/hosts
    fi
    cp $basepath/conf/$profile/hosts /etc/hosts
fi

echo '  --> overwritting ssh banner'
cp $basepath/src/banner /etc/issue

if [[ -f "$basepath/conf/$profile/banner" ]] ; then
    cp $basepath/conf/$profile/banner /etc/issue
fi

read -p 'Do you want to overwrite the sshd_config? [yes/N] ' wish
if [[ "$wish" == "yes" || "$wish" == "Yes" ]] ; then
    echo '  --> overwriting the sshd_config and reloading'
    rm /etc/ssh/sshd_config

    if [[ -f "$basepath/conf/$profile/sshd_config" ]] ; then
        cp $basepath/conf/$profile/sshd_config /etc/ssh/sshd_config
    else
        cp $basepath/src/sshd_config /etc/ssh/sshd_config
    fi

    /etc/init.d/ssh reload
fi

if ! [[ -d "/home/$username/.ssh" ]] ; then
    mkdir /home/$username/.ssh
fi

## Copy over the authorized keys if they exist
if [[ -f "$basepath/conf/$profile/authorized_keys" ]] ; then
    echo '  --> setting the authorized keys'
    if [[ -f "/home/$username/.ssh/authorized_keys" ]] ; then
        rm /home/$username/.ssh/authorized_keys
    fi
    cp $basepath/conf/$profile/authorized_keys /home/$username/.ssh/authorized_keys
fi

if [[ -f "$basepath/conf/$profile/my.cnf" ]] ; then
    echo '  --> copying over my.cnf to /etc/my.cnf'
    cp $basepath/conf/$profile/my.cnf /etc/my.cnf
fi

if [[ -f "$basepath/conf/$profile/mongodb.cnf" ]] ; then
    echo '  --> copying over mongodb.conf to /etc/mongodb.conf'
    cp $basepath/conf/$profile/mongodb.cnf /etc/mongodb.conf
fi

## set up other home folders and if any files in similarly-named
## folders exist in the local config, copy them in.
echo '  --> creating home directories and copying any files over'
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

## Make scripts executable
chmod +x /home/$username/install/*.sh
chmod +x /home/$username/scripts/*.sh

echo '  --> changing shell to bash and re-owning files'
chsh -s '/bin/bash' $username
chown -R $username:$username /home/$username
chmod 750 /home/$username
chmod 400 /home/$username/.ssh/id_rsa

echo 'Profile completed'
echo ''