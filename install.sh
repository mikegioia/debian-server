#!/bin/bash
#
# Trunk Server v2.0
#
# @author   Mike Gioia <mike@particlebits.com>
# @name:    install.sh
# @about:   Install or update packages, update configuration files and dot 
#           files.
# -----------------------------------------------------------------------------

# get arguments
#
usage="$0 [-ug] <profile> [<script_1>, <script_ 2> ...]"
uflag=
gflag=

while getopts 'ug' OPTION
do
    case $OPTION in
        u)  uflag=1
            shift
            ;;
        g)  gflag=1
            shift
            ;;
        ?)  printf "Usage: %s %s" $(basename $0) $usage >&2
            exit 2
            ;;
    esac
done

# set up profile and script args
#
profile=${1:-"default"}
shift
config="conf/$profile/config"

if [ ! -f $config ] ; then
    echo "Could not find the config file you entered: $config"
    echo "Make sure to run ./configure.sh <profile> in the deploy directory"
    exit 1
fi

# check if a list of scripts came in. if not, use the scripts from the 
# config file array.
#
i=0
for var in "$@"
do
    script_args[$i]=$var
    i=$i+1
done

# ask if they want to continue
#
echo "This script will update software and configuration files on your server."
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    exit 0
fi

# read in the config variables and export them to sub-scripts
#
. $config

# set up the basepath
#
basepath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

export basepath
export profile
export username
export nginx_version
export mongodb_version
export openssl_version
export redis_version
export redisphp_version

# update the system if flags present
#
if [ "$uflag" ] ; then
    apt-get update
fi

if [ "$gflag" ] ; then
    apt-get upgrade --show-upgraded
fi

# run the scripts. check the install history to see if we should re-run
#
if ! [ "${#script_args[@]}" -eq 0 ] ; then
    for script in "${script_args[@]}"
    do
        if [ -f ./conf/$profile/scripts/$script.sh ] ; then
            ./conf/$profile/scripts/$script.sh
        else
            ./scripts/$script.sh
        fi
    done
else
    for script in "${scripts[@]}"
    do
        if [ -f ./conf/$profile/scripts/$script.sh ] ; then
            ./conf/$profile/scripts/$script.sh
        else
            ./scripts/$script.sh
        fi
    done
fi

echo "Done!"
echo "Make sure to restart your server for all changes to take effect!"
