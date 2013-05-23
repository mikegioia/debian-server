#!/bin/bash
#
# Trunk Server v2.0
#
# @author   Mike Gioia <mike@particlebits.com>
# @name:    user.sh
# @about:   Create new user and set up the locale settings
# -----------------------------------------------------------------------------

echo 'This script will create a new user and reset locale settings'
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    echo "Aborted"
    exit 0
fi

if [ $(id -u) -eq 0 ]; then
    read -s -p "Enter password for new user $username: " password
    egrep "^$username" /etc/passwd >/dev/null
    if [ $? -eq 0 ]; then
        echo "  --> $username exists!"
        exit 0
    else
        echo '  --> creating new user $username'
        pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
        useradd -m -p $pass $username
        chown $username /home/$username
        chgrp $username /home/$username
        [ $? -eq 0 ] && echo "  --> user has been added to system" || echo "  --> failed to add user"
        echo "  --> adding $username to sudoers group"
        usermod -a -G sudo $username
        echo "  --> setting up locale"
        rm /etc/locale.gen
        cp ./src/locale.gen /etc/locale.gen
        locale-gen
    fi
else
    echo "  --> only root may add a user to the system!"
    exit 1
fi

echo 'User completed'
echo ''