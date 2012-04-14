#!/bin/bash

# run the server installation scripts
#

echo "This script will set up your server. It's best to have a clean Debian 6 install."
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

# read in the config variables
#
. ./$config

# run the scripts
#
./1_user.sh $config &&
./2_mysql.sh $config &&
./3_nginx.sh $config &&
./4_php.sh $config &&
./5_profile.sh $config &&
./6_app.sh $config &&
./7_exim.sh $config &&
./8_mongo.sh $config

echo "Done!"
echo "Make sure to restart your server for all changes to take effect!"
