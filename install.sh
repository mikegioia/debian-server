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
    exit 0
fi

usage="$0 <profile> [--update --upgrade --scripts=a,b,c]"
profile=${1:-"default"}
config="conf/$profile/config"

if [ ! -f $config ] ; then
    echo "Could not find the config file you entered: $config"
    echo "Make sure to run ./configure.sh <profile> in the deploy directory"
    exit 1
fi

# read in the config variables and export them to sub-scripts
#
. $config

export basepath
export profile
export username
export nginx_version
export mongo_version
export openssl_version

# update the system if flags present
#
#apt-get update
#apt-get upgrade --show-upgraded

# run the scripts. check the install history to see if we should re-run
#
for script in "${scripts[@]}"
do
    ./scripts/$script.sh
done

echo "Done!"
echo "Make sure to restart your server for all changes to take effect!"
