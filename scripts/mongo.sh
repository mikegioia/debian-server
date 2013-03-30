#!/bin/bash

# install mongodb from source, 
#

echo 'This script will update/upgrade the system and install mongodb from source'
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    echo "Aborted"
    exit
fi

usage="$0 <config>"
config=${1:-"../conf/config"}

if [ ! -f $config ] ; then
    echo "Could not find the config file you entered: $config"
    exit
fi

. $config

echo '  --> installing mongo from source to /opt/mongodb'
cd /tmp/                                                               
wget http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.0.3.tgz
tar -xzf mongodb-linux-x86_64-2.0.3.tgz

# move to opt
#
mv mongodb-linux-x86_64-2.0.3 /opt/mongodb
mkdir /data 
mkdir /data/mongodb

# create the user
#
useradd mongod -s /bin/false
chown -R mongod:mongod /data/mongodb

# copy the init script
#
cp $basepath/src/mongodb /etc/init.d/mongodb
chmod +x /etc/init.d/mongodb

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
ln -s /opt/mongodb/bin/mongosniff /usr/local/bin/mongosniff
ln -s /opt/mongodb/bin/mongostat /usr/local/bin/mongostat
ln -s /opt/mongodb/bin/mongotop /usr/local/bin/mongotop

# add it to the reboot
#
update-rc.d mongodb defaults
/etc/init.d/mongodb start

# install mongo for php
#
read -p 'Do you want to install the php mongo extension [Y/n]? ' wish
if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    apt-get install php-pear php5-dev
    pecl install mongo
    cp $basepath/src/mongo.ini /etc/php5/conf.d/mongo.ini
fi
