#!/bin/bash
#
# Trunk Server v2.0
#
# @author   Mike Gioia <mike@particlebits.com>
# @name:    install.sh
# @about:   Install or update packages, update configuration files and dot 
#           files.
# -----------------------------------------------------------------------------

echo "This script will update software and configuration files on your server."
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    exit
fi

usage="$0 <config>"
config=${1:-"conf/config"}

if [ ! -f $config ] ; then
    echo "Could not find the config file you entered: $config"
    echo "Make sure to run ./configure.sh <profile> in the deploy directory"
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
