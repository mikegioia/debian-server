#!/bin/bash
#
# Installs PHP from the dotdeb repository.
##

## Prompt to continue
function promptInstall {
    echo -e "\n${blueBgWhiteBold}This script will install PHP 7.0 and PHP-FPM 7.0.${NC}"
    read -p 'Do you want to continue [y/N]? ' wish
    if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        exit 0
    fi
}

## Set up the source file in /etc/apt
function setupSource {
    if ! [[ -f "/etc/apt/sources.list.d/dotdeb.list" ]] ; then
        echo -e "${green}Creating dotdeb.list in /etc/apt/sources.list.d${NC}"
        echo 'deb http://packages.dotdeb.org jessie all' > /etc/apt/sources.list.d/dotdeb.list
        echo 'deb-src http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list.d/dotdeb.list
    fi
}

## Fetch the GPG key if it's not present
function addGpgKey {
    KEY_OK=$(gpg --list-keys 89DF5277)
    if ! [[ "$KEY_OK" ]] ; then
        echo -e "${green}Adding dotdeb GPG key to keyring${NC}"
        gpg --keyserver keys.gnupg.net --recv-key 89DF5277
        gpg -a --export 89DF5277 | sudo apt-key add -
    fi

    apt-get update
}

## Install PHP7 and all modules
function installPhp {
    apt-get install \
        php7.0 php7.0-common php7.0-dev php7.0-curl \
        php7.0-mcrypt php7.0-mysqlnd php7.0-pspell \
        php7.0-tidy php-pear php7.0-cli php7.0-fpm
}

## Look inside an fpm folder in the profile if there is one. If so
## copy those config files to the pool.d for FPM.
function copyPoolConfigs {
    if [[ -d "$basepath/conf/$profile/php/fpm" ]] ; then
        echo -e "${green}Copying over PHP-FPM pool config files${NC}"
        cp $basepath/conf/$profile/php/fpm/*.conf /etc/php/7.0/fpm/pool.d/
    fi
}

## Look for any available mods and add them
function copyModsAvailable {
    if [[ -d "$basepath/conf/$profile/php/mods-available" ]] ; then
        echo -e "${green}Copying over PHP mods${NC}"
        cp $basepath/conf/$profile/php/mods-available/*.ini /etc/php/7.0/mods-available/
        CONF_FILES="$basepath/conf/$profile/php/mods-available/*.ini"
        for c in $CONF_FILES
        do
            config_filename=$(basename $c)
            if ! [[ -h "/etc/php/7.0/cli/conf.d/40-$config_filename" ]] ; then
                ln -s ../../mods-available/$config_filename /etc/php/7.0/cli/conf.d/40-$config_filename
            fi
            if ! [[ -h "/etc/php/7.0/fpm/conf.d/40-$config_filename" ]] ; then
                ln -s ../../mods-available/$config_filename /etc/php/7.0/fpm/conf.d/40-$config_filename
            fi
        done
    fi
}

## Ask to add FPM to startup
## Add mysql to startup
function systemStart {
    read -p "Do you want to add php7.0-fpm to system startup [y/N]? " wish
    if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        /usr/sbin/update-rc.d -f php7.0-fpm defaults
    fi
}

## Ask to install MongoDB extension for php
function mongoExtension {
    if ! [[ -f "/etc/php/7.0/mods-available/mongodb.ini" ]] ; then
        read -p "Do you want to install the PHP MongoDB extension [y/N]? " wish
        if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
            apt-get install php7.0-mongodb
            if ! [[ -h "/etc/php/7.0/cli/conf.d/30-mongodb.ini" ]] ; then
                ln -s ../../mods-available/mongodb.ini /etc/php/7.0/cli/conf.d/30-mongodb.ini
            fi
            if ! [[ -h "/etc/php/7.0/fpm/conf.d/30-mongo.ini" ]] ; then
                ln -s ../../mods-available/mongodb.ini /etc/php/7.0/fpm/conf.d/30-mongodb.ini
            fi
        fi
    fi
}

## Ask to install Redis extension for PHP
## @TODO
function redisExtension {
    if ! [[ -f "/etc/php/7.0/mods-available/redis.ini" ]] ; then
        read -p "Do you want to install the PHP Redis extension [y/N]? " wish
        if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
            apt-get install php7.0-redis
            if ! [[ -h "/etc/php/7.0/cli/conf.d/30-redis.ini" ]] ; then
                ln -s ../../mods-available/redis.ini /etc/php/7.0/cli/conf.d/30-redis.ini
            fi
            if ! [[ -h "/etc/php/7.0/fpm/conf.d/30-mongo.ini" ]] ; then
                ln -s ../../mods-available/redis.ini /etc/php/7.0/fpm/conf.d/30-redis.ini
            fi
        fi
    fi
}

function promptRestart {
    read -p "Do you want to restart PHP-FPM? [y/N]? " wish
    if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        /etc/init.d/php7.0-fpm restart
    fi
}

promptInstall
setupSource
addGpgKey
installPhp
copyPoolConfigs
copyModsAvailable
mongoExtension
redisExtension
promptRestart
exit 0
