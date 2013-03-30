#!/bin/bash

# set up mysql
#

echo 'This script will update the system and install mysql'
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    echo "Aborted"
    exit
fi

usage="$0 <config>"
config=${1:-"../deploy/config"}

if [ ! -f $config ] ; then
    echo "Could not find the config file you entered: $config"
    exit
fi

. .$config

echo '  --> updating system'
apt-get update

echo '  --> installing mysql'
apt-get install mysql-server mysql-client
