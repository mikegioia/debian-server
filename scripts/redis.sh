#!/bin/bash
#
# Installs redis from source
##

## Prompt to continue
function promptInstall {
    echo -e "\n${blueBgWhiteBold}This script will install Redis from source.${NC}"
    read -p 'Do you want to continue [y/N]? ' wish
    if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        exit 0
    fi
}

## Copy tar file, unpack and make
function installRedis {
    REDIS_OK=$(/usr/local/bin/redis-server -v 2>&1 | grep "${redisVersion}")
    if [[ "" == "$REDIS_OK" ]] ; then
        echo -e "${green}Installing Redis to /opt/redis${NC}"

        ## Get the dependencies
        PKG_OK=$(dpkg-query -W --showformat='${Status}\n' build-essential|grep "install ok installed")
        if [[ "" == "$PKG_OK" ]] ; then
            apt-get install build-essential
        fi

        ## Get the binaries
        wget -P /opt/ http://download.redis.io/releases/redis-${redisVersion}.tar.gz
        tar -xzf /opt/redis-${redisVersion}.tar.gz -C /opt

        if [[ -d "/opt/redis" ]] ; then
            rm -rf /opt/redis
        fi

        mv redis-$redisVersion redis
        cd /opt/redis
        make
    else
        echo -e "${yellow}Redis already updated to version ${redisVersion}${NC}"
    fi

    ## Copy binaries over
    cp /opt/redis/src/redis-cli /usr/local/bin/
    cp /opt/redis/src/redis-server /usr/local/bin/
}

## Create directories
function createDirectories {
    if ! [[ -d "/etc/redis" ]] ; then
        mkdir /etc/redis
    fi
    if ! [[ -d "/var/redis" ]] ; then
        mkdir /var/redis
    fi
    if ! [[ -d "/var/redis/6379" ]] ; then
        mkdir /var/redis/6379
    fi
}

## Copy the init script
function copyInit {
    cp $basepath/src/redis_6379 /etc/init.d/redis_6379
    chmod +x /etc/init.d/redis_6379
}

## Copy of the config files
function copyConfig {
    if [[ -f "$basepath/conf/$profile/redis.conf" ]] ; then
        cp $basepath/conf/$profile/redis.conf /etc/redis/6379.conf
    else
        cp $basepath/src/redis.conf /etc/redis/6379.conf
    fi
}

## Add redis to startup
function systemStart {
    read -p "Do you want to add redis to system startup [y/N]? " wish
    if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        /usr/sbin/update-rc.d -f redis_6379 defaults
    fi
}

## Start the process if it isn't
function startRestartRedis {
    if ! [[ -f "/etc/redis/6379.conf" ]] ; then
        echo -e "${redBgWhiteBold}No config file found at /etc/redis/6379.conf! Did you forget to add one to conf/${profile}?${NC}"
        echo -e "${yellowBold}Try running './configure.sh ${profile}' again to generate a new redis.conf file.${NC}"
        return
    fi
    if [[ $( pidof redis-server) ]] ; then
        read -p "Redis is running, do you want to restart it? [y/N]? " wish
        if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
            /etc/init.d/redis_6379 stop
            /etc/init.d/redis_6379 start
        fi
    else
        read -p "Do you want to start Redis? [y/N]? " wish
        if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
            /etc/init.d/redis_6379 start
        fi
    fi
}

promptInstall
installRedis
createDirectories
copyInit
copyConfig
systemStart
startRestartRedis
exit 0