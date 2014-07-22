#!/bin/bash
#
# Debian Server Installation Manager
#
# @author   Mike Gioia <mike@particlebits.com>
# @name:    configure.sh
# @about:   Create the configuration files for a new install. This creates a 
#           new folder in the conf/ directory with all of the skeleton files 
#           for a new environment.
##

## Read in the environment name
usage="$0 <profile>"
shift `echo $OPTIND-1 | bc`
profile=${1:-"default"}
basepath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

## Create the profile directory if it doesn't exist
if ! [[ -d "$basepath/conf/$profile" ]] ; then
    mkdir -p $basepath/conf/$profile
fi

## Create blank authorized keys if none exists
echo "Creating new configuration files"
if ! [[ -f "$basepath/conf/$profile/authorized_keys" ]] ; then
    echo "  --> adding authorized_keys"
    cp $basepath/src/authorized_keys $basepath/conf/$profile/authorized_keys
else
    echo "  --> skipping authorized_keys, file already exists"
fi

## Create blank hosts if none exists
if ! [[ -f "$basepath/conf/$profile/hosts" ]] ; then
    echo "  --> adding hosts"
    cp $basepath/src/hosts $basepath/conf/$profile/hosts
else
    echo "  --> skipping hosts, file already exists"
fi

## Copy banner
if ! [[ -f "$basepath/conf/$profile/banner" ]] ; then
    echo "  --> adding banner"
    cp $basepath/src/banner $basepath/conf/$profile/banner
else
    echo "  --> skipping banner, file already exists"
fi

## Create default config file if none exists
if ! [[ -f "$basepath/conf/$profile/config" ]] ; then
    echo "  --> adding config"
    cp $basepath/src/config $basepath/conf/$profile/config
else
    echo "  --> skipping config, file already exists"
fi

## Create private bash file
if ! [[ -f "$basepath/conf/$profile/bash_private" ]] ; then
    echo "  --> adding bash_private"
    cp $basepath/src/dotfiles/private $basepath/conf/$profile/bash_private
else
    echo "  --> skipping bash_private, file already exists"
fi

## Create firewall script
if ! [[ -f "$basepath/conf/$profile/firewall.sh" ]] ; then
    echo "  --> adding firewall.sh"
    cp $basepath/src/firewall.sh $basepath/conf/$profile/firewall.sh
else
    echo "  --> skipping firewall, file already exists"
fi

## Create nginx folder and default site config
if ! [[ -d "$basepath/conf/$profile/nginx" ]] ; then
    echo "  --> creating nginx directory"
    mkdir $basepath/conf/$profile/nginx
else
    echo "  --> skipping nginx, directory already exists"
fi

## Set up default nginx config file
if ! [[ -f "$basepath/conf/$profile/nginx/example.conf" ] ; then
    echo "  --> creating example nginx config"
    cp $basepath/src/nginx_conf/example.conf $basepath/conf/$profile/nginx/example.conf
    cp $basepath/src/nginx_conf/conf_readme.md $basepath/conf/$profile/nginx/README.md
else
    echo "  --> skipping nginx example config, file already exists"
fi

## Copy over my.cnf
if ! [[ -f "$basepath/conf/$profile/my.cnf" ]] ; then
    echo "  --> adding my.cnf"
    cp $basepath/src/my.cnf $basepath/conf/$profile/my.cnf
else
    echo "  --> skipping my.cnf, file already exists"
fi

## Copy over mongodb.conf
if ! [[ -f "$basepath/conf/$profile/mongodb.conf" ] ; then
    echo "  --> adding mongodb.conf"
    cp $basepath/src/mongodb.conf $basepath/conf/$profile/mongodb.conf
else
    echo "  --> skipping mongodb.conf, file already exists"
fi

## Copy over monitrc
if ! [[ -f "$basepath/conf/$profile/monitrc" ]] ; then
    echo "  --> adding monitrc"
    cp $basepath/src/monitrc $basepath/conf/$profile/monitrc
else
    echo "  --> skipping monitrc, file already exists"
fi

echo ""
echo "Default config files generated. Please edit the files in $basepath/conf/$profile/!"