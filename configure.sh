#!/bin/bash
#
# Trunk Server v2.0
#
# @author   Mike Gioia <mike@particlebits.com>
# @name:    configure.sh
# @about:   Create the configuration files for a new install. This creates a 
#           new folder in the conf/ directory with all of the skeleton files 
#           for a new environment.
# -----------------------------------------------------------------------------

# read in the environment name
#
usage="$0 <profile>"
shift `echo $OPTIND-1 | bc`
profile=${1:-"default"}

if ! [ -d conf/$profile ] ; then
    mkdir conf/$profile
fi

# create blank authorized keys if none exists
#
echo "Creating new configuration files"
if ! [ -f conf/$profile/authorized_keys ] ; then
    echo "  --> adding authorized_keys"
    cp src/authorized_keys conf/$profile/authorized_keys
else
    echo "  --> skipping authorized_keys, file already exists"
fi

# create blank hosts if none exists
#
if ! [ -f conf/$profile/hosts ] ; then
    echo "  --> adding hosts"
    cp src/hosts conf/$profile/hosts
else
    echo "  --> skipping hosts, file already exists"
fi

# create default config file if none exists
#
if ! [ -f conf/$profile/config ] ; then
    echo "  --> adding config"
    cp src/config conf/$profile/config
else
    echo "  --> skipping config, file already exists"
fi

# create private bash file
#
if ! [ -f conf/$profile/bash_private ] ; then
    echo "  --> adding bash_private"
    cp src/dotfiles/private conf/$profile/bash_private
else
    echo "  --> skipping bash_private, file already exists"
fi

# create firewall script
#
if ! [ -f conf/$profile/firewall.sh ] ; then
    echo "  --> adding firewall.sh"
    cp src/firewall.sh conf/$profile/firewall.sh
else
    echo "  --> skipping firewall, file already exists"
fi

# create nginx folder and default site config
#
if ! [ -d conf/$profile/nginx ] ; then
    echo "  --> creating nginx directory"
    mkdir conf/$profile/nginx
else
    echo "  --> skipping nginx, directory already exists"
fi

# set up default nginx config file
#
if ! [ -f conf/$profile/nginx/example.conf ] ; then
    echo "  --> creating example nginx config"
    cp src/nginx_conf/example.conf conf/$profile/nginx/example.conf
    cp src/nginx_conf/conf_readme.md conf/$profile/nginx/README.md
else
    echo "  --> skipping nginx example config, file already exists"
fi

# copy over my.cnf
#
if ! [ -f conf/$profile/my.cnf ] ; then
    echo "  --> adding my.cnf"
    cp src/my.cnf conf/$profile/my.cnf
else
    echo "  --> skipping my.cnf, file already exists"
fi

echo ""
echo "Default config files generated. Please edit the files in ./conf/$profile/!"
