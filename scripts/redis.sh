#!/bin/bash
#
# install redis from source
#

echo 'This script will install Redis.'
read -p 'Do you want to continue [Y/n]? ' wish
if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    echo "Aborted"
    exit
fi

REDIS_OK=$(/usr/local/bin/redis-server -v 2>&1 | grep "${redis_version}")
if [ "" == "$REDIS_OK" ] ; then 
    echo '  --> installing redis from source to /opt/redis'
    
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' build-essential|grep "install ok installed")
    if [ "" == "$PKG_OK" ] ; then
      apt-get install build-essential
    fi

    # get the binaries 
    #
    cd /opt/
    wget http://download.redis.io/releases/redis-${redis_version}.tar.gz
    tar xvzf redis-${redis_version}.tar.gz

    if [ -d /opt/redis ] ; then
        rm -rf /opt/redis
    fi

    mv redis-$redis_version redis
    cd /opt/redis
    make

    # copy binaries over
    #
    cp /opt/redis/src/redis-cli /usr/local/bin/
    cp /opt/redis/src/redis-server /usr/local/bin/
else
    echo "  --> redis already updated to version ${redis_version}"
fi

if ! [ -d /etc/redis ] ; then
    mkdir /etc/redis
fi
if ! [ -d /var/redis ] ; then
    mkdir /var/redis
fi
if ! [ -d /var/redis/6379 ] ; then
    mkdir /var/redis/6379
fi

# copy the init script
#
cp $basepath/src/redis_6379 /etc/init.d/redis_6379
chmod +x /etc/init.d/redis_6379

# copy of the config files
#
if [ -f $basepath/conf/$profile/redis.conf ] ; then
    cp $basepath/conf/$profile/redis.conf /etc/redis/6379.conf
else
    cp $basepath/src/redis.conf /etc/redis/6379.conf
fi

# add it to the reboot
#
read -p 'Do you want to add redis to the startup [Y/n]? ' wish
if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
    update-rc.d redis_6379 defaults
fi

# ask to install redis for php
#
if ! [ -f /etc/php5/mods-available/redis.ini ] ; then
    read -p 'Do you want to install the php redis extension [Y/n]? ' wish
    if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        cd /opt
        wget https://github.com/nicolasff/phpredis/archive/${redisphp_version}.tar.gz
        mv ${redisphp_version}.tar.gz phpredis-${redisphp_version}.tar.gz
        tar -xzf phpredis-${redisphp_version}.tar.gz
        cd phpredis-${redisphp_version}
        phpize
        ./configure
        make && make install
        echo "extension=redis.so" > /etc/php5/mods-available/redis.ini
        cd /etc/php5/fpm/conf.d/
        ln -s ../../mods-available/redis.ini 20-redis.ini
        cd /etc/php5/cli/conf.d/
        ln -s ../../mods-available/redis.ini 20-redis.ini
        cd
    fi
fi

# start redis
#
ps cax | grep 'redis-server' > /dev/null
if ! [ $? -eq 0 ] ; then
    echo '  --> starting redis'
    /etc/init.d/redis_6379 start
fi

echo 'Redis completed'
echo ''