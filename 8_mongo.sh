#!/bin/bash

# install nginx from source
#

echo 'This script will update/upgrade the system and install mongodb from source'
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    exit
fi

#usage="$0 <config>"
config=${1:-"server.cfg"}

if [ ! -f $config ] ; then
    echo "Could not find the config file you entered: $config."
    exit
fi

. ./$config

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
cp ./src/mongodb /etc/init.d/mongodb
chmod +x /etc/init.d/mongodb

# create symlinks
#
ln -s /opt/mongodb/bin/mongo /usr/local/bin/mongo
ln -s /opt/mongodb/bin/mongod /usr/local/bin/mongod

# add it to the reboot
#
update-rc.d mongodb defaults
/etc/init.d/mongodb start

# install mongo for php
#
apt-get install php-pear php5-dev
pecl install mongo
cp ./conf/mongo.ini /etc/php5/conf.d/mongo.ini