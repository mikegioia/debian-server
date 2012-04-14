#!/bin/bash

# set up exim as a mail server
#

usage="$0 <config>"
config=${1:-"server.cfg"}

if [ ! -f $config ] ; then
    echo "Could not find the config file you entered: $config."
    exit
fi

. ./$config

sudo apt-get install exim4
