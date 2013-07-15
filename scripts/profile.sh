#!/bin/bash
#
# Trunk Server v2.0
#
# @author   Mike Gioia <mike@particlebits.com>
# @name:    profile.sh
# @about:   Set up the user profile, copy over dot files
# -----------------------------------------------------------------------------

echo "This script will set the user's profile, aliases, ssh config, and authorized keys"
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    echo "Aborted"
    exit 0
fi

echo '  --> overwriting the home dot files'

# copy over logout, profile, and rc files
#
cp $basepath/src/dotfiles/bash_logout /home/$username/.bash_logout
cp $basepath/src/dotfiles/bash_profile /home/$username/.bash_profile
cp $basepath/src/dotfiles/bashrc /home/$username/.bashrc
cp $basepath/src/dotfiles/inputrc /home/$username/.inputrc

# create ~/.bash directory for files
#
if [ ! -d /home/$username/.bash ] ; then
    mkdir /home/$username/.bash
fi

cp $basepath/src/dotfiles/aliases /home/$username/.bash/aliases
cp $basepath/src/dotfiles/functions /home/$username/.bash/functions
cp $basepath/src/dotfiles/linux /home/$username/.bash/linux

# if there's a private config, copy it over
#
if [ -f $basepath/conf/$profile/bash_private ] ; then
    cp $basepath/conf/$profile/bash_private /home/$username/.bash/private
fi

echo '  --> overwriting the hosts file'

# check if hosts is in conf folder first
#
if [ -f $basepath/conf/$profile/hosts ] ; then
    if [ -f /etc/hosts ] ; then
        rm /etc/hosts
    fi
    cp $basepath/conf/$profile/hosts /etc/hosts
fi

echo '  --> overwritting ssh banner'
cp $basepath/src/banner /etc/issue

if [ -f $basepath/conf/$profile/banner ] ; then
    cp $basepath/conf/$profile/banner /etc/issue
fi

echo '  --> overwriting the sshd_config and reloading'
rm /etc/ssh/sshd_config
cp $basepath/src/sshd_config /etc/ssh/sshd_config
/etc/init.d/ssh reload

echo '  --> setting the authorized keys'
if ! [ -d /home/$username/.ssh ] ; then
    mkdir /home/$username/.ssh
fi

# copy over the authorized keys if they exist
#
if [ -f $basepath/conf/$profile/authorized_keys ] ; then
    if [ -f /home/$username/.ssh/authorized_keys ] ; then
        rm /home/$username/.ssh/authorized_keys
    fi
    cp $basepath/conf/$profile/authorized_keys /home/$username/.ssh/authorized_keys
fi

chsh -s '/bin/bash' $username
chown -R $username:$username /home/$username

echo 'Profile completed'
echo ''
echo 'IMPORTANT'
echo '---------'
echo 'REMEMBER TO REMOVE PASSWORD AUTHENTICATION AND WHITELIST USERS IN SSHD CONFIG FILE!'
echo ''