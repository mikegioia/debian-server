#!/bin/bash

# install mongodb from source
#

echo 'This script will install MongoDB from source.'
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    echo "Aborted"
    exit
fi

MONGODB_OK=$(/opt/mongodb/bin/mongo -v 2>&1 | grep "${mongodb_version}")
if [ "" == "$MONGODB_OK" ] ; then 
    echo '  --> installing mongo from source to /opt/mongodb'
    # get the binaries 
    #
    cd /opt/
    wget http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-${mongodb_version}.tgz
    tar -xzf mongodb-linux-x86_64-${mongodb_version}.tgz

    if [ -d /opt/mongodb ] ; then
        rm -rf /opt/mongodb
    fi

    mv mongodb-linux-x86_64-${mongodb_version} mongodb

    # create symlinks
    #
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

if ! [ -d /data ] ; then
    mkdir /data 
fi
if ! [ -d /data/mongodb ] ; then
    mkdir /data/mongodb
fi

# create the user
#
egrep "^mongod" /etc/passwd >/dev/null
if ! [ $? -eq 0 ]; then
    echo '  --> creating new user mongod'
    useradd mongod -s /bin/false
fi

chown -R mongod:mongod /data/mongodb

# copy the init script
#
cp $basepath/src/mongodb /etc/init.d/mongodb
chmod +x /etc/init.d/mongodb

# copy the config file
#
echo '  --> copying over mongodb.conf to /etc/mongodb.conf'
if [ -f $basepath/conf/$profile/mongodb.conf ] ; then
    cp $basepath/conf/$profile/mongodb.conf /etc/mysql/conf.d/mongodb.conf
fi

# add it to the reboot
#
update-rc.d mongodb defaults

ps cax | grep 'mongo' > /dev/null
if ! [ $? -eq 0 ] ; then
    echo '  --> starting mongodb'
    /etc/init.d/mongodb start
fi

# ask to install mongo for php
#
if ! [ -f /etc/php5/mods-available/mongo.ini ] ; then
    read -p 'Do you want to install the php mongo extension [Y/n]? ' wish
    if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        apt-get install php-pear php5-dev
        pecl install mongo
        echo "extension=mongo.so" > /etc/php5/mods-available/mongo.ini
        cd /etc/php5/fpm/conf.d/
        ln -s ../../mods-available/mongo.ini 20-mongo.ini
        cd /etc/php5/cli/conf.d/
        ln -s ../../mods-available/mongo.ini 20-mongo.ini
        cd
    fi
fi

echo 'MongoDB completed'
echo ''