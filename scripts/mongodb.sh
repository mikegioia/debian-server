#!/bin/bash
#
# Installs MongoDB from source
##

echo 'This script will install MongoDB from source.'
read -p 'Do you want to continue [y/N]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    echo "Aborted"
    exit
fi

MONGODB_OK=$(/opt/mongodb/bin/mongo -v 2>&1 | grep "${mongodb_version}")
if [[ "" == "$MONGODB_OK" ]] ; then 
    echo '  --> installing mongo from source to /opt/mongodb'
    ## Get the binaries 
    cd /opt/
    wget http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-${mongodb_version}.tgz
    tar -xzf mongodb-linux-x86_64-${mongodb_version}.tgz

    if [[ -d "/opt/mongodb" ]] ; then
        rm -rf /opt/mongodb
    fi

    mv mongodb-linux-x86_64-${mongodb_version} mongodb

    ## Create symlinks
    ln -s /opt/mongodb/bin/mongo /usr/local/bin/mongo
    ln -s /opt/mongodb/bin/mongod /usr/local/bin/mongod
    ln -s /opt/mongodb/bin/mongodump /usr/local/bin/mongodump
    ln -s /opt/mongodb/bin/mongoexport /usr/local/bin/mongoexport
    ln -s /opt/mongodb/bin/mongofiles /usr/local/bin/mongofiles
    ln -s /opt/mongodb/bin/mongoimport /usr/local/bin/mongoimport
    ln -s /opt/mongodb/bin/mongorestore /usr/local/bin/mongorestore
    ln -s /opt/mongodb/bin/mongos /usr/local/bin/mongos
    ln -s /opt/mongodb/bin/mongostat /usr/local/bin/mongostat
    ln -s /opt/mongodb/bin/mongotop /usr/local/bin/mongotop
else
    echo "  --> mongodb already updated to version ${mongodb_version}"
fi

if ! [[ -d "/data" ]] ; then
    mkdir /data 
fi
if ! [[ -d "/data/mongodb" ]] ; then
    mkdir /data/mongodb
fi

## Create the user
egrep "^mongod" /etc/passwd >/dev/null
if ! [[ $? -eq 0 ]] ; then
    echo '  --> creating new user mongod'
    adduser --system --no-create-home --disabled-login --disabled-password --group mongod
fi

chown -R mongod:mongod /data/mongodb

## Copy the init script
cp $basepath/src/mongodb /etc/init.d/mongodb
chmod +x /etc/init.d/mongodb

## Copy the config file
if [[ -f "$basepath/conf/$profile/mongodb.conf" ]] ; then
    echo '  --> copying over mongodb.conf to /etc/mongodb.conf'
    cp $basepath/conf/$profile/mongodb.conf /etc/mysql/conf.d/mongodb.conf
fi

## Add it to the reboot
update-rc.d mongodb defaults

ps cax | grep 'mongo' > /dev/null
if ! [[ $? -eq 0 ]] ; then
    echo '  --> starting mongodb'
    /etc/init.d/mongodb start
fi

## Ask to install MongoDB for php
if ! [[ -f "/etc/php5/mods-available/mongo.ini" ]] ; then
    read -p 'Do you want to install the php mongo extension? [y/N] ' wish
    if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        apt-get install php-pear php5-dev
        pecl install mongo
        echo "extension=mongo.so" > /etc/php5/mods-available/mongo.ini
        ln -s ../../mods-available/mongo.ini /etc/php5/cli/conf.d/30-mongo.ini
        ln -s ../../mods-available/mongo.ini /etc/php5/fpm/conf.d/30-mongo.ini
    fi
fi

echo 'MongoDB completed'
echo ''