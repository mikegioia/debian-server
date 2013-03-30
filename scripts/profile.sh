#!/bin/bash

# set up the user profile
#

echo "This script will set the user's aliases, ssh config, and authorized keys"
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    echo "Aborted"
    exit
fi

usage="$0 <config>"
config=${1:-"conf/config"}

if [ ! -f $config ] ; then
    echo "Could not find the config file you entered: $config."
    exit
fi

. .$config

cd

echo '  --> overwriting the alias and profile'

# remove them if they exist
#
if [ -f /home/$username/.bash_aliases ] ; then
    rm /home/$username/.bash_aliases
fi
if [ -f /home/$username/.bash_profile ] ; then
    rm /home/$username/.bash_profile
fi

# check ./conf folder first, that has precedence
#
cp $basepath/src/aliases /home/$username/.bash_aliases
cp $basepath/src/bash_profile /home/$username/.bash_profile

echo '  --> overwriting the hosts file'

# check if hosts is in conf folder first
if [ -f $basepath/conf/hosts ] ; then
    rm /etc/hosts
    cp $basepath/conf/hosts /etc/hosts
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
if [ -f /home/$username/.ssh/authorized_keys ] ; then
    rm /home/$username/.ssh/authorized_keys
fi
cp $path/conf/authorized_keys /home/$username/.ssh/authorized_keys

chsh -s '/bin/bash' $username
chown -R $username /home/$username
chgrp -R $username /home/$username
