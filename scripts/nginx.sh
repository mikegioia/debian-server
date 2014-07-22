#!/bin/bash
#
# Installs nginx from source, and OpenSSL from source
##

echo 'This script will install openssl and nginx from source.'
read -p 'Do you want to continue? [y/N] ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    echo "Aborted"
    exit
fi

## Install requirements if not installed
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' libpcre3-dev|grep "install ok installed")
if [ "" == "$PKG_OK" ] ; then
    apt-get install libpcre3-dev
fi

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' build-essential|grep "install ok installed")
if [ "" == "$PKG_OK" ] ; then
    apt-get install build-essential
fi

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' libssl-dev|grep "install ok installed")
if [ "" == "$PKG_OK" ] ; then
    apt-get install libssl-dev
fi

## Check if nginx is up to date. If not install/update nginx.
NGINX_OK=$(/opt/nginx/sbin/nginx -v 2>&1 | grep "nginx/${nginx_version}")
if [[ "" == "$NGINX_OK" && -n "${nginx_version}" ]] ; then 
    echo '  --> installing nginx from source to /opt/nginx'
    cd /opt/
    wget http://nginx.org/download/nginx-${nginx_version}.tar.gz
    tar -zxvf nginx-${nginx_version}.tar.gz
    cd /opt/nginx-${nginx_version}/
    ./configure \
        --prefix=/opt/nginx \
        --user=nginx \
        --group=nginx \
        --with-http_ssl_module \
        --with-ipv6 \
        --with-http_stub_status_module \
        --with-http_spdy_module \
        --with-http_realip_module
    make
    make install
else
    echo "  --> nginx already updated to version ${nginx_version}"
fi

## Check if nginx user exists. If not, create the new user.
egrep "^nginx" /etc/passwd >/dev/null
if ! [[ $? -eq 0 ]] ; then
    adduser --system --no-create-home --disabled-login --disabled-password --group nginx
fi

# copy over the default nginx and trunk config. set up
# directories.
echo '  --> copying over config files'
if ! [[ -d "/opt/nginx/conf/sites-available" ]] ; then
    mkdir /opt/nginx/conf/sites-available
fi
if ! [[ -d "/opt/nginx/conf/sites-enabled" ]] ; then
    mkdir /opt/nginx/conf/sites-enabled
fi

if [[ -f "$basepath/conf/$profile/nginx.conf" ]] ; then
    cp $basepath/conf/$profile/nginx.conf /opt/nginx/conf/nginx.conf
else
    cp $basepath/src/nginx_conf/nginx.conf /opt/nginx/conf/nginx.conf
fi

cp $basepath/src/nginx_conf/trunk.conf /opt/nginx/conf/trunk.conf
cp $basepath/src/nginx_conf/mime.types /opt/nginx/conf/mime.types

## Copy over the nginx config files to sites-available,
##
## For each config file, check if there's a symlink in
## sites-enabled. if not, add he new sym link.
if [[ -d "$basepath/conf/$profile/nginx" ]] ; then
    cp $basepath/conf/$profile/nginx/*.conf /opt/nginx/conf/sites-available/
    CONF_FILES="/opt/nginx/conf/sites-available/*.conf"
    for c in $CONF_FILES
    do
        config_filename=$(basename $c)
        if ! [[ -h "/opt/nginx/conf/sites-enabled/$config_filename" ]] ; then
            ln -s ../sites-available/$config_filename /opt/nginx/conf/sites-enabled/$config_filename
        fi
    done
fi

## Copy over the init script and set up nginx to start
## on reboot
echo '  --> configuring the init script'
cp $basepath/src/nginx /etc/init.d/nginx
chmod +x /etc/init.d/nginx
/usr/sbin/update-rc.d -f nginx defaults
/usr/sbin/update-rc.d -f apache2 remove

## Copy over remaining nginx files
echo '  --> copying 404 and 50x files'
if ! [[ -d "/var/www" ]] ; then
    mkdir /var/www
fi
if ! [[ -f "/var/www/404.html" ]] ; then
    cp $basepath/src/404.html /var/www/404.html
fi
if ! [[ -f "/var/www/50x.html" ]] ; then
    cp $basepath/src/50x.html /var/www/50x.html
fi

## Update permissions
chown -R www-data:www-data /var/www

## If nginx is running, reload the config. if it's not,
## start nginx.
ps cax | grep 'nginx' > /dev/null
if [[ $? -eq 0 ]] ; then
    /opt/nginx/sbin/nginx -s reload
else
    /etc/init.d/nginx start
fi

echo 'Nginx and OpenSSL completed'
echo ''