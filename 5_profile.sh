#!/bin/bash

# set up the user profile
#

echo "This script will set the user's aliases, ssh config, and authorized keys"
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    exit
fi

usage="$0 <config>"
config=${1:-"server.cfg"}

if [ ! -f $config ] ; then
    echo "Could not find the config file you entered: $config."
    exit
fi

. ./$config

cd

echo '  --> overwriting the alias and profile'
if [ -f /home/$username/.bash_aliases ] ; then
    rm /home/$username/.bash_aliases
fi
cp ./src/aliases /home/$username/.bash_aliases
if [ -f /home/$username/.bash_profile ] ; then
    rm /home/$username/.bash_profile
fi
cp ./src/bash_profile /home/$username/.bash_profile

echo '  --> overwriting the hosts file'
rm /etc/hosts
cp ./src/hosts /etc/hosts

echo '  --> overwriting the sshd_config and reloading'
rm /etc/ssh/sshd_config
cp ./src/sshd_config /etc/ssh/sshd_config
/etc/init.d/ssh reload

echo '  --> setting the authorized keys'
if ! [ -d /home/$username/.ssh ] ; then
    mkdir /home/$username/.ssh
fi
if [ -f /home/$username/.ssh/authorized_keys ] ; then
    rm /home/$username/.ssh/authorized_keys
fi
cp ./src/authorized_keys /home/$username/.ssh/authorized_keys

chsh -s '/bin/bash' $username
chown -R $username /home/$username
chgrp -R $username /home/$username
