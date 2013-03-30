#!/bin/bash

# run the server installation scripts
#

echo "This script will set up your server. It's best to have a clean Debian 6 install."
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    exit
fi

usage="$0 <config>"
config=${1:-"deploy/config"}

if [ ! -f $config ] ; then
    echo "Could not find the config file you entered: $config"
    echo "Make sure to run ./configure in the deploy directory"
    exit
fi

# read in the config variables
#
. $config

# run the scripts
#
for script in "${scripts[@]}"
do
    ./scripts/$script.sh $basepath/$config
done

echo "Done!"
echo "Make sure to restart your server for all changes to take effect!"
