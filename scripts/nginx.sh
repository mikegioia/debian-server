#!/bin/bash

# install nginx from source
#

echo 'This script will update/upgrade the system and install nginx from source'
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    exit
fi

usage="$0 <config>"
config=${1:-"../conf/config"}

if [ ! -f $config ] ; then
    echo "Could not find the config file you entered: $config"
    exit
fi

. $config

echo '  --> installing nginx from source to /opt/nginx'
apt-get update
apt-get upgrade --show-upgraded
apt-get install libpcre3-dev build-essential libssl-dev
cd /opt/
wget http://nginx.org/download/nginx-${nginx_version}.tar.gz
tar -zxvf nginx-${nginx_version}.tar.gz
cd /opt/nginx-${nginx_version}/
./configure --prefix=/opt/nginx --user=nginx --group=nginx --with-http_ssl_module --with-ipv6 --with-http_stub_status_module
make
make install
adduser --system --no-create-home --disabled-login --disabled-password --group nginx

# copy over the default nginx and trunk config. set up directories.
#
mkdir /opt/nginx/conf/sites-available
mkdir /opt/nginx/conf/sites-enabled
cp $basepath/src/nginx_conf/nginx.conf /opt/nginx/conf/nginx.conf
cp $basepath/src/nginx_conf/trunk.conf /opt/nginx/conf/trunk.conf
cp $basepath/src/nginx_conf/mime.types /opt/nginx/conf/mime.types

echo '  --> configuring the init script'
cp $basepath/src/nginx /etc/init.d/nginx
chmod +x /etc/init.d/nginx
/usr/sbin/update-rc.d -f nginx defaults
/usr/sbin/update-rc.d -f apache2 remove
/etc/init.d/nginx start
