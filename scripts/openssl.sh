#!/bin/bash
#
# Installs OpenSSL from source
##

echo 'This script will install OpenSSL from source.'
read -p 'Do you want to continue [y/N]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    echo "Aborted"
    exit
fi

## Install requirements if not installed
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' libpcre3-dev|grep "install ok installed")
if [[ "" == "$PKG_OK" ]] ; then
    apt-get install libpcre3-dev
fi

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' build-essential|grep "install ok installed")
if [[ "" == "$PKG_OK" ]] ; then
    apt-get install build-essential
fi

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' libssl-dev|grep "install ok installed")
if [[ "" == "$PKG_OK" ]] ; then
    apt-get install libssl-dev
fi

## Check if openssl version is equal to installed version.
## if not, update openssl.
OPENSSL_OK=$(openssl version 2>&1 | grep "${openssl_version}")
if [[ "" == "$OPENSSL_OK" && -n "${openssl_version}" ]] ; then 
    echo "  --> installing openssl from source to /opt/openssl-${openssl_version}"
    cd /opt/
    wget http://www.openssl.org/source/openssl-${openssl_version}.tar.gz
    tar xvzf openssl-${openssl_version}.tar.gz
    cd openssl-${openssl_version}
    ./config --prefix=/usr zlib-dynamic --openssldir=/etc/ssl shared 
    make
    make install
else
    echo "  --> OpenSSL already updated to version ${openssl_version}"
fi

echo 'OpenSSL completed'
echo ''