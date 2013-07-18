#!/bin/bash

# install and configure php
#

echo 'This script will install php and php-fpm'
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    echo "Aborted"
    exit 0
fi


echo '  --> adding dotdeb source and fetching key'
echo 'deb http://packages.dotdeb.org stable all' >> /etc/apt/sources.list.d/dotdeb.list
echo 'deb-src http://packages.dotdeb.org stable all' >> /etc/apt/sources.list.d/dotdeb.list
wget http://www.dotdeb.org/dotdeb.gpg
cat dotdeb.gpg | sudo apt-key add -
rm dotdeb.gpg

echo '  --> installing php5 with FPM'
cd /opt
apt-get update
apt-get install php5 php5-fpm php5-common php5-curl php5-dev \
    php5-gd php5-imagick php5-mcrypt php5-memcache php5-mysql \
    php5-pspell php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl \
    php-pear libssh2-php php5-cli

# optionally:
#   php5-idn, php5-ming, php5-recode, php5-cgi, php5-imap

echo '  --> configuring php-fpm'
#mkdir -p /var/run/php5-fpm/




exit

echo '  --> adding dotdeb source and fetching key'
cd /opt
echo 'deb http://packages.dotdeb.org stable all' >> /etc/apt/sources.list
wget http://www.dotdeb.org/dotdeb.gpg
cat dotdeb.gpg | apt-key add -
rm dotdeb.gpg
cd

# update and get php dependencies
#
apt-get update
apt-get build-dep php5
apt-get -y install libfcgi-dev libfcgi0ldbl libjpeg62-dbg libmcrypt-dev libssl-dev

# get the latest version of the source
#
# --with-kerberos=/usr \
# --with-openssl=/opt/openssl-1.0.0a/include/openssl \
./configure \
    --prefix=/usr \
    --with-config-file-path=/etc/php5/cgi \
    --with-config-file-scan-dir=/etc/php5/cgi/conf.d \
    --with-layout=GNU \
    --with-pear=/usr/share/php \
    --enable-calendar \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-sysvmsg \
    --enable-bcmath \
    --with-bz2 \
    --enable-ctype \
    --with-db4 \
    --with-qdbm=/usr \
    --without-gdbm \
    --with-iconv \
    --enable-exif \
    --enable-ftp \
    --with-gettext \
    --enable-mbstring \
    --with-onig=/usr \
    --with-pcre-regex=/usr \
    --enable-shmop \
    --enable-sockets \
    --enable-wddx \
    --with-libxml-dir=/usr \
    --with-zlib \
    --enable-soap \
    --enable-zip \
    --with-mhash=yes \
    --without-mm \
    --with-curl=shared,/usr \
    --with-enchant=shared,/usr \
    --with-zlib-dir=/usr \
    --with-gd=shared,/usr \
    --enable-gd-native-ttf \
    --with-gmp=shared,/usr \
    --with-jpeg-dir=shared,/usr \
    --with-xpm-dir=shared,/usr/X11R6 \
    --with-png-dir=shared,/usr \
    --with-freetype-dir=shared,/usr \
    --with-imap=shared,/usr \
    --with-imap-ssl \
    --with-interbase=shared,/usr \
    --with-pdo-firebird=shared,/usr \
    --enable-intl=shared \
    --with-t1lib=shared,/usr \
    --with-ldap=shared,/usr \
    --with-ldap-sasl=/usr \
    --with-mcrypt=shared,/usr \
    --with-mysql=shared,/usr \
    --with-mysqli=shared,/usr/bin/mysql_config \
    --with-pspell=shared,/usr\
    --with-unixODBC=shared,/usr \
    --with-recode=shared,/usr \
    --with-xsl=shared,/usr \
    --with-snmp=shared,/usr \
    --with-sqlite3=shared,/usr \
    --with-mssql=shared,/usr \
    --with-tidy=shared,/usr \
    --with-xmlrpc=shared \
    --with-pgsql=shared,/usr \
    --enable-fpm \
    --with-fpm-user=www-data \
    --with-fpm-group=www-data


apt-get update
apt-get install php5-fpm php5-cgi php5-mysql php5-curl php5-gd php5-idn \
    php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-ming \
    php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc \
    php5-xsl

# @TODO
# see http://www.rackspace.com/knowledge_center/article/installing-nginx-and-php-fpm-setup-for-php-fpm
# for more info on finishing the FPM installation

