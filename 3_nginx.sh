#!/bin/bash

# install nginx from source
#

echo 'This script will update/upgrade the system and install nginx from source'
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

. ./$config

echo '  --> installing nginx from source to /opt/nginx'
apt-get update
apt-get upgrade --show-upgraded
apt-get install libpcre3-dev build-essential libssl-dev
cd /opt/
wget http://nginx.org/download/nginx-1.0.11.tar.gz
tar -zxvf nginx-1.0.11.tar.gz
cd /opt/nginx-1.0.11/
./configure --prefix=/opt/nginx --user=nginx --group=nginx --with-http_ssl_module --with-ipv6
make
make install
adduser --system --no-create-home --disabled-login --disabled-password --group nginx

echo '  --> configuring the init script'
cd
cp ./src/init-deb.sh /etc/init.d/nginx
chmod +x /etc/init.d/nginx
/usr/sbin/update-rc.d -f nginx defaults
/usr/sbin/update-rc.d -f apache2 remove
/etc/init.d/nginx start
