#!/bin/bash
#
# Installs PHP from the dotdeb repository.
##

## Prompt to continue
function promptInstall {
    echo -e "\n${blueBgWhiteBold}This script will install PHP and PHP-FPM.${NC}"
    read -p 'Do you want to continue [y/N]? ' wish
    if ! [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        exit 0
    fi
}

## Set up the source file in /etc/apt
function setupSource {
    if ! [[ -f "/etc/apt/sources.list.d/dotdeb.list" ]] ; then
        echo -e "${green}Creating dotdeb.list in /etc/apt/sources.list.d${NC}"
        echo 'deb http://packages.dotdeb.org wheezy-php56 all' > /etc/apt/sources.list.d/dotdeb.list
        echo 'deb-src http://packages.dotdeb.org wheezy-php56 all' >> /etc/apt/sources.list.d/dotdeb.list
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

## Install PHP5 and all modules
function installPhp {
    apt-get install \
        php5 php5-common php5-dev php5-curl \
        php5-mcrypt php5-mysqlnd php5-pspell \
        php5-tidy php-pear php5-cli php5-fpm
    # libssh2-php
}

## Look inside an fpm folder in the profile if there is one. If so
## copy those config files to the pool.d for FPM.
function copyPoolConfigs {
    if [[ -d "$basepath/conf/$profile/php/fpm" ]] ; then
        echo -e "${green}Copying over PHP-FPM pool config files${NC}"
        cp $basepath/conf/$profile/php/fpm/*.conf /etc/php5/fpm/pool.d/
    fi
}

## Look for any available mods and add them
function copyModsAvailable {
    if [[ -d "$basepath/conf/$profile/php/mods-available" ]] ; then
        echo -e "${green}Copying over PHP mods${NC}"
        cp $basepath/conf/$profile/php/mods-available/*.ini /etc/php5/mods-available/
        CONF_FILES="$basepath/conf/$profile/php/mods-available/*.ini"
        for c in $CONF_FILES
        do
            config_filename=$(basename $c)
            if ! [[ -h "/etc/php5/cli/conf.d/40-$config_filename" ]] ; then
                ln -s ../../mods-available/$config_filename /etc/php5/cli/conf.d/40-$config_filename
            fi
            if ! [[ -h "/etc/php5/fpm/conf.d/40-$config_filename" ]] ; then
                ln -s ../../mods-available/$config_filename /etc/php5/fpm/conf.d/40-$config_filename
            fi
        done
    fi
}

## Ask to add FPM to startup
## Add mysql to startup
function systemStart {
    read -p "Do you want to add php5-fpm to system startup [y/N]? " wish
    if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        /usr/sbin/update-rc.d -f php5-fpm defaults
    fi
}

## Ask to install MongoDB extension for php
function mongoExtension {
    if ! [[ -f "/etc/php5/mods-available/mongo.ini" ]] ; then
        read -p "Do you want to install the PHP MongoDB extension [y/N]? " wish
        if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
            apt-get install php-pear php5-dev
            pecl install mongo
            echo "extension=mongo.so" > /etc/php5/mods-available/mongo.ini
            if ! [[ -h "/etc/php5/cli/conf.d/30-mongo.ini" ]] ; then
                ln -s ../../mods-available/mongo.ini /etc/php5/cli/conf.d/30-mongo.ini
            fi
            if ! [[ -h "/etc/php5/fpm/conf.d/30-mongo.ini" ]] ; then
                ln -s ../../mods-available/mongo.ini /etc/php5/fpm/conf.d/30-mongo.ini
            fi
        fi
    fi
}

## Ask to install Redis extension for PHP
function redisExtension {
    if ! [[ -f "/etc/php5/mods-available/redis.ini" ]] ; then
        read -p "Do you want to install the PHP Redis extension [y/N]? " wish
        if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
            ## Check if the extension version is set
            if ! [[ -n "$redisphpVersion" ]] ; then
                echo -e "${redBgWhiteBold}No redisphpVersion set in this profile's config file! Did you add one?${NC}"
                read -p "Press any key to continue" anykey
                return
            fi

            cd /opt
            wget https://github.com/nicolasff/phpredis/archive/${redisphpVersion}.tar.gz

            ## Check if it got the file
            if ! [[ -f "/opt/$redisphpVersion.tar.gz" ]] ; then
                echo -e "${redBgWhiteBold}Failed to download PHP Redis extension archive. Is the version correct?${NC}"
                read -p "Press any key to continue" anykey
                return
            fi

            mv ${redisphpVersion}.tar.gz phpredis-${redisphpVersion}.tar.gz
            tar -xzf phpredis-${redisphpVersion}.tar.gz
            cd phpredis-${redisphpVersion}
            phpize
            ./configure
            make && make install

            echo "extension=redis.so" > /etc/php5/mods-available/redis.ini
            if ! [[ -h "/etc/php5/cli/conf.d/30-redis.ini" ]] ; then
                ln -s ../../mods-available/redis.ini /etc/php5/cli/conf.d/30-redis.ini
            fi
            if ! [[ -h "/etc/php5/fpm/conf.d/30-redis.ini" ]] ; then
                ln -s ../../mods-available/redis.ini /etc/php5/fpm/conf.d/30-redis.ini
            fi
        fi
    fi
}

function promptRestart {
    read -p "Do you want to restart PHP-FPM? [y/N]? " wish
    if [[ "$wish" == "y" || "$wish" == "Y" ]] ; then
        /etc/init.d/php5-fpm restart
    fi
}

## @TODO
## Ask to install the cphalcon extension for PHP?

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